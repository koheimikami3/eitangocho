#if os(iOS)
  import GoogleMobileAds
  import SwiftUI
  import UIKit

  /// 広告 1 枠の読み込み・破棄・再試行をまとめた土台(Flutter 版の MobileAdSlot)。
  ///
  /// 3 つの枠(タブバー上・シート内・クイズ結果)で共通するのはここまでで、見た目と置き場所は
  /// `decoration` に任せる。読み込めるまでは、また広告ユニット ID が未設定のときは何も描かない
  /// (先に空の枠を置くと、広告が付かない端末に意味の無い帯が残るため)。ただし `reservesSpace` の枠は、
  /// 読み込みを始めた時点で広告の大きさの空の枠を出す(読み込みが終わってから割り込むと、周りの部品が
  /// 動いて誤タップを招くため)。
  ///
  /// この枠を画面から外せば広告も破棄される(読み込みの状態は `@State` に持つ)。シートに覆われている
  /// 間の消し方は、呼び出し側がそれで表現する。外しても広告を捨てたくない枠(シートに覆われる間の
  /// タブバーのバナー・キーボードで隠れる間のシートのバナー)は、呼び出し側が持つ `MobileAdLoader` を
  /// `loader` に渡す。
  struct MobileAdSlot<Decoration: View>: View {
    /// AdMob の広告ユニット ID。空なら何もしない。
    let adUnitId: String
    /// 枠の幅(装飾の左右の余白を除いた、広告に使える幅)から要求する広告サイズを決める。
    /// nil を返したら枠ごと出さない。
    let resolveSize: (CGFloat) -> AdSize?
    /// 装飾(背景・境界線・余白)の左右の余白。広告に使える幅を出すのに使う。
    var horizontalInset: CGFloat = 0
    /// 表示中の広告の高さの変化。読み込み前・破棄後は nil。枠の高さぶんレイアウトを空けたい側
    /// (タブバー上のバナー)が使う。
    var onHeightChange: (CGFloat?) -> Void = { _ in }
    /// 呼び出し側が持つ読み込み(先読みした広告・枠を外しても捨てない広告)。nil ならこの枠が自分で持つ。
    var loader: MobileAdLoader?
    /// 読み込みを始めた時点で、広告の大きさの空の枠を出しておくか。
    var reservesSpace = false
    /// 読み込めた広告の描画。渡す広告はサイズ確定済みで、背景・境界線・余白は呼び出し側が被せる。
    @ViewBuilder let decoration: (AnyView) -> Decoration

    @Environment(\.ads) private var ads
    @Environment(\.purchase) private var purchase
    @State private var ownLoader = MobileAdLoader()
    @State private var availableWidth: CGFloat?

    private var activeLoader: MobileAdLoader { loader ?? ownLoader }

    var body: some View {
      let active = activeLoader
      Group {
        // Pro を買ったら 3 枠とも即座に消す。次にこの枠が作り直されるまで待っていると、
        // 設定画面から戻るまで買ったはずの広告が残る。
        if purchase?.proUnlocked != true, let size = active.loadedSize, let bannerView = active.bannerView {
          decoration(AnyView(MobileBannerView(bannerView: bannerView).frame(width: size.width, height: size.height)))
        } else if reservesSpace, purchase?.proUnlocked != true, let size = active.requestedSize {
          decoration(AnyView(Color.clear.frame(width: size.width, height: size.height)))
        } else {
          // 幅を測るためだけの高さ 0 の面(読み込む広告のサイズは幅で決まる)。
          Color.clear.frame(height: 0)
        }
      }
      .frame(maxWidth: .infinity)
      .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { availableWidth = $0 }
      // 幅が決まった時点で 1 回だけ読み込む(Flutter 版も最初のフレームの幅でサイズを決めていた)。
      // 読み込みは画面の task に載せない。SwiftUI は同じ枠のまま task を取り消して起こし直すことがあり、
      // SDK の初期化を待つ間に取り消されると広告が出なくなるため(枠が破棄されたら読み込みも止まる)。
      .onChange(of: availableWidth != nil, initial: true) {
        guard let availableWidth, let ads, let purchase else { return }
        let resolveSize = resolveSize
        let adWidth = availableWidth - horizontalInset * 2
        // 渡された読み込みが済んでいる(または読み込み中の)ときは何もしない(`load` が見る)。
        active.load(adUnitId: adUnitId, size: { resolveSize(adWidth) }, ads: ads, purchase: purchase)
      }
      .onChange(of: purchase?.proUnlocked == true) { _, unlocked in
        if unlocked { active.discard() }
      }
      .onChange(of: purchase?.proUnlocked == true ? nil : active.loadedSize?.height, initial: true) { _, height in
        onHeightChange(height)
      }
      .onDisappear { onHeightChange(nil) }
    }
  }

  /// 1 枠ぶんの広告の読み込み(Flutter 版の _MobileAdSlotState)。
  @Observable
  final class MobileAdLoader: NSObject, BannerViewDelegate {
    /// 読み込めた広告のサイズ。読み込み前・破棄後は nil。
    private(set) var loadedSize: CGSize?

    /// 要求中の広告のサイズ。読み込みを始めたときに決まり、再試行を諦めたとき・破棄したときに nil に戻る
    /// (`reservesSpace` の枠が、読み込みの間に空けておく大きさ)。
    private(set) var requestedSize: CGSize?

    /// 読み込みに使う広告のビュー。広告を出すと決まってから作る。`@State` の初期値は枠の View が作り直される
    /// たびに評価されるので、ここで作ると捨てるだけのビューを親の描き直しのたびに作り、Pro の人でも
    /// 広告の SDK に触れることになる。
    @ObservationIgnored private(set) var bannerView: BannerView?

    /// 実行中の読み込み(SDK の初期化待ちを含む)。二重に走らせないために持つ。
    @ObservationIgnored private var loading: Task<Void, Never>?

    /// SDK に広告を要求して、結果を待っている間。先読みした広告を枠が受け取ったとき、
    /// 応答待ちの間にもう 1 回要求しないために持つ(`loading` は SDK に渡した時点で外れる)。
    @ObservationIgnored private var requesting = false

    /// 読み込み失敗後の再試行。通信断は一時的なことが多いのに、1 回失敗したきりだと次に画面が
    /// 作り直されるまでずっと空のままになる。
    @ObservationIgnored private var retry: Task<Void, Never>?
    @ObservationIgnored private var retryCount = 0
    @ObservationIgnored private var reload: (() -> Void)?

    /// 再試行の上限。これを超えたら次にこの枠が作り直されるまで諦める
    /// (在庫切れのときに延々とリクエストを投げても仕方がない)。
    private static let maxRetries = 3

    /// 読み込みを始める。待っている間に枠が画面から外れて破棄されたら、何もせずに終わる(self を弱く持つ)。
    func load(adUnitId: String, size: @escaping () -> AdSize?, ads: AdsController, purchase: PurchaseModel) {
      reload = { [weak self] in
        self?.load(adUnitId: adUnitId, size: size, ads: ads, purchase: purchase)
      }
      guard loadedSize == nil, loading == nil, !requesting else { return }
      guard !adUnitId.isEmpty else {
        adLogger.info("広告ユニット ID が空のためこの枠は出しません")
        return
      }
      // Pro を買った後に作られた枠は、そもそも広告を要求しない。AdsController は一度 true を返すと
      // その値を保つため、購入後の判定はここで行う。
      guard !purchase.proUnlocked else { return }
      // 再試行を待っている間に読み込み直すことになったら(先読みした広告を枠が受け取ったときなど)、
      // 待っている方は取り消す。両方が走ると同じ枠に 2 回要求を投げる。
      retry?.cancel()
      loading = Task { [weak self] in
        let enabled = await ads.isEnabled()
        guard let self else { return }
        loading = nil
        guard enabled, !purchase.proUnlocked else { return }

        // 端末に合うサイズが無ければ広告そのものを諦める(枠も出さない)。
        guard let adSize = size() else {
          adLogger.info("広告サイズを決められませんでした(\(adUnitId, privacy: .public))")
          return
        }
        adLogger.info(
          "読み込み開始: \(adSize.size.width)x\(adSize.size.height) / \(adUnitId, privacy: .public)")
        requestedSize = adSize.size
        requesting = true
        let bannerView = self.bannerView ?? BannerView()
        self.bannerView = bannerView
        bannerView.adUnitID = adUnitId
        bannerView.adSize = adSize
        bannerView.delegate = self
        bannerView.rootViewController = Self.rootViewController()
        bannerView.load(Request())
      }
    }

    /// 読み込み済みの広告を捨て、枠の高さも返す。
    func discard() {
      retry?.cancel()
      loadedSize = nil
      requestedSize = nil
    }

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
      adLogger.info("読み込み成功: \(bannerView.adUnitID ?? "", privacy: .public)")
      requesting = false
      retryCount = 0
      loadedSize = bannerView.adSize.size
    }

    /// 在庫切れ・通信断など。通信断は一時的なことが多いので数回試す。
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
      adLogger.info("読み込み失敗: \(error.localizedDescription, privacy: .public)")
      requesting = false
      scheduleRetry()
    }

    /// 失敗した読み込みを間隔を空けて試し直す(10 秒 → 20 秒 → 40 秒)。
    private func scheduleRetry() {
      guard retryCount < Self.maxRetries else {
        adLogger.info("再試行の上限に達したので諦めます(\(self.bannerView?.adUnitID ?? "", privacy: .public))")
        requestedSize = nil
        return
      }
      let delay = 10 * (1 << retryCount)
      retryCount += 1
      adLogger.info("\(delay) 秒後に再試行します(\(self.retryCount)/\(Self.maxRetries))")
      retry?.cancel()
      retry = Task { [weak self] in
        try? await Task.sleep(for: .seconds(delay))
        guard !Task.isCancelled else { return }
        self?.reload?()
      }
    }

    /// 広告を押したときに開く画面の親。
    private static func rootViewController() -> UIViewController? {
      UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)?
        .rootViewController
    }
  }

  /// 読み込み済みの BannerView を、広告の大きさに固定した入れ物ごと SwiftUI に置く。
  ///
  /// BannerView を直に置くと、画面に載せたときに SwiftUI が大きさを付け直し、SDK がそれを受けて
  /// 広告を取り直す(実測: 画面に載った直後に 2 回目の読み込み成功が届き、先読みした広告が捨てられていた。
  /// 取り直しが「Invalid ad width or height」で失敗すると、枠だけ残って中身が白くなる)。
  /// SwiftUI に大きさを付けさせるのは入れ物だけにし、BannerView の大きさは変えない。
  private struct MobileBannerView: UIViewRepresentable {
    let bannerView: BannerView

    func makeUIView(context: Context) -> UIView {
      let container = UIView()
      bannerView.frame = CGRect(origin: .zero, size: bannerView.adSize.size)
      container.addSubview(bannerView)
      return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
  }

  extension AdSize {
    /// 端末の向きに合わせた通常サイズのアンカー型アダプティブバナー(Flutter 版の
    /// `getCurrentOrientationAnchoredAdaptiveBannerAdSize`)。
    ///
    /// GMA 13 で非推奨になったが、Google が用意する「幅に合わせた小さめのバナー」は今もこれだけ
    /// (大型は端末高の 15% = 実測 118pt あり、常設するには大きすぎる)。非推奨の警告を出さないよう、
    /// 非推奨の宣言を付けた入れ物をプロトコル越しに呼ぶ。SDK から削除されたら、固定の 320x50
    /// (`AdSizeBanner`)か、高さの上限を指定できる `inlineAdaptiveBanner(width:maxHeight:)` に移す。
    static func currentOrientationAnchoredAdaptive(width: CGFloat) -> AdSize {
      (DeprecatedAdSizes.self as any AnchoredAdaptiveAdSizes.Type).currentOrientation(width: width)
    }
  }

  private protocol AnchoredAdaptiveAdSizes {
    static func currentOrientation(width: CGFloat) -> AdSize
  }

  private enum DeprecatedAdSizes: AnchoredAdaptiveAdSizes {
    @available(*, deprecated)
    static func currentOrientation(width: CGFloat) -> AdSize {
      currentOrientationAnchoredAdaptiveBanner(width: width)
    }
  }
#endif
