import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:eitangocho/features/settings/domain/translation_language.dart';

/// クイズの出題方向。表面に何を出すかを決める(既定は英語 → 訳)。
///
/// 値の名前は訳の言語が日本語だけだった頃のままにしている。shared_preferences に
/// enum 名で保存しているため、変えると既存の設定が既定に戻ってしまう。
enum QuizDirection {
  enToJa,
  jaToEn;

  /// 設定画面の表示用ラベル(「英語 → 日本語」の「日本語」は訳の言語)
  String label(AppLocalizations l10n, TranslationLanguage language) =>
      switch (this) {
        enToJa => l10n.quizDirectionFromEnglish(language.shortLabel(l10n)),
        jaToEn => l10n.quizDirectionToEnglish(language.shortLabel(l10n)),
      };
}
