#!/usr/bin/env python3
"""生成(LLM)の出力が fill-instructions.md の形式と決まりに合っているかを確かめる。

使い方(tool/dictgen で):
    python3 validate.py <input.json> <output.json>   1 組だけ確かめる
    python3 validate.py <ディレクトリ>                input-NNN.json と output-NNN.json を組にして全部確かめる

問題があれば内容を出して終了コード 1 で終わる。output の無い input は「未生成」として数えるだけで、
問題には含めない(収集と生成を並行して進めている途中でも回せるようにするため)。

確かめるのは形式と機械的に判定できる決まりだけ。訳や例文の良し悪しは人(Claude)が読んで確かめる。
"""

import json
import re
import sys
from pathlib import Path

FIELDS = ("meaning", "exampleEn", "exampleTranslation")
LANGS = ("ja", "zhHant")
POS = {"noun", "verb", "adjective", "adverb", "other"}
KEPT_SOURCES = {"ejdict", "kaikki", "tatoeba"}
# 入力のどの出どころを写すべきか(例文の訳は例文と同じ)
INPUT_SOURCE_KEY = {"meaning": "meaningSource", "exampleEn": "exampleSource", "exampleTranslation": "exampleSource"}
MAX_SENSES = 7
MAX_WORDS_PER_SENSE = 3
EXAMPLE_WORDS = range(8, 16)
# EJDict の表記の記号(落とす決まり)
NOTATION = re.compile(r"[〈〉《》『』]")
# 繁体字の例文の訳に残りやすい半角の約物
HALFWIDTH_PUNCT = re.compile(r"[,?!;:]")


def check_source(word, where, item, input_value, input_source, problems):
    """出どころが入力の値と合っているかを確かめる。"""
    source = item.get("source")
    if set(item) - {"value", "source"}:
        problems.append(f"{word} {where}: value と source 以外のキー {sorted(set(item) - {'value', 'source'})}")
    if source in KEPT_SOURCES:
        if item.get("value") != input_value:
            problems.append(f"{word} {where}: 「{source}」(そのまま)なのに入力と値が違う")
        if source != input_source:
            problems.append(f"{word} {where}: 出どころが入力({input_source})と違う「{source}」")
    elif source == "llm_revised":
        if not input_value:
            problems.append(f"{word} {where}: 入力が空なのに llm_revised(llm_filled のはず)")
        elif item.get("value") == input_value:
            problems.append(f"{word} {where}: 入力と同じ値なのに llm_revised(入力の出どころのはず)")
    elif source == "llm_filled":
        if input_value:
            problems.append(f"{word} {where}: 入力が空でないのに llm_filled")
    else:
        problems.append(f"{word} {where}: 不明な出どころ「{source}」")


