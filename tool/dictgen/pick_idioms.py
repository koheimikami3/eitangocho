#!/usr/bin/env python3
"""熟語の単語リスト(words/idioms.txt)を作る。

範囲: Wiktionary の熟語と前置詞句のうち、既存の単語リストに無く、句動詞でもことわざでもなく、
差別語・古語の表示がなく、Tatoeba の英文で使われる回数が上位 TOP_N のもの。卑語はドラマで出て
意味を調べたい語なので除かない。見出しは Wiktionary のままで、活用形や one's の置き換えは数えるのにだけ使う。

使い方(tool/dictgen で):
    python3 pick_idioms.py <作業ディレクトリ> <eng_sentences.tsv.bz2> [--list-only]

eng_sentences.tsv.bz2 は Tatoeba の英文データ(約 25 MB、CC BY 2.0 FR)。先に手元へ取っておく:
    https://downloads.tatoeba.org/exports/per_language/eng/eng_sentences.tsv.bz2

1. Wiktionary の CATEGORIES と SKIP_CATEGORIES の全項目を取る(作業ディレクトリの candidates-*.json にキャッシュ)
2. 形で絞り、SKIP_CATEGORIES の句と既存の単語リストにある句を除く
3. 英文の索引を作り、活用させても届く回数の上限(上限数)を句ごとに数える
4. 上限数の多い順に kaikki を引き、活用形と意味ごとのタグを取る(kaikki.jsonl に書き足す)。
   すべての意味に EXCLUDED_TAGS のどれかが付くもの・項目が無いものは除く。
   上限数が RANK_DEPTH 位の回数を下回ったら、残りはどうしても届かないので引かない
5. 原形と活用形を含む英文を数え、多い順に上位 TOP_N を words/idioms.txt へ書く。
   全順位は作業ディレクトリの ranked.tsv に書く(区切りを決める判断材料)

kaikki は止まっても続きから進む。--list-only を付けると 2 までで止め、候補の数だけ出す。
"""

import bz2
import glob
import heapq
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parent
# Wikimedia の API は連絡先入りの User-Agent を求める
USER_AGENT = "eitangocho-dictgen/1.0 (https://github.com/koheimikami3)"
CATEGORIES = ["English idioms", "English prepositional phrases"]
# 句動詞は words/phrasal-verbs.txt で扱う。ことわざは文なので単語帳の見出しに向かない
SKIP_CATEGORIES = ["English phrasal verbs", "English proverbs"]
# 頻度で落ちない不適切な語だけを除く。vulgar はドラマで出て意味を調べたい語なので除かない
EXCLUDED_TAGS = {"offensive", "derogatory", "archaic", "obsolete"}
TOP_N = 2000
# 区切りを広げて検討できるよう、kaikki はこの順位に届きうる句まで引く
RANK_DEPTH = 3000
# 相手への負荷を抑えるための間隔(秒)。dictgen-collect が Tatoeba に空ける間隔と同じ
REQUEST_INTERVAL = 0.5

WORD = r"[\w'-]+"
ANY_WORDS = rf"{WORD}(?: {WORD}){{0,2}}"
POSSESSIVE = "my|your|his|her|its|our|their|one's"
# 見出しの中の代名詞を、数えるときだけ実際の文に出る形へ置き換える
SLOTS = {
    "one's": POSSESSIVE,
    # Tatoeba の英文は Tom's のように名前の所有格が多い
    "someone's": rf"{POSSESSIVE}|someone's|somebody's|[a-z]+'s",
    "somebody's": rf"{POSSESSIVE}|someone's|somebody's|[a-z]+'s",
    "oneself": "myself|yourself|himself|herself|itself|oneself|ourselves|yourselves|themselves",
}
# Tatoeba の英文は Tom と Mary が多い
PEOPLE = "me|you|him|her|us|them|someone|somebody|everyone|everybody|anyone|anybody|tom|mary"
# 句の末尾の someone / something を任意の語にすると get to someone が get to の全文に当たるので、
# 目的語になる語だけにする
TRAILING_SLOTS = {
    "someone": PEOPLE,
    "somebody": PEOPLE,
    "something": "it|this|that|these|those|them|something|anything|everything|nothing",
}
# 句の途中の someone を任意の語にすると do somebody wrong が do anything wrong にも当たるので、人を指す形だけにする
SOMEONE_MIDDLE = rf"{PEOPLE}|i|he|she|we|they|(?:the|a|an|my|your|his|her|our|their|this|that) {WORD}"
MIDDLE_SLOTS = {"someone": SOMEONE_MIDDLE, "somebody": SOMEONE_MIDDLE, "something": ANY_WORDS}
# en-verb の活用形に are・were は入らない
BE_FORMS = "be|am|is|are|was|were|been|being"


