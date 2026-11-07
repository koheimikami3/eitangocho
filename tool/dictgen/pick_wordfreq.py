#!/usr/bin/env python3
"""wordfreq の単語リスト(words/wordfreq.txt)を作る。

範囲: wordfreq(英語)の上位 20,000 語のうち、既存の単語リストにも同梱辞書にも無い普通の単語。除くのは次のとおり。

- 英小文字以外を含む語・1 文字の語(1・don't・u.s・a)
- kaikki に小文字の見出しが無い語(固有名詞や語の断片)
- kaikki で全部の意味が略語(abbreviation・initialism・acronym)の語
- kaikki で全部の意味に offensive・derogatory・archaic・obsolete のどれかが付く語(差別語・古語)。
  vulgar は除かない(ドラマで出て意味を調べたい語のため)
- 差別語(SLURS)。侮蔑のタグが無い意味が 1 つでもあると上の条件を抜けるので、語を指定する
- be・have・do の活用形(BE_HAVE_DO_FORMS)。kaikki に別の意味もあるが、アプリが原形に寄せて引く
- 人名・地名など(NOT_COMMON_WORDS)。kaikki にも EJDict にも小文字の見出しがあり、下の条件を抜けるので語を指定する
- 次の 4 つ。ただし KEEP の語は、これらと kaikki の見出し・略語・差別語・古語の条件では除かない
  - EJDict に小文字の見出しが無い語(paris・maxwell・didnt)。kaikki では人名や綴りの崩れた語を判別できないため
  - kaikki で意味の半分以上が活用形の語(told・made)。アプリは別の意味があっても原形に寄せて引く
  - 2 文字の語(ll・st)
  - kaikki で全部の意味が綴り違い(alt_of)の語(matt・oxford)

並び: wordfreq の順位順(頻度の高い順)。

使い方(tool/dictgen で):
    pip install wordfreq==3.1.1  # 1. の順位を初めて取るときだけ要る(仮想環境で)
    python3 pick_wordfreq.py <作業ディレクトリ>

1. wordfreq の上位 20,000 語を取る(作業ディレクトリにキャッシュ)
2. 英小文字だけの 2 文字以上の語にし、既存リスト・同梱辞書の語を除く
3. kaikki を引く(kaikki.jsonl に書き足す。止まっても続きから進む)。
   alt_of(綴り違い)の行き先も残し、build_bundle.py が IPA を埋めるのに使う(組み立てのときに通信しないため)
4. kaikki の結果で絞り、words/wordfreq.txt へ書く
"""

