#if os(iOS)
  import SwiftUI
  import UIKit

  /// 設定の「作者の他のアプリ」の 1 行。押すと App Store を開く(Flutter 版の MobileAuthorAppRow)。
  ///
  /// カードの地・角丸・影・行の間の区切り線は MobileSettingsSection が持つ。
  struct MobileAuthorAppRow: View {
    let app: AuthorApp

    @Environment(\.palette) private var palette
    @Environment(\.openURL) private var openURL
    @Environment(\.analytics) private var analytics

    var body: some View {
      MobilePressable(style: .row, action: open) { pressed in
        HStack(spacing: 12) {
          icon
          VStack(alignment: .leading, spacing: 2) {
            AppText(app.name, style: AppTextStyle(size: 15, weight: .w600))
              .foregroundStyle(palette.text)
            AppText(app.tagline, style: AppTextStyle(size: 12, height: 1.4))
              .foregroundStyle(palette.textAlpha(45))
            AppText(app.availability, style: AppTextStyle(size: 11))
              .foregroundStyle(palette.textAlpha(40))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          getLabel
        }
        // 左右 14 は MobileSettingsDivider と同じ。区切り線を行に揃える。
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(pressed ? palette.pressBackground : .clear)
      }
    }

    private var icon: some View {
      let shape = RoundedRectangle(cornerRadius: 12)
      return Group {
        if let image = UIImage(named: app.iconName) {
          Image(uiImage: image).resizable()
        } else {
          Color.clear
        }
      }
      .frame(width: 52, height: 52)
      .clipShape(shape)
      // 枠線は角丸の内側に重ねて引く。明るいアイコンがカードの地に溶けないよう縁を作るのが目的で、
      // 外側に足すと 52 の見た目が狂う。
      .overlay(shape.strokeBorder(palette.borderAlpha(10), lineWidth: 1))
    }

    /// 「入手」は App Store のボタンに合わせた見た目のラベルで、ボタンではない(押せるのは行全体)。
    private var getLabel: some View {
      AppText(.getApp, style: AppTextStyle(size: 13, weight: .w700))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Capsule().fill(palette.buttonFill))
        .appShadows(palette.buttonShadow, in: Capsule(), scale: 1)
    }

    /// App Store を外で開く(https の universal link で App Store アプリに渡る)。
    private func open() {
      analytics.logAuthorAppTapped(app.name)
      openURL(app.appStoreURL)
    }
  }
#endif