def get_json(url):
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def fetch_candidates(work, category):
    """Wiktionary の分類の全項目名を返す。"""
    cache = work / f"candidates-{category.replace(' ', '-')}.json"
    if cache.exists():
        return json.loads(cache.read_text(encoding="utf-8"))
    titles, cont = [], None
    while True:
        params = {"action": "query", "list": "categorymembers", "cmtitle": f"Category:{category}",
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


def listed_words():
    """既存の単語リストにある語(重複を除くため)。"""
    words = set()
    for path in glob.glob(str(ROOT / "words/*.txt")):
        if Path(path).name == "idioms.txt":
            continue
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if line.strip() and not line.startswith("#"):
                words.add(line.strip().lower())
    return words


def matches_shape(title):
    return re.fullmatch(r"[a-z'-]+( [a-z'-]+)+", title) is not None


def kaikki_entry(phrase):
    """kaikki の項目から、活用形と除くかどうかを返す。通信の失敗は None(次回やり直す)。"""
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
    entries = list(map(json.loads, filter(None, lines)))
    senses = [s for e in entries for s in e.get("senses", [])]
    if not senses:
        return {"phrase": phrase, "found": False, "excluded": False, "vulgar": "none", "forms": []}
    # 語数の変わる形(more hard up など)は別の句を数えてしまうので使わない
    forms = sorted({f["form"] for e in entries for f in e.get("forms", [])
                    if matches_shape(f["form"]) and len(f["form"].split(" ")) == len(phrase.split(" "))}
                   - {phrase})
    excluded = all(EXCLUDED_TAGS & set(s.get("tags", [])) for s in senses)
    vulgar_senses = sum("vulgar" in s.get("tags", []) for s in senses)
    vulgar = "all" if vulgar_senses == len(senses) else "some" if vulgar_senses else "none"
    return {"phrase": phrase, "found": True, "excluded": excluded, "vulgar": vulgar, "forms": forms}


def load_jsonl(path):
    if not path.exists():
        return {}
    rows = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]
    return {row["phrase"]: row for row in rows}


def load_sentences(path):
    """英文(小文字)と、語 → その語を含む英文の番号の索引を返す。

    1 万句を 200 万文に正規表現で当てると時間がかかりすぎるので、句の中で一番少ない語を含む文だけを調べる。
    """
    sentences, index = [], {}
    with bz2.open(path, "rt", encoding="utf-8") as f:
        for line in f:
            text = line.rstrip("\n").split("\t", 2)[2].lower().replace("’", "'")
            number = len(sentences)
            sentences.append(text)
            for word in set(re.findall(r"[a-z]+", text)):
                index.setdefault(word, array("I")).append(number)
    return sentences, index


def to_regex(form, loose=False):
    """活用形 1 つを、文の中で探す正規表現と、必ず含まれる語の組で返す。組の中はどれか 1 語があればよい。

    loose は kaikki を引く前の上限数を数えるための形で、1 語目の活用(took the plunge)と
    最後の語の複数形(red herrings)を問わない。
    """
    parts = form.split(" ")
    regex, needed = [], []
    for i, word in enumerate(parts):
        if word in SLOTS:
            regex.append(f"(?:{SLOTS[word]})")
        elif word in TRAILING_SLOTS:
            if i == 0:  # someone else の someone は置き換えると別の句を数えるのでそのまま
                regex.append(f"(?:{word})")
            elif i == len(parts) - 1:
                regex.append(f"(?:{TRAILING_SLOTS[word]})")
            else:
                regex.append(f"(?:{MIDDLE_SLOTS[word]})")
        elif i == 0 and word == "be":
            regex.append(f"(?:{BE_FORMS})")
        elif i == 0 and loose:
            regex.append(WORD)
        elif i == len(parts) - 1 and loose and word.isalpha():
            regex.append(rf"{word}(?:s|es)?")
            needed.append((word, word + "s", word + "es"))
        else:
            regex.append(re.escape(word))
            needed += [(w,) for w in re.findall(r"[a-z]+", word)]
    return " ".join(regex), needed


def count_sentences(forms, sentences, index, loose=False):
    """forms のどれかを含む英文の件数。"""
    hits = set()
    for form in forms:
        regex, needed = to_regex(form, loose)
        # do something のように決まった語が残らない句は、語を問わず当たってしまうので原形のまま数える
        if not needed:
            regex, needed = to_regex(form)
        if not needed:
            continue
        pattern = re.compile(rf"(?<![\w-]){regex}(?![\w-])")
        rarest = min(needed, key=lambda words: sum(len(index.get(w, ())) for w in words))
        for word in rarest:
            hits.update(i for i in index.get(word, ()) if pattern.search(sentences[i]))
    return len(hits)