import glob
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
USER_AGENT = "eitangocho-dictgen/1.0 (https://github.com/koheimikami3)"
PREBUILT = ROOT.parent.parent / "native/Packages/EitangochoCore/Sources/EitangochoWordInfo/Resources/prebuilt-dictionary.json"
EJDICT = ROOT.parent.parent / "assets/ejdict/ejdict-hand-utf8.txt"
TOP_COUNT = 20000
# 内容が変わらないよう、取る版を固定する(pip install の版と揃える)
WORDFREQ_VERSION = "3.1.1"
TOP_CACHE = f"wordfreq-{WORDFREQ_VERSION}-top-{TOP_COUNT}.txt"
ABBREVIATION_TAGS = {"abbreviation", "initialism", "acronym"}
AVOID_TAGS = {"offensive", "derogatory", "archaic", "obsolete"}
SLURS = set("nigger nigga faggot fag dyke retarded mick cunt".split())
BE_HAVE_DO_FORMS = set("is am are was were been being has had having does did done doing".split())
# 人名・地名・商標と、語の断片や綴りの崩れ(don・cant・wont)で順位が上がった語。別の意味があっても、その意味で引く人が少ない語。
# 別の意味でよく使う語(jack・bill・victor・nick)は入れない。候補の一覧を見て選んだ
NOT_COMMON_WORDS = set((
    "john trump japan china peter tom twitter mike martin lee harry don jimmy victoria carter johnny josh jay rick "
    "billy graham jerry khan nelson batman bobby charlotte franklin ken wright turner collins morris costa brad bailey "
    "superman hart marc palmer dale shanghai sally drake cox randy jenny kirk donna yahoo timothy freeman rand morocco "
    "fuller tucker surrey chandler wheeler gloria hank beck benedict jess bonnie hogan goodman dell kris sheila tanner "
    "meg sawyer burgess dickens ulster thatcher skinner mercer phoebe bowman cutler madras collier barker welch dyer "
    "bourne greenwood obi clement colleen dirk trey bey coca chevy airbus draper fay lea raj lam ole mil lib ave sol "
    "ting roc wen ser col cor tor pas lac tata cant wont"
).split())
# 機械的な絞り込みで落ちるが、単語帳に残す語。候補の一覧を見て選んだ
KEEP = set((
    # 略語・差別語・古語の条件で落ちるが、普通に使う語
    "condo limo nerd caucus christianity welsh dumbass whore "
    # 大文字で書く語のうち、国籍・言語・宗教・祝日を表す語(国名や都市名は入れない)
    "english french german spanish greek dutch arabic swiss danish indian american british european chinese russian "
    "australian african japanese canadian asian italian scottish irish korean latin mexican israeli turkish brazilian "
    "egyptian swedish thai iranian syrian portuguese pakistani hispanic czech iraqi norwegian cuban hebrew indonesian "
    "vietnamese malaysian persian belgian hindi austrian hungarian filipino finnish ukrainian nigerian palestinian "
    "victorian muslim jewish islamic islam hindu buddhist buddhism judaism catholic catholicism protestant christmas "
    "easter halloween bible nazi "
    # 卑語(ドラマで出て意味を調べたい語は除かない決まり)
    "fucked balls asshole fuckin lmao wtf cum screwed tits dammit shits motherfucker pissing ffs screwing dildo "
    "shitting blowjob lmfao shite ho "
    # 活用形の意味が多いが、原形が辞書に無くアプリが寄せられない語
    "alumni destined uprising accredited panties whoops condensed outspoken handwritten entrenched condolences "
    "goggles barracks nuggets "
    # 2 文字の語
    "oh ah ha eh uh um aw hm yo ma ai vs "
    # 綴り違いの扱いだが、この綴りで引く語
    "thru grad rpm fulfillment postwar kickoff counsellor chateau raja "
    # 略語の形でも日常で使う語
    "etc aka atm pdf gif ceo vip ufo asap wifi bbq btw omg lol "
    # 話し言葉
    "wanna kinda sorta gimme gotcha dunno outta anyways bro nah yup yay duh jeez geez meh haha hmm ooh aww yikes "
    # EJDict に大文字の見出しだけあるが、普通の語として使う語
    "cellular tertiary biblical mafia expo diaspora utopia nemesis alpine titan excellency odyssey messiah sabbath grail "
    # EJDict より新しいなどで見出しが無い語
    "based app anime podcast iconic sexually mega indie remix cyber gameplay manga vibe admin meme transgender "
    "headphones ninja mindset midfielder superhero startup bot fundraising intro mic promo thankfully rehab analytics "
    "username bluetooth screenshot selfie homosexuality turbo retro flawed pixel ebook fest manually songwriter hyper "
    "restart sushi cosmetics hashtag blockchain storytelling graffiti samurai preseason multiplayer bandwidth "
    "computational filmmaker ebola meth midfield falsely geek playlist wiki cinematic crypto testosterone attacker "
    "fundraiser societal entrepreneurship connectivity encryption bloke entitlement karate meltdown onboard "
    "accreditation dealings neurological reboot robotic uniquely amenities pediatric robotics lockdown tsunami "
    "wellbeing delusional dumpster inbox ridiculously homophobic router fella malware negativity techno motivational "
    "noir progressively biomedical makeover paranormal vaguely postseason digitally homepage neuroscience stripper "
    "workload cardio federally inadvertently redevelopment rematch undocumented correctional homelessness logically "
    "offseason pharma cosplay anonymously mindfulness proactive prominently unpublished childcare hoodie matchup "
    "openness oversized smiley clinically multicultural standalone biomass comedic biker decidedly dopamine "
    "identifiable lifespan racially undisclosed dysfunctional handheld legitimately metadata oncology revisit "
    "wastewater cybersecurity geographically ramen synth homophobia insanely mixtape socioeconomic carb fatally "
    "grossly holistic microbial millennial opioid playback positivity relatable usefulness crowdfunding cutie exec "
    "mojo preparedness selectively skincare uplifting voicemail biopsy deadliest fracking fungal prematurely "
    "prioritize spectroscopy unanswered unethical cryptocurrency disproportionately ecommerce exponentially externally "
    "fanbase latte margarita pedophile peptide rockstar typo chai detox playbook tofu"
).split())
REQUEST_INTERVAL = 0.5


def fetch_top_words(work):
    """wordfreq の上位の語を順位順に返す。"""
    path = work / TOP_CACHE
    if not path.exists():
        # キャッシュがあれば wordfreq を入れなくても回せるよう、ここで読み込む
        from importlib.metadata import version
        from wordfreq import top_n_list

        if version("wordfreq") != WORDFREQ_VERSION:
            sys.exit(f"wordfreq {WORDFREQ_VERSION} を入れて実行する(入っているのは {version('wordfreq')})")
        path.write_text("\n".join(top_n_list("en", TOP_COUNT)) + "\n", encoding="utf-8")
    return path.read_text(encoding="utf-8").splitlines()


