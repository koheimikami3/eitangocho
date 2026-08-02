import 'package:eitangocho/features/word_registration/domain/word_info.dart';

/// 単語情報の自動取得を抽象化する(将来 LLM 実装への差し替えを可能にするため)。
/// 実装は DictionaryWordInfoProvider(kaikki + Tatoeba + EJDict)。
abstract interface class WordInfoProvider {
  /// 辞書に未収録の場合は null を返す。
  /// ネットワーク等の失敗は [WordInfoException] を投げる。
  Future<WordInfo?> fetch(String word);
}
