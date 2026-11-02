#if os(iOS)
  import SwiftUI

  /// 設定画面の Pro の欄の未購入のときの中身(見出し + 手に入るものの一覧 + 一言 + 購入ボタン + 購入を復元)。
  ///
  /// 「開発者へのコーヒーの差し入れ」ではなく「Pro 版」を主役にし、手に入るものをチェック付きで並べる
  /// (2.14.0 でテーマカラーが加わり、広告を消すだけの買い物ではなくなったため)。差し入れの温かさは薄字の一言にだけ残す。
  /// 購入ボタンは幅いっぱいで下に置く(箇条書きに行の幅を使わせ、仏語などの長い訳でも折り返しにくくするため)。
  struct MobileProOffer: View {
    let purchase: PurchaseModel

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 6) {
          Image(systemName: "star.fill")
            .font(.system(size: 15))
            .foregroundStyle(palette.accent)
          AppText(.proUpgradeTitle, style: AppTextStyle(size: 15, weight: .w700))
            .foregroundStyle(palette.text)
        }
        Spacer().frame(height: 8)
        VStack(alignment: .leading, spacing: 4) {
          MobileProFeatureRow(label: String(localized: .proFeatureNoAds), upcoming: false)
          MobileProFeatureRow(
            label: String(localized: .proFeatureThemeColors(ThemeColor.allCases.count)), upcoming: false)
          // 機能が増えることだけを伝え、この買い切りに含めるとは約束しない(将来の別売りの余地を残す)。
          // 機能を足したら、この行の上に 1 行増やす。
          MobileProFeatureRow(label: String(localized: .proFeatureMore), upcoming: true)
        }
        Spacer().frame(height: 10)
        note
        Spacer().frame(height: 12)
        MobileProPurchaseButton(
          priceText: purchase.priceText, purchasing: purchase.purchasing,
          // 価格が引けていない = 商品を取得できていないので押させない。
          action: purchase.priceText == nil ? nil : { Task { await purchase.buy() } })
        MobileProRestoreLink(purchase: purchase)
      }
      .multilineTextAlignment(.leading)
      .padding(EdgeInsets(top: 14, leading: 14, bottom: 2, trailing: 14))
    }

    /// 箇条書きの下の一言。購入の失敗は一時的にこの一言を置き換えて出す。
    @ViewBuilder
    private var note: some View {
      if purchase.purchaseFailed {
        AppText(.purchaseFailed, style: AppTextStyle(size: 12))
          .foregroundStyle(palette.danger)
      } else {
        AppText(.proCoffeeNote, style: AppTextStyle(size: 12))
          .foregroundStyle(palette.textAlpha(45))
      }
    }
  }

  /// 手に入るものの 1 行。今使える機能はチェック、予定の行は点線の丸に「+」と薄めの文字で見分ける。
  private struct MobileProFeatureRow: View {
    let label: String
    let upcoming: Bool

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 7) {
        ZStack {
          if upcoming {
            Circle().strokeBorder(palette.accent, style: StrokeStyle(lineWidth: 1.3, dash: [2, 1.6]))
            Image(systemName: "plus")
              .font(.system(size: 7.5, weight: .bold))
              .foregroundStyle(palette.accent)
          } else {
            Circle().fill(palette.accent)
            Image(systemName: "checkmark")
              .font(.system(size: 7.5, weight: .bold))
              .foregroundStyle(.white)
          }
        }
        .frame(width: 15, height: 15)
        AppText(label, style: AppTextStyle(size: 13))
          .foregroundStyle(upcoming ? palette.textAlpha(55) : palette.text)
      }
    }
  }

  /// 幅いっぱいの購入ボタン(「買い切り ¥300 で購入」→ 処理中)。価格を引けなければグレーで押せない。
  private struct MobileProPurchaseButton: View {
    let priceText: String?
    let purchasing: Bool
    let action: (() -> Void)?

    @Environment(\.palette) private var palette

    /// 処理中のインジケータの直径。
    private static let indicatorSize: CGFloat = 16

    var body: some View {
      let enabled = !purchasing && action != nil
      // 押せる間と処理中はアクセント色のまま。価格を引けずに押せないときだけグレーに落とす。
      let filled = enabled || purchasing
      let style = AppTextStyle(size: 14, weight: .w600)
      let label: LocalizedStringResource =
        if let priceText { .buyOneTime(priceText) } else { .priceUnavailable }
      MobilePressable(action: enabled ? action : nil) {
        let shape = RoundedRectangle(cornerRadius: 11)
        // 処理中もボタンの高さを変えないよう、文字を見えないまま残してインジケータを重ねる。
        ZStack {
          AppText(label, style: style)
            .foregroundStyle(filled ? .white : palette.proButtonDoneForeground)
            .opacity(purchasing ? 0 : 1)
          if purchasing {
            // App Store のダイアログが出るまでの待ちを埋める。
            CircularProgress(color: .white, size: Self.indicatorSize, lineWidth: 2)
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background {
          if filled {
            shape.fill(palette.buttonFill)
          } else {
            shape.fill(palette.proButtonDone)
          }
        }
        .appShadows(filled ? palette.buttonShadow : [], in: shape, scale: 1)
      }
    }
  }

  /// 購入ボタンの下の「購入を復元」の文字リンク(Flutter 版の MobileProRestoreRow)。
  ///
  /// 機種変更・再インストールで購入が消えた人のための導線。復元の状況(確認中…・復元しました など)は、
  /// しばらくリンクの文字を置き換えて出す。
  private struct MobileProRestoreLink: View {
    let purchase: PurchaseModel

    @Environment(\.palette) private var palette

    var body: some View {
      MobilePressable(style: .text, action: purchase.restoring ? nil : { Task { await purchase.restore() } }) {
        Group {
          if let status = purchase.restoreStatus {
            AppText(Self.label(status), style: AppTextStyle(size: 13))
              .foregroundStyle(palette.textAlpha(45))
          } else {
            // 13pt の文字でもカード地に対して 4.5:1 を満たす accentOnSoft にする(accent のままだと足りない)。
            AppText(.restorePurchases, style: AppTextStyle(size: 13))
              .foregroundStyle(palette.accentOnSoft)
          }
        }
        .frame(maxWidth: .infinity)
        // 文字だけでは押しにくいので、上下に余白を足してタップ領域を広げる。
        .padding(.vertical, 10)
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
#endif
