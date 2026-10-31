#if os(iOS)
  import SwiftUI

  /// iOS 版のボトムシート枠(画面高の 88%・上角丸・左右にアクション付きヘッダ。Flutter 版の MobileSheet)。
  ///
  /// 単語の登録・編集・発音で共通に使う。出すのは `AppOverlay.presentSheet`。
  /// キーボードが出ている間はキーボードの上の高さの 88% にし、キーボードの裏も面の色で埋める
  /// (外側の幕が覗くと、iOS のキーボードの角丸の外側に灰色が見える)。
  struct MobileSheet<Content: View, Footer: View>: View {
    let title: String
    /// ヘッダのタイトルの文字サイズ。発音シートは単語そのものを見出しに出すため大きくする。
    var titleFontSize: CGFloat = 15
    let leftLabel: String
    let onLeft: () -> Void
    /// 右上のアクション(保存など)。nil なら出さない。
    var rightLabel: String?
    var onRight: (() -> Void)?
    /// 中身をスクロール領域に載せるか。フォームは true(既定)。
    /// WebView のように自前で高さいっぱいに広がるものは false にして、余白ごとシートの残り高を渡す。
    var scrollableBody = true
    /// 上端のつまみ(下へスワイプで閉じられる合図)を出すか。閉じるボタンだけで閉じる発音シートは出さない。
    var showGrabber = true
    @ViewBuilder let content: () -> Content
    /// スクロール領域の外側、シート最下部に固定で置くもの(バナー広告。6c で使う)。
    @ViewBuilder var footer: () -> Footer

    @Environment(\.palette) private var palette
    @Environment(\.mobileSheetLayout) private var layout

    /// 画面高に対するシートの高さ(デザインの height:88%)。
    private static var heightFactor: CGFloat { 0.88 }

    var body: some View {
      let shape = UnevenRoundedRectangle(topLeadingRadius: 18, topTrailingRadius: 18)
      VStack(spacing: 0) {
        MobileSheetHeader(
          showGrabber: showGrabber, title: title, titleFontSize: titleFontSize, leftLabel: leftLabel,
          onLeft: onLeft, rightLabel: rightLabel, onRight: onRight)
        if scrollableBody {
          ScrollView {
            content()
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(EdgeInsets(top: 14, leading: 18, bottom: 40, trailing: 18))
              // 何も無いところのタップでキーボードを閉じる。複数行の欄は Return を「完了」にしているが、
              // ほかに閉じる手段が無いと困るため。中身の背面で受けるので、入力欄やボタンのタップは奪わない。
              // スクロールでは閉じない(下の欄を見に行くたびに閉じないように)。
              .background {
                Color.clear
                  .contentShape(Rectangle())
                  .onTapGesture { UIApplication.shared.dismissKeyboard() }
              }
          }
          .scrollDismissesKeyboard(.never)
        } else {
          content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        footer()
      }
      .frame(height: layout.availableHeight * Self.heightFactor)
      .clipShape(shape)
      // 面の色はキーボードの裏まで伸ばす(切り抜きの外に描く)。
      .background(alignment: .top) {
        shape.fill(palette.surface)
          .padding(.bottom, -layout.keyboardHeight)
      }
    }
  }

  extension MobileSheet where Footer == EmptyView {
    init(
      title: String, titleFontSize: CGFloat = 15, leftLabel: String, onLeft: @escaping () -> Void,
      rightLabel: String? = nil, onRight: (() -> Void)? = nil, scrollableBody: Bool = true, showGrabber: Bool = true,
      @ViewBuilder content: @escaping () -> Content
    ) {
      self.init(
        title: title, titleFontSize: titleFontSize, leftLabel: leftLabel, onLeft: onLeft, rightLabel: rightLabel,
        onRight: onRight, scrollableBody: scrollableBody, showGrabber: showGrabber, content: content,
        footer: { EmptyView() })
    }
  }

  /// シートのヘッダ(つまみ・左の文字のボタン・中央のタイトル・右の主ボタン)。下へ引くと閉じる。
  private struct MobileSheetHeader: View {
    let showGrabber: Bool
    let title: String
    let titleFontSize: CGFloat
    let leftLabel: String
    let onLeft: () -> Void
    let rightLabel: String?
    let onRight: (() -> Void)?

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(spacing: 0) {
        if showGrabber { MobileSheetGrabber() }
        // タイトルは左右のボタン幅に影響されず中央に置きたいため重ねる。
        ZStack {
          AppText(title, style: AppTextStyle(size: titleFontSize, weight: .w700))
            .foregroundStyle(palette.text)
          HStack(spacing: 0) {
            MobilePressable(style: .text, action: onLeft) {
              AppText(leftLabel, style: AppTextStyle(size: 15))
                .foregroundStyle(palette.accentOnSoft)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
            Spacer(minLength: 0)
            // 確定操作(登録・保存)は文字ではなくピル形の主ボタンにする。
            if let rightLabel, let onRight {
              MobileFilledButton(
                label: rightLabel, fontSize: 14, weight: .w700,
                padding: EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16), cornerRadius: 99, action: onRight)
            }
          }
        }
        .padding(.horizontal, 16)
        .frame(height: showGrabber ? 46 : 50)
      }
      .frame(maxWidth: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle().fill(palette.borderAlpha(6)).frame(height: 1)
      }
      .mobileSheetDragHandle()
    }
  }

  /// シート上端のつまみ(下へスワイプで閉じられる合図)。並び替えシートのように MobileSheet を使わないシートでも出す。
  struct MobileSheetGrabber: View {
    @Environment(\.palette) private var palette

    var body: some View {
      Capsule()
        .fill(palette.borderAlpha(12))
        .frame(width: 36, height: 5)
        .padding(.top, 7)
    }
  }

  extension UIApplication {
    /// 今の入力欄のフォーカスを外してキーボードを閉じる。
    func dismissKeyboard() {
      sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
  }
#endif
