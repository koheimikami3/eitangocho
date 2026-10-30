# 開発ガイド

CLAUDE.md から外した参照情報。構成を把握したいとき・コマンドを確認したいときに読む。

## ディレクトリ構成

MVVM ベースの機能別レイヤー構成。DDD 的な重いレイヤリングは行わない。

```
lib/
├── components/   # 機能横断の汎用ウィジェット
├── constants/    # 定数(色、設定値等)
├── enums/        # 機能横断の enum(品詞等)
├── utils/        # ヘルパー
├── providers/    # グローバル Provider(DB インスタンス等)
├── db/           # drift のテーブル定義・DAO・Database クラス
├── l10n/         # 画面の文言(ARB。app_ja.arb がテンプレート)と生成された AppLocalizations
└── features/     # 機能別: word / quiz / word_registration / settings / sync /
                  #         ads / purchase(iOS のみ)/ review / analytics
    └── <feature>/
        ├── data/          # DAO・外部 API と連携する Riverpod Provider
        ├── domain/        # Freezed モデル・機能固有 enum
        └── presentation/  # ページ、State、Notifier、widgets/
```

## ビルド・開発コマンド

```bash
flutter run -d macos                                    # macOS で実行
flutter run -d <simulator-id>                           # iOS で実行
dart run build_runner build --delete-conflicting-outputs # コード生成
flutter gen-l10n                                        # ARB から文言クラスを生成(pub get でも走る)
flutter test -r failures-only                           # 全テスト実行(失敗だけ表示)
flutter test test/path/to/specific_test.dart            # 個別テスト実行
flutter analyze                                         # 静的解析
```

## リント

`flutter_lints` ベース(`analysis_options.yaml` 参照)。コードスタイルはリンタが
強制するため md には書かない。リンタで表現できない規約だけ CLAUDE.md の
「規約」「コメント規約」に置く。

## アプリアイコン

編集するのは `shared/AppIcon.icon`(Icon Composer で開く)。レイヤー素材は `.icon` の
中の `Assets/` にあるので、別の場所に原本を置く必要はない。方針は
[design.md](design.md) の「アプリアイコン」。

新しい絵に差し替えるとき:

1. Icon Composer で New(Canvas 1024 × 1024)。対応プラットフォームは iOS と macOS の両方
2. 前景レイヤーを**下から**追加する。背景は読み込まない
3. レイヤーの Fill は白 `#FFFFFF` / 100%
4. **`Group` を選んで** Liquid Glass を設定: Specular ON / Blur OFF /
   Translucency ON 40% / Shadow Neutral 50%。レイヤー選択時に出る `Effects` は別物
5. **`Icon`(キャンバス)を選んで**背景を Solid で指定。インスペクタ右上のスコープを
   切り替えて Default と Dark の 2 つを入れる
   - 16 進入力は macOS のカラーパネル → 左から 2 番目のタブ → RGB スライダ →
     「16進カラー #」。カラーホイールのタブには入力欄が無い
6. **File → Save As** で `shared/AppIcon.icon` に保存する。`.icon` は書類形式そのもの
   なので **Export ではない**
7. `shared/AppIcon-dev.icon` の `Assets/` を新しい素材で置き換え、`icon.json` の
   `image-name` / `name` を合わせる。色指定は反転のまま変えない

`icon.json` の `layers` は**先頭が一番上のレイヤー**。追加した順とは逆になるので、
手で並べ替えるときに取り違えやすい。

確認:

```bash
flutter build macos --release              # AppIcon
flutter build macos --debug                # AppIcon-dev
flutter build ios --release --no-codesign
flutter build ios --debug --no-codesign

APP="build/macos/Build/Products/Release/シンプル英単語帳.app"
plutil -extract CFBundleIconName raw "$APP/Contents/Info.plist"   # AppIcon
# 旧 OS 向けに actool が描いた絵を見る
iconutil -c iconset "$APP/Contents/Resources/AppIcon.icns" -o /tmp/appicon.iconset
```

## ネイティブ版(Swift / SwiftUI、移行中)

Flutter 版を置き換える Swift 版を `native/` で作っている。1 つのターゲットで iOS 18 / macOS 15 の
両方をビルドし、Bundle ID は Flutter 版と同じ(Debug は `.dev` 付き)。データ引き継ぎの規則は
[design.md](design.md) の「ネイティブ版(native/)への引き継ぎ」。

```
native/
├── Eitangocho.xcodeproj      # ビルド設定は書かず Configs/ の xcconfig に置く。Eitangocho/ は同期フォルダ
├── Configs/                  # Shared / Debug / Release の xcconfig(BUNDLE_ID_SUFFIX・表示名・アイコン)
├── Support/                  # OS ごとの entitlements(iCloud コンテナ・App Group)
├── Eitangocho/               # SwiftUI のアプリ(Design/ = トークン・書体、Components/ = 共通部品、
│                             #  Features/<機能>/ = 画面とモデル、Diagnostics/ = Dev ビルドだけの診断画面)
├── EitangochoTests/          # アプリのモデルのテスト
└── Packages/EitangochoCore/  # 画面を持たない部分(EitangochoData = DB / EitangochoSync = 書き出し・同期 /
                              #  EitangochoWordInfo = 単語情報の取得)
```