def main():
    args = sys.argv[1:]
    if len(args) < 2 or args[0].startswith("-") or args[1].startswith("-"):
        print(__doc__)
        sys.exit(64)
    work = Path(args[0])
    work.mkdir(parents=True, exist_ok=True)

    titles = sorted({t for c in CATEGORIES for t in fetch_candidates(work, c)})
    skipped = {t for c in SKIP_CATEGORIES for t in fetch_candidates(work, c)}
    listed = listed_words()
    shaped = [t for t in titles if matches_shape(t)]
    not_skipped = [t for t in shaped if t not in skipped]
    candidates = [t for t in not_skipped if t not in listed]
    print(f"Wiktionary の項目 {len(titles)} / 形で絞った後 {len(shaped)} / "
          f"句動詞・ことわざを除いた後 {len(not_skipped)} / 既存の単語リストを除いた後 {len(candidates)}", flush=True)
    if "--list-only" in args:
        return

    sentences, index = load_sentences(args[1])
    print(f"英文 {len(sentences)}", flush=True)
    upper = {p: count_sentences([p], sentences, index, loose=True) for p in candidates}
    print(f"上限数が 0 の句 {sum(c == 0 for c in upper.values())}", flush=True)

    kaikki_path = work / "kaikki.jsonl"
    kaikki = load_jsonl(kaikki_path)
    counts = {}
    # 残った句の RANK_DEPTH 位までの回数。先頭がその順位の回数になる
    best = []
    with kaikki_path.open("a", encoding="utf-8") as f:
        for number, phrase in enumerate(sorted(candidates, key=lambda p: (-upper[p], p)), 1):
            if upper[phrase] == 0 or (len(best) == RANK_DEPTH and upper[phrase] < best[0]):
                break
            if phrase not in kaikki:
                entry = kaikki_entry(phrase)
                time.sleep(REQUEST_INTERVAL)
                if entry is None:
                    continue
                f.write(json.dumps(entry) + "\n")
                f.flush()
                kaikki[phrase] = entry
            entry = kaikki[phrase]
            if entry["found"] and not entry["excluded"]:
                counts[phrase] = count_sentences([phrase] + entry["forms"], sentences, index)
                heapq.heappush(best, counts[phrase])
                if len(best) > RANK_DEPTH:
                    heapq.heappop(best)
            if number % 200 == 0:
                print(f"  kaikki {number} 句目 / 上限数 {upper[phrase]} / 残った句 {len(counts)}", flush=True)

    looked_up = [p for p in candidates if p in kaikki]
    not_found = [p for p in looked_up if not kaikki[p]["found"]]
    excluded = [p for p in looked_up if kaikki[p]["excluded"]]
    missing = [p for p in candidates if p not in kaikki and upper[p] >= (best[0] if len(best) == RANK_DEPTH else 1)]
    print(f"kaikki に無い {len(not_found)} / 表示で除いた {len(excluded)} / 残り {len(counts)} / "
          f"頻度が足りず引かなかった {len(candidates) - len(looked_up)}")
    if missing:
        sys.exit(f"取れなかった句が {len(missing)} ある。もう一度実行すると続きから進む")
    ranked = sorted(counts, key=lambda p: (-counts[p], p))
    (work / "ranked.tsv").write_text("".join(f"{p}\t{counts[p]}\t{kaikki[p]['vulgar']}\n" for p in ranked), encoding="utf-8")
    picked = ranked[:TOP_N]
    header = f"""# 熟語 {len(picked)} 語。使われる頻度の高い順。
# 範囲: Wiktionary の熟語と前置詞句のうち、既存の単語リストに無く、句動詞でもことわざでもなく、差別語・古語の表示がなく、使われる頻度が上位 {TOP_N} のもの。
#   形の条件: 2 語以上、英小文字・空白・ハイフン・アポストロフィのみ。
#   除く分類: {", ".join(f"Category:{c}" for c in SKIP_CATEGORIES)}。
#   除く表示: kaikki(Wiktionary の抽出データ)ですべての意味に {", ".join(sorted(EXCLUDED_TAGS))} のどれかが付くもの。卑語(vulgar)は除かない。
#   頻度: Tatoeba(CC BY 2.0 FR)の英文のうち、原形か活用形(kaikki の forms)を含む文の件数。one's・someone・something は実際の文に出る語(所有格・代名詞・名詞句など)に置き換えて数える。
# 出典: Wiktionary「Category:English idioms」「Category:English prepositional phrases」の項目名
#   https://en.wiktionary.org/wiki/Category:English_idioms
#   https://en.wiktionary.org/wiki/Category:English_prepositional_phrases
# ライセンス: Creative Commons Attribution-ShareAlike 4.0 International(CC BY-SA 4.0)
#   https://creativecommons.org/licenses/by-sa/4.0/
# 作り方: tool/dictgen/pick_idioms.py
"""
    (ROOT / "words/idioms.txt").write_text(header + "\n".join(picked) + "\n", encoding="utf-8")
    print(f"採った {len(picked)} → words/idioms.txt")


if __name__ == "__main__":
    main()
