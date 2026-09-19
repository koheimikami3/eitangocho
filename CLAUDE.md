# CLAUDE.md

このファイルは Claude Code がこのリポジトリで作業する際のガイドラインです。

## 応答言語

ユーザーへの応答は日本語で行うこと。コード内のコメント・ドキュメントコメント(`///`)も日本語で記述する。

## プロジェクト概要

英単語帳アプリ (eitangocho)。macOS / iOS 向けの Flutter アプリ。
データはローカル DB(drift / SQLite)に保持し、端末間は iCloud 上の JSON
スナップショット 1 個で同期する(自前サーバは持たない)。

- 外部 API・確定済み設計判断: `docs/design.md`(常時は読み込まない。外部データ取得・
  同期・広告・課金・ビルド / 提出まわりに手を入れる前に該当節を読むこと)。
  追記するときは同ファイル冒頭の「書き方」に従い、溜め込まない
- ディレクトリ構成・コマンド一覧・リント・疑問の調べ方: `docs/development.md`
  (常時は読み込まない。構成やコマンドを確認したいときに読む)
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

MVVM ベースの機能別レイヤー構成。機能ごとに `lib/features/<feature>/` の下を
`data/`(DAO・外部 API の Provider)/ `domain/`(Freezed モデル・enum)/
`presentation/`(Page・State・Notifier・`widgets/`)に分ける。

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

## コード生成・依存

- 生成ファイル(`*.g.dart`、`*.freezed.dart`)はコミットする。
  モデル・Provider・drift スキーマ等の生成対象を変更したら build_runner を再実行すること。
- `pubspec.yaml` を変更したら `pubspec.lock` も一緒にコミットすること。

## テスト

- テストファイルは `test/` 内で `lib/` 構造をミラーする。
- テストが失敗した場合、まず生成ファイルが最新かを確認すること。

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
- 大きな変更は段階的な単位に分割し、単位ごとにコミットすること
  (コミットごとにテストは回さない。検証は下記「完了時の検証」のタイミングで行う)。
- 実装中に想定外の問題が発生した場合は、一旦止まって計画を見直すこと。

## Subagent Strategy

- 調査・探索は原則メインで直接行う(grep で当たりを付けて必要箇所だけ読む)。
- サブエージェントは、ユーザーが求めたとき、または多数のファイルを走査して
  結論だけ要る調査のときに限り使う。並行起動はしない。

## 完了時の検証

時間がかかるので回数を絞る。

- `flutter analyze` と `flutter test -r failures-only` は、**依頼された実装が
  すべて終わった時点で 1 回だけ**実行する。途中のステップ・コミットごとには実行しない。
- Dart のコード(`lib/` / `test/`)を変更していない作業(docs・設定・ネイティブのみ)
  では実行しない。
- 途中で動作を確かめる必要があるときは、該当する個別テストだけを実行する。
- `git diff` はまず `--stat` で変更ファイルを確認し、中身は必要なファイルだけ見る。
