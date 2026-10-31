#if os(macOS)
  import SwiftUI

  /// macOS 版のライセンス一覧のダイアログ(Flutter 版の showLicenseDialog)。
  ///
  /// iOS はプッシュ遷移だが macOS はダイアログ(デザインどおり)。全文は別の画面にせず、
  /// 同じダイアログの中で一覧と入れ替える(ウィンドウ全体を覆う遷移を挟むと設定画面から遠くなるため)。
  struct LicenseDialog: View {
    let dismiss: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    /// 全文を表示中の項目。nil なら一覧。
    @State private var selected: LicenseItem?
    @State private var items: Result<[LicenseItem], Error> = Result { try LicenseCatalog.load() }

    var body: some View {
      AppDialogSurface(cornerRadius: 13, verticalInset: 40) {
        VStack(spacing: 0) {
          header
          // 中身が短ければその高さに縮め、ウィンドウに収まらなければスクロールする(Flutter の shrinkWrap)。
          ViewThatFits(in: .vertical) {
            content
            ScrollView { content }
          }
        }
        .frame(maxWidth: px(520))
      }
    }

    private var header: some View {
      HStack(spacing: px(8)) {
        AppText(selected?.name ?? String(localized: .licenses), style: AppTextStyle(size: 14, weight: .w700))
          .foregroundStyle(colors.textPrimary)
          .lineLimit(1)
          .frame(maxWidth: .infinity, alignment: .leading)
        // 全文の表示中だけ「戻る」を出す。
        if selected != nil {
          button(String(localized: .back)) { selected = nil }
        }
        button(String(localized: .close), action: dismiss)
      }
      // 下の線の太さの分は下の余白に足す(Flutter の Container は枠線の幅を内側の余白に足す)。
      .padding(EdgeInsets(top: px(14), leading: px(18), bottom: px(14 + 1), trailing: px(18)))
      .overlay(alignment: .bottom) {
        Rectangle().fill(colors.border).frame(height: px(1))
      }
    }

    private func button(_ label: String, action: @escaping () -> Void) -> some View {
      AppOutlinedButton(
        label: label, verticalPadding: 6, fontSize: 13, fontWeight: .w400, borderRadius: 7, action: action)
    }

    @ViewBuilder
    private var content: some View {
      if let selected {
        LicenseText(item: selected)
      } else {
        switch items {
        case .success(let items):
          VStack(spacing: 0) {
            ForEach(items) { item in
              LicenseRow(item: item) { selected = item }
            }
          }
        case .failure:
          AppText(.licenseLoadFailed, style: AppTextStyle(size: 13))
            .foregroundStyle(colors.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(px(18))
        }
      }
    }
  }

  private struct LicenseRow: View {
    let item: LicenseItem
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: px(2)) {
          AppText(item.name, style: AppTextStyle(size: 14))
            .foregroundStyle(colors.textPrimary)
          AppText(item.summary ?? String(localized: .licenseCount(item.texts.count)), style: AppTextStyle(size: 12))
            .foregroundStyle(colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        AppText("›", style: AppTextStyle(size: 14, height: 1))
          .foregroundStyle(colors.textDisabled)
      }
      .padding(EdgeInsets(top: px(12), leading: px(18), bottom: px(12 + 1), trailing: px(18)))
      .background(isHovered ? colors.inputBackground : .clear)
      .overlay(alignment: .bottom) {
        Rectangle().fill(colors.border).frame(height: px(1))
      }
      .hoverTap($isHovered, in: Rectangle(), action: action)
      .pointerStyle(.link)
    }
  }

  /// ライセンスの全文。複数あるときは区切り線を挟む。文字は選んでコピーできる。
  private struct LicenseText: View {
    let item: LicenseItem

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        ForEach(Array(item.texts.enumerated()), id: \.offset) { index, text in
          if index > 0 {
            Rectangle().fill(colors.border).frame(height: px(1)).padding(.vertical, px(18))
          }
          AppText(text, style: AppTextStyle(size: 12, height: 1.7))
            .foregroundStyle(colors.textSecondary)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .padding(px(18))
    }
  }
#endif