def listed_words():
    """既存の単語リストと同梱辞書にある語(重複を除くため)。"""
    words = set(json.loads(PREBUILT.read_text(encoding="utf-8"))["words"])
    for path in glob.glob(str(ROOT / "words/*.txt")):
        if Path(path).name == "wordfreq.txt":
            continue
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if line.strip() and not line.startswith("#"):
                words.add(line.strip().lower())
    return words


def ejdict_lowercase_headwords():
    """EJDict の小文字の見出し。大文字の見出しは固有名詞なので入れない(訳は使わない)。"""
    headwords = set()
    for line in EJDICT.read_text(encoding="utf-8").splitlines():
        for headword in line.split("\t")[0].split(","):
            if headword.strip() == headword.strip().lower():
                headwords.add(headword.strip())
    return headwords


def candidates(top_words):
    """英小文字だけの 2 文字以上の語のうち、既存リスト・同梱辞書に無いものを順位順に返す。"""
    listed = listed_words()
    return [w for w in top_words if re.fullmatch(r"[a-z]{2,}", w) and w not in listed]


def kaikki_entry(word):
    """kaikki の小文字の見出しから、活用形だけの語か・その原形・alt_of の行き先・意味ごとのタグを返す。
    通信の失敗は None(次回やり直す)。

    IPA に使えるのは綴り違い(alt_of: jewellery → jewelry)の行き先だけ。活用形(form_of)の原形は発音が違う
    (abandoned と abandon)ので残さない。タグと品詞は、除く条件を変えても引き直さずに済むよう丸ごと残す。
    """
    # URL の作り方はアプリの KaikkiClient と同じ
    path = f"/dictionary/English/meaning/{word[0]}/{urllib.parse.quote(word[:2])}/{urllib.parse.quote(word)}.jsonl"
    request = urllib.request.Request("https://kaikki.org" + path, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            lines = response.read().decode("utf-8").splitlines()
    except urllib.error.HTTPError as e:
        if e.code != 404:
            print(f"  kaikki 失敗: {word}: {e}", file=sys.stderr)
            return None
        lines = []
    except Exception as e:  # 通信失敗は次回の再実行に回す
        print(f"  kaikki 失敗: {word}: {e}", file=sys.stderr)
        return None
    entries = [e for e in map(json.loads, filter(None, lines)) if e.get("word") == word]
    senses = [s for e in entries for s in e.get("senses", [])]
    def targets(key):
        found = []
        for sense in senses:
            for ref in sense.get(key, []):
                target = (ref.get("word") or "").strip().lower()
                if target and target != word and target not in found:
                    found.append(target)
        return found

    form_only = bool(senses) and all(s.get("form_of") for s in senses)
    return {"word": word, "found": bool(senses), "formOnly": form_only,
            "formOf": targets("form_of") if form_only else [], "altOf": targets("alt_of"),
            "pos": sorted({e.get("pos", "") for e in entries}),
            "senseTags": [sorted(s.get("tags", [])) for s in senses]}


def load_jsonl(path):
    if not path.exists():
        return {}
    rows = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]
    return {row["word"]: row for row in rows}


def all_senses_tagged(row, tags):
    """全部の意味に tags のどれかが付いているか。"""
    return bool(row["senseTags"]) and all(tags & set(sense) for sense in row["senseTags"])


