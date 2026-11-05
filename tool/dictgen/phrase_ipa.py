#!/usr/bin/env python3
"""句動詞の IPA を、構成する語の IPA から組み立てる。

kaikki には句動詞の発音がほとんど無い(句動詞 996 語のうち 87 語)。LLM に IPA を書かせると
もっともらしい誤りが混ざって確かめきれないので、確かな語の IPA をつなぎ、強勢だけを決まりで付ける。

- 不変化詞(up・with など)は PARTICLES の表を使う。辞書の値には弱形や方言が混ざる(in /ən/、to /t̪oː/)ため、
  米音の強形を手で書いた
- 強勢は Wiktionary の句動詞の大半と同じ形にする。副詞として働く不変化詞があれば、最後の副詞に第 1 強勢、
  動詞に第 2 強勢(give up → /ˌɡɪv ˈʌp/)。前置詞だけなら動詞に第 1 強勢(deal with → /ˈdil wɪθ/)。
  前置詞には強勢の印を付けない。副詞か前置詞かは PREPOSITIONS と PREPOSITIONAL_PHRASES で決める
- 頭の動詞の IPA は、辞書(kaikki)→ ipa-dict の順に探す。動詞でない読みが選ばれていた語は HEAD_OVERRIDES で直す

使い方(tool/dictgen で。決まりの確かめ用):
    python3 phrase_ipa.py
kaikki に IPA がある句動詞と組み立てた値を並べ、強勢の位置が一致した数と、組み立てた全件を出す。
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
IPA_DICT = ROOT / "out/ipa-dict/en_US.txt"
IPA_DICT_URL = "https://raw.githubusercontent.com/open-dict-data/ipa-dict/master/data/en_US.txt"

# 米音の強形(辞書の見出しの読み)
PARTICLES = {
    "about": "əˈbaʊt", "across": "əˈkɹɔs", "after": "ˈæftɚ", "ahead": "əˈhɛd", "along": "əˈlɔŋ",
    "apart": "əˈpɑɹt", "around": "əˈɹaʊnd", "aside": "əˈsaɪd", "away": "əˈweɪ", "back": "bæk", "by": "baɪ",
    "down": "daʊn", "for": "fɔɹ", "forward": "ˈfɔɹwɚd", "in": "ɪn", "into": "ˈɪntu", "of": "ʌv", "off": "ɔf",
    "on": "ɑn", "out": "aʊt", "over": "ˈoʊvɚ", "through": "θɹu", "to": "tu", "together": "təˈɡɛðɚ", "up": "ʌp",
    "with": "wɪθ",
}
# 句の中でいつも前置詞として働く語(強勢を置かない)
PREPOSITIONS = {"for", "with", "to", "of", "into", "after"}
# 副詞にも前置詞にもなる不変化詞(in・on など)のうち、主な意味で前置詞として働く 2 語の句。
# 目的語の後ろに回せない(count on it は言えても count it on とは言わない)ものを、辞書の最初の意味で選んだ。
# ここに無い句は副詞として扱い、不変化詞に強勢を置く
PREPOSITIONAL_PHRASES = {
    "abide by", "act on", "bank on", "base on", "be about", "bet on", "blow on", "border on", "break through",
    "call on", "cap on", "check on", "cheat on", "chew on", "choke on", "come across", "come by", "consist in",
    "crush on", "cut through", "dawn on", "deal in", "decide on", "delight in", "die on", "draw on", "end in",
    "engage in", "fall on", "feed on", "find in", "fix on", "flip through", "forget about", "get on", "get over",
    "glance over", "go about", "go over", "go through", "grow on", "hang over", "happen on", "hit on", "hold by",
    "hop on", "jump on", "key on", "knock on", "know about", "land on", "lean on", "lie in", "light on", "live in",
    "live on", "live through", "look through", "major in", "munch on", "pass through", "pick on", "plan on",
    "play in", "prey on", "read through", "reflect on", "rest on", "result in", "revolve around", "ride on",
    "run across", "run on", "run through", "see about", "see through", "set on", "settle on", "share in",
    "sit on", "skate on", "sleep on", "spit on", "spy on", "stand on", "stand over", "start on", "step on",
    "stomp on", "swear by", "swear on", "talk about", "tap on", "tell on", "touch on", "tread on", "trip over",
    "walk through", "watch over", "work around", "work in", "work on", "work through",
}
# 句の頭の語で、辞書(kaikki)の値が動詞の米音でないもの。名詞などの別の読み(do /doʊ/・lead /lɛd/)や、
# 英音・方言の読み(stop /stɒp/・fight /fəɪt/)が選ばれていた。句動詞の中では動詞として読むので手で直す
HEAD_OVERRIDES = {
    "camp": "kæmp", "do": "du", "dog": "dɔɡ", "fight": "faɪt", "lead": "lid", "major": "ˈmeɪdʒɚ",
    "pass": "pæs", "play": "pleɪ", "spread": "spɹɛd", "stop": "stɑp", "turn": "tɝn", "use": "juz",
    "wear": "wɛɹ", "write": "ɹaɪt",
}
# 決まりに当てはまらない句(come on in は最後の in も副詞、het は単独の語として辞書に無い)
PHRASE_OVERRIDES = {"come on in": "/ˌkʌm ɑn ˈɪn/", "het up": "/ˌhɛt ˈʌp/"}
STRESS = "ˈˌ"
VOWELS = set("aeiouæɑɒɔəɛɪʊʌɝɚ")


def clean(ipa):
    """1 語の IPA から、句の中では要らない印を落とす。

    最初の / / の中だけを使い(kaikki は後ろに異音表記を続けることがある)、音節の点・連結の印・
    長音の印(米音の表記に揃える)・省略できる音の括弧を落とす。
    """
    match = re.search(r"/([^/]+)/", ipa)
    ipa = match.group(1) if match else ipa.strip()
    return re.sub(r"[.̯‿ː()]", "", ipa)


def from_ipa_dict(ipa):
    """ipa-dict(CMU 発音辞書由来)の表記を、kaikki の書き方に揃える。

    ipa-dict は強く読む ʌ も ə で、弱く読む ɚ も ɝ で書き、暗い l を ɫ で、破擦音を連結の印なし(tʃ)で書く。
    強勢の印の直後の母音だけを強く読む母音とみなし、ə → ʌ、それ以外の ɝ → ɚ に直す。
    """
    chars = list(ipa.replace("ɫ", "l").replace("tʃ", "t͡ʃ").replace("dʒ", "d͡ʒ"))
    stressed = set()
    for i, c in enumerate(chars):
        if c in STRESS:
            j = next((k for k in range(i + 1, len(chars)) if chars[k] in VOWELS), None)
            if j is not None:
                stressed.add(j)
    for i, c in enumerate(chars):
        if c == "ə" and i in stressed:
            chars[i] = "ʌ"
        elif c == "ɝ" and i not in stressed:
            chars[i] = "ɚ"
    return "".join(chars)


def primary(ipa):
    """第 1 強勢にする(印が無ければ前に付け、第 2 強勢なら第 1 に上げる)。"""
    if "ˈ" in ipa:
        return ipa
    if "ˌ" in ipa:
        return ipa.replace("ˌ", "ˈ", 1)
    return "ˈ" + ipa


def secondary(ipa):
    """第 2 強勢にする(第 1 強勢を下げる。印が無ければ前に付ける)。"""
    if "ˈ" in ipa:
        return ipa.replace("ˈ", "ˌ")
    return ipa if "ˌ" in ipa else "ˌ" + ipa


def unstressed(ipa):
    return ipa.replace("ˈ", "").replace("ˌ", "")


def compose(phrase, word_ipa):
    """句の IPA を返す。構成する語の IPA が無ければ空文字。word_ipa は 1 語の IPA を返す関数。"""
    if phrase in PHRASE_OVERRIDES:
        return PHRASE_OVERRIDES[phrase]
    head, *rest = phrase.split(" ")
    if not rest or any(word not in PARTICLES for word in rest):
        return ""
    head_ipa = HEAD_OVERRIDES.get(head) or word_ipa(head)
    if not head_ipa:
        return ""

    def is_preposition(i, word):
        # 3 語の句の最後(look down on・get away with)は、目的語を取る前置詞
        return word in PREPOSITIONS or phrase in PREPOSITIONAL_PHRASES or (len(rest) == 2 and i == 1)

    adverbs = [i for i, word in enumerate(rest) if not is_preposition(i, word)]
    last_adverb = adverbs[-1] if adverbs else None
    parts = [secondary(clean(head_ipa)) if adverbs else primary(clean(head_ipa))]
    for i, word in enumerate(rest):
        ipa = PARTICLES[word]
        parts.append(primary(ipa) if i == last_adverb else unstressed(ipa))
    return "/" + " ".join(parts) + "/"


# ipa-dict の値を手で直したもの・ipa-dict に無い語。辞書に入れる単語(kaikki に IPA が無い 163 語)を全部読み、
# CMU 発音辞書由来の崩れ(複合語の区切り違い・第 1 強勢が 2 つ・un- の弱化・t の脱落)があったものだけ直した
IPA_DICT_FIXES = {
    "additionally": "əˈdɪʃənəli", "attendee": "əˌtɛnˈdi", "businessperson": "ˈbɪznəsˌpɝsən",
    "ceasefire": "ˈsisˌfaɪɚ", "distractor": "dɪˈstɹæktɚ", "environmentally": "ɪnˌvaɪɹənˈmɛntəli",
    "flextime": "ˈflɛksˌtaɪm", "homeowner": "ˈhoʊmˌoʊnɚ", "housekeep": "ˈhaʊsˌkip",
    "inflationary": "ɪnˈfleɪʃəˌnɛɹi", "internationally": "ˌɪntɚˈnæʃənəli", "liberalization": "ˌlɪbɚələˈzeɪʃən",
    "misidentify": "ˌmɪsaɪˈdɛntəˌfaɪ", "multinational": "ˌmʌltiˈnæʃənəl", "nonlinear": "nɑnˈlɪniɚ",
    "politically": "pəˈlɪtɪkli", "refinance": "ˌɹiˈfaɪnæns", "repairperson": "ɹɪˈpɛɹˌpɝsən",
    "revaluation": "ˌɹivæljuˈeɪʃən", "reviewer": "ɹɪˈvjuɚ", "sightsee": "ˈsaɪtˌsi", "takeover": "ˈteɪkˌoʊvɚ",
    "unattended": "ˌʌnəˈtɛndɪd", "unauthorize": "ʌnˈɔθəˌɹaɪz", "unauthorized": "ʌnˈɔθəˌɹaɪzd",
    "unsecured": "ˌʌnsɪˈkjʊɹd", "unsure": "ʌnˈʃʊɹ", "webpage": "ˈwɛbˌpeɪd͡ʒ",
}


def load_ipa_dict():
    """ipa-dict(en_US)の 見出し → 最初の候補(IPA_DICT_FIXES で直した値)。無ければ取ってくるコマンドを出して止まる。"""
    if not IPA_DICT.exists():
        raise SystemExit(f"ipa-dict が無い。取ってくる:\n  mkdir -p {IPA_DICT.parent} && curl -fL -o {IPA_DICT} {IPA_DICT_URL}")
    table = {}
    for line in IPA_DICT.read_text(encoding="utf-8").splitlines():
        word, _, ipas = line.partition("\t")
        if word and ipas:
            # 囲みの / / は外して持つ(使う側で付ける)
            table.setdefault(word.lower(), from_ipa_dict(ipas.split(",")[0].strip().strip("/")))
    return table | IPA_DICT_FIXES


def stress_pattern(ipa):
    """語ごとの強勢の印(比べる用)。"""
    return [next((c for c in word if c in STRESS), "") for word in ipa.strip("/").split(" ")]


def main():
    bundle = json.loads((ROOT.parent.parent / "native/Packages/EitangochoCore/Sources/EitangochoWordInfo/Resources/prebuilt-dictionary.json").read_text(encoding="utf-8"))["words"]
    ipa_dict = load_ipa_dict()
    word_ipa = lambda w: (bundle.get(w) or {}).get("ipa") or ipa_dict.get(w, "")
    phrases = [w for w in bundle if " " in w]
    same = compared = 0
    print("# kaikki の値と組み立てた値")
    for phrase in phrases:
        kaikki = bundle[phrase]["ipa"]
        composed = compose(phrase, word_ipa)
        if kaikki and composed and len(kaikki.strip("/").split(" ")) == len(phrase.split(" ")):
            compared += 1
            same += stress_pattern(kaikki) == stress_pattern(composed)
        if kaikki:
            print(f"{phrase}\t{kaikki}\t{composed}")
    print(f"# 語の区切りが同じ {compared} 語のうち、強勢の位置が一致 {same}")
    print("# 組み立てた全件")
    empty = []
    for phrase in phrases:
        if not bundle[phrase]["ipa"]:
            composed = compose(phrase, word_ipa)
            if composed:
                print(f"{phrase}\t{composed}")
            else:
                empty.append(phrase)
    print(f"# 組み立てられない {len(empty)}: {', '.join(empty)}")


if __name__ == "__main__":
    main()
