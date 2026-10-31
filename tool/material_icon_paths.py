#!/usr/bin/env python3
"""Flutter 版が使う Material アイコンの輪郭を、Swift 版の Path の元データにする。

Flutter 版の `Icons.xxx` は Flutter SDK に入っている MaterialIcons フォントの字形で
描かれる。Swift 版でも同じ字形にするため、その字形の輪郭を SVG のパス文字列にして
`native/Eitangocho/Design/MaterialIconPaths.swift` に書き出す(フォントは同梱しない。
使うアイコンは数個で、フォントそのものは 1.6MB あるため)。

アイコンを足すときは ICONS に Flutter の名前を足して再実行する。
アイコンのライセンスは Apache License 2.0(Flutter SDK の MaterialIcons_LICENSE.txt)。

使い方(fontTools が要る):
    python3 -m venv /tmp/fonttools && /tmp/fonttools/bin/pip install fonttools
    /tmp/fonttools/bin/python tool/material_icon_paths.py
"""

import os
import pathlib
import re
import subprocess

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

# macOS 版で使うアイコン(Flutter の Icons の名前)。
ICONS = ["check", "expand_more", "search", "volume_up"]

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "native" / "Eitangocho" / "Design" / "MaterialIconPaths.swift"


def flutter_root() -> pathlib.Path:
    if "FLUTTER_ROOT" in os.environ:
        return pathlib.Path(os.environ["FLUTTER_ROOT"])
    flutter = subprocess.run(["which", "flutter"], capture_output=True, text=True).stdout.strip()
    return pathlib.Path(flutter).resolve().parent.parent


def codepoints(root: pathlib.Path) -> dict[str, int]:
    source = (root / "packages/flutter/lib/src/material/icons.dart").read_text(encoding="utf-8")
    found = {}
    for name in ICONS:
        match = re.search(rf"static const IconData {name} = IconData\((0x[0-9a-f]+)", source)
        if not match:
            raise SystemExit(f"{name} が icons.dart に無い")
        found[name] = int(match.group(1), 16)
    return found


def camel(name: str) -> str:
    head, *rest = name.split("_")
    return head + "".join(part.capitalize() for part in rest)


def main() -> None:
    root = flutter_root()
    font = TTFont(root / "bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf")
    cmap = font.getBestCmap()
    glyphs = font.getGlyphSet()
    units_per_em = font["head"].unitsPerEm
    ascent = font["hhea"].ascent

    lines = []
    for name, codepoint in codepoints(root).items():
        pen = SVGPathPen(glyphs)
        # フォントの座標(y が上向き・ベースライン基準)を、Flutter の Icon と同じく
        # 字の大きさの正方形(y が下向き・左上が原点)に移し、1 を一辺とする比にする。
        scale = 1 / units_per_em
        glyphs[cmap[codepoint]].draw(TransformPen(pen, (scale, 0, 0, -scale, 0, ascent * scale)))
        lines.append(f'    case .{camel(name)}: "{pen.getCommands()}"')

    OUTPUT.write_text(
        "// tool/material_icon_paths.py が生成したファイル。手で直さない。\n"
        "// Flutter SDK の MaterialIcons の字形(Apache License 2.0)。\n\n"
        "nonisolated extension MaterialIcon {\n"
        "  /// 一辺 1 の正方形に収めた輪郭(SVG のパス。y は下向き)。\n"
        "  var svgPath: String {\n"
        "    switch self {\n" + "\n".join(lines) + "\n    }\n  }\n}\n",
        encoding="utf-8",
    )
    print(f"{len(lines)} 個を {OUTPUT.relative_to(ROOT)} に書いた")


if __name__ == "__main__":
    main()
