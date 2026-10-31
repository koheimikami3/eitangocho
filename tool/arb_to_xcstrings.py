#!/usr/bin/env python3
"""Flutter 版の ARB(lib/l10n/app_*.arb)から Swift 版の String Catalog を作る。

移行のときに 1 回だけ使う。以後は Swift 版は xcstrings、Flutter 版は ARB を
別々に直す(Flutter 版には修正以外で文言を足さない)。

変換の規則:
- キーは ARB のキーのまま。Xcode の STRING_CATALOG_GENERATE_SYMBOLS で
  `LocalizedStringResource.navLearning` のような型付きの記号になる
- 差し込み `{name}` は、テンプレート(ja)の placeholders の宣言順に位置を付けた
  `%1$@`(String)/ `%1$lld`(int)にする。引数が 1 つなら位置を付けない
- ICU の plural は複数形のバリエーションにする。`=1` は `one` に寄せる
  (en / es の `one` は 1 だけなので同じ意味。ja / zh-Hant には `one` が無く、
  OS がこの形を使わないので、件数が 1 のときも `other` の文言になる)
- ICU の select は値ごとのキー(`translationLanguageName.ja` など)に分ける。
  `other{}` は捨てる

使い方: python3 tool/arb_to_xcstrings.py
"""

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
ARB_DIR = ROOT / "lib" / "l10n"
OUTPUT = ROOT / "native" / "Eitangocho" / "Resources" / "Localizable.xcstrings"

# ARB のファイル名の言語 → String Catalog の言語。app_zh.arb は gen-l10n の都合で
# 置いた素の zh(中身は zh_Hant と同じ)なので使わない。
LANGUAGES = {"ja": "ja", "en": "en", "es": "es", "fr": "fr", "zh_Hant": "zh-Hant"}
TEMPLATE = "ja"
# プロジェクトの developmentRegion。対応外の言語の端末はこの言語になる
# (Flutter 版の AppLocale.resolve と同じく英語)。
SOURCE_LANGUAGE = "en"

SPECIFIERS = {"String": "@", "int": "lld"}


def after_closing_brace(text, open_index):
    """text[open_index] の `{` に対応する `}` の次の位置。"""
    depth, j = 1, open_index + 1
    while depth:
        if j >= len(text):
            raise ValueError(f"閉じていない括弧: {text}")
        depth += {"{": 1, "}": -1}.get(text[j], 0)
        j += 1
    return j


def parse(text):
    """ICU のメッセージを、文字列と {...} の部分の並びに分ける。"""
    parts, buffer, i = [], "", 0
    while i < len(text):
        char = text[i]
        if char == "{":
            j = after_closing_brace(text, i)
            if buffer:
                parts.append(buffer)
                buffer = ""
            parts.append(parse_argument(text[i + 1 : j - 1]))
            i = j
        else:
            buffer += char
            i += 1
    if buffer:
        parts.append(buffer)
    return parts


def parse_argument(body):
    """{...} の中身。差し込み・plural・select のどれか。"""
    pieces = body.split(",", 2)
    name = pieces[0].strip()
    if len(pieces) == 1:
        return ("arg", name)
    kind = pieces[1].strip()
    if kind not in ("plural", "select"):
        raise ValueError(f"対応していない形式: {body}")
    cases, rest = {}, pieces[2].strip()
    while rest:
        open_index = rest.index("{")
        label = rest[:open_index].strip()
        j = after_closing_brace(rest, open_index)
        cases[label] = parse(rest[open_index + 1 : j - 1])
        rest = rest[j:].strip()
    return (kind, name, cases)


def render(parts, specifiers):
    """並びを書式の文字列にする。plural / select はここに来ない前提。"""
    out = ""
    for part in parts:
        if isinstance(part, str):
            out += part
        elif part[0] == "arg":
            out += specifiers[part[1]]
        else:
            raise ValueError(f"入れ子の {part[0]} には対応していない")
    return out


def string_unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


def convert(key, text, placeholders):
    """1 言語分の値。(キー, localization) の並びを返す(select は複数のキーになる)。"""
    names = list(placeholders)
    if len(names) == 1:
        specifiers = {names[0]: "%" + SPECIFIERS[placeholders[names[0]]]}
    else:
        specifiers = {
            name: f"%{index}${SPECIFIERS[placeholders[name]]}"
            for index, name in enumerate(names, start=1)
        }
    parts = parse(text)
    complex_parts = [p for p in parts if isinstance(p, tuple) and p[0] != "arg"]
    if not complex_parts:
        return [(key, string_unit(render(parts, specifiers)))]
    if len(complex_parts) > 1:
        raise ValueError(f"{key}: plural / select は 1 つだけに対応")
    kind, name, cases = complex_parts[0]
    index = parts.index(complex_parts[0])
    prefix, suffix = parts[:index], parts[index + 1 :]

    if kind == "select":
        # select の値で決まる名前は差し込みを持たない前提(今の ARB はそう)。
        return [
            (f"{key}.{label}", string_unit(render(prefix + case + suffix, specifiers)))
            for label, case in cases.items()
            if label != "other"
        ]

    variations = {}
    for label, case in cases.items():
        category = {"=0": "zero", "=1": "one"}.get(label, label)
        variations[category] = string_unit(render(prefix + case + suffix, specifiers))
    return [(key, {"variations": {"plural": variations}})]


def main():
    arbs = {
        language: json.loads((ARB_DIR / f"app_{arb_name}.arb").read_text(encoding="utf-8"))
        for arb_name, language in LANGUAGES.items()
    }
    template = arbs[TEMPLATE]
    strings = {}
    for key, text in template.items():
        if key.startswith("@"):
            continue
        meta = template.get(f"@{key}", {})
        placeholders = {
            name: info.get("type", "String")
            for name, info in meta.get("placeholders", {}).items()
        }
        for language, arb in arbs.items():
            if key not in arb:
                print(f"警告: {language} に {key} が無い", file=sys.stderr)
                continue
            for out_key, localization in convert(key, arb[key], placeholders):
                entry = strings.setdefault(
                    out_key, {"extractionState": "manual", "localizations": {}}
                )
                if "description" in meta:
                    entry["comment"] = meta["description"]
                entry["localizations"][language] = localization

    catalog = {"sourceLanguage": SOURCE_LANGUAGE, "strings": strings, "version": "1.0"}
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    # Xcode が保存するときと同じ書式(キーの並び・" : ")にして、開いただけで差分が出ないようにする。
    OUTPUT.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2, sort_keys=True, separators=(",", " : "))
        + "\n",
        encoding="utf-8",
    )
    print(f"{len(strings)} 件を {OUTPUT.relative_to(ROOT)} に書いた")


if __name__ == "__main__":
    main()
