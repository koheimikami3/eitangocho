#!/usr/bin/env python3
"""wordfreq の単語リスト(words/wordfreq.txt)を作る。

範囲: wordfreq(英語)の上位 20,000 語のうち、既存の単語リストにも同梱辞書にも無い普通の単語。除くのは次のとおり。

- 英小文字以外を含む語・1 文字の語(1・don't・u.s・a)
- kaikki に小文字の見出しが無い語(固有名詞や語の断片)
- kaikki で全部の意味が略語(abbreviation・initialism・acronym)の語
- kaikki で全部の意味に offensive・derogatory・archaic・obsolete のどれかが付く語(差別語・古語)。
  vulgar は除かない(ドラマで出て意味を調べたい語のため)
- kaikki で全部の意味が活用形(form_of)で、その原形が辞書(既存リストかこのリスト)にある語(told・games)。
  アプリが辞書の原形に寄せて引くので、別の見出しは要らない。原形が辞書に無い語は残す

並び: wordfreq の順位順(頻度の高い順)。

使い方(tool/dictgen で):
    pip install wordfreq==3.1.1  # 1. の順位を初めて取るときだけ要る(仮想環境で)
    python3 pick_wordfreq.py <作業ディレクトリ>

1. wordfreq の上位 20,000 語を取る(作業ディレクトリにキャッシュ)
2. 英小文字だけの 2 文字以上の語にし、既存リスト・同梱辞書の語を除く
3. kaikki を引く(kaikki.jsonl に書き足す。止まっても続きから進む)。
   alt_of(綴り違い)の行き先も残し、build_bundle.py が IPA を埋めるのに使う(組み立てのときに通信しないため)
4. kaikki の結果で絞り、words/wordfreq.txt へ書く
"""

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
PREBUILT = ROOT.parent.parent / "native/Packages/EitangochoCore/Sources/EitangochoWordInfo/Resources/prebuilt-dictionary.json"
TOP_COUNT = 20000
# 内容が変わらないよう、取る版を固定する(pip install の版と揃える)
WORDFREQ_VERSION = "3.1.1"
TOP_CACHE = f"wordfreq-{WORDFREQ_VERSION}-top-{TOP_COUNT}.txt"
ABBREVIATION_TAGS = {"abbreviation", "initialism", "acronym"}
AVOID_TAGS = {"offensive", "derogatory", "archaic", "obsolete"}
REQUEST_INTERVAL = 0.5


def fetch_top_words(work):
    """wordfreq の上位の語を順位順に返す。"""
    path = work / TOP_CACHE
    if not path.exists():
        # キャッシュがあれば wordfreq を入れなくても回せるよう、ここで読み込む
        from importlib.metadata import version
        from wordfreq import top_n_list

        if version("wordfreq") != WORDFREQ_VERSION:
            sys.exit(f"wordfreq {WORDFREQ_VERSION} を入れて実行する(入っているのは {version('wordfreq')})")
        path.write_text("\n".join(top_n_list("en", TOP_COUNT)) + "\n", encoding="utf-8")
    return path.read_text(encoding="utf-8").splitlines()


def listed_words():
    """既存の単語リストと同梱辞書にある語(重複を除くため)。"""
    words = set(json.loads(PREBUILT.read_text(encoding="utf-8"))["words"])
    for path in glob.glob(str(ROOT / "words/*.txt")):
        if Path(path).name == "wordfreq.txt":
            continue
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if line.strip() and not line.startswith("#"):
                words.add(line.strip().lower())
    return words


def candidates(top_words):
    """英小文字だけの 2 文字以上の語のうち、既存リスト・同梱辞書に無いものを順位順に返す。"""
    listed = listed_words()
    return [w for w in top_words if re.fullmatch(r"[a-z]{2,}", w) and w not in listed]


