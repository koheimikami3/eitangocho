#!/usr/bin/env python3
"""句動詞の単語リスト(words/phrasal-verbs.txt・words/phrasal-verbs-2.txt)を作る。

範囲: Wiktionary の句動詞のうち、差別語・古語の表示がなく、使われる頻度が上位のもの。範囲の違いは LISTS の定義を見る。
「NGSL の動詞に限る」「例文がある」のような代わりの目安では普通の句(cheer up など)まで落ちたため、
頻度の順位で切る。見出しは原形で、活用形は頻度を数えるのにだけ使う。

使い方(tool/dictgen で):
    python3 pick_phrasal_verbs.py <作業ディレクトリ> [--list-only] [--list <LISTS の名前>]

--list を省くと phrasal-verbs を作る。

1. Wiktionary の Category:English phrasal verbs の全項目を取る(作業ディレクトリの candidates.json にキャッシュ)
2. 形で絞る: 2〜3 語・英小文字だけ・2 語目以降がすべて不変化詞か前置詞
3. kaikki で verb の項目を引き、活用形と意味ごとのタグを取る(kaikki.jsonl に書き足す)。
   すべての意味に除くタグのどれかが付くもの・verb の項目が無いものは除く
4. Tatoeba で原形と活用形を含む英文をまとめて数える(freq.jsonl に書き足す)
5. 件数の多い順に上位 top_n を採り、ほかの単語リストにある句を除いて words/<名前>.txt へ書く

3 と 4 は別のサイトなので、kaikki を別スレッドで引きながら、引けた句から順に数える(Tatoeba は TATOEBA_WORKERS 本同時)。
どちらも止まっても続きから進む。--list-only を付けると 2 までで止め、候補の数だけ出す。
"""

import glob
import json
import queue
import re
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent
# Wikimedia の API は連絡先入りの User-Agent を求める
USER_AGENT = "eitangocho-dictgen/1.0 (https://github.com/koheimikami3)"
PARTICLES = set(
    "up out off down in on over away back through around about along across by after into "
    "for with to of apart aside ahead forward together".split()
)
# 頻度で落ちない不適切な語だけを除く。slang は chill out にも付くので除かない(珍しい俗語は順位で落ちる)
EXCLUDED_TAGS = {"vulgar", "offensive", "derogatory", "archaic", "obsolete"}
# 表示では落ちなかったが、学習用の辞書に入れない句(生成で空欄になったもの)。
# 上位 top_n を採った後に除く(繰り上げで足すと順位の区切りが変わるため)
MANUAL_EXCLUDED = {
    "bite in",  # すべての意味が dated
    "sex in",  # ギャングの性的な入会儀式の意味だけ
}
# 同じく空欄になったが、卑語を除かないリストには入れる句
MANUAL_EXCLUDED_VULGAR = {
    "feel up",  # 性的にさわる意味だけ
    "shit on",  # 表示の無い意味が文字どおりの 1 つだけで、残りは vulgar
}
# phrasal-verbs は生成済みなので範囲を変えない。phrasal-verbs-2 はその続きで、
# ドラマなどで出て意味を調べたい語のために卑語を除かない(順位は卑語を含めて付け直す)
LISTS = {
    "phrasal-verbs": {
        "top_n": 1000,
        "allow_vulgar": False,
        "title": "句動詞",
        "scope": "卑語・差別語・古語の表示がなく、使われる頻度が上位 1000 のもの",
        "manual_excluded": MANUAL_EXCLUDED | MANUAL_EXCLUDED_VULGAR,
        "manual_note": "表示では落ちなかった性的・卑俗・古い意味だけの句",
    },
    "phrasal-verbs-2": {
        "top_n": 1500,
        "allow_vulgar": True,
        "title": "句動詞の続き",
        "scope": "差別語・古語の表示がなく(卑語は除かない)、使われる頻度が上位 1500 のもののうち、ほかの単語リストに無いもの",
        "manual_excluded": MANUAL_EXCLUDED,
        "manual_note": "表示では落ちなかった性的・古い意味だけの句",
    },
}
# 相手への負荷を抑えるための間隔(秒)。dictgen-collect が Tatoeba に空ける間隔と同じ
REQUEST_INTERVAL = 0.5
# 活用形を OR でつないだ検索は 1 回 4 秒ほどかかるので、Tatoeba には 3 本同時に問い合わせる。
# それでも全体で毎秒 1 回を下回り、原形だけを 1 秒おきに数えていたときより負荷は軽い
TATOEBA_WORKERS = 3


class NotFound(Exception):
    pass


