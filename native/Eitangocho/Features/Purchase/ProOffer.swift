#if os(macOS)
  import SwiftUI

  /// macOS 版の設定画面の Pro の欄(2.18.0)。設定の先頭に置く。iOS の MobileProSection と同じく、
  /// 未購入のときは Pro 版で手に入るものの一覧と購入ボタン(ProOffer)、購入後は 1 行のお礼(ProPurchasedRow)に縮める。
  /// 課金を扱えない環境では、呼び出し側が欄ごと出さない。
  struct ProSection: View {
    let purchase: PurchaseModel

    var body: some View {
      SettingsCard {
        if purchase.proUnlocked {
          ProPurchasedRow()
        } else {
          ProOffer(purchase: purchase, source: .settings)
        }
      }
    }
  }

  /// Pro の欄の未購入のときの中身(見出し + 手に入るものの一覧 + 一言 + 購入ボタン + 購入を復元)。
  /// 構成と文言は iOS の MobileProOffer と同じ。macOS には広告が無いので「広告を非表示」の行は出さない。
  ///
  /// Pro 版の案内のダイアログ(ProOfferDialog)でも同じ中身を出す。そのときは `onClose` を渡し、
  /// 一番下の「購入を復元」を「閉じる」に替える(復元は設定画面の Pro の欄からできる)。
  struct ProOffer: View {
    let purchase: PurchaseModel
    /// 計測用(どこに出した欄から購入を始めたか)。
    let source: ProPurchaseSource
    var onClose: (() -> Void)?

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        AppText(.proUpgradeTitle, style: AppTextStyle(size: 14))
          .foregroundStyle(colors.textPrimary)
        Spacer().frame(height: px(8))
        VStack(alignment: .leading, spacing: px(4)) {
          ProFeatureRow(label: String(localized: .proFeatureThemeColors(ThemeColor.allCases.count)), upcoming: false)
          ProFeatureRow(label: String(localized: .proFeatureQuizOptions), upcoming: false)
          // 機能が増えることだけを伝え、この買い切りに含めるとは約束しない(iOS と同じ)。
          ProFeatureRow(label: String(localized: .proFeatureMore), upcoming: true)
        }
        Spacer().frame(height: px(10))
        note
        Spacer().frame(height: px(12))
        ProPurchaseButton(
          priceText: purchase.priceText, purchasing: purchase.purchasing,
          // 価格が引けていない = 商品を取得できていないので押させない。
          action: purchase.priceText == nil ? nil : { Task { await purchase.buy(source: source) } })
        if let onClose {
          ProTextLink(label: String(localized: .close), color: colors.accentOnSoft, action: onClose)
        } else {
          ProRestoreLink(purchase: purchase)
        }
      }
      .multilineTextAlignment(.leading)
      .padding(EdgeInsets(top: px(14), leading: px(14), bottom: px(2), trailing: px(14)))
    }

    /// 箇条書きの下の一言。購入の失敗は一時的にこの一言を置き換えて出す。
    @ViewBuilder
    private var note: some View {
      if purchase.purchaseFailed {
        AppText(.purchaseFailed, style: AppTextStyle(size: 12))
          .foregroundStyle(colors.danger)
      } else {
        AppText(.proCoffeeNote, style: AppTextStyle(size: 12))
          .foregroundStyle(colors.textTertiary)
      }
    }
  }

  /// Pro 版の案内のダイアログ(iOS の MobileProOfferDialog と同じ役割)。鍵付きのテーマカラー・クイズの鍵付きの項目を
  /// 押したときに出し、押してすぐ購入の画面を出して驚かせないよう、一度ここで買うかを選ばせる。買えたら閉じる。
  struct ProOfferDialog: View {
    let purchase: PurchaseModel
    /// 計測用(どこで出した案内から購入を始めたか)。
    let source: ProPurchaseSource
    let dismiss: () -> Void

    @Environment(\.uiScale) private var px

    var body: some View {
      AppDialogSurface(cornerRadius: 13) {
        ProOffer(purchase: purchase, source: source, onClose: dismiss)
          // 欄の余白(上 14・左右 14・下 2)はカードの中の詰めた値なので、ダイアログでは足して広げる(iOS と同じ)。
          .padding(EdgeInsets(top: px(10), leading: px(8), bottom: px(6), trailing: px(8)))
          .frame(width: px(340))
      }
      .onChange(of: purchase.proUnlocked) { _, unlocked in
        if unlocked { dismiss() }
      }
    }

    /// 出す。課金を扱えない環境(SDK キーが未設定・初期化の失敗)では買えないので出さない。
    @MainActor
    static func present(purchase: PurchaseModel?, source: ProPurchaseSource, overlay: AppOverlay?) {
      guard let purchase, purchase.available else { return }
      overlay?.present { dismiss in
        ProOfferDialog(purchase: purchase, source: source, dismiss: dismiss)
      }
    }
  }

  /// Pro の欄の購入後の 1 行(「Pro 版」+ お礼 + 押せない「購入済み」)。iOS の MobileProPurchasedRow と同じ。
  private struct ProPurchasedRow: View {
    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      HStack(spacing: px(8)) {
        VStack(alignment: .leading, spacing: px(3)) {
          AppText(.proPurchasedTitle, style: AppTextStyle(size: 14))
            .foregroundStyle(colors.textPrimary)
          AppText(.proPurchasedThanks, style: AppTextStyle(size: 12))
            .foregroundStyle(colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        AppText(.purchased, style: AppTextStyle(size: 13, weight: .w600))
          .foregroundStyle(colors.disabledButtonForeground)
          .padding(.horizontal, px(12))
          .padding(.vertical, px(7))
          .background(RoundedRectangle(cornerRadius: px(8)).fill(colors.disabledButton))
      }
      .padding(.horizontal, px(14))
      .padding(.vertical, px(12))
    }
  }

  /// 手に入るものの 1 行。今使える機能はチェック、予定の行は点線の丸に「+」と薄めの文字で見分ける。
  private struct ProFeatureRow: View {
    let label: String
    let upcoming: Bool

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      HStack(spacing: px(7)) {
        ZStack {
          if upcoming {
            Circle().strokeBorder(colors.accent, style: StrokeStyle(lineWidth: px(1.3), dash: [px(2), px(1.6)]))
            Image(systemName: "plus")
              .font(.system(size: px(7.5), weight: .bold))
              .foregroundStyle(colors.accent)
          } else {
            Circle().fill(colors.accent)
            Image(systemName: "checkmark")
              .font(.system(size: px(7.5), weight: .bold))
              .foregroundStyle(.white)
          }
        }
        .frame(width: px(15), height: px(15))
        AppText(label, style: AppTextStyle(size: 13))
          .foregroundStyle(upcoming ? colors.textAlpha(55) : colors.textPrimary)
      }
    }
  }

  /// 幅いっぱいの購入ボタン(「買い切り ¥300 で購入」→ 処理中)。価格を引けなければグレーで押せない。
  private struct ProPurchaseButton: View {
    let priceText: String?
    let purchasing: Bool
    let action: (() -> Void)?

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      let enabled = !purchasing && action != nil
      // 押せる間と処理中はアクセント色のまま。価格を引けずに押せないときだけグレーに落とす。
      let filled = enabled || purchasing
      let shape = RoundedRectangle(cornerRadius: px(9))
      let label: LocalizedStringResource =
        if let priceText { .buyOneTime(priceText) } else { .priceUnavailable }
      // 処理中もボタンの高さを変えないよう、文字を見えないまま残してインジケータを重ねる。
      ZStack {
        AppText(label, style: AppTextStyle(size: 14, weight: .w600, height: 1.4))
          .foregroundStyle(filled ? .white : colors.disabledButtonForeground)
          .opacity(purchasing ? 0 : 1)
        if purchasing {
          CircularProgress(color: .white, size: px(14), lineWidth: px(2))
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, px(9))
      .background {
        if filled {
          shape.fill(
            LinearGradient(
              colors: isHovered && enabled ? colors.buttonGradientHover : colors.buttonGradient,
              startPoint: .top, endPoint: .bottom))
        } else {
          shape.fill(colors.disabledButton)
        }
      }
      .appShadows(filled ? colors.buttonShadow : [], in: shape, scale: px.factor)
      .hoverTap($isHovered, in: shape) { if enabled { action?() } }
      .pointerStyle(enabled ? .link : nil)
    }
  }

  /// 購入ボタンの下の「購入を復元」。復元の状況(確認中…・復元しました など)は、しばらく文字を置き換えて出す。
  private struct ProRestoreLink: View {
    let purchase: PurchaseModel

    @Environment(\.colors) private var colors

    var body: some View {
      if let status = purchase.restoreStatus {
        ProTextLink(label: Self.label(status), color: colors.textTertiary, action: nil)
      } else {
        ProTextLink(
          label: String(localized: .restorePurchases), color: colors.accentOnSoft,
          action: purchase.restoring ? nil : { Task { await purchase.restore() } })
      }
    }

    private static func label(_ status: RestoreStatus) -> String {
      switch status {
      case .checking: String(localized: .restoreChecking)
      case .restored: String(localized: .restoreDone)
      case .notFound: String(localized: .restoreNotFound)
      case .failed: String(localized: .restoreFailed)
      }
    }
  }

  /// 欄の一番下の文字のリンク(「購入を復元」・ダイアログの「閉じる」)。文字だけでは押しにくいので上下に余白を足す。
  private struct ProTextLink: View {
    let label: String
    let color: Color
    let action: (() -> Void)?

    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      AppText(label, style: AppTextStyle(size: 13))
        .foregroundStyle(color)
        .underline(isHovered && action != nil)
        .frame(maxWidth: .infinity)
        .padding(.vertical, px(10))
        .hoverTap($isHovered, in: Rectangle()) { action?() }
        .pointerStyle(action != nil ? .link : nil)
    }
  }
#endif
