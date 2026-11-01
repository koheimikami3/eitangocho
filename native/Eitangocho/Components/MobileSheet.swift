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
    /// 左上の丸いボタンの読み上げの名前(「キャンセル」「戻る」など)。
    let leftLabel: String
    /// 左上の丸いボタンの絵柄(閉じる ✕ / 戻る ‹)。
    var leftIcon: MobileSheetLeftIcon = .close
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
          title: title, titleFontSize: titleFontSize, showGrabber: showGrabber, leftLabel: leftLabel,
          leftIcon: leftIcon, onLeft: onLeft, rightLabel: rightLabel, onRight: onRight)
        if scrollableBody {
          ScrollView {
            content()
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(EdgeInsets(top: 14, leading: 18, bottom: 40, trailing: 18))
              // 何も無いところのタップでキーボードを閉じる。複数行の欄は Return を「完了」にしているが、
              // ほかに閉じる手段が無いと困るため。スクロールでは閉じない(下の欄を見に行くたびに閉じないように)。
              .background { KeyboardDismissTapArea() }
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
      title: String, titleFontSize: CGFloat = 15, leftLabel: String, leftIcon: MobileSheetLeftIcon = .close,
      onLeft: @escaping () -> Void, rightLabel: String? = nil, onRight: (() -> Void)? = nil,
      scrollableBody: Bool = true, showGrabber: Bool = true, @ViewBuilder content: @escaping () -> Content
    ) {
      self.init(
        title: title, titleFontSize: titleFontSize, leftLabel: leftLabel, leftIcon: leftIcon, onLeft: onLeft,
        rightLabel: rightLabel, onRight: onRight, scrollableBody: scrollableBody, showGrabber: showGrabber,
        content: content, footer: { EmptyView() })
    }
  }

  /// シート左上の丸いボタンの絵柄。
  enum MobileSheetLeftIcon {
    /// シートを閉じる(キャンセル・閉じる)。
    case close
    /// シートの中で前の段階へ戻る(登録シートのフォーム → 単語の入力)。閉じると誤解されないよう ✕ にしない。
    case back

    var systemName: String {
      switch self {
      case .close: "xmark"
      case .back: "chevron.left"
      }
    }
  }

  /// シートのヘッダ(つまみ・左の丸いボタン・中央のタイトル・右の主ボタン)。下へ引くと閉じる。
  /// MobileSheet を使わない並び替えのシートも、左右のボタンなしでこれを使う(見た目を登録・編集シートに揃える)。
  ///
  /// 左右のボタンは、ヘッダ右上の 🔍・＋ と同じ Liquid Glass にする(2026-11-01 のユーザーの要望。
  /// Flutter 版は左が文字のボタン、右がピル形の主ボタン)。iOS 18 の代わりの見た目も 🔍・＋ と同じ。
  struct MobileSheetHeader: View {
    let title: String
    var titleFontSize: CGFloat = 15
    var showGrabber = true
    /// 左上の丸いボタンの読み上げの名前。nil ならボタンを出さない。
    var leftLabel: String?
    var leftIcon: MobileSheetLeftIcon = .close
    var onLeft: (() -> Void)?
    var rightLabel: String?
    var onRight: (() -> Void)?

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(spacing: 0) {
        if showGrabber { MobileSheetGrabber() }
        // タイトルは左右のボタン幅に影響されず中央に置きたいため重ねる。
        ZStack {
          AppText(title, style: AppTextStyle(size: titleFontSize, weight: .w700))
            .foregroundStyle(palette.text)
          HStack(spacing: 0) {
            if let leftLabel, let onLeft {
              MobileGlassCircleButton(systemName: leftIcon.systemName, accessibilityLabel: leftLabel, action: onLeft)
            }
            Spacer(minLength: 0)
            // 確定操作(登録・保存)は、何が起きるかが分かるよう ✓ の丸にせず文字のまま主ボタンにする。
            if let rightLabel, let onRight {
              MobileGlassCapsuleButton(label: rightLabel, action: onRight)
            }
          }
        }
        .padding(.horizontal, 16)
        .frame(height: rowHeight)
        // つまみの無いシート(発音)は、丸いボタンがシートの上端に付かないよう上を空ける。
        .padding(.top, !showGrabber && hasButtons ? 6 : 0)
      }
      .frame(maxWidth: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle().fill(palette.borderAlpha(6)).frame(height: 1)
      }
      .mobileSheetDragHandle()
    }
  }

  extension MobileSheetHeader {
    private var hasButtons: Bool { leftLabel != nil || rightLabel != nil }

    /// タイトルの行の高さ。丸いボタン(44pt)があるときは上下に 6pt ずつ空ける。
    /// ボタンの無い並び替えのシートは Flutter 版の高さのまま。
    private var rowHeight: CGFloat {
      if hasButtons { return MobileGlassCircleButton.diameter + 12 }
      return showGrabber ? 46 : 50
    }
  }

  /// シート上端のつまみ(下へスワイプで閉じられる合図)。
  private struct MobileSheetGrabber: View {
    @Environment(\.palette) private var palette

    var body: some View {
      Capsule()
        .fill(palette.borderAlpha(12))
        .frame(width: 36, height: 5)
        .padding(.top, 7)
    }
  }

  /// 押されたらキーボードを閉じる、中身の背面に敷く面。
  ///
  /// SwiftUI の onTapGesture を背面に置くと、入力欄の上のタップまで拾ってフォーカスを外してしまう
  /// (入力欄は SwiftUI の側では押せる物として扱われないため)。UIKit の面に認識器を付ければ、
  /// 入力欄・ボタンの上のタップはその面に届かないので、何も無いところのタップだけを拾える。
  private struct KeyboardDismissTapArea: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
      let view = UIView()
      let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
      tap.cancelsTouchesInView = false
      view.addGestureRecognizer(tap)
      return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject {
      @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        recognizer.view?.window?.endEditing(true)
      }
    }
  }
#endif
