#!/usr/bin/env python3
"""CEFR-J の単語リスト(words/cefrj.txt)を作る。

範囲: CEFR-J 語彙表(A1〜B2)と Octanove Vocabulary Profile(C1〜C2)の見出しのうち、既存の単語リストに無い語。
英綴り(colour・analyse)も別の見出しとして入れる(綴りどおりに引けるように)。除くのは次の 4 つだけ。

- 記号(`.`・`'`)入りの表記を含む見出し(a.m./am・Mr./Mr・'m)。略語・縮約形は単語帳の見出しにしない。
  同じ行の記号の無い表記(am・mr)も同じ略語なので一緒に除く
- 品詞が be-verb・have-verb・do-verb の行(am・was・had・done)。be・have・do の活用形だけの行で、
  アプリが辞書の原形に寄せて引く。kaikki に略語などの別の意味もあり、次の判定では落ちないため品詞で除く
- kaikki で全部の意味が活用形(form_of)で、その原形が辞書(既存リストかこのリスト)にある語(these・stimuli)。
  アプリが辞書の原形に寄せて引くので、別の見出しは要らない。原形が辞書に無い語(belongings)は残す
- 元のリストの誤記(MISSPELLINGS)。実在しない綴りで、生成しても訳と例文が作れない

並び: A1 → A2 → B1 → B2 → C1 → C2。各レベルの中は CSV の順。品詞違いで同じ見出しが何度も出るので、最初の 1 回だけ使う。

使い方(tool/dictgen で):
    python3 pick_cefrj.py <作業ディレクトリ>

1. 2 つの CSV を取る(作業ディレクトリにキャッシュ)
2. 見出しを `/` で分けて trim・小文字化し、記号入りの表記を含む見出し・be / have / do の活用形の行・既存リストの語を除く
3. kaikki を引き、原形が辞書にある活用形だけの語を除く(kaikki.jsonl に書き足す。止まっても続きから進む)。
   alt_of(綴り違い)の行き先も残し、build_bundle.py が IPA を埋めるのに使う(組み立てのときに通信しないため)
4. words/cefrj.txt へ書く
"""

import csv
import glob
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
USER_AGENT = "eitangocho-dictgen/1.0 (https://github.com/koheimikami3)"
# 内容が変わらないよう、取る版をコミットで固定する
SOURCE_BASE = "https://raw.githubusercontent.com/openlanguageprofiles/olp-en-cefrj/d4e45b75b38f27b30dfc5c44d8c571aec7e7092f/"
SOURCES = ["cefrj-vocabulary-profile-1.5.csv", "octanove-vocabulary-profile-c1c2-1.0.csv"]
LEVELS = ["A1", "A2", "B1", "B2", "C1", "C2"]
# be・have・do の活用形だけを載せる行の品詞
INFLECTION_POS = {"be-verb", "have-verb", "do-verb"}
# 元のリストの誤記(正しい綴りは portent・misdemeanour・worn-out・flat-out)。生成の検査で見つけた
MISSPELLINGS = {"porten", "misdemanour", "wornout", "flatout"}
REQUEST_INTERVAL = 0.5


