# CLAUDE.md

このファイルは Claude Code がこのリポジトリで作業する際のガイドラインです。

## 応答言語

ユーザーへの応答は日本語で行うこと。コード内のコメント・ドキュメントコメント(`///`)も日本語で記述する。

## プロジェクト概要

英単語帳アプリ (eitangocho)。macOS / iOS 向けの Flutter アプリ。
データはローカル DB(drift / SQLite)に保持し、端末間は iCloud 上の JSON
スナップショット 1 個で同期する(自前サーバは持たない)。

- 外部 API・確定済み設計判断の詳細: @docs/design.md
- ストアに掲載したリリースノートの控え: `docs/release-notes.md`
  (提出のたびに追記する。書き方の決まりも同ファイルの冒頭にある)
- 機能仕様と UI の詳細(レイアウト・配色・寸法)は実装済みアプリと
  `lib/constants/app_colors.dart` / `lib/constants/app_palette.dart` /
  `lib/constants/app_dimensions.dart` のトークンが正基準

## 技術スタック

- Flutter for macOS / iOS(ネイティブ UI は使わず、独自デザイン)
- Riverpod コード生成方式(`@riverpod` → `.g.dart`)+ Freezed(`@freezed` → `.freezed.dart`)
- drift(SQLite)
- 配布は Mac App Store / App Store。macOS は App Sandbox 必須
  (`com.apple.security.network.client` を Debug / Release 両方の entitlements に設定)
- iCloud 同期のネイティブ実装は `shared/IcloudFileStorePlugin.swift` に置き、
  macOS / iOS 両方の Xcode プロジェクトから同じファイルを参照する(片方だけ直す事故を防ぐ)

## アーキテクチャ

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
                  #         ads / purchase(iOS のみ)
    └── <feature>/
        ├── data/          # DAO・外部 API と連携する Riverpod Provider
        ├── domain/        # Freezed モデル・機能固有 enum
        └── presentation/  # ページ、State、Notifier、widgets/
