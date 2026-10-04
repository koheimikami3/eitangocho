import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/utils/app_locale.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'translation_language_provider.g.dart';

/// 今の訳の言語。項目名(「日本語訳」など)や取得元の切り替えはここから引く。
///
/// 設定のロード前も端末の言語から決めた既定を返す。SettingsState の既定値
/// (ja)にフォールバックすると、繁体字の利用者に一瞬「日本語訳」が出るため。
@riverpod
TranslationLanguage translationLanguage(Ref ref) =>
    ref.watch(settingsProvider.select((s) => s.value?.translationLanguage)) ??
    AppLocale.deviceDefaultTranslationLanguage;
