#if os(iOS)
  import EitangochoSync
  import SwiftUI

  /// iOS 版の設定の「データ」カードのうち、iCloud 同期の行(Flutter 版の MobileSyncRows)。
  ///
  /// 同期の状態はカードの外に出さず「今すぐ同期」行の右端に出す。カードの下に置くと、
  /// 間に書き出し / 読み込みの行が挟まって何に掛かる文か読めないため。
  /// エラーだけは長く折り返しが要るので独立した行にする。
  struct MobileSyncRows: View {
    let sync: SyncController

    var body: some View {
      VStack(spacing: 0) {
        MobileSettingsToggleRow(label: String(localized: .icloudSync), value: sync.enabled) { enabled in
          Task { await sync.setEnabled(enabled) }
        }
        if sync.enabled {
          MobileSettingsDivider()
          MobileSyncNowRow(
            syncing: sync.syncing,
            status: SyncStatusText.status(syncing: sync.syncing, lastSyncedAt: sync.lastSyncedAt)
          ) { Task { await sync.syncNow() } }
          if let failure = sync.failure {
            MobileSettingsDivider()
            MobileSyncErrorRow(message: SyncStatusText.failure(failure))
          }
        }
      }
    }
  }

  private struct MobileSyncNowRow: View {
    let syncing: Bool
    let status: String
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 0) {
        // カードの地に載るアクセントの文字は accentOnSoft を使う(accent のままだと 4.5:1 に届かない)。
        AppText(.syncNow, style: AppTextStyle(size: 14))
          .foregroundStyle(syncing ? palette.textAlpha(40) : palette.accentOnSoft)
          .frame(maxWidth: .infinity, alignment: .leading)
        // 右端の状態はバージョンの行(MobileSettingsValueRow)と同じ体裁。
        AppText(status, style: AppTextStyle(size: 13))
          .foregroundStyle(palette.textAlpha(40))
          // 状態の幅を先に確定させて 1 行に収め、残りをラベルに渡す。優先度がないと HStack が
          // 幅を等分して提案し、ラベルの余白を残したまま日時の途中で折り返してしまう。
          .lineLimit(1)
          .layoutPriority(1)
        if syncing {
          CircularProgress(color: palette.accent, size: 16, lineWidth: 2)
            .padding(.leading, 8)
        }
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 13)
      .contentShape(Rectangle())
      .onTapGesture { if !syncing { action() } }
    }
  }

  private struct MobileSyncErrorRow: View {
    let message: String

    @Environment(\.palette) private var palette

    var body: some View {
      // 行というより注記なので、他の行(14px)より小さくする。
      AppText(message, style: AppTextStyle(size: 12, height: 1.5))
        .foregroundStyle(palette.danger)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
  }
#endif
