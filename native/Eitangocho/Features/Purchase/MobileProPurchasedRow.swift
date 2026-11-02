#if os(iOS)
  import SwiftUI

  /// 設定画面の Pro の欄の購入後の 1 行(「Pro 版」+ お礼 + 押せない「購入済み」)。
  ///
  /// 購入を復元は出さない。復元が要るのは購入が消えて未購入に見えている人で、その人には MobileProOffer が出るため。
  struct MobileProPurchasedRow: View {
    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 8) {
        VStack(alignment: .leading, spacing: 3) {
          AppText(.proPurchasedTitle, style: AppTextStyle(size: 14))
            .foregroundStyle(palette.text)
          AppText(.proPurchasedThanks, style: AppTextStyle(size: 12))
            .foregroundStyle(palette.textAlpha(45))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        AppText(.purchased, style: AppTextStyle(size: 13, weight: .w600))
          .foregroundStyle(palette.proButtonDoneForeground)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(RoundedRectangle(cornerRadius: 9).fill(palette.proButtonDone))
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 13)
    }
  }
#endif
