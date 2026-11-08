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
# 複合語・熟語(join_words)の中で強勢を置かない冠詞・接続詞。冠詞は句の中で読む弱形(once in a while の a は /eɪ/ と読まない)
FUNCTION_WORDS = {"a": "ə", "an": "ən", "the": "ðə", "and": "ænd", "or": "ɔɹ"}
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


def join_words(phrase, word_ipa):
    """複合語・熟語(bus stop・brand-new)の IPA を返す。構成する語の IPA が 1 つでも無ければ空文字。

    複合語の強勢は前に来る語(bus stop)も後ろに来る語(central heating)もあり、決まりでは決められない。
    推測の強勢を入れないよう、各語の IPA をそれぞれの強勢のまま空白でつなぐ(ハイフンも語の区切りとして扱う)。
    ただし前置詞・冠詞・接続詞(face to face の to)は句の中で強く読まないので、強勢の印を付けない
    (ipa-dict は 1 音節の語にも強勢の印を付けている)。
    """
    parts = []
    for word in re.split(r"[ -]", phrase):
        if word in PREPOSITIONS or word in FUNCTION_WORDS:
            parts.append(unstressed(FUNCTION_WORDS.get(word) or PARTICLES[word]))
            continue
        ipa = word_ipa(word)
        if not ipa:
            return ""
        parts.append(clean(ipa))
    return "/" + " ".join(parts) + "/"


# 派生語の組み立て(derive)。強勢の位置を動かさない語尾・接頭辞だけを扱う。
# -ity・-ation・-ic のように強勢が動く語尾は、元の語からは決まらないので扱わない(WEB_IPA で手で埋める)
# 語尾 → 元の語の候補の作り方(綴り)と、元の語の IPA に足す音。順に試し、最初に元の語が引けたものを使う
SUFFIXES = [
    # -ically(chaotically ← chaotic)・-ally(geologically ← geological)は ipa-dict の書き方(politically /pəˈlɪtɪkli/)に揃える
    ("ically", lambda w: [w[:-4]], "li"),
    ("ally", lambda w: [w[:-2]], "i"),
    # -ably・-ibly(reliably ← reliable): 元の語の末尾の /bəl/ を /bli/ にする
    ("bly", lambda w: [w[:-1] + "e"], None),
    ("ily", lambda w: [w[:-3] + "y"], None),
    ("ly", lambda w: [w[:-2]], "li"),
    ("iness", lambda w: [w[:-5] + "y"], "nəs"),
    ("ness", lambda w: [w[:-4]], "nəs"),
    ("ment", lambda w: [w[:-4]], "mənt"),
    ("ful", lambda w: [w[:-3]], "fəl"),
    ("less", lambda w: [w[:-4]], "ləs"),
    ("able", lambda w: [w[:-4], w[:-4] + "e"], "əbəl"),
    ("ers", lambda w: [w[:-1]], "z"),
    ("er", lambda w: [w[:-2], w[:-1]], "ɚ"),
    ("ist", lambda w: [w[:-3]], "ɪst"),
    ("ing", lambda w: [w[:-3], w[:-3] + "e"], "ɪŋ"),
    # sloped は slope + d(slop + ed と読まない)ので、e を残した形を先に試す
    ("ed", lambda w: [w[:-1], w[:-2], w[:-3]], None),
    ("s", lambda w: [w[:-1]], None),
]
# 接頭辞と付ける音。un-・in- は元の語の第 1 強勢を残し(unsure /ʌnˈʃʊɹ/)、ほかは接頭辞に第 2 強勢を置く
# (preindustrial /ˌpɹiɪnˈdʌstɹiəl/)。cyber- は複合語の前の語として第 1 強勢を持ち、元の語は第 2 強勢に下げる
PREFIXES = {
    "un": "ʌn", "in": "ɪn", "im": "ɪm", "pre": "ˌpɹi", "sub": "ˌsʌb", "inter": "ˌɪntɚ", "counter": "ˌkaʊntɚ",
    "anti": "ˌænti", "post": "ˌpoʊst", "non": "ˌnɑn",
}
COMPOUND_HEADS = {"cyber": "ˈsaɪbɚ"}
# 複合語の後ろの語にしない語。語尾として扱う(recommendable を recommend + able、cultish を cult + ish と分けない)。
# ipa-dict には語尾や略語も見出しにあるので、語尾と同じ綴りの語(ion・age・mic)も入れる
NOT_COMPOUND_TAILS = {
    "able", "ably", "ness", "less", "ment", "ful", "ally", "ically", "ing", "ers", "ist", "ism", "ish", "age", "ion",
    "ic", "mic", "ala", "ide", "ity", "ize", "ise", "ous", "ive", "ent", "ant", "ence", "ance", "ate",
}
VOICELESS = ("p", "k", "f", "θ", "s", "ʃ", "t͡ʃ", "t")
SIBILANTS = ("s", "z", "ʃ", "ʒ", "t͡ʃ", "d͡ʒ")