def get_json(url):
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def fetch_candidates(work):
    """Wiktionary の分類の全項目名を返す。"""
    cache = work / "candidates.json"
    if cache.exists():
        return json.loads(cache.read_text(encoding="utf-8"))
    titles, cont = [], None
    while True:
        params = {"action": "query", "list": "categorymembers", "cmtitle": "Category:English phrasal verbs",
                  "cmnamespace": "0", "cmlimit": "500", "format": "json"}
        if cont:
            params["cmcontinue"] = cont
        data = get_json("https://en.wiktionary.org/w/api.php?" + urllib.parse.urlencode(params))
        titles += [m["title"] for m in data["query"]["categorymembers"]]
        cont = data.get("continue", {}).get("cmcontinue")
        if not cont:
            break
        time.sleep(1)
    cache.write_text(json.dumps(titles, ensure_ascii=False), encoding="utf-8")
    return titles


def listed_words(output_name):
    """作るリスト以外の単語リストにある語(重複を除くため)。"""
    words = set()
    for path in glob.glob(str(ROOT / "words/*.txt")):
        if Path(path).name == output_name:
            continue
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if line.strip() and not line.startswith("#"):
                words.add(line.strip().lower())
    return words


def matches_shape(title):
    parts = title.split(" ")
    return (2 <= len(parts) <= 3 and all(re.fullmatch(r"[a-z]+", p) for p in parts)
            and all(p in PARTICLES for p in parts[1:]))


def kaikki_entry(phrase):
    """kaikki の verb の項目から、活用形と除くかどうかを返す。通信の失敗は None(次回やり直す)。"""
    # URL の作り方はアプリの KaikkiApiClient と同じ
    path = f"/dictionary/English/meaning/{phrase[0]}/{urllib.parse.quote(phrase[:2])}/{urllib.parse.quote(phrase)}.jsonl"
    request = urllib.request.Request("https://kaikki.org" + path, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            lines = response.read().decode("utf-8").splitlines()
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"  kaikki 失敗: {phrase}: {e}", file=sys.stderr)
            return None
        lines = []
    except Exception as e:  # 通信失敗は次回の再実行に回す
        print(f"  kaikki 失敗: {phrase}: {e}", file=sys.stderr)
        return None
    entries = [e for e in map(json.loads, filter(None, lines)) if e.get("pos") == "verb"]
    senses = [s for e in entries for s in e.get("senses", [])]
    if not senses:
        return {"phrase": phrase, "found": False, "excluded": False, "forms": []}
    particles = phrase.split(" ")[1:]
    forms = sorted({f["form"] for e in entries for f in e.get("forms", [])
                    if re.fullmatch(r"[a-z]+( [a-z]+)+", f["form"]) and f["form"].split(" ")[1:] == particles}
                   - {phrase})
    excluded = all(EXCLUDED_TAGS & set(s.get("tags", [])) for s in senses)
    vulgar_only = excluded and not all((EXCLUDED_TAGS - {"vulgar"}) & set(s.get("tags", [])) for s in senses)
    return {"phrase": phrase, "found": True, "excluded": excluded, "vulgar_only": vulgar_only, "forms": forms}


def is_excluded(entry, allow_vulgar):
    return entry["excluded"] and not (allow_vulgar and entry.get("vulgar_only"))


def needs_fetch(entry):
    """vulgar_only が無い古いキャッシュのうち、除いた句だけ引き直す(除かなかった句は卑語を許しても結果が同じ)。"""
    return entry["excluded"] and "vulgar_only" not in entry


def tatoeba_count(phrase, forms):
    """原形と活用形のどれかをそのまま含む英文の件数。失敗したら None(書き足さず、次回やり直す)。"""
    query = " | ".join(f'="{f}"' for f in [phrase] + forms)
    params = {"lang": "eng", "q": query, "sort": "relevance", "limit": "1"}
    try:
        data = get_json("https://api.tatoeba.org/unstable/sentences?" + urllib.parse.urlencode(params))
        return data["paging"]["total"]
    except Exception as e:  # 通信失敗・形式の変化は次回の再実行に回す
        print(f"  Tatoeba 失敗: {phrase}: {e}", file=sys.stderr)
        return None


def load_jsonl(path):
    if not path.exists():
        return {}
    rows = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]
    return {row["phrase"]: row for row in rows}