def kaikki_entry(word):
    """kaikki の小文字の見出しから、活用形だけの語か・その原形・alt_of の行き先・意味ごとのタグを返す。
    通信の失敗は None(次回やり直す)。

    IPA に使えるのは綴り違い(alt_of: jewellery → jewelry)の行き先だけ。活用形(form_of)の原形は発音が違う
    (abandoned と abandon)ので残さない。タグと品詞は、除く条件を変えても引き直さずに済むよう丸ごと残す。
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
    entries = [e for e in map(json.loads, filter(None, lines)) if e.get("word") == word]
    senses = [s for e in entries for s in e.get("senses", [])]
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
            "formOf": targets("form_of") if form_only else [], "altOf": targets("alt_of"),
            "pos": sorted({e.get("pos", "") for e in entries}),
            "senseTags": [sorted(s.get("tags", [])) for s in senses]}


def load_jsonl(path):
    if not path.exists():
        return {}
    rows = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]
    return {row["word"]: row for row in rows}


def all_senses_tagged(row, tags):
    """全部の意味に tags のどれかが付いているか。"""
    return bool(row["senseTags"]) and all(tags & set(sense) for sense in row["senseTags"])


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith("-"):
        print(__doc__)
        sys.exit(64)
    work = Path(args[0])
    work.mkdir(parents=True, exist_ok=True)

    picked = candidates(fetch_top_words(work))
    print(f"既存リストに無い語 {len(picked)}", flush=True)

    kaikki_path = work / "kaikki.jsonl"
    kaikki = load_jsonl(kaikki_path)
    with kaikki_path.open("a", encoding="utf-8") as f:
        for word in picked:
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

    missing = [w for w in picked if w not in kaikki]
    if missing:
        sys.exit(f"kaikki を引けなかった語が {len(missing)} ある。もう一度実行すると続きから進む")
    not_found = [w for w in picked if not kaikki[w]["found"]]
    abbreviation = [w for w in picked if all_senses_tagged(kaikki[w], ABBREVIATION_TAGS)]
    avoid = [w for w in picked if all_senses_tagged(kaikki[w], AVOID_TAGS) and w not in abbreviation]
    # 上の条件で除いた語は辞書に入らないので、原形としては数えない
    removed = set(not_found) | set(abbreviation) | set(avoid)
    known = listed_words() | {w for w in picked if w not in removed}
    form_only = [w for w in picked if w not in removed
                 and kaikki[w]["formOnly"] and any(base in known for base in kaikki[w]["formOf"])]
    removed |= set(form_only)
    kept = [w for w in picked if w not in removed]
    print(f"kaikki に小文字の見出しが無くて除いた {len(not_found)}: {', '.join(not_found)}")
    print(f"全部の意味が略語で除いた {len(abbreviation)}: {', '.join(abbreviation)}")
    print(f"全部の意味が差別語・古語で除いた {len(avoid)}: {', '.join(avoid)}")
    print(f"原形が辞書にある活用形で除いた {len(form_only)}: {', '.join(form_only)}")

    header = f"""# wordfreq(英語)の上位 {TOP_COUNT:,} 語のうち、既存の単語リストにも同梱辞書にも無い {len(kept):,} 語。wordfreq の順位順。
#   除くもの: 英小文字以外を含む語・1 文字の語、kaikki(Wiktionary の抽出データ)に小文字の見出しが無い語、
#     kaikki で全部の意味が略語の語、全部の意味に offensive・derogatory・archaic・obsolete のどれかが付く語、
#     全部の意味が活用形で、その原形が辞書にある語(told・games など)。vulgar(卑語)は除かない。
# 出典: Robyn Speer. (2022). rspeer/wordfreq: v3.0 (v3.0.2). Zenodo. https://doi.org/10.5281/zenodo.7199437
#   使った版は wordfreq {WORDFREQ_VERSION}。https://github.com/rspeer/wordfreq
#   wordfreq のデータの元: Google Books Ngrams(http://books.google.com/ngrams)、Leeds Internet Corpus、Wikipedia、
#     ParaCrawl、OPUS OpenSubtitles 2018(OpenSubtitles、http://www.opensubtitles.org/)、
#     SUBTLEX(Marc Brysbaert ほか。自由に入手できるデータ。http://crr.ugent.be/programs-data/subtitle-frequencies)ほか
# ライセンス: wordfreq のコードは Apache License 2.0、データは Creative Commons Attribution-ShareAlike 4.0 International
#   (CC BY-SA 4.0) https://creativecommons.org/licenses/by-sa/4.0/
# 作り方: tool/dictgen/pick_wordfreq.py
"""
    (ROOT / "words/wordfreq.txt").write_text(header + "\n".join(kept) + "\n", encoding="utf-8")
    print(f"採った {len(kept)} → words/wordfreq.txt")


if __name__ == "__main__":
    main()
