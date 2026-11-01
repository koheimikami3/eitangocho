import Foundation
import OSLog

/// AdMob の広告ユニット ID(Flutter 版の AdUnitIds と同じ値)。配置ごとに 1 つ作る。
///
/// 広告 ID をコードに直書きしているのは、DeepL の API キーと性質が違うため。広告 ID は AdMob の
/// 管理画面が発行する公開値で、秘匿する意味も、設定画面から入力させる意味も無い
/// (実際に配信されるアプリはバンドル ID で照合される)。
///
/// 配置ごとに分けるのは、レポート・自動更新の間隔・eCPM の下限・配信停止がすべてユニット単位だから。
/// 1 つを使い回すと、どの枠が稼いでいるのか後から分けられない。
enum AdUnitIds {
  /// タブバーの上に常設するアンカー型アダプティブバナー。
  static var tabBarBanner: String { isDebug ? testBanner : releaseTabBarBanner }

  /// 登録シート・編集シートの最下部に出すアンカー型アダプティブバナー。
  static var sheetBanner: String { isDebug ? testBanner : releaseSheetBanner }

  /// クイズ結果に出す 300x250 レクタングル。
  static var quizRectangle: String { isDebug ? testRectangle : releaseQuizRectangle }

  /// 登録シートの単語の入力・読み込み中に出す 300x250 レクタングル。
  static var registrationRectangle: String { isDebug ? testRectangle : releaseRegistrationRectangle }

  /// 1 つでも配線済みのユニットがあるか。全部空なら SDK にも触れない。
  static var hasAnyUnit: Bool {
    !tabBarBanner.isEmpty || !sheetBanner.isEmpty || !quizRectangle.isEmpty || !registrationRectangle.isEmpty
  }

  private static var isDebug: Bool {
    #if DEBUG
      true
    #else
      false
    #endif
  }

  /// Debug は Google 公式のテスト ID を使う。開発中に本番ユニットを叩くと無効なトラフィックと
  /// みなされ、AdMob アカウントごと停止されうるため。
  private static let testBanner = "ca-app-pub-3940256099942544/2435281174"
  private static let testRectangle = "ca-app-pub-3940256099942544/2934735716"

  /// 本番の ID。AdMob の「バナー(タブバー上)」ユニット。
  private static let releaseTabBarBanner = "ca-app-pub-3768273762534884/2278462321"
  /// AdMob の「バナー(登録シート)」ユニット。
  private static let releaseSheetBanner = "ca-app-pub-3768273762534884/5497904061"
  /// AdMob の「レクタングル(クイズ結果)」ユニット。
  private static let releaseQuizRectangle = "ca-app-pub-3768273762534884/2121765839"
  /// AdMob の「レクタングル(登録シート)」ユニット。
  private static let releaseRegistrationRectangle = "ca-app-pub-3768273762534884/4408267767"
}

/// 広告まわりのログ(Flutter 版の adLog)。広告は「出ない」が正常系(在庫切れ・SDK 未初期化・ID 未設定)と
/// 区別がつかないうえ、動作確認が実機・シミュレータでしかできない。失敗を黙って握ると原因を追う手段が
/// 無くなるため、経路の要所で出す。
let adLogger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "ads")
