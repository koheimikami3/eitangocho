#!/usr/bin/env python3
"""句動詞の単語リスト(words/phrasal-verbs.txt)を作る。

範囲: NGSL の動詞でできた句動詞のうち、Wiktionary に項目があり、Tatoeba に例文が 1 つ以上あるものすべて。
語数の目標や「上位○語」の切り方はせず、この範囲に入るものを全部採る(NGSL などと同じく一言で説明できる区切りにするため)。

使い方(tool/dictgen で):
    python3 pick_phrasal_verbs.py <作業ディレクトリ> [--list-only]

1. Wiktionary の Category:English phrasal verbs の全項目を取る(作業ディレクトリの candidates.json にキャッシュ)
2. 形で絞る: 2〜3 語・英小文字だけ・先頭が NGSL の動詞・2 語目以降がすべて不変化詞か前置詞
3. Tatoeba で句をそのまま含む英文の件数を数える(counts.jsonl に 1 行ずつ書き足す。止まっても続きから数える)
4. 件数が 1 件以上のものを、件数の多い順に words/phrasal-verbs.txt へ書く

--list-only を付けると 2 までで止め、候補の数だけ出す。
"""

import glob
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
# Wikimedia の API は連絡先入りの User-Agent を求める
USER_AGENT = "eitangocho-dictgen/1.0 (https://github.com/koheimikami3)"
PARTICLES = set(
    "up out off down in on over away back through around about along across by after into "
    "for with to of apart aside ahead forward together".split()
)
# Tatoeba への負荷を抑えるための間隔(秒)
TATOEBA_INTERVAL = 1.0


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


def ngsl_verbs():
    """NGSL の生成結果で品詞に verb を持つ語。"""
    verbs = set()
    for path in glob.glob(str(ROOT / "out/ngsl/output-*.json")):
        for word in json.loads(Path(path).read_text(encoding="utf-8")):
            if "verb" in word["partsOfSpeech"]["value"]:
                verbs.add(word["word"].lower())
    if not verbs:
        sys.exit("out/ngsl/output-*.json が無い(NGSL の生成結果から動詞を読む)")
    return verbs


def listed_words():
    """既存の単語リストにある語(重複を除くため)。"""
    words = set()
    for path in glob.glob(str(ROOT / "words/*.txt")):
        if Path(path).name == "phrasal-verbs.txt":
            continue
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if line.strip() and not line.startswith("#"):
                words.add(line.strip().lower())
    return words


def matches_shape(title, verbs):
    parts = title.split(" ")
    return (2 <= len(parts) <= 3 and all(re.fullmatch(r"[a-z]+", p) for p in parts)
            and parts[0] in verbs and all(p in PARTICLES for p in parts[1:]))


def tatoeba_count(phrase):
    """句をそのまま含む英文の件数。失敗したら None(書き足さず、次回やり直す)。"""
    params = {"lang": "eng", "q": f'="{phrase}"', "sort": "relevance", "limit": "1"}
    try:
        data = get_json("https://api.tatoeba.org/unstable/sentences?" + urllib.parse.urlencode(params))
        return data["paging"]["total"]
    except Exception as e:  # 通信失敗・形式の変化は次回の再実行に回す
        print(f"  失敗: {phrase}: {e}", file=sys.stderr)
        return None


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith("-"):
        print(__doc__)
        sys.exit(64)
    work = Path(args[0])
    work.mkdir(parents=True, exist_ok=True)

    titles = fetch_candidates(work)
    verbs = ngsl_verbs()
    listed = listed_words()
    shaped = sorted({t for t in titles if matches_shape(t, verbs)} - listed)
    print(f"Wiktionary の項目 {len(titles)} / 形で絞った後 {len(shaped)}")
    if "--list-only" in args:
        return

    counts_path = work / "counts.jsonl"
    counts = {}
    if counts_path.exists():
        for line in counts_path.read_text(encoding="utf-8").splitlines():
            row = json.loads(line)
            counts[row["phrase"]] = row["count"]
    todo = [p for p in shaped if p not in counts]
    with counts_path.open("a", encoding="utf-8") as f:
        for i, phrase in enumerate(todo, 1):
            count = tatoeba_count(phrase)
            if count is not None:
                counts[phrase] = count
                f.write(json.dumps({"phrase": phrase, "count": count}) + "\n")
                f.flush()
            if i % 100 == 0:
                print(f"  {i}/{len(todo)}")
            time.sleep(TATOEBA_INTERVAL)

    missing = [p for p in shaped if p not in counts]
    if missing:
        sys.exit(f"件数を取れなかった句が {len(missing)} ある。もう一度実行すると続きから数える")
    picked = sorted((p for p in shaped if counts[p] >= 1), key=lambda p: (-counts[p], p))
    header = f"""# 句動詞 {len(picked)} 語。Tatoeba の例文の件数が多い順。
# 範囲: NGSL 1.2 の動詞でできた句動詞のうち、Wiktionary に項目があり、Tatoeba に例文が 1 つ以上あるものすべて。
#   形の条件: 2〜3 語、先頭が NGSL で品詞に動詞を持つ語、2 語目以降がすべて不変化詞か前置詞。
#   件数は Tatoeba で句を原形のまま含む英文を数えたもので、並べ順と「例文がある」の判定にだけ使った。
# 出典: Wiktionary「Category:English phrasal verbs」の項目名
#   https://en.wiktionary.org/wiki/Category:English_phrasal_verbs
# ライセンス: Creative Commons Attribution-ShareAlike 4.0 International(CC BY-SA 4.0)
#   https://creativecommons.org/licenses/by-sa/4.0/
# 作り方: tool/dictgen/pick_phrasal_verbs.py
"""
    (ROOT / "words/phrasal-verbs.txt").write_text(header + "\n".join(picked) + "\n", encoding="utf-8")
    print(f"例文あり {len(picked)} / 例文なし {len(shaped) - len(picked)} → words/phrasal-verbs.txt")


if __name__ == "__main__":
    main()
