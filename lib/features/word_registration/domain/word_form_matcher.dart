/// 例文が見出し語(または規則変化形)を実際に含んでいるかを判定する。
///
/// 外部ソースの例文検索はどちらも見出し語と無関係な文を返しうるため、
/// 採用前にこのフィルタを必ず通す:
/// - Tatoeba の検索はステミングするので、`negligible` で検索すると
///   `negligence` / `negligent` の文しか返らないことがある(引用符で
///   囲んでも無効)。`substantial` では `substantiate` の文が混ざる
/// - kaikki の例文は語義ごとに付くため、派生語の項に入った文が混ざる
///
/// 判定は「文中のいずれかのトークンが見出し語の語形集合に一致するか」。
/// 見出し語化(lemmatize)は行わないため、活用形で登録された単語
/// (`looked` 等)は原形の文にマッチしない。単語帳には原形を登録する
/// 前提で割り切っている。
library;

/// [sentence] が [word] またはその規則変化形をトークンとして含むか。
///
/// [word] が `give up` のような句(句動詞・複合語)のときは、**先頭語だけ
/// 規則変化を許し、後続のトークンはその形のまま**文中にあることを求める。
/// 句動詞の後ろに付くのは副詞・前置詞(up / forward / to)で活用しないため。
/// 語順と隣接は問わない: `The wedding was put off.` のように受動態で語順が
/// 変わる文や、`give himself up` のように目的語が割り込む文を落とさないため。
///
/// 先頭語が不規則変化する句(`give up` に対する `He gave up.`)は拾えない。
/// 単語 1 語のときと同じ割り切りで、Tatoeba は候補を複数件取るため
/// 実用上は原形を含む文が残る。
bool containsWordForm(String sentence, String word) {
  final headwordTokens = _tokenize(word).toList();
  if (headwordTokens.isEmpty) return false;

  final sentenceTokens = _tokenize(sentence).toSet();
  final forms = wordForms(headwordTokens.first);
  if (!sentenceTokens.any(forms.contains)) return false;
  return headwordTokens.skip(1).every(sentenceTokens.contains);
}

/// [word] の規則変化形(小文字)。不規則変化は扱わない。
Set<String> wordForms(String word) {
  final base = word.trim().toLowerCase();
  if (base.isEmpty) return const {};

  final forms = {base, '${base}s', '${base}es', '${base}ed', '${base}d',
      '${base}ing'};

  // make → making / made 相当(語尾 e の脱落)
  if (base.endsWith('e') && base.length > 1) {
    final stem = base.substring(0, base.length - 1);
    forms.addAll(['${stem}ing', '${stem}ed']);
  }
  // study → studies / studied
  if (base.endsWith('y') && base.length > 1 && !_isVowel(base[base.length - 2])) {
    final stem = base.substring(0, base.length - 1);
    forms.addAll(['${stem}ies', '${stem}ied']);
  }
  // drag → dragged / dragging(短母音 + 子音で終わる語の子音重ね)
  if (base.length > 2 &&
      !_isVowel(base[base.length - 1]) &&
      base[base.length - 1] != 'y' &&
      _isVowel(base[base.length - 2]) &&
      !_isVowel(base[base.length - 3])) {
    final doubled = base + base[base.length - 1];
    forms.addAll(['${doubled}ed', '${doubled}ing']);
  }
  return forms;
}

/// 文を小文字のトークン列に分解する。空白とハイフンで区切り、前後の
/// 約物を落とす(`well-known` は well / known に割れて後者が拾える)。
/// 語中のアポストロフィは残す(`don't` を don で切らない)。
Iterable<String> _tokenize(String sentence) sync* {
  for (final raw in sentence.toLowerCase().split(RegExp(r"[^a-z']+"))) {
    final token = raw.replaceAll(RegExp(r"^'+|'+$"), '');
    if (token.isNotEmpty) yield token;
  }
}

bool _isVowel(String c) => 'aeiou'.contains(c);
