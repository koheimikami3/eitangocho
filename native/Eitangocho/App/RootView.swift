import SwiftUI

/// 起動の段階に応じて画面を出し分ける。配色と表示倍率はここで設定から配る。
struct RootView: View {
  let model: AppModel

  var body: some View {
    content
      .environment(\.colors, model.settings.appearance.colors)
      #if os(macOS)
        .environment(\.uiScale, UIScale(factor: model.settings.uiScale))
        .frame(minWidth: WindowAppearance.minimumSize.width, minHeight: WindowAppearance.minimumSize.height)
        .onChange(of: model.settings.appearance, initial: true) { _, appearance in
          WindowAppearance.apply(appearance)
        }
      #endif
      .preferredColorScheme(model.settings.appearance == .dark ? .dark : .light)
  }

  @ViewBuilder
  private var content: some View {
    switch model.phase {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .failed(let failure):
      StartupFailureView(failure: failure, model: model)
    case .ready(let session):
      #if DEBUG
        DiagnosticsView(session: session)
      #else
        // 本番の画面は Phase 2 以降で作る。
        Text(verbatim: "\(session.importOutcome)")
      #endif
    }
  }
}
