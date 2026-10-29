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
├── Eitangocho/               # SwiftUI のアプリ(Diagnostics/ は Dev ビルドだけの診断画面)
└── Packages/EitangochoCore/  # 画面を持たない部分(EitangochoData = DB / EitangochoSync = 書き出し・同期)
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

## 技術的な疑問の解決

1. プロジェクト固有の設計: `docs/*.md` や既存コードを参照する
2. Flutter / Dart / パッケージの使い方: 公式ドキュメントを Web 検索で確認する
3. それでも不明な場合: ユーザーに質問する
