import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/toolbar_search_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS のネイティブメニューバーを Dart で定義するアプリメニュー。
///
/// なぜ CallbackShortcuts ではなくこれか:
/// macOS は Command 系ショートカット(⌘N/⌘F)をネイティブメニューバー経由で
/// 先に処理するため、focus ベースの `CallbackShortcuts` にはイベントが届かない
/// (標準 MainMenu.xib の Find 項目が ⌘F を横取りし、⌘N は OS へ抜ける)。
/// Command 系はメニューバーに載せるのが macOS 流の正解。`PlatformMenuBar` で
/// 標準メニューを置換し、⌘N/⌘F を native keyEquivalent として Dart コールバック
/// へ配線する。非 Command のクイズ用ショートカットは focus 方式のままで問題ない。
///
/// メニュー全体を置換するため、標準のアプリ/ウィンドウメニュー項目も
/// `PlatformProvidedMenuItem` で再構成する(About / Quit / 最小化 等)。
/// コピー&ペースト等のテキスト編集ショートカットはメニュー項目が無くても
/// Flutter の `DefaultTextEditingShortcuts` が入力欄で処理するため、
/// 編集メニューには載せていない。
class AppMenuBar extends ConsumerWidget {
  const AppMenuBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ネイティブメニューバーを持つのは macOS のみ。他プラットフォーム
    // (将来の iOS 含む・テストの既定ターゲット)では PlatformMenuBar を
    // 張らずに child をそのまま返す。PlatformProvidedMenuItem は macOS 以外だと
    // serialize 時に例外を投げるため、ここでガードする必要がある。
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return child;
    }

    final view = ref.watch(mainPageProvider.select((s) => s.view));

    return PlatformMenuBar(
      menus: buildMenus(
        onRegister: () => ref
            .read(mainPageProvider.notifier)
            .selectView(MainView.registration),
        // 検索フィールドが無いビューでは null を渡し、⌘F を無効化する。
        onSearch: view.hasSearchField
            ? () => ref.read(toolbarSearchFocusProvider).requestFocus()
            : null,
      ),
      child: child,
    );
  }

  /// メニュー構成を組み立てる。
  ///
  /// native ⌘ 発火は widget test で再現できないため、⌘N/⌘F の配線と、
  /// ⌘F の有効/無効(onSearch が null かどうか)をこの純粋関数経由で検証する。
  /// `PlatformMenuItem.onSelected` を null にすると、その項目とショートカット
  /// 双方が無効になる(ショートカットは onSelected が設定されているときのみ
  /// 有効、という仕様)。
  @visibleForTesting
  static List<PlatformMenuItem> buildMenus({
    required VoidCallback onRegister,
    required VoidCallback? onSearch,
  }) {
    return [
      // 先頭メニューは macOS のアプリメニューになる。ラベルはシステムが
      // バンドル名(CFBundleName = シンプル英単語帳)に差し替える。
      const PlatformMenu(
        label: 'シンプル英単語帳',
        menus: [
          PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about),
          PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.servicesSubmenu,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.hideOtherApplications,
              ),
              PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.showAllApplications,
              ),
            ],
          ),
          PlatformMenuItemGroup(
            members: [
              PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: '単語',
        menus: [
          PlatformMenuItem(
            label: '単語を登録',
            shortcut: const SingleActivator(
              LogicalKeyboardKey.keyN,
              meta: true,
            ),
            onSelected: onRegister,
          ),
        ],
      ),
      PlatformMenu(
        label: '編集',
        menus: [
          PlatformMenuItem(
            label: '検索',
            shortcut: const SingleActivator(
              LogicalKeyboardKey.keyF,
              meta: true,
            ),
            onSelected: onSearch,
          ),
        ],
      ),
      const PlatformMenu(
        label: 'ウィンドウ',
        menus: [
          PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.minimizeWindow,
          ),
          PlatformProvidedMenuItem(
            type: PlatformProvidedMenuItemType.zoomWindow,
          ),
        ],
      ),
    ];
  }
}
