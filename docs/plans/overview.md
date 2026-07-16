# 実装計画 全体像(Phase 1〜4)

英単語帳アプリ eitangocho の開発フェーズ Phase 1〜4 の実装計画の共通前提をまとめたドキュメント。
各フェーズの詳細は `docs/plans/phase1.md`〜`phase4.md` を参照。

この計画一式は 2026-07-16 に確定した(設計判断はすべてユーザー承認済み)。
**別セッション・別モデルがこの計画書だけを読んで実装に着手できること**を目的としている。

## 計画書の読み方

| ドキュメント | 内容 | 解像度 |
|---|---|---|
| [phase1.md](phase1.md) | 基盤(依存・リント・DB スキーマ)+ 単語 CRUD + 全単語テーブル | **コードレベル**(読むだけで着手可能) |
| [phase2.md](phase2.md) | 学習中カードビュー + フラッシュクイズ + 設定画面 | 設計書レベル |
| [phase3.md](phase3.md) | 自動入力(Free Dictionary + EJDict + DeepL)+ 音声再生 | 設計書レベル(WordInfoProvider 抽象はコードレベル確定済み) |
| [phase4.md](phase4.md) | JSON エクスポート/インポート + ショートカット + 磨き込み + ストア提出 | 設計書レベル |

Phase 2〜4 のファイルリスト・ウィジェット分割は「Phase 1 完了時点のコードベースに合わせて
実装時に微調整する」前提。ただし**設計判断(何をどう作るか・使用パッケージ)は本計画で確定済み**であり、
実装時に揺れそうな箇所は各計画書に「選択肢と推奨案」として明記している。

## 正とする参照先

- 機能仕様・外部 API・データ設計: `docs/design.md`
- UI(レイアウト・配色・文言・全画面の状態遷移): `docs/prototype/design/eitangocho.html`
  - HTML プロトタイプはシードデータ・モック辞書・全インタラクションを含む動作するモック。
    実装で迷ったらこのファイルの該当箇所を読むこと
- アプリアイコン案: `docs/prototype/design/icon.html`(Phase 4 で使用)

## フェーズ間の依存関係

```
Phase 1(基盤 + CRUD + 全単語テーブル)
  └→ Phase 2(学習中カード + クイズ + 設定画面)
       └→ Phase 3(自動入力 + 音声)※設定画面(Phase 2)に DeepL キー欄を追加するため Phase 2 に依存
            └→ Phase 4(エクスポート/インポート + 磨き込み + ストア提出)
```

- 順番どおりに実装する。フェーズをまたいだ先行実装はしない
- DB スキーマは Phase 1 で**全テーブルを schemaVersion 1 として一括定義**するため、
  Phase 2〜4 でマイグレーションは発生しない(Phase 3・4 は Phase 1 で定義済みのテーブルを使うだけ)

## 確定済みの設計判断(ユーザー承認済み・変更しないこと)

| # | 論点 | 決定 |
|---|---|---|
| 1 | DB スキーマ範囲 | words + ejdict_entries + dictionary_cache_entries を Phase 1 で schemaVersion 1 として一括定義 |
| 2 | 品詞(複数)の保存 | `partsOfSpeech` TEXT カラムに enum 名 CSV(例 `'verb,noun'`)。TypeConverter で `List<PartOfSpeech>` に変換 |
| 3 | 設定画面 | Phase 2 で新設(クイズ方向 + IPA 表示)。Phase 3 で DeepL キー欄を追加 |
| 4 | クイズ実績 | 記録する・UI 表示なし。回答毎に `lastReviewedAt` 更新、「覚えている」で `correctCount`+1。出題は学習済み全件シャッフル |
| 5 | HTTP クライアント | `http` |
| 6 | 音声再生 | `just_audio` |
| 7 | 設定値の保存先 | `shared_preferences`(DeepL API キー含む。ローカル個人アプリとして平文保存を許容) |
| 8 | ウィンドウ | 透明タイトルバー(MainFlutterWindow.swift で `titlebarAppearsTransparent` + `fullSizeContentView`) |
| 9 | EJDict 同梱 | テキストを 1 ファイルに結合して asset 同梱、初回起動時に drift へバッチ INSERT |
| 10 | Phase 1 の登録 UI | 手動フォームのみ(プロトタイプの「ステップ 2」を直接表示)。2 ステップ化は Phase 3 |

