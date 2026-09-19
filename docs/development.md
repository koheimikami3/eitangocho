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
                  #         ads / purchase(iOS のみ)/ review
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

## 技術的な疑問の解決

1. プロジェクト固有の設計: `docs/*.md` や既存コードを参照する
2. Flutter / Dart / パッケージの使い方: 公式ドキュメントを Web 検索で確認する
3. それでも不明な場合: ユーザーに質問する
