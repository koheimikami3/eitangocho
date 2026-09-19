#!/usr/bin/env bash
#
# Xcode でアーカイブしたバンドルのバージョンが pubspec とずれていないか確かめる。
#
# CFBundleShortVersionString は $(FLUTTER_BUILD_NAME) を参照しており、その実体は
# Flutter ツールが pubspec から書き出す Flutter-Generated.xcconfig にある。
# この書き出しは `flutter build` / `flutter run` が走ったときにしか起きず、
# Xcode 単体の Archive は pubspec を読まない。そのため前回ビルド時の古い
# バージョンでアーカイブされる事故が起きる(1.3.0 と 1.5.0 の macOS で実際に
# 起きた。docs/design.md 参照)。
#
# 直すのではなく検知して止める。xcconfig はビルド開始時に読み切られるので、
# ビルドフェーズから書き直してもそのビルドには反映されないため。
#
# 使い方: verify_flutter_version.sh <Flutter-Generated.xcconfig> <pubspec.yaml>
#
# **ビルド番号は比較しない**。pubspec 側は +1 固定にしてあり、実際の番号は
# アップロード時に Xcode が割り当てる(`--build-number` で明示することもある)
# ため、ずれているのが正常な状態になる。docs/design.md 参照。

set -euo pipefail

generated="${1:?Flutter-Generated.xcconfig のパスを渡してください}"
pubspec="${2:?pubspec.yaml のパスを渡してください}"

# Xcode は "error:" で始まる行をビルドエラーとして拾う。
fail() {
  echo "error: $1" >&2
  exit 1
}

if [[ ! -f "$generated" ]]; then
  fail "$generated がありません。Archive の前に 'flutter build macos --config-only' を実行してください。"
fi

version_line="$(grep -E '^version:' "$pubspec" | head -1 | sed -E 's/^version:[[:space:]]*//')"
[[ -n "$version_line" ]] || fail "$pubspec から version を読めませんでした。"
expected="${version_line%%+*}"

actual="$(grep -E '^FLUTTER_BUILD_NAME=' "$generated" | head -1 | cut -d= -f2- || true)"
[[ -n "$actual" ]] || fail "$generated に FLUTTER_BUILD_NAME がありません。'flutter build macos --config-only' を実行してください。"

if [[ "$actual" != "$expected" ]]; then
  fail "バージョンが pubspec とずれています(アーカイブ: $actual / pubspec: $expected)。'flutter build macos --config-only' を実行してからビルドし直してください。"
fi