## 使用パッケージとバージョン(2026-07-16 時点の pub.dev 最新安定版)

開発環境: Flutter 3.44.6 stable / Dart 3.12.2。
バージョン指定はキャレット(`^`)で記載する。導入フェーズの列に従って、各フェーズの
pubspec 変更コミットで追加すること(`pubspec.lock` も一緒にコミット)。

### dependencies

| パッケージ | バージョン | 導入フェーズ | 用途 |
|---|---|---|---|
| flutter_riverpod | ^3.3.2 | 1 | 状態管理 |
| riverpod_annotation | ^4.0.3 | 1 | `@riverpod` コード生成 |
| freezed_annotation | ^3.1.0 | 1 | Freezed モデル |
| json_annotation | ^4.12.0 | 1 | JSON シリアライズ(Phase 3 の API モデル、Phase 4 のエクスポートで使用) |
| drift | ^2.34.2 | 1 | ローカル DB |
| drift_flutter | ^0.3.1 | 1 | drift の Flutter 向け DB オープン |
| shared_preferences | ^2.5.5 | 2 | 設定値保存 |
| http | ^1.6.0 | 3 | Free Dictionary / DeepL API |
| just_audio | ^0.10.6 | 3 | 発音 mp3 再生 |
| url_launcher | ^6.3.2 | 3 | Google 翻訳リンク(audio なしフォールバック) |
| file_selector | ^1.1.0 | 4 | JSON エクスポート/インポートのファイルダイアログ |

### dev_dependencies

| パッケージ | バージョン | 導入フェーズ | 用途 |
|---|---|---|---|
| build_runner | ^2.15.2 | 1 | コード生成ランナー |
| riverpod_generator | ^4.0.4 | 1 | `@riverpod` 生成 |
| riverpod_lint | ^3.1.4 | 1 | Riverpod 用リント |
| custom_lint | ^0.8.1 | 1 | riverpod_lint の実行基盤 |
| freezed | ^3.2.5 | 1 | Freezed 生成 |
| json_serializable | ^6.14.0 | 1 | JSON 生成 |
| drift_dev | ^2.34.4 | 1 | drift 生成 |
| pedantic_mono | ^1.37.0 | 1 | リントルール(flutter_lints から置換) |

注意: Riverpod は 3.x 世代(riverpod_annotation 4.x / riverpod_generator 4.x)。
Web 上の古い 2.x 系サンプル(`AutoDisposeNotifier` 等)と API が異なるので、
生成コードのエラーが出たら公式ドキュメント(riverpod.dev)を確認すること。

## ディレクトリ構成(Phase 1〜4 完了時の全体像)

CLAUDE.md のアーキテクチャ規約に従う。1 点だけ拡張として **`lib/app/` を新設**する:
サイドバー・ツールバー・ビュー切替を持つアプリシェル(画面骨格)は
features の 4 分類(word / quiz / word_registration / settings)のどれにも属さない
機能横断の構造物であり、`components/`(汎用ウィジェット)とも役割が異なるため。