def check_word(inp, out, problems):
    word = inp["word"]
    if out.get("word") != word:
        problems.append(f"{word}: 出力の語が「{out.get('word')}」になっている")
        return

    pos = out.get("partsOfSpeech")
    if not isinstance(pos, dict) or not isinstance(pos.get("value"), list):
        problems.append(f"{word} 品詞: 形が違う")
    else:
        values = pos.get("value")
        if not values:
            problems.append(f"{word} 品詞: 空")
        if not set(values) <= POS:
            problems.append(f"{word} 品詞: 知らない値 {sorted(set(values) - POS)}")
        if len(values) != len(set(values)):
            problems.append(f"{word} 品詞: 重複がある")
        # 品詞の入力は ja と zhHant に同じ値が入っているので ja を正とする
        check_source(word, "品詞", pos, inp["ja"]["partsOfSpeech"], "kaikki", problems)

    for lang in LANGS:
        block = out.get(lang)
        if not isinstance(block, dict):
            problems.append(f"{word} {lang}: 無い")
            continue
        for field in FIELDS:
            item = block.get(field)
            if not isinstance(item, dict) or "value" not in item or "source" not in item:
                problems.append(f"{word} {lang}.{field}: 形が違う")
                continue
            if not item["value"]:
                problems.append(f"{word} {lang}.{field}: 空")
            check_source(word, f"{lang}.{field}", item, inp[lang][field], inp[lang][INPUT_SOURCE_KEY[field]], problems)

    try:
        ja_en = out["ja"]["exampleEn"]["value"]
        zh_en = out["zhHant"]["exampleEn"]["value"]
        ja_meaning = out["ja"]["meaning"]["value"]
        zh_meaning = out["zhHant"]["meaning"]["value"]
        zh_translation = out["zhHant"]["exampleTranslation"]["value"]
    except (KeyError, TypeError):
        return  # 形の問題は上で出している
    if ja_en != zh_en:
        problems.append(f"{word}: 英例文が日本語と繁体字で違う")
    n = len(ja_en.split())
    if n not in EXAMPLE_WORDS:
        problems.append(f"{word}: 英例文が {n} 語(8〜15 語の決まり)")
    if NOTATION.search(ja_meaning):
        problems.append(f"{word} ja.meaning: 表記の記号が残っている")
    # 区切りの後に空白を入れない決まり。Codex の長い実行の途中で「, 」に崩れたことがある
    if ", " in ja_meaning:
        problems.append(f"{word} ja.meaning: 訳語の区切りが「, 」(「,」の決まり)")
    if ", " in zh_meaning:
        problems.append(f"{word} zhHant.meaning: 訳語の区切りが「, 」(「 / 」の決まり)")
    senses = ja_meaning.split(" / ")
    if len(senses) > MAX_SENSES:
        problems.append(f"{word} ja.meaning: 語義が {len(senses)} 個(7 個までの決まり)")
    if any(len(s.split(",")) > MAX_WORDS_PER_SENSE for s in senses):
        problems.append(f"{word} ja.meaning: 1 語義の訳語が 4 個以上ある")
    if len(zh_meaning.split(" / ")) > MAX_SENSES:
        problems.append(f"{word} zhHant.meaning: 訳語が 8 個以上")
    if HALFWIDTH_PUNCT.search(zh_translation):
        problems.append(f"{word} zhHant.exampleTranslation: 半角の約物がある")


def check_pair(input_path, output_path):
    """1 組を確かめて問題の一覧を返す。"""
    try:
        inputs = json.loads(Path(input_path).read_text(encoding="utf-8"))
        outputs = json.loads(Path(output_path).read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        return [f"JSON として読めない: {e}"]
    if not isinstance(outputs, list):
        return ["出力が JSON の配列になっていない"]
    problems = []
    if len(outputs) != len(inputs):
        problems.append(f"語の数が違う(入力 {len(inputs)}、出力 {len(outputs)})")
    for inp, out in zip(inputs, outputs):
        if not isinstance(out, dict):
            problems.append(f"{inp['word']}: 出力がオブジェクトになっていない")
            continue
        check_word(inp, out, problems)
    return problems


def main():
    args = sys.argv[1:]
    if len(args) == 2:
        pairs = [(Path(args[0]), Path(args[1]))]
    elif len(args) == 1 and Path(args[0]).is_dir():
        directory = Path(args[0])
        pairs = [(p, directory / p.name.replace("input-", "output-")) for p in sorted(directory.glob("input-*.json"))]
    else:
        print(__doc__)
        sys.exit(64)

    failed, missing, ok = [], [], 0
    for input_path, output_path in pairs:
        if not output_path.exists():
            missing.append(output_path.name)
            continue
        problems = check_pair(input_path, output_path)
        if problems:
            failed.append(output_path.name)
            print(f"## {output_path.name}: {len(problems)} 件")
            for p in problems:
                print(f"  - {p}")
        else:
            ok += 1

    print(f"\n合格 {ok} / 問題あり {len(failed)} / 未生成 {len(missing)}")
    if failed:
        print("問題あり: " + " ".join(failed))
    if missing:
        print("未生成: " + " ".join(missing))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
