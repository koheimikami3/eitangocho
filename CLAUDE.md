# CLAUDE.md

このファイルは Claude Code がこのリポジトリで作業する際のガイドラインです。
全プロジェクト共通の作業ルール(言語・設計原則・Planning 等)は `~/.claude/CLAUDE.md` にある。

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
- **DeepL キーは設定画面から入力しローカル保存**(コードに埋め込まない)
- **プラットフォーム分岐は `AppPlatform`(`lib/utils/app_platform.dart`)に集約**。
  画面幅では分岐しない(macOS は uiScale で論理幅が縮むため)
- **iOS 専用ウィジェットは `mobile_` プレフィックス**で同じディレクトリに置く。
  配色は macOS が `context.colors`(`AppColors`)、iOS は `context.palette`(`AppPalette`)。
  どちらもライト / ダークの 2 セットを持つ
- **kaikki の `sounds` / `examples`、Tatoeba の `translations` は `required` にしない**
  (丸ごと欠落・null になりうる)

## コード生成

- 生成ファイル(`*.g.dart`、`*.freezed.dart`)はコミットする。
  モデル・Provider・drift スキーマ等の生成対象を変更したら build_runner を再実行すること。

## テスト

- テストファイルは `test/` 内で `lib/` 構造をミラーする。
- テストが失敗した場合、まず生成ファイルが最新かを確認すること。

## 完了時の検証

- 完了時の検証コマンドは `flutter analyze` と `flutter test -r failures-only`
  (実行タイミングは `~/.claude/CLAUDE.md` の「完了時の検証」に従う)。
- 対象は Dart のコード(`lib/` / `test/`)の変更。docs・設定・ネイティブのみの作業では実行しない。
