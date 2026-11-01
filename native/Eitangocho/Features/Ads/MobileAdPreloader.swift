#if os(iOS)
  import Foundation
  import GoogleMobileAds
  import SwiftUI

  /// 広告を、それを出す画面を開く前に読み込んでおく(シートの下端のバナー・クイズ結果のレクタングル)。
  ///
  /// 画面を開いてから読み込むと 1〜2 秒遅れて出て、周りの部品へ伸ばした指の先に広告が来る。
  /// 手前の画面(一覧・出題中)にいる間に 1 枚読み込んでおき、画面を開いたらそれを渡して、次の 1 枚を
  /// 読み込み始める。先読みした分を使わないまま終わることもあるが、それは要求が 1 回むだになるだけ。
  final class MobileAdPreloader {
    private let adUnitId: String
    /// 枠の幅から要求する広告サイズを決める(広告を出す画面と同じ決め方)。
    private let resolveSize: (CGFloat) -> AdSize?

    private var next: (loader: MobileAdLoader, preparedAt: Date)?
    private var context: (width: CGFloat, ads: AdsController, purchase: PurchaseModel)?

    /// 先読みした広告を使う期限。読み込んだまま長く置いた広告は使わない
    /// (Google は全画面広告を読み込みから 1 時間で期限切れとしているので、それに合わせる)。
    private static let maxAge: TimeInterval = 60 * 60

    init(adUnitId: String, resolveSize: @escaping (CGFloat) -> AdSize?) {
      self.adUnitId = adUnitId
      self.resolveSize = resolveSize
    }

    /// 先読みを始める(済んでいれば何もしない)。`width` は広告を出す枠の幅。
    func prepare(width: CGFloat, ads: AdsController, purchase: PurchaseModel) {
      context = (width, ads, purchase)
      fillIfNeeded()
    }

    /// 先読みした広告を受け取る(まだ読み込み中でもよい)。受け取ったら次の 1 枚を読み込み始める。
    /// 先読みが無い・古いときは nil(シートが自分で読み込む)。
    func take() -> MobileAdLoader? {
      defer {
        next = nil
        fillIfNeeded()
      }
      guard let next, Date.now.timeIntervalSince(next.preparedAt) < Self.maxAge else { return nil }
      return next.loader
    }

    private func fillIfNeeded() {
      guard next == nil, let context else { return }
      let loader = MobileAdLoader()
      let resolveSize = resolveSize
      let width = context.width
      // Pro・ユニット ID 未設定・広告を出さない判定のときは、load が何もせずに返る。
      loader.load(adUnitId: adUnitId, size: { resolveSize(width) }, ads: context.ads, purchase: context.purchase)
      next = (loader, .now)
    }
  }

  extension EnvironmentValues {
    /// シートの下端のバナーの先読み。RootView が配る。
    @Entry var sheetBannerPreloader: MobileAdPreloader?
    /// クイズ結果のレクタングルの先読み。RootView が配る。
    @Entry var quizRectanglePreloader: MobileAdPreloader?
  }
#endif
