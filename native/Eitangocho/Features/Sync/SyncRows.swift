#if os(macOS)
  import EitangochoSync
  import SwiftUI

  /// 設定の「データ」カードのうち、iCloud 同期の行(Flutter 版の DesktopSyncRows)。
  ///
  /// 同期の状態はカードの外に出さず「今すぐ同期」行の右端に出す。カードの下に置くと、
  /// 間に書き出し / 読み込みの行が挟まって何に掛かる文か読めないため。
  /// エラーだけは長く折り返しが要るので独立した行にする。
  struct SyncRows: View {
    let sync: SyncController

    var body: some View {
      VStack(spacing: 0) {
        SettingsToggleRow(label: String(localized: .icloudSync), value: sync.enabled) { enabled in
          Task { await sync.setEnabled(enabled) }
        }
        if sync.enabled {
          SettingsDivider()
          SyncNowRow(
            syncing: sync.syncing,
            status: SyncStatusText.status(syncing: sync.syncing, lastSyncedAt: sync.lastSyncedAt)
          ) { Task { await sync.syncNow() } }
          if let failure = sync.failure {
            SettingsDivider()
            SyncErrorRow(message: SyncStatusText.failure(failure))
          }
        }
      }
    }
  }

  /// 「今すぐ同期」行。iOS 版と同じくカード内の行として組む(カードの外にボタンだけ取り残さないため)。
  private struct SyncNowRow: View {
    let syncing: Bool
    let status: String
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      // 寸法は SettingsLinkRow に合わせる(同じカードに並ぶため)。
      HStack(spacing: 0) {
        // カードの地に載るアクセントの文字は accentOnSoft を使う(accent のままだと 4.5:1 に届かない)。
        AppText(.syncNow, style: SettingsRowStyle.label)
          .foregroundStyle(syncing ? colors.textDisabled : colors.accentOnSoft)
          .frame(maxWidth: .infinity, alignment: .leading)
        // 右端の状態はバージョンの行(SettingsValueRow)と同じ体裁。
        AppText(status, style: SettingsRowStyle.label)
          .foregroundStyle(colors.textTertiary)
        if syncing {
          CircularProgress(color: colors.accent, size: 14, lineWidth: 2)
            .padding(.leading, px(8))
        }
      }
      .padding(px(SettingsRowStyle.padding))
      .background(isHovered && !syncing ? colors.inputBackground : .clear)
      .hoverTap($isHovered, in: Rectangle()) { if !syncing { action() } }
      .pointerStyle(syncing ? nil : .link)
    }
  }

  private struct SyncErrorRow: View {
    let message: String

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      // 行というより注記なので、他の行(13px)より小さくする。
      AppText(message, style: AppTextStyle(size: 12, height: 1.5))
        .foregroundStyle(colors.danger)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, px(14))
        .padding(.vertical, px(9))
    }
  }
#endif
