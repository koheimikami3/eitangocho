#!/usr/bin/env python3
"""生成・検査の済んだ出力をまとめ、アプリに同梱する辞書ファイルを書く。

使い方(tool/dictgen で):
    python3 build_bundle.py

SOURCES の各ディレクトリの output-NNN.json をまとめ、
native/Packages/EitangochoCore/Sources/EitangochoWordInfo/Resources/prebuilt-dictionary.json に書く。
out/ は gitignore なので、コミットする正本は書き出した側。辞書に語を足したら、生成・検査の後にこれを回す。

- validate.py の検査に通らない組が 1 つでもあれば書かずに止まる
- IPA は生成の対象外なので、同じディレクトリの input-NNN.json(収集で kaikki から取った値)から取る
- 英例文は言語間で共通にする決まり(fill-instructions.md)なので 1 つだけ持つ。違っていれば止まる
- 出どころ(source)はアプリで使わないので書かない
"""

import json
import sys
from pathlib import Path

from validate import check_pair

ROOT = Path(__file__).resolve().parent
SOURCES = ["ngsl", "tsl-bsl-nawl", "phrasal-verbs"]
LANGS = ("ja", "zhHant")
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
                    "ipa": next((inp[lang]["ipa"] for lang in LANGS if inp[lang]["ipa"]), ""),
                    "pos": row["partsOfSpeech"]["value"],
                    "exampleEn": example.pop(),
                    **{lang: {"meaning": row[lang]["meaning"]["value"],
                              "exampleTranslation": row[lang]["exampleTranslation"]["value"]} for lang in LANGS},
                }
    if problems:
        print("\n".join(problems), file=sys.stderr)
        sys.exit("問題があるので書かなかった")
    DEST.parent.mkdir(parents=True, exist_ok=True)
    DEST.write_text(json.dumps({"version": VERSION, "words": words}, ensure_ascii=False, separators=(",", ":")) + "\n",
                    encoding="utf-8")
    with_ipa = sum(bool(entry["ipa"]) for entry in words.values())
    print(f"{len(words)} 語(IPA あり {with_ipa})→ {DEST.relative_to(ROOT.parent.parent)}")


if __name__ == "__main__":
    main()