```

### 規約

- **Page / PageBody 分離**: `XxxPage` は Scaffold・タイトルバーのみ、中身は `XxxPageBody`
- **State + Notifier のペア**: 画面状態は `XxxPageState`(Freezed)+ `XxxPageNotifier`(`@riverpod` class)
- **1 ウィジェット 1 ファイル**: 小さなボタンでも `presentation/widgets/` 配下に分割
- **presentation 層から DB / HTTP を直接触らない**: クエリは DAO に集約し、
  `data/` の Provider 経由で公開する
- **インポートは絶対パッケージパス**(`package:eitangocho/...`)で統一。
  相対インポート・バレルファイルは使わない
- **単語情報の自動取得は `WordInfoProvider` 抽象の裏に隠す**(実装差し替え可能にする)
- **LLM 機能は `--dart-define=ENABLE_AI=true` で切り替え**。ストア配布ビルドには
  AI 関連コードを含めない。別リポジトリには絶対に分けない
- **API キーをコードに埋め込まない**(DeepL キーは設定画面から入力しローカル保存)
- **プラットフォーム分岐は `AppPlatform`(`lib/utils/app_platform.dart`)に集約**。
  画面幅では分岐しない(macOS は uiScale で論理幅が縮むため)
- **iOS 専用ウィジェットは `mobile_` プレフィックス**で同じディレクトリに置く。
  配色は macOS が `AppColors`(ライト固定)、iOS は `context.palette`(`AppPalette`)
- **外部 API のレスポンスモデルで、存在が保証されないフィールドを `required` にしない**
  (kaikki の `sounds` / `examples`、Tatoeba の `translations` は丸ごと欠落・null に
  なりうる。安易な required は欠落時にデシリアライズごと失敗する)

## 設計原則

- シンプルさを優先すること。必要最小限の変更で目的を達成する。
- 実装前に既存の共通実装・ユーティリティがないか確認し、重複実装を避けること。
- **既存実装との対称性**: 類似機能を追加・拡張するときは、最も近い既存実装を参照モデル
  として先に特定し、型設計・命名・構成・エラーハンドリングを最初から揃えること。
- 変更は必要な箇所のみに留め、無関係なリファクタリングを混ぜないこと。
- スコープや方針の分岐(実装の先送り・実装方針の選択など)を独断で決めず、
  理由を添えてユーザーに確認・承認を得ること。
- バグ修正では、一時的な回避策ではなく根本原因を特定して修正すること。

## コメント規約

- 非自明な設計判断には「なぜその実装にしたか」をコメントに残すこと。
- コメントは実装と一致させ、変更時は古い記述を必ず更新すること。
- 行番号(`L42` 等)をコメントにハードコードしないこと。関数名・クラス名など
  意味的な参照を使うこと。

## 技術的な疑問の解決

1. プロジェクト固有の設計: `docs/*.md` や既存コードを参照する
2. Flutter / Dart / パッケージの使い方: 公式ドキュメントを Web 検索で確認する
3. それでも不明な場合: ユーザーに質問する

## ビルド・開発コマンド

```bash
flutter run -d macos                                    # macOS で実行
flutter run -d <simulator-id>                           # iOS で実行
dart run build_runner build --delete-conflicting-outputs # コード生成
flutter test                                            # 全テスト実行
flutter test test/path/to/specific_test.dart            # 個別テスト実行
flutter analyze                                         # 静的解析
```

- 生成ファイル(`*.g.dart`、`*.freezed.dart`)はコミットする。
  モデル・Provider・drift スキーマ等の生成対象を変更したら build_runner を再実行すること。
- `pubspec.yaml` を変更したら `pubspec.lock` も一緒にコミットすること。

## テスト

- テストファイルは `test/` 内で `lib/` 構造をミラーする。
- テストが失敗した場合、まず生成ファイルが最新かを確認すること。

## リント

`flutter_lints` ベース(`analysis_options.yaml` 参照)。
コードスタイルはリンタが強制するため、この md には書かない。
リンタで表現できない規約のみ「規約」「コメント規約」に記載している。

(当初 `pedantic_mono` を予定していたが、Phase 1 実装時にユーザー判断で
見送り、`flutter_lints` を継続採用することにした)

## Planning

- 非自明なタスク(複数ステップや設計判断を伴うもの)では、実装前に Plan Mode に入ること。
- 計画の最初のステップとして、実装ブランチ名を決定し checkout すること。
- Plan Mode では、実装に入る前にユーザーの承認を得ること。
- 計画には以下を必ず含めること:
  - 変更対象ファイルのリスト
  - 変更の順序と依存関係
  - 検証方法(どのテスト・コマンドで確認するか)
  - コミット単位(分割理由も記載)
- 不明点や設計判断が必要な箇所があれば、実装前にユーザーに質問すること。
- 大きな変更は、段階的に実装・検証できる単位に分割し、単位ごとにコミットすること。
- 実装中に想定外の問題が発生した場合は、一旦止まって計画を見直すこと。

## Subagent Strategy

- 調査・探索タスクはサブエージェントに委譲し、メインコンテキストを清潔に保つこと。
- 複数の独立した調査は並行してサブエージェントを起動すること。
- 1 つのサブエージェントには 1 つのタスクを割り当てること。

## Verification Before Completion

- タスク完了を宣言する前に、必ず以下を実行すること:
  - `flutter analyze` で解析エラー・警告がないことを確認
  - `flutter test` でテストが通ることを確認
  - `git diff` で意図しない変更が含まれていないことを確認

## Compact Instructions

- コンパクション時は、現在のタスクの計画・TODO リスト・判断事項を必ず保持すること。
- 変更済み / 変更予定のファイル一覧を必ず保持すること。
- 直近のテスト結果やエラー内容を必ず保持すること。
