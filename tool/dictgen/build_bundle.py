#!/usr/bin/env python3
"""生成・検査の済んだ出力をまとめ、アプリに同梱する辞書ファイルを書く。

使い方(tool/dictgen で):
    python3 build_bundle.py

SOURCES の各ディレクトリの output-NNN.json をまとめ、
native/Packages/EitangochoCore/Sources/EitangochoWordInfo/Resources/prebuilt-dictionary.json に書く。
out/ は gitignore なので、コミットする正本は書き出した側。辞書に語を足したら、生成・検査の後にこれを回す。

- validate.py の検査に通らない組が 1 つでもあれば書かずに止まる
- IPA は生成の対象外なので、同じディレクトリの input-NNN.json(収集で kaikki から取った値)から取る。
  kaikki に無い語は、単語なら綴り違いの行き先・ipa-dict(out/ipa-dict/en_US.txt)、句動詞・複合語なら
  phrase_ipa.py で組み立てて埋める(fill_missing_ipa)。最後まで空の語は一覧を出す
- 英例文は言語間で共通にする決まり(fill-instructions.md)なので 1 つだけ持つ。違っていれば止まる
- 出どころ(source)はアプリで使わないので書かない
- 韓国語は既存の語に後から足すので、out/ko/ の出力を語の `ko` に足す(add_korean)。無ければ `ko` は書かない
"""

import json
import re
import sys
from difflib import SequenceMatcher
from pathlib import Path

from phrase_ipa import PHRASE_WORD_IPA, compose, join_words, load_ipa_dict
from validate import check_ko_pair, check_pair

ROOT = Path(__file__).resolve().parent
SOURCES = ["ngsl", "tsl-bsl-nawl", "phrasal-verbs", "cefrj", "phrasal-verbs-2", "idioms", "wordfreq"]
LANGS = ("ja", "zhHant")
# 韓国語の出力の置き場(collect_ko.py)。単語リストごとに分けず 1 か所に足していく
KOREAN_SOURCE = "ko"
# pick_cefrj.py が kaikki から残した綴り違いの行き先(IPA を埋めるのに使う)
ALT_OF = ROOT / "out/cefrj-pick/kaikki.jsonl"
# alt_of の行き先を綴り違いとみなす似ている度合い(jewellery → jewelry は 0.89、are → our は 0.33)
ALT_OF_MIN_SIMILARITY = 0.7
DEST = ROOT.parent.parent / "native/Packages/EitangochoCore/Sources/EitangochoWordInfo/Resources/prebuilt-dictionary.json"
# アプリの PrebuiltDictionary が読める形の版。形を変えたら上げ、アプリ側も合わせる
VERSION = 1


def main():
    words, problems = {}, []
    for source in SOURCES:
        for output_path in sorted((ROOT / "out" / source).glob("output-*.json")):
            input_path = output_path.with_name(output_path.name.replace("output-", "input-"))
            found = check_pair(input_path, output_path)
            if found:
                problems.append(f"{output_path.relative_to(ROOT)}: 検査の問題 {len(found)} 件")
                continue
            inputs = {row["word"]: row for row in json.loads(input_path.read_text(encoding="utf-8"))}
            for row in json.loads(output_path.read_text(encoding="utf-8")):
                word = row["word"].strip().lower()
                if word in words:
                    problems.append(f"{word}: 2 つの出力に入っている")
                    continue
                example = {row[lang]["exampleEn"]["value"] for lang in LANGS}
                if len(example) != 1:
                    problems.append(f"{word}: 英例文が言語ごとに違う")
                    continue
                inp = inputs[row["word"]]
                words[word] = {
                    "ipa": phonemic(next((inp[lang]["ipa"] for lang in LANGS if inp[lang]["ipa"]), "")),
                    "pos": row["partsOfSpeech"]["value"],
                    "exampleEn": example.pop(),
                    **{lang: {"meaning": row[lang]["meaning"]["value"],
                              "exampleTranslation": row[lang]["exampleTranslation"]["value"]} for lang in LANGS},
                }
    with_korean = add_korean(words, problems)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        sys.exit("問題があるので書かなかった")
    filled = fill_missing_ipa(words)
    DEST.parent.mkdir(parents=True, exist_ok=True)
    DEST.write_text(json.dumps({"version": VERSION, "words": words}, ensure_ascii=False, separators=(",", ":")) + "\n",
                    encoding="utf-8")
    with_ipa = sum(bool(entry["ipa"]) for entry in words.values())
    print(f"{len(words)} 語(IPA あり {with_ipa}、うち kaikki 以外で埋めた {filled})→ {DEST.relative_to(ROOT.parent.parent)}")
    empty = [word for word, entry in words.items() if not entry["ipa"]]
    if empty:
        print(f"IPA が空 {len(empty)}: {', '.join(empty)}")
    if with_korean:
        print(f"韓国語あり {with_korean} / {len(words)}")


