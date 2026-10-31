#if os(iOS)
  import SwiftUI

  /// 設定画面「Pro」の購入行(説明 + 価格 + 購入ボタン。Flutter 版の MobileProPurchaseRow)。
  ///
  /// 「開発者へのコーヒーの差し入れ」を主役にし、広告の非表示はそのお礼として見せる。商品(広告の非表示)と
  /// 寄付(差し入れ)を同じ重さで並べると、何を買うのかがぼやけるため。
  struct MobileProPurchaseRow: View {
    let purchase: PurchaseModel

    @Environment(\.palette) private var palette

    var body: some View {
      let done = purchase.proUnlocked
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          AppText(.proCoffeeTitle, style: AppTextStyle(size: 14))
            .foregroundStyle(palette.text)
          Spacer().frame(height: 3)
          if done {
            // 購入済みならお礼の 1 行だけ。価格もお礼の内容(広告の非表示)ももう要らない。
            AppText(.proCoffeeThanks, style: AppTextStyle(size: 12))
              .foregroundStyle(palette.textAlpha(45))
          } else {
            // お礼(広告の非表示)は薄字にしない。薄いと「差し入れるだけ」に見え、何が得られるのかが
            // 伝わらないため。
            AppText(.proCoffeeReward, style: AppTextStyle(size: 12))
              .foregroundStyle(palette.text)
            Spacer().frame(height: 2)
            AppText(note, style: AppTextStyle(size: 12))
              .foregroundStyle(purchase.purchaseFailed ? palette.danger : palette.textAlpha(45))
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // 見出しを 1 行に収めるため、ボタンとの間隔とボタンの左右の余白は他の行より詰めている
        // (ボタンの幅は「購入済み」に合わせて固定のため)。
        Spacer().frame(width: 8)
        MobileProPurchaseButton(
          done: done, purchasing: purchase.purchasing,
          // 価格が引けていない = 商品を取得できていないので押させない。
          action: purchase.priceText == nil ? nil : { Task { await purchase.buy() } })
      }
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 14)
      .padding(.vertical, 13)
    }

    /// 未購入のときの価格の行。失敗メッセージは一時的に価格を置き換える(お礼の行はそのまま残す)。
    private var note: String {
      if purchase.purchaseFailed { return String(localized: .purchaseFailed) }
      guard let priceText = purchase.priceText else { return String(localized: .priceUnavailable) }
      return String(localized: .oneTimePrice(priceText))
    }
  }

  /// 購入ボタン(購入 → 処理中 → 購入済み)。
  private struct MobileProPurchaseButton: View {
    let done: Bool
    let purchasing: Bool
    let action: (() -> Void)?

    @Environment(\.palette) private var palette

    /// 処理中のインジケータの直径。
    private static let indicatorSize: CGFloat = 16

    var body: some View {
      // 購入済み・処理中・商品を引けていないときは押せない。
      let enabled = !done && !purchasing && action != nil
      // 押せる間と処理中は青いまま。押せなくなったらグレーに落とす(購入済みだけでなく、価格を引けなかったときも)。
      let filled = enabled || purchasing
      let style = AppTextStyle(size: 13, weight: .w600)
      MobilePressable(action: enabled ? action : nil) {
        let shape = RoundedRectangle(cornerRadius: 9)
        // 大きさは「購入」「購入済み」・インジケータのうち最も大きいものに固定し、表示の切り替え
        // (購入 → インジケータ → 購入済み)でボタンが伸び縮みしないようにする。どちらの文字が大きいかは
        // 言語や書体で変わるので、見えない文字を重ねて大きさを取る(読み上げからは外す)。
        ZStack {
          Group {
            AppText(.purchase, style: style)
            AppText(.purchased, style: style)
            Color.clear.frame(width: Self.indicatorSize, height: Self.indicatorSize)
          }
          .hidden()
          .accessibilityHidden(true)
          if purchasing {
            // App Store のダイアログが出るまでの待ちを埋める。
            CircularProgress(color: .white, size: Self.indicatorSize, lineWidth: 2)
          } else {
            AppText(done ? .purchased : .purchase, style: style)
              .foregroundStyle(filled ? .white : palette.proButtonDoneForeground)
          }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
          if filled {
            shape.fill(LinearGradient(colors: palette.buttonGradient, startPoint: .top, endPoint: .bottom))
          } else {
            shape.fill(palette.proButtonDone)
          }
        }
        .appShadows(filled ? palette.buttonShadow : [], in: shape, scale: 1)
      }
    }
  }
#endif
