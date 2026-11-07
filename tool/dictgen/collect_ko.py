#!/usr/bin/env python3
"""同梱の辞書の語に韓国語を足すための、生成(LLM)の入力を作る。

使い方(tool/dictgen で):
    python3 collect_ko.py <出力ディレクトリ> [単語リスト]

単語リストを省くと辞書の全語が対象。既にある input-NNN.json に入っている語は飛ばし、残りを 50 語ごとに
次の番号の input-NNN.json へ書く。止まっても再実行で続きから集められ、辞書に語を足した後も同じコマンドで
増えた語だけを集められる。

見出し・品詞・英例文・日本語と繁体字の訳は同梱の辞書(検査済みの最終の値)から取り、韓国語の訳語だけ kaikki を引く。
アプリの KaikkiClient は TranslationLanguage の言語の訳語しか残さず、enum に足すとアプリで選べてしまうので、
ここでは kaikki を直接引く。例文は言語間で共有する決まりで変えないので、Tatoeba は引かない。
"""

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

from build_bundle import DEST
from pick_cefrj import REQUEST_INTERVAL, USER_AGENT

# 生成 1 回分の語数。dictgen-collect の chunkSize と同じ
CHUNK_SIZE = 50


def fetch_kaikki(title):
    """kaikki の 1 ページを行の配列で返す。404 は None。それ以外の失敗は例外で止める(再実行で続きから)。"""
    time.sleep(REQUEST_INTERVAL)
    # URL の作り方はアプリの KaikkiClient と同じ
    quote = urllib.parse.quote
    path = f"/dictionary/English/meaning/{quote(title[0])}/{quote(title[:2])}/{quote(title)}.jsonl"
    request = urllib.request.Request("https://kaikki.org" + path, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.read().decode("utf-8").splitlines()
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def korean_translations(word):
    """kaikki の韓国語の訳語を、品詞・訳語・語義の説明の組で重複なく返す。無ければ空。"""
    # kaikki は大文字小文字を区別するので、404 なら頭大文字で引き直す(KaikkiClient.fetchEntriesJson と同じ)
    lines = fetch_kaikki(word)
    if lines is None:
        lines = fetch_kaikki(word[0].upper() + word[1:]) or []
    found = []
    for entry in map(json.loads, filter(None, lines)):
        for translation in entry.get("translations", []):
            if translation.get("lang_code") != "ko" or not translation.get("word"):
                continue
            row = {"pos": entry.get("pos", ""), "word": translation["word"], "sense": translation.get("sense", "")}
            if row not in found:
                found.append(row)
    return found


def main():
    args = sys.argv[1:]
    if not 1 <= len(args) <= 2 or args[0].startswith("-"):
        print(__doc__)
        sys.exit(64)
    directory = Path(args[0])
    directory.mkdir(parents=True, exist_ok=True)

    dictionary = json.loads(DEST.read_text(encoding="utf-8"))["words"]
    if len(args) == 2:
        listed = [line.strip().lower() for line in Path(args[1]).read_text(encoding="utf-8").splitlines()]
        words = [word for word in listed if word and not word.startswith("#")]
        unknown = [word for word in words if word not in dictionary]
        if unknown:
            sys.exit(f"辞書に無い語: {', '.join(unknown)}")
    else:
        words = list(dictionary)

    existing = sorted(directory.glob("input-*.json"))
    collected = {row["word"] for path in existing for row in json.loads(path.read_text(encoding="utf-8"))}
    remaining = [word for word in words if word not in collected]
    number = max((int(path.stem.removeprefix("input-")) for path in existing), default=0)

    for start in range(0, len(remaining), CHUNK_SIZE):
        rows = []
        for word in remaining[start:start + CHUNK_SIZE]:
            entry = dictionary[word]
            rows.append({
                "word": word,
                "partsOfSpeech": entry["pos"],
                "exampleEn": entry["exampleEn"],
                "ja": entry["ja"]["meaning"],
                "zhHant": entry["zhHant"]["meaning"],
                "kaikkiKo": korean_translations(word),
            })
        number += 1
        path = directory / f"input-{number:03d}.json"
        # 書きかけのファイルを残さないよう、書き終えてから名前を変える(途中で止まっても次回はこの分からやり直す)
        temporary = path.with_suffix(".tmp")
        temporary.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        os.replace(temporary, path)
        print(f"wrote {path.name} ({len(rows)} words, kaikki あり {sum(bool(row['kaikkiKo']) for row in rows)})", flush=True)
    print(f"done: 今回 {len(remaining)} 語、全 {len(collected) + len(remaining)} 語 under {directory}")


if __name__ == "__main__":
    main()
