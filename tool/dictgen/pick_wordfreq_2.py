#!/usr/bin/env python3
"""wordfreq の 20,001〜40,000 位の単語リスト(words/wordfreq-2.txt)を作る。

pick_wordfreq.py(上位 20,000 語)の続き。除く条件は pick_wordfreq.py と同じで、次を足した。

- EJDict に小文字の見出しが無い語も、次は残す(EJDict は -ly の副詞や -ed の形容詞を見出しに持たないことが多いため)
  - -ly で終わり、元の形容詞(harsh → harshly、gentle → gently、basic → basically)が辞書・単語リストにある語。
    LY_NOT_ADVERBS の語(人名など)は除く
  - ED_ADJECTIVES の語(形容詞として使う -ed の語)。過去形として使うだけの語は入れない。
    アプリは過去形を kaikki の form_of で原形に寄せて引くが(crawled → crawl)、形容詞の意味
    (weathered「風雨にさらされた」)は原形の訳では分からないため。一覧を読んで選んだ
  - KEEP_2 の語
- 一覧を読んで外す語: 人名・地名・語の断片など(NOT_COMMON_WORDS_2)、専門的すぎる語(TOO_TECHNICAL)、差別語(SLURS_2)
- kaikki の条件(略語・差別語・古語・活用形・綴り違い)で落ちても、KEEP_2 の語は残す

wordfreq はハイフンで語を分けて数えるので(low-key は low と key)、ハイフンを含む語はこのリストに入らない。
Claude の判断で足す words/claude-words.txt に入れる。

使い方(tool/dictgen で):
    pip install wordfreq==3.1.1  # 順位を初めて取るときだけ要る(仮想環境で)
    python3 pick_wordfreq_2.py <作業ディレクトリ>

kaikki は EJDict に見出しがある語だけ引く(作業ディレクトリの kaikki.jsonl に書き足す。止まっても続きから進む)。
"""

import json
import re
import sys
import time
from pathlib import Path

from pick_wordfreq import (
    ABBREVIATION_TAGS, AVOID_TAGS, BE_HAVE_DO_FORMS, NOT_COMMON_WORDS, PREBUILT, REQUEST_INTERVAL, ROOT, SLURS,
    WORDFREQ_VERSION, all_senses_tagged, ejdict_lowercase_headwords, kaikki_entry, load_jsonl, mostly_forms,
)

START_RANK = 20000
TOP_COUNT = 40000
TOP_CACHE = f"wordfreq-{WORDFREQ_VERSION}-top-{TOP_COUNT}.txt"
OUTPUT = "wordfreq-2.txt"
# このリストと、Claude の判断で足すリスト(このリストの結果を見て重なりを除いて作る)は、既存の語に数えない
NOT_LISTED_FILES = {OUTPUT, "claude-words.txt", "claude-compounds.txt"}