def add_korean(words, problems):
    """out/ko/ の出力を語の `ko` に足し、足した語数を返す。

    英例文は生成のときの入力と今の辞書で同じものだけを使う。後から英例文を直した語に古い訳が残らないようにするため。
    """
    added = 0
    for output_path in sorted((ROOT / "out" / KOREAN_SOURCE).glob("output-*.json")):
        input_path = output_path.with_name(output_path.name.replace("output-", "input-"))
        found = check_ko_pair(input_path, output_path)
        if found:
            problems.append(f"{output_path.relative_to(ROOT)}: 検査の問題 {len(found)} 件")
            continue
        inputs = {row["word"]: row for row in json.loads(input_path.read_text(encoding="utf-8"))}
        for row in json.loads(output_path.read_text(encoding="utf-8")):
            word = row["word"]
            entry = words.get(word)
            if entry is None:
                problems.append(f"{word}: 韓国語の出力にあるが辞書に無い")
            elif "ko" in entry:
                problems.append(f"{word}: 2 つの韓国語の出力に入っている")
            elif inputs[word]["exampleEn"] != entry["exampleEn"]:
                problems.append(f"{word}: 韓国語の生成のときと英例文が違う")
            else:
                entry["ko"] = {"meaning": row["meaning"], "exampleTranslation": row["exampleTranslation"]}
                added += 1
    return added


def phonemic(ipa):
    """kaikki の IPA の後ろに続く異音表記(`/ˈsɪt.i/ [ˈsɪɾ.i]` の [...])を落とし、最初の / / だけにする。"""
    match = re.match(r"/[^/]+/", ipa)
    return match.group(0) if match else ipa


def fill_missing_ipa(words):
    """kaikki に IPA が無い語を埋め、埋めた数を返す。句の組み立ては kaikki の値で埋まった単語を先に使う。

    - 単語: ipa-dict → 英綴りを米綴りに直して ipa-dict → 綴り違いの行き先(alt_of)の順。
      alt_of には方言・誤記・略語の行き先(are → our)も混ざるので最後に回し、綴りが似た行き先だけを使う。
      派生語(impolitely)・つながった複合語(toothache)は組み立てない(強勢が推測になるため空のまま)
    - 句動詞: phrase_ipa.compose。それ以外の空白・ハイフン入りの語は phrase_ipa.join_words
      (ハイフン入りは先に 1 語として探す。e-book のように ipa-dict に 1 語で載る語があるため)
    """
    ipa_dict = load_ipa_dict()
    alt_of = load_alt_of()
    kaikki = {word: entry["ipa"] for word, entry in words.items() if entry["ipa"]}
    word_ipa = lambda w: kaikki.get(w) or ipa_dict.get(w, "")
    phrase_word_ipa = lambda w: PHRASE_WORD_IPA.get(w) or word_ipa(w)

    def single(word):
        for spelling in [word, *us_spellings(word)]:
            if spelling in ipa_dict:
                return f"/{ipa_dict[spelling]}/"
        for target in alt_of.get(word, []):
            if SequenceMatcher(None, word, target).ratio() >= ALT_OF_MIN_SIMILARITY and (ipa := word_ipa(target)):
                return ipa if ipa.startswith("/") else f"/{ipa}/"
        return ""

    filled = 0
    for word, entry in words.items():
        if entry["ipa"]:
            continue
        if " " in word:
            ipa = compose(word, phrase_word_ipa) or join_words(word, phrase_word_ipa)
        else:
            ipa = single(word) or ("-" in word and join_words(word, phrase_word_ipa)) or ""
        if ipa:
            entry["ipa"] = ipa
            filled += 1
    return filled


def load_alt_of():
    """pick_cefrj.py が残した、綴り違いの見出し → 行き先(jewellery → jewelry)。無ければ空。"""
    if not ALT_OF.exists():
        return {}
    rows = [json.loads(line) for line in ALT_OF.read_text(encoding="utf-8").splitlines()]
    return {row["word"]: row["altOf"] for row in rows if row["altOf"]}


# 英綴り → 米綴りの決まり。ipa-dict(米音)は英綴りの見出しを持たないことがあるので、米綴りで引き直す。
# ipa-dict に載る綴りになったときだけ使うので、four → for のような当てはまらない変換は引けずに落ちる
US_SPELLINGS = [
    (r"isation", "ization"), (r"is(e|ed|es|er|ers|ing)$", r"iz\1"), (r"ys(e|ed|es|ing)$", r"yz\1"),
    (r"our", "or"), (r"tre(s?)$", r"ter\1"), (r"ogue$", "og"), (r"ence$", "ense"),
    (r"ll(ed|ing|er|ers)$", r"l\1"), (r"ilful", "illful"), (r"amme$", "am"), (r"ae", "e"), (r"oe", "e"),
]


def us_spellings(word):
    """英綴りの決まりを 1 つずつ当てた米綴りの候補。"""
    spellings = []
    for pattern, replacement in US_SPELLINGS:
        spelling = re.sub(pattern, replacement, word)
        if spelling != word and spelling not in spellings:
            spellings.append(spelling)
    return spellings


if __name__ == "__main__":
    main()
