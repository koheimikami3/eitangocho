#if os(iOS)
  import SwiftUI
  import WebKit

  /// iOS 版の発音確認シート。Google 翻訳をアプリ内の WebView で開く(Flutter 版の showMobilePronunciationSheet)。
  ///
  /// 単語の編集シートと同じ枠(MobileSheet)に載せる。外部ブラウザに飛ばすと学習が途切れるため、確認はアプリ内で完結させる。
  struct MobilePronunciationSheet: View {
    let word: String
    let url: URL
    let dismiss: () -> Void

    var body: some View {
      // WebView 自身が残りの高さいっぱいに広がるため、スクロールの枠には載せない。
      // 閉じるボタンだけで閉じるので、つまみは出さない(デザインどおり)。
      MobileSheet(
        title: word, titleFontSize: 17, leftLabel: String(localized: .close), onLeft: dismiss, scrollableBody: false,
        showGrabber: false
      ) {
        MobilePronunciationWebView(url: url)
      }
    }
  }

  /// 発音確認用の WebView(Flutter 版の MobilePronunciationWebView)。読み込み中は面の色で覆い、
  /// 最初の表示の前に失敗したら、その場で引き直せる画面を出す。
  private struct MobilePronunciationWebView: View {
    let url: URL

    @Environment(\.palette) private var palette
    @State private var load = PronunciationPageLoad()
    /// 引き直すたびに上げて、WebView に読み込み直させる。
    @State private var reloadCount = 0

    var body: some View {
      if load.hasError {
        VStack(spacing: 16) {
          AppText(.pageLoadFailed, style: AppTextStyle(size: 13, height: 1.6))
            .foregroundStyle(palette.textAlpha(60))
            .multilineTextAlignment(.center)
          // 一時的な失敗で閉じ直させないよう、その場で引き直せるようにする。
          AppText(.reload, style: AppTextStyle(size: 14, weight: .w600))
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture(perform: reload)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        WebView(url: url, reloadCount: reloadCount, load: $load)
          .overlay {
            if load.isLoading {
              // 読み込み中は白紙が見えるため、面の色で覆ってインジケータを出す。
              palette.surface
                .overlay { CircularProgress(color: palette.accent) }
            }
          }
      }
    }

    private func reload() {
      load.reload()
      reloadCount += 1
    }
  }

  private struct WebView: UIViewRepresentable {
    let url: URL
    let reloadCount: Int
    @Binding var load: PronunciationPageLoad

    func makeCoordinator() -> Coordinator { Coordinator(load: $load) }

    func makeUIView(context: Context) -> WKWebView {
      // Google 翻訳は JavaScript 無しでは発音ボタンも訳文も出ない(WKWebView の既定で有効)。
      let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
      webView.navigationDelegate = context.coordinator
      webView.load(URLRequest(url: url))
      context.coordinator.loadedCount = reloadCount
      return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
      guard context.coordinator.loadedCount != reloadCount else { return }
      context.coordinator.loadedCount = reloadCount
      webView.load(URLRequest(url: url))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
      @Binding var load: PronunciationPageLoad
      var loadedCount = 0

      init(load: Binding<PronunciationPageLoad>) {
        _load = load
      }

      func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        load.started()
      }

      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        load.finished()
      }

      func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        load.failed(error)
      }

      func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error
      ) {
        load.failed(error)
      }
    }
  }
#endif