def derive(word, word_ipa, depth=0, compounds=True):
    """派生語・つながった複合語の IPA(囲みの / / なし)を、元の語の IPA から組み立てる。組み立てられなければ空文字。

    word_ipa は 1 語の IPA を返す関数(無ければ空文字)。元の語も派生語のこと(unreliably ← reliably ← reliable)が
    あるので、2 段まで自分を呼ぶ。複合語(hairdryer)は前の語に第 1 強勢、後ろの語に第 2 強勢を置く(英語の複合名詞の決まり)。
    """
    if depth > 2:
        return ""
    # 接頭辞を外した残りは、語そのものか語尾の付いた派生語に限る(intergalactic を in + ter + galactic と分けない)
    lookup = lambda w: (ipa := word_ipa(w)) and clean(ipa) or derive(w, word_ipa, depth + 1, compounds=False)

    for suffix, bases, sound in SUFFIXES:
        if not word.endswith(suffix) or len(word) - len(suffix) < 3:
            continue
        for base in bases(word):
            base_ipa = (ipa := word_ipa(base)) and clean(ipa)
            if not base_ipa:
                continue
            if suffix == "bly":
                if re.search(r"(ə?l̩|əl)$", base_ipa):
                    return re.sub(r"(ə?l̩|əl)$", "li", base_ipa)
                continue
            if suffix == "ily":
                if base_ipa.endswith("i"):
                    return base_ipa[:-1] + "əli"
                continue
            if suffix == "ed":
                last = base_ipa[-3:] if base_ipa.endswith(("t͡ʃ",)) else base_ipa[-1]
                return base_ipa + ("ɪd" if last in ("t", "d") else "t" if last in VOICELESS else "d")
            if suffix == "s":
                last = base_ipa[-3:] if base_ipa.endswith(("t͡ʃ", "d͡ʒ")) else base_ipa[-1]
                return base_ipa + ("ɪz" if last in SIBILANTS else "s" if last in VOICELESS else "z")
            if suffix == "ly" and base_ipa.endswith("l"):
                # -fully・-ally の l は 1 つしか読まない(insightfully /ɪnˈsaɪtfəli/)
                return base_ipa + "i"
            if suffix == "ally" and not base_ipa.endswith("əl"):
                continue
            if suffix == "ically" and not base_ipa.endswith("ɪk"):
                continue
            return base_ipa + sound

    for head, head_ipa in COMPOUND_HEADS.items():
        if word.startswith(head) and (base_ipa := lookup(word[len(head):])):
            return head_ipa + secondary(base_ipa)
    # 長い接頭辞から試す(inter- を in- として外さない)
    for prefix, prefix_ipa in sorted(PREFIXES.items(), key=lambda item: -len(item[0])):
        if word.startswith(prefix) and len(word) - len(prefix) >= 4 and (base_ipa := lookup(word[len(prefix):])):
            return prefix_ipa + primary(base_ipa)

    if not compounds:
        return ""
    # 前の語を長い方から試す(noticeboard を no + ticeboard と分けない)。ただし前の語が複数形の s で終わるときは、
    # s を後ろの語に回した分け方を使う(kickstart は kicks + tart でなく kick + start)
    for i in range(len(word) - 3, 2, -1):
        head, tail = word[:i], word[i:]
        if tail in NOT_COMPOUND_TAILS or (head.endswith("s") and word_ipa(head[:-1])):
            continue
        head_ipa, tail_ipa = word_ipa(head), word_ipa(tail)
        if head_ipa and tail_ipa:
            return primary(clean(head_ipa)) + secondary(clean(tail_ipa))
    return ""


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
    "anticancer": "ˌæntiˈkænsɚ", "autonomously": "ɔˈtɑnəməsli", "bestseller": "ˌbɛstˈsɛlɚ",
    "businesswoman": "ˈbɪznəsˌwʊmən", "contextual": "kənˈtɛkst͡ʃuəl", "correctness": "kəˈɹɛktnəs",
    "culturally": "ˈkʌlt͡ʃɚəli", "dj": "ˈdiˌd͡ʒeɪ", "dna": "ˌdiˌɛnˈeɪ", "dynamically": "daɪˈnæmɪkli",
    "elegantly": "ˈɛlɪɡəntli", "explosively": "ɪkˈsploʊsɪvli", "ferociously": "fəˈɹoʊʃəsli",
    "figuratively": "ˈfɪɡjɚətɪvli", "film-maker": "ˈfɪlmˌmeɪkɚ", "hard-working": "ˌhɑɹdˈwɝkɪŋ",
    "hiv": "ˌeɪt͡ʃˌaɪˈvi", "hospitalize": "ˈhɑspɪtəˌlaɪz", "hysterically": "hɪˈstɛɹɪkli",
    "impersonator": "ɪmˈpɝsəˌneɪtɚ", "impressionist": "ɪmˈpɹɛʃənɪst", "incongruously": "ɪnˈkɑŋɡɹuəsli",
    "indignantly": "ɪnˈdɪɡnəntli", "infected": "ɪnˈfɛktɪd", "ingratiating": "ɪnˈɡɹeɪʃiˌeɪtɪŋ",
    "intrinsically": "ɪnˈtɹɪnsɪkli", "intuitively": "ɪnˈtuɪtɪvli", "irrelevancy": "ɪˈɹɛləvənsi",
    "microcomputer": "ˌmaɪkɹoʊkəmˈpjutɚ", "mistrustful": "mɪsˈtɹʌstfəl", "modernization": "ˌmɑdɚnəˈzeɪʃən",
    "non-smoking": "ˌnɑnˈsmoʊkɪŋ", "nonchalantly": "ˌnɑnʃəˈlɑntli", "pc": "ˌpiˈsi", "ph": "ˌpiˈeɪt͡ʃ",
    "policewoman": "pəˈlisˌwʊmən", "realisation": "ˌɹiələˈzeɪʃən", "realization": "ˌɹiələˈzeɪʃən", "self-aggrandizement": "ˌsɛlfəˈɡɹændɪzmənt",
    "spokeswoman": "ˈspoʊksˌwʊmən", "startlingly": "ˈstɑɹtlɪŋli", "sterility": "stəˈɹɪlɪti",
    "superficially": "ˌsupɚˈfɪʃəli", "t-shirt": "ˈtiˌʃɝt", "tee-shirt": "ˈtiˌʃɝt",
    "unrealistic": "ˌʌnɹiəˈlɪstɪk", "verbally": "ˈvɝbəli",
    # wordfreq の語。r の音節の区切り違い(sɚˈæmɪks)・n や t の脱落もあった
    "aka": "ˌeɪˌkeɪˈeɪ", "asap": "ˌeɪˌɛsˌeɪˈpi", "blockchain": "ˈblɑkˌt͡ʃeɪn", "ceramics": "səˈɹæmɪks",
    "correctional": "kəˈɹɛkʃənəl", "handheld": "ˈhændˌhɛld", "ineligible": "ɪnˈɛlɪd͡ʒəbəl",
    "intellectually": "ˌɪntəˈlɛkt͡ʃuəli", "offseason": "ˈɔfˌsizən", "outspoken": "ˌaʊtˈspoʊkən",
    "postwar": "ˌpoʊstˈwɔɹ", "reborn": "ˌɹiˈbɔɹn", "regeneration": "ɹiˌd͡ʒɛnəˈɹeɪʃən", "rpm": "ˌɑɹˌpiˈɛm",
    "saturated": "ˈsæt͡ʃəˌɹeɪtɪd", "saturation": "ˌsæt͡ʃəˈɹeɪʃən", "supplementary": "ˌsʌpləˈmɛntəɹi",
    "theoretically": "ˌθiəˈɹɛtɪkəli", "unanswered": "ʌnˈænsɚd", "unborn": "ˌʌnˈbɔɹn",
    "undocumented": "ʌnˈdɑkjəmɛntɪd", "uplifting": "ʌpˈlɪftɪŋ", "vs": "ˈvɝsəs",
    # kaikki の英音・崩れた値(build_bundle の UNUSABLE_IPA)を ipa-dict で埋め直した語のうち、ipa-dict も崩れていたもの
    "archbishop": "ˌɑɹt͡ʃˈbɪʃəp", "calmly": "ˈkɑmli", "cogently": "ˈkoʊd͡ʒəntli", "disadvantaged": "ˌdɪsədˈvæntɪd͡ʒd",
    "denomination": "dɪˌnɑməˈneɪʃən", "dishonesty": "dɪsˈɑnəsti", "dislodge": "dɪsˈlɑd͡ʒ", "ecological": "ˌɛkəˈlɑd͡ʒɪkəl",
    "electrode": "ɪˈlɛktɹoʊd", "espionage": "ˈɛspiəˌnɑʒ", "firearm": "ˈfaɪɚˌɑɹm", "gaga": "ˈɡɑɡɑ",
    "hardcore": "ˌhɑɹdˈkɔɹ", "hierarchy": "ˈhaɪəˌɹɑɹki", "illogical": "ɪˈlɑd͡ʒɪkəl", "imam": "ɪˈmɑm",
    "incarceration": "ɪnˌkɑɹsəˈɹeɪʃən", "incompetence": "ɪnˈkɑmpətəns", "incompetent": "ɪnˈkɑmpətənt",
    "insomnia": "ɪnˈsɑmniə", "iraqi": "ɪˈɹæki", "islamic": "ɪzˈlɑmɪk", "login": "ˈlɔɡˌɪn", "mirage": "mɪˈɹɑʒ",
    "moderator": "ˈmɑdəˌɹeɪtɚ", "offshore": "ˌɔfˈʃɔɹ", "overnight": "ˌoʊvɚˈnaɪt", "overseer": "ˈoʊvɚˌsiɚ",
    "overturn": "ˌoʊvɚˈtɝn", "papa": "ˈpɑpə", "popularise": "ˈpɑpjələˌɹaɪz", "predominantly": "pɹɪˈdɑmənəntli",
    "prosecute": "ˈpɹɑsəˌkjut", "pyjamas": "pəˈd͡ʒɑməz", "relocation": "ˌɹiloʊˈkeɪʃən", "shoplift": "ˈʃɑpˌlɪft",
    "solitariness": "ˈsɑləˌtɛɹinəs", "subcontinent": "ˌsʌbˈkɑntɪnənt", "telescopic": "ˌtɛləˈskɑpɪk",
    "terrorist": "ˈtɛɹəɹɪst", "uncommon": "ʌnˈkɑmən", "unwanted": "ʌnˈwɔntɪd", "uphold": "ʌpˈhoʊld",
    "virtuosity": "ˌvɝt͡ʃuˈɑsəti", "yoghurt": "ˈjoʊɡɚt",
    # 同じ埋め直しで ipa-dict に無かった語
    "digitalize": "ˈdɪd͡ʒɪtəˌlaɪz", "dodgy": "ˈdɑd͡ʒi", "entrée": "ˈɑnˌtɹeɪ", "glocal": "ˈɡloʊkəl",
    "jewellery": "ˈd͡ʒuəlɹi", "motorway": "ˈmoʊtɚˌweɪ", "naivety": "naɪˈivəti", "opioid": "ˈoʊpiˌɔɪd",
    "pawnbroker": "ˈpɔnˌbɹoʊkɚ", "postgraduate": "ˌpoʊstˈɡɹæd͡ʒuət", "pullover": "ˈpʊlˌoʊvɚ", "raja": "ˈɹɑd͡ʒə",
    "remonstrance": "ɹɪˈmɑnstɹəns", "shoal": "ʃoʊl", "solipsism": "ˈsɑləpˌsɪzəm", "totemic": "toʊˈtɛmɪk",
    "undemonstrative": "ˌʌndɪˈmɑnstɹətɪv", "waistcoat": "ˈweɪstˌkoʊt",
}