SLURS_2 = set("coon wop tranny whitey gimp retardation".split())
# 人名・地名・商標・語の断片・古語。候補の一覧を読んで選んだ
NOT_COMMON_WORDS_2 = set((
    "pap rem tam petit deb pollard pueblo wight tong gage serge nee cert firth castor croft seine hackney laird "
    "gabby zee coulter whitehead pasha coz tele bethel chesterfield daw fives salaam dory fob haw marguerite mot "
    "plat angelica butte joss champaign mulligan supra whiting coney brill ascot ism nave rah slough vail mahatma "
    "bbl jag ruff kip merle wainwright swami bowser giro hove wot agar dup parr zed chit roux swain bower mew gar "
    "ell largo rani nous tuff babu carmine moa fey doge faraday tun juju argyle maw freedman balboa macron muscat "
    "flack pent liege bosh dram vide senna farrow mackintosh panzer beryl columbine reeve waterman brant trad "
    "woodruff crosse fem patten foss gens thane hidalgo wort sop burgh hep hist burley landau ult excelsior mufti "
    "carina cline lough qua shad sou neath buss dauphin pandit gat marquess burg canto rho hark crick materiel wadi "
    "corrie cotter lido palatine belvedere merci pippin tabor wether gam bate hob lingua bur pix sputnik mayflower "
    "hearthstone argent therefor ere whit thence"
).split())
# 学習者がまず引かない化学・物理・医学・数学などの専門語。候補の一覧を読んで選んだ
TOO_TECHNICAL = set((
    "assay distal transverse alum leach medial ionic apostolic caliphate vertex lien fibrosis sulfate codex "
    "capacitor palladium theta acetate actin axial carcinoma corolla hyperbolic impedance ply cantor chromium "
    "schema adjutant polynomial manganese tungsten sine lancet transponder planar ester diode hepatic lambda "
    "cortical ventral quark diffraction thoracic phenotype magneto ammonium cathode ionization uterine photovoltaic "
    "ohm resistor rhea telemetry dielectric mica endogenous carbide sapiens scalar chancery valence emitter servo "
    "xenon praxis apical yaw anode capacitance cutaneous interpolation transducer gauss daemon dipole plexus "
    "presbytery plenum parietal caudal homologous annular adsorption allele ethylene ethyl hydroxide hydrolysis "
    "citrate reagent polyethylene sulfide selenium iridium molybdenum beryllium argon boron cadmium thorium radon "
    "halogen androgen cytoplasm chromatin metabolite epithelium glycogen methanol nitrous nitric recombinant "
    "chromatography electrostatic spectrometer spectroscopic oscillator relativistic orthogonal elliptic "
    "heterogeneity necrosis metastasis atherosclerosis embolism conductivity viscosity peroxide isotope tracer "
    "coolant fission polarity hertz viscous dynamical attenuation ablation accretion acetone alveolar amalgam "
    "anaerobic ascendant bitumen carotid cation centrifuge conformation dermal endocrinology ferrous fascia "
    "follicle germination interferon lathe meniscus micron osmosis pectoral septum sternum synapse tibia torsion "
    "urea urethra vertebral"
).split())
# 機械的な条件で落ちるが、単語帳に残す語。候補の一覧を読んで選んだ
KEEP_2 = set((
    # 活用形の意味が多いが、原形が辞書に無くアプリが寄せられない語
    "unprotected assorted leggings secluded bespoke congested disgruntled bonkers woodworking arrears dilapidated "
    "sweepstakes skydiving premeditated untapped crumpled outstretched pliers undies tongs mumps townspeople "
    "malnourished shingles enamored dejected droppings preconceived overblown racketeering medicated overbearing "
    "auspices environs gratifying hallowed lice "
    # 綴り違いの扱いだが、この綴りで引く語
    "fiancee bestselling valor watercolor fairytale primetime longstanding hotspot cliche timeframe eyeshadow "
    "inhumane speciality centerpiece rigor seatbelt voiceover nonviolent fiberglass interpretive backdoor byproduct "
    "colorless savor standup sugarcane ambience esophagus epicenter counterattack lifecycle gallbladder hairspray "
    "hotdog popup entree pussycat grandad velcro coed cutout "
    # 差別語・古語・略語の扱いだが、普通に使う語
    "fraught alimony trucker drunkard wimpy loony tux corgi physio "
    # EJDict に無い -ly の副詞のうち、元の形容詞が辞書に無いか形が違う語
    "vehemently unknowingly unwittingly purportedly profusely woefully demonstrably gleefully"
).split())
# 形容詞として使う -ed の語(EJDict に無いもの)。1,218 語を読んで選んだ
ED_ADJECTIVES = set((
    "esteemed unintended scarred tinted unrestricted brainwashed dehydrated protracted studded interconnected "
    "patterned appalled estranged skewed unreleased uninsured untitled conflicted deranged intertwined unsolicited "
    "riddled entangled disgraced orphaned corrugated deluded textured tapered weathered crazed dazed overloaded "
    "motorized treasured unlicensed overcrowded tiered gendered unregulated beaded clouded stylized frosted "
    "forested unconfirmed unjustified unregistered unhinged abridged uncensored terraced recessed unsupported "
    "fatigued disordered displeased mortified stunted dilated dismayed cluttered exasperated multifaceted flustered "
    "unfulfilled unimpressed unsupervised withered handcrafted misinformed underrepresented undervalued unreported "
    "disenfranchised disoriented infatuated undetermined parched unsubstantiated unchallenged unfiltered unopposed "
    "unaccounted unpunished unrecognized untested uncontested uncomplicated underserved incensed undamaged "
    "engrossed unaltered unclassified unloved enthralled mismatched undiagnosed blighted unedited unelected "
    "indentured unaffiliated unscheduled unstructured disheartened dumbfounded encrusted constipated dispossessed "
    "bewildered saddened flattered unclaimed predisposed mired hunched frayed bloodied bewitched handpicked sloped "
    "tenured braided"
).split())
# -ly で終わるが副詞でない語や、綴りの誤り。-ly の条件で拾わない
LY_NOT_ADVERBS = set("milly waverly tilly lolly moly aly handedly heartedly accidently latterly".split())