def fetch_sources(work):
    """CSV の行を、ファイルの順につないで返す。"""
    rows = []
    for name in SOURCES:
        path = work / name
        if not path.exists():
            request = urllib.request.Request(SOURCE_BASE + name, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(request, timeout=30) as response:
                path.write_bytes(response.read())
        rows += list(csv.DictReader(path.read_text(encoding="utf-8").splitlines()))
    return rows


def listed_words():
    """既存の単語リストにある語(重複を除くため)。"""
    words = set()
    for path in glob.glob(str(ROOT / "words/*.txt")):
        if Path(path).name == "cefrj.txt":
            continue
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if line.strip() and not line.startswith("#"):
                words.add(line.strip().lower())
    return words


def candidates(rows):
    """(見出し, レベル) をレベル順に重複なく返す。記号入りの表記を含む見出し・活用形の行・既存リストの語は除く。"""
    listed, seen, picked = listed_words(), set(), []
    for level in LEVELS:
        for row in rows:
            if row["CEFR"] != level or row["pos"] in INFLECTION_POS:
                continue
            spellings = [w.strip().lower() for w in row["headword"].split("/")]
            if any(re.search(r"[.']", w) for w in spellings):
                continue
            for word in spellings:
                if not word or word in seen or word in listed or word in MISSPELLINGS:
                    continue
                seen.add(word)
                picked.append((word, level))
    return picked


def kaikki_entry(word):
    """kaikki の全項目から、活用形だけの語か・その原形・alt_of の行き先を返す。通信の失敗は None(次回やり直す)。

    IPA に使えるのは綴り違い(alt_of: jewellery → jewelry)の行き先だけ。活用形(form_of)の原形は発音が違う
    (abandoned と abandon)ので残さない。
    """
    # URL の作り方はアプリの KaikkiClient と同じ
    path = f"/dictionary/English/meaning/{word[0]}/{urllib.parse.quote(word[:2])}/{urllib.parse.quote(word)}.jsonl"
    request = urllib.request.Request("https://kaikki.org" + path, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            lines = response.read().decode("utf-8").splitlines()
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"  kaikki 失敗: {word}: {e}", file=sys.stderr)
            return None
        lines = []
    except Exception as e:  # 通信失敗は次回の再実行に回す
        print(f"  kaikki 失敗: {word}: {e}", file=sys.stderr)
        return None
    senses = [s for e in map(json.loads, filter(None, lines)) for s in e.get("senses", [])]
    def targets(key):
        found = []
        for sense in senses:
            for ref in sense.get(key, []):
                target = (ref.get("word") or "").strip().lower()
                if target and target != word and target not in found:
                    found.append(target)
        return found

    form_only = bool(senses) and all(s.get("form_of") for s in senses)
    return {"word": word, "found": bool(senses), "formOnly": form_only,
            "formOf": targets("form_of") if form_only else [], "altOf": targets("alt_of")}


def load_jsonl(path):
    if not path.exists():
        return {}
    rows = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]
    return {row["word"]: row for row in rows}


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith("-"):
        print(__doc__)
        sys.exit(64)
    work = Path(args[0])
    work.mkdir(parents=True, exist_ok=True)

    picked = candidates(fetch_sources(work))
    print(f"既存リストに無い見出し {len(picked)}", flush=True)

    kaikki_path = work / "kaikki.jsonl"
    # 活用形だけの語は原形(formOf)で判定するので、formOf を持たない古い行は引き直す
    kaikki = {w: row for w, row in load_jsonl(kaikki_path).items() if not row["formOnly"] or "formOf" in row}
    with kaikki_path.open("a", encoding="utf-8") as f:
        for word, _ in picked:
            if word in kaikki:
                continue
            entry = kaikki_entry(word)
            if entry is not None:
                kaikki[word] = entry
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")
                f.flush()
                if len(kaikki) % 200 == 0:
                    print(f"  引いた {len(kaikki)}", flush=True)
            time.sleep(REQUEST_INTERVAL)

    missing = [w for w, _ in picked if w not in kaikki]
    if missing:
        sys.exit(f"kaikki を引けなかった語が {len(missing)} ある。もう一度実行すると続きから進む")
    known = listed_words() | {w for w, _ in picked}
    form_only = [w for w, _ in picked
                 if kaikki[w]["formOnly"] and any(base in known for base in kaikki[w]["formOf"])]
    kept = [(w, level) for w, level in picked if w not in form_only]
    counts = {level: sum(1 for _, l in kept if l == level) for level in LEVELS}
    print(f"原形が辞書にある活用形で除いた {len(form_only)}: {', '.join(form_only)}")
    print(f"kaikki に無い {sum(1 for w, _ in kept if not kaikki[w]['found'])}")

    breakdown = "・".join(f"{level} {counts[level]:,}" for level in LEVELS)
    header = f"""# CEFR-J の見出しのうち、既存の単語リストに無い {len(kept):,} 語。CEFR のレベル順({breakdown})。
# 範囲: CEFR-J 語彙表(A1〜B2)と Octanove Vocabulary Profile(C1〜C2)の見出し。英綴りの見出しも入れる。
#   除くもの: 記号(. や ')入りの表記を含む見出し(a.m./am など)、品詞が be-verb・have-verb・do-verb の行、
#     kaikki(Wiktionary の抽出データ)で全部の意味が活用形で、その原形が辞書にある語(these・stimuli など)、
#     元のリストの誤記({', '.join(sorted(MISSPELLINGS))})。
#   並び: 各レベルの中は CSV の順。品詞違いで同じ見出しが何度も出るときは最初の 1 回。
# 出典:
#   The CEFR-J Wordlist Version 1.5. Compiled by Yukio Tono, Tokyo University of Foreign Studies.
#     (cefrj-vocabulary-profile-1.5.csv)
#   Octanove Vocabulary Profile C1/C2 1.0(octanove-vocabulary-profile-c1c2-1.0.csv)
#   https://github.com/openlanguageprofiles/olp-en-cefrj
# ライセンス: CEFR-J は出典を示せば研究・商用とも利用可。Octanove は Creative Commons Attribution-ShareAlike 4.0
#   International(CC BY-SA 4.0) https://creativecommons.org/licenses/by-sa/4.0/
# 作り方: tool/dictgen/pick_cefrj.py
"""
    (ROOT / "words/cefrj.txt").write_text(header + "\n".join(w for w, _ in kept) + "\n", encoding="utf-8")
    print(f"採った {len(kept)} → words/cefrj.txt")


if __name__ == "__main__":
    main()
