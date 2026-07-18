# Phase 4 実装計画: JSON エクスポート/インポート + ショートカット + 磨き込み + ストア提出

> 前提・確定済み設計判断は [overview.md](overview.md) を参照。
> 本計画は設計書レベル。設計判断は確定済みだが、ファイル分割・微細な UI 調整は
> Phase 3 完了時点のコードベースに合わせて実装時に微調整してよい。

## ゴール

- JSON エクスポート/インポート(バックアップ兼デバイス間の手動移行手段)
- キーボードショートカット
- UI の磨き込み(アニメーション・ホバー・コンテキストメニュー・アプリアイコン)
- Mac App Store 提出準備

**ブランチ名: `feature/phase4-export-polish`**(Phase 3 マージ後の main から作成)

## pubspec に追加するもの

- dependencies: `file_selector: ^1.1.0`

## 作成・変更するファイル(想定。実装時に微調整可)

### 変更

- `pubspec.yaml` / `pubspec.lock`(C1)
- `macos/Runner/DebugProfile.entitlements` / `Release.entitlements`:
  `com.apple.security.files.user-selected.read-write` を **両方に** 追加
  (App Sandbox 下で保存/読込ダイアログのファイルへアクセスするために必須)(C1)
- `lib/features/settings/presentation/settings_view.dart`: エクスポート/インポート導線(C1)
- `lib/app/main_page.dart` ほか: ショートカット定義(C2)
- 各ウィジェット: アニメーション・ホバー磨き込み(C3)
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/`: アイコン差し替え(C3)
- `pubspec.yaml`(version)・`macos/Runner/Configs/AppInfo.xcconfig`(Bundle ID・表示名)(C4)

### 作成

- `lib/features/settings/data/word_export_service.dart`: エクスポート/インポートのロジック
  (DAO 呼び出し・JSON 変換。DB スキーマから独立した転送用モデルを含む)(C1)
- `lib/features/settings/domain/word_export.dart`: 転送用 Freezed モデル(json_serializable)(C1)
- `lib/features/settings/presentation/widgets/import_result_dialog.dart`(C1)
- テスト: `word_export_service_test`(roundtrip・マージ規則・不正データ)(C1)

## 設計

### JSON エクスポート/インポート(C1)

**フォーマット**(転送用モデル。DB の `Word` をそのまま toJson しない —
スキーマ変更の影響を切り離すため):

```json
{
  "version": 1,
  "exportedAt": "2026-07-16T12:34:56.789Z",
  "words": [
    {
      "word": "serendipity",
      "ipa": "/ˌserənˈdɪpəti/",
      "japanese": "偶然の幸運、思いがけない発見",
      "partsOfSpeech": ["noun"],
      "exampleEn": "Meeting her was pure serendipity.",
      "exampleJa": "彼女に出会えたのはまったくの偶然の幸運だった。",
      "audioUrl": "https://.../serendipity.mp3",
      "isLearned": false,
      "lastReviewedAt": null,
      "correctCount": 0,
      "createdAt": "2026-07-01T00:00:00.000Z",
      "updatedAt": "2026-07-10T00:00:00.000Z"
    }
  ]
}
```

- `id` は**含めない**(インポート先で採番。単語文字列がマージキー)
- 日時は ISO8601 UTC。`partsOfSpeech` は enum name の配列
- EJDict・dictionary_cache はエクスポート対象外(端末側で再生成できるため)

**エクスポート**: `file_selector` の `getSaveLocation`
(suggestedName 例 `eitangocho-2026-07-16.json`)→ 全単語を変換して書き出し → 完了 SnackBar。

**インポート(マージ方式・確定済みの推奨)**:

- `openFile`(拡張子 json)→ パース → `version` が未知なら中断してエラーダイアログ
- 各エントリ: 単語文字列(trim・小文字化)で既存レコードを照合
  - 一致なし → 新規追加(createdAt/updatedAt はファイルの値を維持)
  - 一致あり → **updatedAt が新しい方を採用**(ファイル側が新しければ上書き)。
    将来の iCloud 同期(タイムスタンプ勝ち)と同じ規則にしておく
- 必須フィールド(word / japanese)欠落や型不正のエントリはスキップして続行
- 結果ダイアログ: 「追加 n 件 / 更新 n 件 / 変更なし n 件 / スキップ n 件」
- 全体を 1 トランザクションで実行(途中失敗で中途半端に残さない)

**UI 導線**: 設定画面に「データ」セクション(「エクスポート...」「インポート...」ボタン)。

### キーボードショートカット(C2)

アプリ全体は `Shortcuts` + `Actions`(MainPage 直下)、クイズ中は
`Focus` + `KeyboardListener` または `CallbackShortcuts` で実装:

| キー | 動作 | スコープ |
|---|---|---|
| ⌘N | 単語を登録ビューへ | 全体 |
| ⌘F | 検索フィールドにフォーカス | 学習中・全単語ビュー |
| Space / Enter | 答えを表示 | クイズ(未開示時) |
| ← または 1 | 忘れていた | クイズ(開示後) |
| → または 2 | 覚えている | クイズ(開示後) |
| Esc | モーダル/ダイアログを閉じる | showDialog 既定動作の確認のみ |

### 磨き込み(C3)

- カード出現アニメーション(プロトタイプ `cardIn`: opacity 0→1 + translateY 4px→0、
  0.25s ease)。実装は自作の Implicit/Explicit アニメーション。追加パッケージは入れない
- ホバー状態の総点検(プロトタイプの `style-hover` を網羅):
  カード枠(accent 45%)+ 影、テーブル行、サイドバー項目、各ボタン、
  「日本語訳を表示」破線ボックス
- 右クリックメニューの見た目調整(Phase 1 では Material 標準。プロトタイプの
  角丸 8・選択行が accent 背景 + 白文字のスタイルに寄せる。工数次第で任意)
- アプリアイコン: `docs/prototype/design/icon.html` をブラウザで開いて 1024×1024 PNG を
  書き出し、`AppIcon.appiconset` の各サイズ(16〜1024)を生成して差し替える
  (`sips -z <size> <size> icon1024.png --out app_icon_<size>.png` で一括生成できる)
- **UI デザインチェック(全画面横断)**: Phase 1〜3 は機能実装を優先してきたため、
  プロトタイプとの見た目の細かな乖離が未確認のまま蓄積している(Phase 3 で
  ボタンの alignment 崩れ・コンテンツの中央/左寄せ崩れ・プレースホルダ色の
  視認性・全体サイズ感などが実機確認で複数見つかった実績があり、他画面にも
  同種の問題が残っている可能性が高い)。Phase 4 の磨き込みの一環として、
  全画面(学習中カード・全単語テーブル・フラッシュクイズ・単語登録・設定・
  各ダイアログ)を `flutter run -d macos` で実機確認し、`docs/prototype/design/eitangocho.html`
  をブラウザで並べて配色・余白・整列・フォントサイズ・ホバー/フォーカス状態を
  1 画面ずつ突き合わせる。見つかった差異はスクリーンショット付きでユーザーに
  提示し、都度確認を取りながら修正する(独断でデザインを変えない)

### UI スケール(Phase 3 で導入済み)への対応

Phase 3 で全体表示倍率(`AppDimensions.uiScale`。設定画面のスライダーで
1.0〜2.0 を変更可能)を導入した。Phase 4 の磨き込み・新規 UI 追加では、
この可変倍率下でもレイアウトが破綻しないことを確認すること
(固定 px の横並びは高倍率・小ウィンドウで溢れやすい。全単語テーブルは
最小幅未満で横スクロールにフォールバックする実装済みパターンを参照)。

### ストア提出準備(C4)

コード側:

- `pubspec.yaml` の `version` を `1.0.0+1` で確定(以後の提出ごとに +N)
- Bundle ID・表示名(`PRODUCT_NAME`)を `AppInfo.xcconfig` で確定
- `flutter build macos --release` が通り、リリースビルドで全機能が動くことを確認
  (**App Sandbox + network.client は設定済み**。Phase 4 で追加した
  user-selected.read-write が Release にも入っていることを再確認)
- App Category(`LSApplicationCategoryType` = `public.app-category.education`)を
  Info.plist に設定

人手作業(Apple Developer / App Store Connect。計画書としてはチェックリストのみ):

1. Apple Developer Program のメンバーシップ確認
2. App ID 登録・Mac App Store 用証明書(Distribution / Installer)作成
3. App Store Connect でアプリ作成(名称・プライバシーポリシー URL・スクリーンショット)
4. プライバシー「データ収集なし」+ 外部通信(dictionaryapi.dev / api-free.deepl.com /
   translate.google.com へのリンク)の申告を確認
5. Xcode(または `xcodebuild -exportArchive`)で署名付き .pkg を作成し
   Transporter でアップロード → 審査提出

## 実装の順序とコミット計画

分割理由: 4 つの独立した作業(機能追加 / 入力系 / 見た目 / 提出設定)を
それぞれ単独で検証・リバートできる単位に分ける。相互依存はなく、
C4(提出設定)のみ全コミット完了後に行う(リリースビルドの網羅確認のため)。

### C1: `feat: JSON エクスポート/インポートを追加`

検証: `flutter analyze` / `flutter test`(word_export_service_test:
エクスポート → インポートの roundtrip、updatedAt マージ規則、必須欠落スキップ、
未知 version 拒否)/ `flutter run -d macos`:
- エクスポートした JSON が上記フォーマットになっている
- 単語を編集してから古いファイルをインポート → 上書きされない(updatedAt 規則)
- 別 DB 状態(単語を数件削除)でインポート → 追加/更新/スキップ件数が正しい
- サンドボックスで保存/読込ダイアログが正常に動く(entitlements 確認)

### C2: `feat: キーボードショートカットを追加`

検証: `flutter analyze` / `flutter test` / `flutter run -d macos` で表のキーを一通り確認。
テキスト入力中に Space がクイズ操作に吸われない等の干渉がないこと。

### C3: `style: アニメーション・ホバー・アプリアイコンの磨き込み`

検証: `flutter analyze` / `flutter test` / `flutter run -d macos` でプロトタイプと並べて
見た目を比較。Dock・About にアイコンが反映されること。

### C4: `chore: Mac App Store 提出設定`

検証: `flutter build macos --release` 成功。リリースビルドを起動して
登録 → 自動入力 → クイズ → エクスポートの一連が動くこと(サンドボックスの
リリース entitlements で網羅確認)。

## 実装時に判断が揺れそうな箇所(選択肢と推奨)

1. **インポート方式**(確定済みの推奨)
   - A(推奨): マージ(上記の updatedAt 規則)。バックアップ復元と端末間移行の両方に安全
   - B: 全置換(既存を消してファイル内容にする)。単純だが誤操作で全損しうるため、
     採用するなら確認ダイアログ必須。MVP では A のみ実装し、B は作らない
2. **エクスポート/インポートの導線**
   - A(推奨): 設定画面のボタンのみ。シンプルで発見性も十分
   - B: `PlatformMenuBar` でメニューバー(ファイル > 書き出す...)にも載せる。
     macOS らしいが対応範囲が広がる。Phase 4 の余力があれば追加
3. **単語照合の大文字小文字**: マージキーは小文字化して比較(推奨)。
   ただし DB 上の表記は既存レコードを維持する
4. **ショートカットの実装方式**: `Shortcuts`/`Actions` が Flutter の作法だが、
   フォーカス管理が煩雑なら MainPage 直下の `CallbackShortcuts` に単純化してよい
   (推奨: まず CallbackShortcuts で素朴に。テキスト入力中の干渉だけ必ず確認)

## やらないこと(Phase 4 のスコープ外)

- iOS 対応・レスポンシブ(サイドバー ⇔ タブバー切替)— 将来構想
- iCloud Drive 経由の自動同期 — 将来構想(JSON 手動移行がその代替)
- LLM 統合・`--dart-define=ENABLE_AI` の分岐導入 — 将来構想
- 自動アップデート機構(Mac App Store 配布のため不要)
- アナリティクス・クラッシュレポート(サーバレス・プライバシー方針のため入れない)