# kaikki・ipa-dict に無いか崩れていて、derive でも組み立てられない(または組み立てを誤る)語の米音。
# Cambridge Dictionary の米音を、kaikki の書き方(ɹ・ɛ・長音の印なし・t の弾音なし)に直して書いた(2026-11-08)
WEB_IPA = {
    "mp3 player": "ˌɛmpiˈθɹi ˌpleɪɚ", "phrasal verb": "ˌfɹeɪzəl ˈvɝb", "physicality": "ˌfɪzɪˈkæləti",
    "genomic": "d͡ʒɪˈnoʊmɪk", "circumnavigation": "ˌsɝkəmˌnævəˈɡeɪʃən", "materialization": "məˌtɪɹiələˈzeɪʃən",
    "materialisation": "məˌtɪɹiələˈzeɪʃən", "retrospection": "ˌɹɛtɹəˈspɛkʃən", "proprietorial": "pɹəˌpɹaɪəˈtɔɹiəl",
    "recumbent": "ɹɪˈkʌmbənt", "ephemerality": "ɪˌfɛmɚˈæləti", "topographical": "ˌtɑpəˈɡɹæfɪkəl",
    "angularity": "ˌæŋɡjəˈlɛɹəti", "inexorability": "ˌɪnˌɛksɚəˈbɪləti", "relegation": "ˌɹɛləˈɡeɪʃən",
    "ecommerce": "ˌiˈkɑmɝs", "regenerative": "ɹɪˈd͡ʒɛnəɹətɪv", "rondo": "ˈɹɑndoʊ", "captaincy": "ˈkæptənsi",
    "cryptography": "kɹɪpˈtɑɡɹəfi", "luminosity": "ˌluməˈnɑsəti", "taxonomic": "ˌtæksəˈnɑmɪk",
    "betrothed": "bɪˈtɹoʊðd", "hydrology": "haɪˈdɹɑləd͡ʒi", "resonator": "ˈɹɛzənˌeɪtɚ", "onside": "ˌɑnˈsaɪd",
    "trigonometry": "ˌtɹɪɡəˈnɑmətɹi", "hallo": "hæˈloʊ", "agave": "əˈɡɑvi", "masala": "məˈsɑlə",
    "wasabi": "wəˈsɑbi", "esports": "ˈiˌspɔɹts", "hijab": "ˈhɪd͡ʒæb", "halal": "hæˈlæl",
    "islamophobia": "ɪzˌlæməˈfoʊbiə", "omg": "ˌoʊˌɛmˈd͡ʒi", "gif": "ɡɪf", "ebook": "ˈiˌbʊk",
    "self-aggrandisement": "ˌsɛlfəˈɡɹændɪzmənt",
    # 句の組み立て(compose・join_words)に使う語
    "skive": "skaɪv", "laze": "leɪz", "mooch": "mut͡ʃ", "quieten": "ˈkwaɪətən", "homeroom": "ˈhoʊmɹum",
    "miso": "ˈmisoʊ", "sharpener": "ˈʃɑɹpənɚ",
    # derive・ipa-dict の値が誤っていた語(複合語の区切り違い・語尾を語と取り違え・英音の値)
    "cultish": "ˈkʌltɪʃ", "metalled": "ˈmɛtəld", "clothespin": "ˈkloʊðzˌpɪn", "unwaveringly": "ʌnˈweɪvɚɪŋli",
    "anticlimactically": "ˌæntiklaɪˈmæktɪkli", "tantalisingly": "ˈtæntəˌlaɪzɪŋli",
    "radiotherapy": "ˌɹeɪdioʊˈθɛɹəpi", "physiotherapy": "ˌfɪzioʊˈθɛɹəpi", "physiotherapist": "ˌfɪzioʊˈθɛɹəpɪst",
    "radiocarbon": "ˌɹeɪdioʊˈkɑɹbən", "neurotransmitter": "ˌnʊɹoʊtɹænsˈmɪtɚ", "echolocate": "ˌɛkoʊˈloʊkeɪt",
    # Cambridge に無く、Web の検索で見つけた辞書の値(Vocabulary.com・WordReference・Dictionary.com・SpanishDict)
    "taciturnity": "ˌtæsɪˈtɝnəti", "fabulation": "ˌfæbjəˈleɪʃən", "fabulate": "ˈfæbjəˌleɪt",
    "emulsification": "ɪˌmʌlsəfəˈkeɪʃən", "presentational": "ˌpɹɛzənˈteɪʃənəl",
    # Web に見出しが無く、Cambridge で確かめた元の語(demystify・choreograph・maternal・enviable)に
    # 強勢の位置が決まった語尾(-ation・-ical・-istic)を足した
    "demystification": "diˌmɪstəfəˈkeɪʃən", "choreographical": "ˌkɔɹiəˈɡɹæfɪkəl",
    "maternalistic": "məˌtɝnəˈlɪstɪk", "wordage": "ˈwɝdɪd͡ʒ", "unenviably": "ʌnˈɛnviəbli", "uptime": "ˈʌpˌtaɪm",
}