def fetch_top_words(work):
    """wordfreq の上位 TOP_COUNT 語を順位順に返す。"""
    path = work / TOP_CACHE
    if not path.exists():
        from importlib.metadata import version
        from wordfreq import top_n_list

        if version("wordfreq") != WORDFREQ_VERSION:
            sys.exit(f"wordfreq {WORDFREQ_VERSION} を入れて実行する(入っているのは {version('wordfreq')})")
        path.write_text("\n".join(top_n_list("en", TOP_COUNT)) + "\n", encoding="utf-8")
    return path.read_text(encoding="utf-8").splitlines()


def listed_words():
    """既存の単語リストと同梱辞書にある語。"""
    words = set(json.loads(PREBUILT.read_text(encoding="utf-8"))["words"])
    for path in (ROOT / "words").glob("*.txt"):
        if path.name in NOT_LISTED_FILES:
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.strip() and not line.startswith("#"):
                words.add(line.strip().lower())
    return words


def ly_base_adjectives(word):
    """-ly の副詞の元になる形容詞の候補(harshly → harsh、gently → gentle、happily → happy、basically → basic)。"""
    stem = word[:-2]
    bases = [stem, stem + "e"]
    if stem.endswith("i"):
        bases.append(stem[:-1] + "y")
    if word.endswith("bly") or word.endswith("ply") or word.endswith("tly"):
        bases.append(word[:-1] + "e")
    if word.endswith("ically"):
        bases.append(word[:-4])
    if word.endswith("lly"):
        bases.append(word[:-2])
    return bases


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith("-"):
        print(__doc__)
        sys.exit(64)
    work = Path(args[0])
    work.mkdir(parents=True, exist_ok=True)

    listed = listed_words()
    band = fetch_top_words(work)[START_RANK:]
    picked = [w for w in band if re.fullmatch(r"[a-z]{2,}", w) and w not in listed]
    ejdict = ejdict_lowercase_headwords()
    in_ejdict = [w for w in picked if w in ejdict]
    print(f"既存リストに無い語 {len(picked)}(うち EJDict にある語 {len(in_ejdict)})", flush=True)

    kaikki_path = work / "kaikki.jsonl"
    kaikki = load_jsonl(kaikki_path)
    with kaikki_path.open("a", encoding="utf-8") as f:
        for word in in_ejdict:
            if word in kaikki:
                continue
            entry = kaikki_entry(word)
            if entry is not None:
                kaikki[word] = entry
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")
                f.flush()
            time.sleep(REQUEST_INTERVAL)
    missing = [w for w in in_ejdict if w not in kaikki]
    if missing:
        sys.exit(f"kaikki を引けなかった語が {len(missing)} ある。もう一度実行すると続きから進む")

    # EJDict にある語: pick_wordfreq.py と同じ条件に、読んで外す語を足す
    read_out = SLURS | SLURS_2 | BE_HAVE_DO_FORMS | NOT_COMMON_WORDS | NOT_COMMON_WORDS_2 | TOO_TECHNICAL
    rules = [("kaikki に小文字の見出しが無い語", lambda w: not kaikki[w]["found"]),
             ("全部の意味が略語の語", lambda w: all_senses_tagged(kaikki[w], ABBREVIATION_TAGS)),
             ("全部の意味が差別語・古語の語", lambda w: all_senses_tagged(kaikki[w], AVOID_TAGS)),
             ("意味の半分以上が活用形の語", lambda w: mostly_forms(kaikki[w])),
             ("全部の意味が綴り違いの語", lambda w: all_senses_tagged(kaikki[w], {"alt-of"}))]
    dropped = {name: [] for name, _ in rules}
    dropped["読んで外した語"] = []
    kept = set()
    for word in in_ejdict:
        if word in read_out:
            dropped["読んで外した語"].append(word)
            continue
        name = None if word in KEEP_2 else next((name for name, rule in rules if rule(word)), None)
        if name:
            dropped[name].append(word)
        else:
            kept.add(word)

    # EJDict に無い語: -ly の副詞・-ed の形容詞・KEEP_2 だけ残す
    known = listed | kept
    no_ejdict_kept = {"KEEP_2": [], "-ly の副詞": [], "-ed の形容詞": []}
    for word in picked:
        if word in ejdict:
            continue
        if word in KEEP_2:
            no_ejdict_kept["KEEP_2"].append(word)
        elif word.endswith("ly") and word not in LY_NOT_ADVERBS and any(b in known for b in ly_base_adjectives(word)):
            no_ejdict_kept["-ly の副詞"].append(word)
        elif word in ED_ADJECTIVES:
            no_ejdict_kept["-ed の形容詞"].append(word)
        else:
            continue
        kept.add(word)

    # 指定の綴り間違いや、指定した語が候補に無くなったときに気づけるように止める
    specified = KEEP_2 | ED_ADJECTIVES | NOT_COMMON_WORDS_2 | TOO_TECHNICAL | SLURS_2
    unknown = sorted(specified - set(picked))
    if unknown:
        sys.exit(f"指定した語が候補に無い: {', '.join(unknown)}")

    for name, words in dropped.items():
        print(f"{name}で除いた {len(words)}")
    for name, words in no_ejdict_kept.items():
        print(f"EJDict に無いが残した({name}) {len(words)}")

    result = [w for w in picked if w in kept]
    header = f"""# wordfreq(英語)の {START_RANK + 1:,}〜{TOP_COUNT:,} 位のうち、既存の単語リストにも同梱辞書にも無い {len(result):,} 語。wordfreq の順位順。
#   除く条件は words/wordfreq.txt(上位 {START_RANK:,} 語)と同じで、一覧を読んで外した人名・地名など・専門的すぎる語・差別語を足した。
#   EJDict に小文字の見出しが無い語は除くが、-ly の副詞(元の形容詞が辞書にある語)と、読んで選んだ -ed の形容詞は残す。
# 出典: Robyn Speer. (2022). rspeer/wordfreq: v3.0 (v3.0.2). Zenodo. https://doi.org/10.5281/zenodo.7199437
#   使った版は wordfreq {WORDFREQ_VERSION}。https://github.com/rspeer/wordfreq
#   wordfreq のデータの元・ライセンスは words/wordfreq.txt の見出しのとおり(データは CC BY-SA 4.0)
# 作り方: tool/dictgen/pick_wordfreq_2.py
"""
    (ROOT / "words" / OUTPUT).write_text(header + "\n".join(result) + "\n", encoding="utf-8")
    print(f"採った {len(result)} → words/{OUTPUT}")


if __name__ == "__main__":
    main()
