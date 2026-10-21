"""同梱フォントの縦の数値を直し、字面を行の上下中央に置く。

行の上端・下端(hhea / OS/2 win)の配分が字面に対して偏っているフォントは、
枠の中で上下中央に置いても文字が上下どちらかに寄って見える。行全体の高さは
変えずに上下の配分だけを直し、基準にした字面の中心を行の中心に合わせる。

- cjk: Noto Sans JP / TC。行の上端・下端が 1160 / -288 で、字面の枠
  (OS/2 typo = 880 / -120)に対して上が広く、和文が下に寄る(ボタン・チップなど)。
  基準は字面の枠。
- ipa: Andika。積み重なる発音区別符号のために上が大きく取ってあり(2500 / -800)、
  発音記号が下に寄って、直下の品詞チップに詰まって見える。基準は発音記号で
  使う字の実際の外形。

何度かけても同じ結果になる(行の高さと基準の字面は書き換えないため)。
フォントを差し替えたら、このスクリプトを再度かけること。

使い方(fontTools が要る):
    python3 -m venv /tmp/fonttools && /tmp/fonttools/bin/pip install fonttools
    /tmp/fonttools/bin/python tool/center_font_metrics.py cjk \\
        assets/fonts/NotoSansJP.ttf assets/fonts/NotoSansTC.ttf
    /tmp/fonttools/bin/python tool/center_font_metrics.py ipa \\
        assets/fonts/Andika-Regular.ttf
"""

import sys

from fontTools.pens.boundsPen import BoundsPen
from fontTools.ttLib import TTFont

# 発音記号の外形を測る字。スラッシュ・強勢記号・長音記号と、
# 上に伸びる字(b d ð ʃ など)・下に伸びる字(g j p ʒ など)を含める。
_IPA_SAMPLE = "/[]ˈˌːbdfghjklpqtyəɪʊæɑɔʃʒθðŋɛʌɜɒɚɝ"


def _cjk_reference(font: TTFont) -> tuple[float, float]:
    """和文の字面の枠(上端, 下端)。"""
    os2 = font["OS/2"]
    return os2.sTypoAscender, os2.sTypoDescender


def _ipa_reference(font: TTFont) -> tuple[float, float]:
    """発音記号で使う字の外形の(上端, 下端)。"""
    cmap = font.getBestCmap()
    glyphs = font.getGlyphSet()
    top, bottom = 0.0, 0.0
    for ch in _IPA_SAMPLE:
        pen = BoundsPen(glyphs)
        glyphs[cmap[ord(ch)]].draw(pen)
        if pen.bounds:
            bottom = min(bottom, pen.bounds[1])
            top = max(top, pen.bounds[3])
    return top, bottom


def center(path: str, reference) -> None:
    font = TTFont(path)
    hhea = font["hhea"]
    os2 = font["OS/2"]

    # 行の高さ(上端 + 下端)は保ったまま、基準の字面の中心が行の中心に来るよう配分する。
    total = hhea.ascent - hhea.descent
    top, bottom = reference(font)
    ascent = round(total / 2 + (top + bottom) / 2)
    descent = ascent - total  # 負の値

    hhea.ascent, hhea.descent = ascent, descent
    # Windows 系の描画が見る値も揃える(usWinDescent は正の値で持つ)。
    os2.usWinAscent, os2.usWinDescent = ascent, -descent
    # USE_TYPO_METRICS が立っているフォントは typo の値で行を組む描画系があるため、
    # typo も同じ値にする(立っていないフォントの typo は字面の枠なので触らない)。
    if os2.fsSelection & (1 << 7):
        os2.sTypoAscender, os2.sTypoDescender = ascent, descent
    font.save(path)
    print(f"{path}: ascent {ascent}, descent {descent} (total {total})")


if __name__ == "__main__":
    mode, *paths = sys.argv[1:]
    reference = {"cjk": _cjk_reference, "ipa": _ipa_reference}[mode]
    for path in paths:
        center(path, reference)