```bash
swift test --package-path native/Packages/EitangochoCore    # パッケージのテスト
xcodebuild -project native/Eitangocho.xcodeproj -scheme Eitangocho -destination 'generic/platform=macOS' build
xcodebuild -project native/Eitangocho.xcodeproj -scheme Eitangocho -destination 'generic/platform=iOS Simulator' build
```

- Swift 版が書き出した JSON を Flutter 版が読めることは
  `test/features/settings/data/native_export_compat_test.dart` で確かめる。書き出しの形を変えたら
  `UPDATE_FIXTURES=1 swift test --package-path native/Packages/EitangochoCore` で固定データを作り直し、
  そのテストも通す
- Swift 版の Dev ビルドを入れると Flutter 版の Dev ビルドを置き換える(Bundle ID が同じ)。
  Flutter 版を入れ直すと、引き継いだ時点の元ファイルで起動する

### ネイティブ版の UI の書き方

- **トークン**: 配色は `Eitangocho/Design/AppColors.swift`(`@Environment(\.colors)`)、寸法は
  `AppDimensions.swift`。値は Flutter 版の `lib/constants/` から写したもので、移行期間は両方を揃える。
  Flutter 版で色を指定していない所は Material 3 の既定色(`materialOnSurface` など)を写してある
- **表示倍率**: 画面には素の値を書き、`@Environment(\.uiScale) private var px` の `px(14)` で倍率を掛ける。
  Flutter 版の `Transform.scale` と違い、入力欄など AppKit の部品も同じ倍率で大きくなる
- **文字の書式**: 文字は `AppText(文字列, style: AppTextStyle(size:weight:height:letterSpacing:))` で組む。
  Flutter の `TextStyle` と同じ値を書けば、行の高さ・ベースラインが Flutter 版と同じになる
  (SwiftUI は代替フォントの行の高さを使わないので、和文を含むかで余白を足している)。
  height・letterSpacing の既定は、Flutter 版の文字が Material から継承する bodyMedium の値
  (1.43・0.25。行間は上下に均等)なので、Flutter 版で書いてある所だけ書く。継承元が違う所は値を書く
  (メニューの項目は labelLarge = w500・字間 0.1、入力欄は bodyLarge = 行の高さ 1.5・字間 0.5)。
  入力欄など `Text` 以外は `style.font(px)` を使い、高さは `AppTextField.height` で Flutter と揃える
- **フォント**: `assets/fonts/` を Xcode のファイル参照で同梱し、起動時に `AppFonts.register()` で登録する。
  可変フォントは太さを wght 軸で指定し、Inter の光学サイズ(opsz)は 14 に止める(CoreText は自動で動かす)
- **アイコン**: Flutter 版の `Icons.xxx` は `MaterialIconView` で描く。足すときは
  `tool/material_icon_paths.py` の `ICONS` に名前を足して再実行する
- **メニューとダイアログ**: 右クリックメニュー・ポップアップメニュー・ダイアログは標準の部品を使わず、
  `AppOverlay`(`@Environment(\.appOverlay)`)に出す。右クリックは `RightClickArea` で受ける。
  一時的な通知(Flutter の SnackBar)も `AppOverlay.showSnackBar` で出す
- **ライセンス一覧**: SwiftPM はライセンスを集めないので `Features/Settings/Licenses/LicenseCatalog.swift` で
  手で持つ。Swift パッケージを足したら、その LICENSE を `Eitangocho/Resources/Licenses/` に置き、
  `LicenseCatalog.packages` に足す(`LicenseCatalogTests` の一覧も直す)
- **計測**: イベントは `Features/Analytics/AnalyticsLogger.swift` の送り口から送る(名前と値は Flutter 版と同じ)。
  モデルには `AnalyticsLogger` を渡し、画面からは `@Environment(\.analytics)` で取る。ユーザープロパティと
  screen_view は `AnalyticsReporting` が状態の変化を拾って送る。Firebase は Release ビルドだけ初期化し、
  Debug は送るはずだった内容をログ(カテゴリ analytics)に出す
- **String Catalog**: 文言は `Eitangocho/Resources/Localizable.xcstrings` に置き、`Text(.navLearning)` /
  `String(localized: .wordCount(3))` のように生成された記号で引く(キーは ARB と同じ)。
  `tool/arb_to_xcstrings.py` は移行のときに 1 回だけ使ったもので、以後は xcstrings を直接直す
- **テストの置き場所**: DB・同期・単語情報は `Packages/EitangochoCore/Tests/`(`swift test`)。
  アプリのモデル・トークン・文字の書式は `EitangochoTests/`(アプリに読み込ませて動かす。
  テスト中は引き継ぎも同期も始めない)

```bash
xcodebuild test -project native/Eitangocho.xcodeproj -scheme Eitangocho -destination 'platform=macOS'
```

## 技術的な疑問の解決

1. プロジェクト固有の設計: `docs/*.md` や既存コードを参照する
2. Flutter / Dart / パッケージの使い方: 公式ドキュメントを Web 検索で確認する
3. それでも不明な場合: ユーザーに質問する
