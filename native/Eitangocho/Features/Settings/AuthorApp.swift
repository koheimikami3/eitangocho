import Foundation

/// 設定の「作者の他のアプリ」に出す 1 本ぶんの情報(Flutter 版の AuthorApp)。
///
/// ReviewConfig と同じく、コードに直書きする公開値だけを持つ(App Store の ID もアイコンも秘匿する意味が無い)。
/// 紹介先はどちらも iPhone 専用なので、この枠を出すのは iOS だけ。
/// どちらも日本語だけのアプリなので、出すのは日本語の画面のときだけ(SettingsViewMobile)。
struct AuthorApp: Equatable, Identifiable, Sendable {
  /// アプリ名。App Store の掲載名は長いので、通称の方を出す。計測(author_app_tapped の app)にもこの名前を送る。
  let name: String
  /// 何をするアプリかの 1 行の説明。**掲載名の ` - ` 以降をそのまま使う**(ストアで見た文言と食い違わせない)。
  let tagline: String
  /// 価格と対応端末。
  let availability: String
  /// App Store のページ。**`itms-apps://` ではなく https で持つ**: iOS は universal link で App Store アプリが開き、
  /// 開けない環境でも Web ページに落ちるだけで済む。
  let appStoreURL: URL
  /// 同梱のアイコンの名前(`Resources/AuthorApps/`)。オフラインや読み込みの失敗で枠が崩れないよう、
  /// ネットワークではなく同梱で持つ。**ストアの掲載のアートワークではなく AppIcon を使う**
  /// (Icon Composer のアプリはストア側が角丸込みのガラスの絵になっていて、行の角丸と二重になるため)。
  let iconName: String

  var id: String { name }

  static let subrisu = AuthorApp(
    name: "サブリス",
    tagline: "サブスクと固定費をリストで管理",
    availability: "無料 · iPhone",
    appStoreURL: URL(string: "https://apps.apple.com/jp/app/id1661226530")!,
    iconName: "subrisu_icon")

  static let metronome = AuthorApp(
    name: "メトロノーム",
    tagline: "拍子・テンポ・BPM",
    availability: "無料 · iPhone",
    appStoreURL: URL(string: "https://apps.apple.com/jp/app/id6814060706")!,
    iconName: "metronome_icon")

  /// 表示順。既存を上、新しく出したものを下に足す。
  static let all = [subrisu, metronome]
}