def mostly_forms(row):
    """意味の半分以上が活用形か。"""
    return sum("form-of" in sense for sense in row["senseTags"]) * 2 >= len(row["senseTags"])


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith("-"):
        print(__doc__)
        sys.exit(64)
    work = Path(args[0])
    work.mkdir(parents=True, exist_ok=True)

    picked = candidates(fetch_top_words(work))
    print(f"既存リストに無い語 {len(picked)}", flush=True)

    kaikki_path = work / "kaikki.jsonl"
    kaikki = load_jsonl(kaikki_path)
    with kaikki_path.open("a", encoding="utf-8") as f:
        for word in picked:
            if word in kaikki:
                continue
            entry = kaikki_entry(word)
            if entry is not None:
                kaikki[word] = entry
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")
                f.flush()
                if len(kaikki) % 200 == 0:
                    print(f"  引いた {len(kaikki)}", flush=True)
            time.sleep(REQUEST_INTERVAL)

    missing = [w for w in picked if w not in kaikki]
    if missing:
        sys.exit(f"kaikki を引けなかった語が {len(missing)} ある。もう一度実行すると続きから進む")
    not_found = [w for w in picked if not kaikki[w]["found"] and w not in KEEP]
    abbreviation = [w for w in picked if all_senses_tagged(kaikki[w], ABBREVIATION_TAGS) and w not in KEEP]
    avoid = [w for w in picked if all_senses_tagged(kaikki[w], AVOID_TAGS) and w not in abbreviation and w not in KEEP]
    slurs = [w for w in picked if w in SLURS]
    be_have_do = [w for w in picked if w in BE_HAVE_DO_FORMS]
    not_common = [w for w in picked if w in NOT_COMMON_WORDS]
    removed = set(not_found) | set(abbreviation) | set(avoid) | SLURS | BE_HAVE_DO_FORMS | NOT_COMMON_WORDS
    # 指定の綴り間違いや、指定した語が候補に無くなったときに気づけるように止める
    unknown = sorted((KEEP | NOT_COMMON_WORDS) - set(picked)) + sorted(KEEP & removed)
    if unknown:
        sys.exit(f"KEEP・NOT_COMMON_WORDS の語が候補に無い: {', '.join(unknown)}")

    # 順に当てはめ、最初に当たった理由で数える
    ejdict = ejdict_lowercase_headwords()
    rules = [("EJDict に小文字の見出しが無い語", lambda w: w not in ejdict),
             ("意味の半分以上が活用形の語", lambda w: mostly_forms(kaikki[w])),
             ("2 文字の語", lambda w: len(w) == 2),
             ("全部の意味が綴り違いの語", lambda w: all_senses_tagged(kaikki[w], {"alt-of"}))]
    dropped = {name: [] for name, _ in rules}
    kept = []
    for word in picked:
        if word in removed:
            continue
        name = None if word in KEEP else next((name for name, rule in rules if rule(word)), None)
        if name:
            dropped[name].append(word)
        else:
            kept.append(word)

    print(f"kaikki に小文字の見出しが無くて除いた {len(not_found)}: {', '.join(not_found)}")
    print(f"全部の意味が略語で除いた {len(abbreviation)}: {', '.join(abbreviation)}")
    print(f"全部の意味が差別語・古語で除いた {len(avoid)}: {', '.join(avoid)}")
    print(f"差別語の指定で除いた {len(slurs)}: {', '.join(slurs)}")
    print(f"be・have・do の活用形で除いた {len(be_have_do)}: {', '.join(be_have_do)}")
    print(f"人名・地名などの指定で除いた {len(not_common)}: {', '.join(not_common)}")
    for name, words in dropped.items():
        print(f"{name}で除いた {len(words)}: {', '.join(words)}")
    print(f"KEEP で残した {len(KEEP)}")

    header = f"""# wordfreq(英語)の上位 {TOP_COUNT:,} 語のうち、既存の単語リストにも同梱辞書にも無い {len(kept):,} 語。wordfreq の順位順。
#   除くもの: 英小文字以外を含む語・1 文字の語、kaikki(Wiktionary の抽出データ)に小文字の見出しが無い語、
#     kaikki で全部の意味が略語の語、全部の意味に offensive・derogatory・archaic・obsolete のどれかが付く語、
#     指定した差別語、be・have・do の活用形、指定した人名・地名など。vulgar(卑語)は除かない。
#     さらに、EJDict に小文字の見出しが無い語、kaikki で意味の半分以上が活用形の語、2 文字の語、全部の意味が綴り違いの語。
#     ただし単語帳に残すと決めた語(pick_wordfreq.py の KEEP)は、この 4 つと kaikki の見出し・略語・差別語・古語の条件では除かない。
# 出典: Robyn Speer. (2022). rspeer/wordfreq: v3.0 (v3.0.2). Zenodo. https://doi.org/10.5281/zenodo.7199437
#   使った版は wordfreq {WORDFREQ_VERSION}。https://github.com/rspeer/wordfreq
#   wordfreq のデータの元: Google Books Ngrams(http://books.google.com/ngrams)、Leeds Internet Corpus、Wikipedia、
#     ParaCrawl、OPUS OpenSubtitles 2018(OpenSubtitles、http://www.opensubtitles.org/)、
#     SUBTLEX(Marc Brysbaert ほか。自由に入手できるデータ。http://crr.ugent.be/programs-data/subtitle-frequencies)ほか
# ライセンス: wordfreq のコードは Apache License 2.0、データは Creative Commons Attribution-ShareAlike 4.0 International
#   (CC BY-SA 4.0) https://creativecommons.org/licenses/by-sa/4.0/
# 作り方: tool/dictgen/pick_wordfreq.py
"""
    (ROOT / "words/wordfreq.txt").write_text(header + "\n".join(kept) + "\n", encoding="utf-8")
    print(f"採った {len(kept)} → words/wordfreq.txt")


if __name__ == "__main__":
    main()
