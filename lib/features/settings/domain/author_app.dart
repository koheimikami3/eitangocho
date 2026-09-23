/// 設定の「作者の他のアプリ」に出す 1 本ぶんの情報。
///
/// [ReviewConfig] と同じく、コードに直書きする公開値だけを持つ
/// (App Store の ID もアイコンも秘匿する意味が無い)。
final class AuthorApp {
  const AuthorApp({
    required this.name,
    required this.tagline,
    required this.availability,
    required this.appStoreUrl,
    required this.iconAsset,
  });

  /// アプリ名。App Store の掲載名は長いので、通称の方を出す。
  final String name;

  /// 何をするアプリかの 1 行説明。**掲載名の ` - ` 以降をそのまま使う**
  /// (ストアで見た文言と食い違わせない)。
  final String tagline;

  /// 価格と対応端末。どちらも iPhone 専用なので macOS には出さない
  /// (この枠を出すのは iOS だけ)。
  final String availability;

  /// App Store のページ。**`itms-apps://` ではなく https で持つ**:
  /// iOS は universal link で App Store アプリが開き、開けない環境でも
  /// Web ページに落ちるだけで済む。
  final String appStoreUrl;

  /// アイコンはネットワークではなくアセットで持つ。オフラインや読み込み失敗で
  /// 枠が崩れるのを避けるため(実体は先方アプリの AppIcon の縮小版)。
  ///
  /// **ストアの掲載アートワークではなく AppIcon を使う**。Icon Composer を
  /// 採用したアプリはストア側が角丸込みのガラス描画になっていて、カード側の
  /// 角丸と二重になるため。
  final String iconAsset;

  static const subrisu = AuthorApp(
    name: 'サブリス',
    tagline: 'サブスクと固定費をリストで管理',
    availability: '無料 · iPhone',
    appStoreUrl: 'https://apps.apple.com/jp/app/id1661226530',
    iconAsset: 'assets/images/subrisu_icon.png',
  );

  static const metronome = AuthorApp(
    name: 'メトロノーム',
    tagline: '拍子・テンポ・BPM',
    availability: '無料 · iPhone',
    appStoreUrl: 'https://apps.apple.com/jp/app/id6814060706',
    iconAsset: 'assets/images/metronome_icon.png',
  );

  /// 表示順。既存を上、新しく出したものを下に足す。
  static const all = <AuthorApp>[subrisu, metronome];
}
