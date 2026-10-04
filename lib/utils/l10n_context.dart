import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// `AppLocalizations.of(context)` の短縮形。
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