def kaikki_worker(phrases, kaikki, path, out_queue):
    """kaikki を引き、引けた項目を順に out_queue に渡す。最後に None を渡す。"""
    with path.open("a", encoding="utf-8") as f:
        for phrase in phrases:
            if phrase in kaikki and not needs_fetch(kaikki[phrase]):
                out_queue.put(kaikki[phrase])
                continue
            entry = kaikki_entry(phrase)
            if entry is not None:
                f.write(json.dumps(entry) + "\n")
                f.flush()
                out_queue.put(entry)
            time.sleep(REQUEST_INTERVAL)
    out_queue.put(None)


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith("-"):
        print(__doc__)
        sys.exit(64)
    work = Path(args[0])
    work.mkdir(parents=True, exist_ok=True)
    list_name = args[args.index("--list") + 1] if "--list" in args else "phrasal-verbs"
    config = LISTS[list_name]
    output = f"{list_name}.txt"
    allow_vulgar = config["allow_vulgar"]

    titles = fetch_candidates(work)
    shaped = sorted({t for t in titles if matches_shape(t)})
    print(f"Wiktionary の項目 {len(titles)} / 形で絞った後 {len(shaped)}", flush=True)
    if "--list-only" in args:
        return

    kaikki_path, freq_path = work / "kaikki.jsonl", work / "freq.jsonl"
    kaikki, freq = load_jsonl(kaikki_path), load_jsonl(freq_path)
    entries = queue.Queue()
    threading.Thread(target=kaikki_worker, args=(shaped, kaikki, kaikki_path, entries), daemon=True).start()
    lock = threading.Lock()

    def count_one(entry):
        count = tatoeba_count(entry["phrase"], entry["forms"])
        if count is not None:
            with lock:
                freq[entry["phrase"]] = {"phrase": entry["phrase"], "count": count}
                f.write(json.dumps(freq[entry["phrase"]]) + "\n")
                f.flush()
                if len(freq) % 200 == 0:
                    print(f"  数えた {len(freq)}", flush=True)
        time.sleep(REQUEST_INTERVAL)

    with freq_path.open("a", encoding="utf-8") as f, ThreadPoolExecutor(TATOEBA_WORKERS) as pool:
        while (entry := entries.get()) is not None:
            kaikki[entry["phrase"]] = entry
            if entry["found"] and not is_excluded(entry, allow_vulgar) and entry["phrase"] not in freq:
                pool.submit(count_one, entry)

    not_found = [p for p in shaped if p in kaikki and not kaikki[p]["found"]]
    excluded = [p for p in shaped if p in kaikki and is_excluded(kaikki[p], allow_vulgar)]
    usable = [p for p in shaped if p in kaikki and kaikki[p]["found"] and not is_excluded(kaikki[p], allow_vulgar)]
    missing = ([p for p in shaped if p not in kaikki or needs_fetch(kaikki[p])]
               + [p for p in usable if p not in freq])
    print(f"kaikki に無い {len(not_found)} / 表示で除いた {len(excluded)} / 残り {len(usable)}")
    if missing:
        sys.exit(f"取れなかった句が {len(missing)} ある。もう一度実行すると続きから進む")
    # 順位はほかのリストにある句も含めて付ける(既存のリストを足してもこのリストの範囲が動かないように)
    listed = listed_words(output) | config["manual_excluded"]
    ranked = sorted(usable, key=lambda p: (-freq[p]["count"], p))[:config["top_n"]]
    picked = [p for p in ranked if p not in listed]
    excluded_tags = EXCLUDED_TAGS - {"vulgar"} if allow_vulgar else EXCLUDED_TAGS
    header = f"""# {config["title"]} {len(picked)} 語。使われる頻度の高い順。
# 範囲: Wiktionary の句動詞のうち、{config["scope"]}。
#   形の条件: 2〜3 語、2 語目以降がすべて不変化詞か前置詞。
#   除く表示: kaikki(Wiktionary の抽出データ)で verb のすべての意味に {", ".join(sorted(excluded_tags))} のどれかが付くもの。
#   個別に除いた句: {", ".join(sorted(config["manual_excluded"]))}({config["manual_note"]})。
#   頻度: Tatoeba の英文のうち、原形か活用形(kaikki の forms)を含む文の件数。
# 出典: Wiktionary「Category:English phrasal verbs」の項目名
#   https://en.wiktionary.org/wiki/Category:English_phrasal_verbs
# ライセンス: Creative Commons Attribution-ShareAlike 4.0 International(CC BY-SA 4.0)
#   https://creativecommons.org/licenses/by-sa/4.0/
# 作り方: tool/dictgen/pick_phrasal_verbs.py
"""
    (ROOT / "words" / output).write_text(header + "\n".join(picked) + "\n", encoding="utf-8")
    print(f"採った {len(picked)} → words/{output}")


if __name__ == "__main__":
    main()