```
lib/
├── main.dart                      # ProviderScope + EitangochoApp 起動
├── app/                           # アプリシェル(Phase 1)
│   ├── eitangocho_app.dart        # MaterialApp(テーマ・フォント)
│   ├── main_page.dart             # サイドバー + ツールバー + コンテンツ切替
│   ├── main_page_state.dart       # 選択中ビュー・検索文字列(Freezed)
│   ├── main_page_notifier.dart
│   └── widgets/                   # sidebar, sidebar_item, toolbar, search_field 等
├── components/                    # 機能横断の汎用ウィジェット(発音ボタン等。Phase 3〜)
├── constants/                     # 配色・寸法(Phase 1 でプロトタイプから抽出)
├── enums/                         # PartOfSpeech(Phase 1)
├── utils/
├── providers/                     # databaseProvider 等のグローバル Provider
├── db/                            # drift: tables / AppDatabase / DAO / TypeConverter
└── features/
    ├── word/                      # 全単語テーブル(P1)、学習中カード(P2)、編集・削除(P1)
    ├── quiz/                      # フラッシュクイズ(P2)
    ├── word_registration/         # 登録フォーム(P1)→ 2 ステップ + 自動入力(P3)
    │   ├── data/                  # FD/DeepL クライアント、DictionaryWordInfoProvider(P3)
    │   ├── domain/                # WordInfo・WordInfoProvider 抽象(P1 で型確定)
    │   └── presentation/
    └── settings/                  # 設定画面(P2)、DeepL キー欄(P3)、エクスポート導線(P4)
```

## 状態管理の方針(全フェーズ共通)

- **DB インスタンス**: `lib/providers/database_provider.dart` で `AppDatabase` を
  `@Riverpod(keepAlive: true)` 提供
- **単語リスト**: `WordDao.watchAll()`(drift の watch)を `@riverpod` の Stream で公開。
  学習中のみ・件数などはその派生 Provider で計算(DB に別クエリは投げない)
- **画面状態**: CLAUDE.md 規約どおり `XxxPageState`(Freezed)+ `XxxPageNotifier`(`@riverpod` class)。
  対象: MainPage(選択ビュー・検索)、QuizPage、WordRegistrationPage
- **モーダル(編集・削除確認)**: ページではないため State/Notifier ペアの対象外。
  `showDialog` + ダイアログ内ローカル state(TextEditingController 等)で完結させ、
  確定時のみ DAO を呼ぶ
- **カードの「日本語訳を表示」トグル**: カードウィジェットのローカル state
  (画面切替で揮発してよい・プロトタイプも永続化していない)
- **設定**: shared_preferences を包む `SettingsNotifier`(quizDirection / showIpa / deeplApiKey)

## ブランチ・コミット運用

- フェーズごとに main からブランチを切る(ブランチ名は各計画書に記載)。
  フェーズ完了時に main へマージしてから次フェーズへ
- コミット単位は各計画書の「コミット計画」に従う。**各コミット時点で
  `flutter analyze`(警告 0)と `flutter test`(全パス)が通る状態を保つ**
- 生成ファイル(`*.g.dart` / `*.freezed.dart`)はコミットに含める
- `pubspec.yaml` を変更したコミットには `pubspec.lock` を含める

## 共通の検証コマンド

```bash
dart run build_runner build --delete-conflicting-outputs   # 生成対象を変えたら必ず
flutter analyze                                            # 警告 0 を維持
flutter test                                               # 全テストパス
flutter run -d macos                                       # 手動確認(各計画書にチェックリストあり)
```

手動確認の観点は各計画書のコミットごとに列挙している。UI の見た目に迷ったら
プロトタイプ HTML をブラウザで開いて比較すること。

## 全フェーズ共通の注意事項

- **プロトタイプとの一致を優先**: 配色・文言・余白はプロトタイプの値(phase1.md の定数表に転記済み)を使う。
  独自の意匠変更をしない
- **`--dart-define=ENABLE_AI`**: MVP(Phase 1〜4)では AI 機能を実装しないため未使用。
  フラグ分岐コードを先回りで入れないこと(将来 LLM 統合時に導入)
- **API キーをコードに埋め込まない**: DeepL キーは設定画面から入力し shared_preferences 保存(Phase 3)
- **外部 API のレスポンスモデルで存在が保証されないフィールドを `required` にしない**(Phase 3 の
  Free Dictionary モデルで特に注意。`phonetics` / `example` 等は欠落しうる)
- テスト失敗時はまず生成ファイルが最新か(build_runner 再実行)を確認する