# 句を組み立てるときだけ使う語の IPA。kaikki の先頭の値が句の意味と合わないもの(bow to の bow は「弓」の発音ではない)、
# 珍しい発音のもの(chew の /t͡ʃju/、remote の /ɹəˈməʊt̞/)、強勢の無いもの(because の /bɪkəz/)。
# 熟語 2,000 語に使われる語は全部読み、弱形(in /ən/)・方言(fight /fəɪt/)・誤り(do /doʊ/)を直した
PHRASE_WORD_IPA = {
    "because": "bɪˈkɔz", "bow": "ˈbaʊ", "chew": "ˈt͡ʃu", "remote": "ɹɪˈmoʊt",
    "as": "æz", "backyard": "ˌbækˈjɑɹd", "bath": "bæθ", "behind": "bɪˈhaɪnd", "better": "ˈbɛtɚ", "caught": "kɔt",
    "channel": "ˈt͡ʃænəl", "collect": "kəˈlɛkt", "colored": "ˈkʌlɚd", "concert": "ˈkɑnsɚt", "content": "kənˈtɛnt",
    "contrast": "ˈkɑntɹæst", "could": "kʊd", "couldn't": "ˈkʊdənt", "deaf": "dɛf", "do": "du", "dog": "dɔɡ",
    "don't": "doʊnt", "draw": "dɹɔ", "falling": "ˈfɔlɪŋ", "fight": "faɪt", "first": "fɝst", "granted": "ˈɡɹæntɪd",
    "in": "ɪn", "jackpot": "ˈd͡ʒækˌpɑt", "left": "lɛft", "noise": "nɔɪz", "nude": "nud", "nutshell": "ˈnʌtˌʃɛl",
    "on": "ɑn", "overboard": "ˈoʊvɚˌbɔɹd", "paper": "ˈpeɪpɚ", "particular": "pɚˈtɪkjəlɚ", "pass": "pæs",
    "relief": "ɹɪˈlif", "road": "ɹoʊd", "sale": "seɪl", "spread": "spɹɛd", "stop": "stɑp", "tank": "tæŋk",
    "tantrum": "ˈtæntɹəm", "tears": "tɪɹz", "that": "ðæt", "there": "ðɛɹ", "trouble": "ˈtɹʌbəl", "what's": "wʌts",
    "wheels": "wilz", "while": "waɪl", "whim": "wɪm", "wife": "waɪf", "write": "ɹaɪt", "you": "ju",
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
