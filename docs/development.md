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

## 技術的な疑問の解決

1. プロジェクト固有の設計: `docs/*.md` や既存コードを参照する
2. Flutter / Dart / パッケージの使い方: 公式ドキュメントを Web 検索で確認する
3. それでも不明な場合: ユーザーに質問する
