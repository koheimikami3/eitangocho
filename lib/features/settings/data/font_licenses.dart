import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 同梱フォントのライセンスを [LicenseRegistry] に登録する。
///
/// 出典の表示だけで足りる辞書・例文データ(registerDataSourceLicenses)と
/// 違い、SIL Open Font License はフォントと一緒に著作権表示と本文を配布する
/// ことが条件なので、各フォントの OFL.txt をアセットに持って全文を載せる。
/// 見出しはフォント名(pubspec の family ではなく正式な書体名)。
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in const [
      ('Inter', 'Inter-OFL.txt'),
      ('Noto Sans JP', 'NotoSansJP-OFL.txt'),
      ('Noto Sans TC', 'NotoSansTC-OFL.txt'),
      ('Andika', 'Andika-OFL.txt'),
    ]) {
      final text = await rootBundle.loadString('assets/fonts/licenses/$file');
      yield LicenseEntryWithLineBreaks([name], text);
    }
  });
}
