/// 見出し語(単語・句動詞)の表記ゆれを入口で潰す。
///
/// 前後の空白を落とし、語の間の連続空白を 1 つにまとめる。句動詞を登録
/// できるようにしたことで、`give  up` のように空白を重ねて入力されうる
/// ようになった。そのままだと kaikki のパス(`give  up.jsonl`)が 404 に
/// なり、`give up` と別単語として重複登録もできてしまう。
///
/// 保存・照合の直前で通す前提。`WordDao._matchKey` と
/// `WordExportService._mergeKey`(trim + 小文字化)は同期のマージキー
/// でもあるため触らない。ここで正規化した文字列を渡せば両者はそのまま成立する。
String normalizeHeadword(String word) =>
    word.trim().replaceAll(RegExp(r'\s+'), ' ');
