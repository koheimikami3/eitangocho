import EitangochoData
import SwiftUI

/// 右クリックの「編集...」「削除...」のメニュー(Flutter 版の showWordContextMenu)。macOS 専用。
enum WordContextMenu {
  @MainActor
  static func show(
    at position: CGPoint, word: Word, overlay: AppOverlay?, colors: AppColors, onEdit: @escaping () -> Void,
    onDelete: @escaping () -> Void
  ) {
    overlay?.showMenu(
      at: position,
      items: [
        AppOverlay.MenuItem(label: String(localized: .editEllipsis), action: onEdit),
        AppOverlay.MenuItem(
          label: String(localized: .deleteEllipsis), color: colors.danger, hoverColor: colors.danger, action: onDelete),
      ])
  }
}
