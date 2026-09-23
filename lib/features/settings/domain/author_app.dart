/// 設定の「作者の他のアプリ」に出す 1 本ぶんの情報。
///
/// [ReviewConfig] と同じく、コードに直書きする公開値だけを持つ定数クラスにする
/// (App Store の ID もアイコンも秘匿する意味が無い)。
abstract final class AuthorApp {
  /// アプリ名。App Store の掲載名は長いので、通称の方を出す。
  static const name = 'サブリス';

  /// 何をするアプリかの 1 行説明。
  static const tagline = 'サブスクと固定費をリストで管理';

  /// 価格と対応端末。iPhone 専用なので macOS には出さない
  /// (この枠を出すのは iOS だけ)。
  static const availability = '無料 · iPhone';

  /// App Store のページ。**`itms-apps://` ではなく https で持つ**:
  /// iOS は universal link で App Store アプリが開き、開けない環境でも
  /// Web ページに落ちるだけで済む。
  static const appStoreUrl = 'https://apps.apple.com/jp/app/id1661226530';

  /// アイコンはネットワークではなくアセットで持つ。オフラインや読み込み失敗で
  /// 枠が崩れるのを避けるため(実体は先方アプリの AppIcon の縮小版)。
  static const iconAsset = 'assets/images/subrisu_icon.png';
}
