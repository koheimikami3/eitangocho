# Phase 3 実装計画: 自動入力(Free Dictionary + EJDict + DeepL)+ 音声再生

> 前提・確定済み設計判断は [overview.md](overview.md)、テーブル定義と `WordInfoProvider` 抽象の
> コードは [phase1.md](phase1.md) を参照(**Phase 1 で確定済み。ここでは変更しない**)。
> 本計画は設計書レベル。設計判断は確定済みだが、ファイル分割は実装時に微調整してよい。

## ゴール

- EJDict-hand(英和辞書)の asset 同梱と初回起動時の DB 取込
- Free Dictionary API / DeepL API クライアントと `DictionaryWordInfoProvider`
  (`WordInfoProvider` の実装)+ レスポンスキャッシュ
- 単語登録フローの 2 ステップ化(単語入力 → 自動入力 → 確認フォーム)
- 発音音声の再生(just_audio)と Google 翻訳リンクへのフォールバック
- 設定画面への DeepL API キー欄追加

**ブランチ名: `feature/phase3-autofill-audio`**(Phase 2 マージ後の main から作成)

## pubspec に追加するもの

- dependencies: `http: ^1.6.0`、`just_audio: ^0.10.6`、`url_launcher: ^6.3.2`
- `flutter.assets` に `assets/ejdict/` を追加

## 作成・変更するファイル(想定。実装時に微調整可)

### 変更

- `pubspec.yaml` / `pubspec.lock`(C1)
- `lib/db/app_database.dart`: EjdictDao / DictionaryCacheDao を daos に追加(C1, C2)
- `lib/features/word_registration/presentation/`: 2 ステップ化(C3)
- `lib/features/word/presentation/widgets/word_card.dart`(Phase 2 産)・
  `word_table_row.dart` / `word_table_header.dart`: 発音ボタン/リンク追加。
  テーブルに「発音」列(56px)を追加(C4)
- `lib/features/quiz/presentation/`: 表面/答え面に発音ボタン追加(C4)
- `lib/features/settings/`: DeepL キー欄追加(C5)

### 作成

- `assets/ejdict/ejdict-hand-utf8.txt` + `assets/ejdict/LICENSE`(CC0 全文)(C1)
- `lib/db/daos/ejdict_dao.dart`: `lookup(word)` / `bulkInsert` / `count`(C1)
- `lib/db/daos/dictionary_cache_dao.dart`: `find(word)` / `save(word, json)`(C2)
- `lib/features/word_registration/data/ejdict_importer.dart`: 初回取込ロジック(C1)
- `lib/features/word_registration/data/free_dictionary_api_client.dart`(C2)
- `lib/features/word_registration/data/free_dictionary_response.dart`: Freezed レスポンスモデル(C2)
- `lib/features/word_registration/data/deepl_client.dart`(C2)
- `lib/features/word_registration/data/dictionary_word_info_provider.dart`:
  WordInfoProvider 実装 + `wordInfoProviderProvider`(C2)
- `lib/components/pronunciation_button.dart`: 発音ボタン/リンク(機能横断)(C4)
- `lib/providers/audio_player_provider.dart`: just_audio プレイヤー(C4)
- `lib/utils/google_translate_url.dart`: 発音確認 URL 生成(C4)
- テスト: `ejdict_importer_test`、`free_dictionary_api_client_test`(フィクスチャ JSON)、
  `deepl_client_test`、`dictionary_word_info_provider_test`(フェイク合成)、
  registration notifier の自動入力テスト

## 設計

### EJDict の同梱と初回取込(C1)

**asset の作成手順**(実装者がリポジトリ準備として 1 回実行し、結果をコミットする):

```bash
mkdir -p assets/ejdict
for c in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
  curl -fsSL "https://raw.githubusercontent.com/kujirahand/EJDict/master/src/$c.txt"
done > assets/ejdict/ejdict-hand-utf8.txt
curl -fsSL "https://raw.githubusercontent.com/kujirahand/EJDict/master/LICENSE" \
  -o assets/ejdict/LICENSE
```

- 形式: 1 行 1 エントリ「`単語<TAB>訳文字列`」(訳内の複数語義は ` / ` 区切りの原文のまま)。
  計約 4.4MB・5〜6 万行。CC0 なのでそのままコミットしてよい(LICENSE を同梱する)

**取込(ejdict_importer.dart)**:

- 判定: `EjdictDao.count() == 0` なら未取込(shared_preferences のフラグより DB 自体を
  見るほうが、DB ファイル削除時に自動復旧できる)
- `rootBundle.loadString` → 行分割 → `\t` で 2 分割(2 要素未満の行はスキップ)。
  同一単語が複数行ある場合は改行で連結して 1 レコードにする
- drift の `batch` + `insertAll(mode: InsertMode.insertOrReplace)` を 5,000 行程度の
  チャンクで実行(1 トランザクション内)
- 実行タイミング: アプリ起動時に `FutureProvider`(keepAlive)で開始。
  完了前に自動入力が呼ばれた場合は完了を await する。UI は起動をブロックしない
  (下記「揺れそうな箇所」1 参照)

### Free Dictionary API クライアント(C2)

- `GET https://api.dictionaryapi.dev/api/v2/entries/en/{word}`(URL エンコード必須)
- 200 → `List<FreeDictionaryEntry>` をパース、404 → `null`(未収録)、
  それ以外・タイムアウト・SocketException → `WordInfoException`
- レスポンスモデル(Freezed + json_serializable)。**CLAUDE.md 規約: 欠落しうるフィールドを
  `required` にしない**。実レスポンスで欠落し得るのは `phonetic`、`phonetics[].text`、
  `phonetics[].audio`、`definitions[].example` など:

```dart
FreeDictionaryEntry { String? word, String? phonetic,
    @Default([]) List<FdPhonetic> phonetics, @Default([]) List<FdMeaning> meanings }
FdPhonetic { String? text, String? audio }
FdMeaning  { String? partOfSpeech, @Default([]) List<FdDefinition> definitions }
FdDefinition { String? definition, String? example }
```

- WordInfo へのマッピング(先頭エントリを優先しつつ全エントリを走査):
  - `ipa`: `phonetic` → なければ `phonetics[].text` の最初の非空値
  - `audioUrl`: `phonetics[].audio` の最初の非空値
  - `partsOfSpeech`: `meanings[].partOfSpeech` を enum 変換して重複排除。
    verb / noun / adjective / adverb 以外(pronoun, preposition 等)は `other`
  - `exampleEn`: `definitions[].example` の最初の非空値

### DeepL クライアント(C2)

- `POST https://api-free.deepl.com/v2/translate`、
  ヘッダ `Authorization: DeepL-Auth-Key {key}`、
  ボディ `{"text": ["{exampleEn}"], "source_lang": "EN", "target_lang": "JA"}`(JSON)
- レスポンス `translations[0].text` を exampleJa に使う
- 呼び出し条件: DeepL キーが設定済み **かつ** exampleEn が取得できたときのみ
  (design.md: 文の翻訳のみに使う。単語訳には使わない)
- 失敗(キー不正・上限超過・ネットワーク)は WordInfoException にせず
  **exampleJa 空のまま続行**し、フォームに警告を出す(下記「揺れそうな箇所」3)

### DictionaryWordInfoProvider(C2)

`WordInfoProvider` の実装。処理順:

1. `word.trim().toLowerCase()` をキーに `dictionary_cache_entries` を確認。
   ヒットすれば API を呼ばず保存済み JSON をパース(design.md: 再フェッチしない)
2. キャッシュ miss → Free Dictionary API。成功したら生 JSON をキャッシュ保存
3. EJDict を lookup し `japanese` に設定(複数語義は原文のまま。ユーザーがフォームで削る)
4. exampleEn があり DeepL キーが設定済みなら翻訳して `exampleJa`
5. 返却: FD・EJDict の**両方 miss なら null**(未収録)。どちらかヒットなら WordInfo

Riverpod 公開(実装差し替え可能に):

```dart
@riverpod
WordInfoProvider wordInfoProvider(Ref ref) => DictionaryWordInfoProvider(...);
```

登録 Notifier はこの Provider 経由でのみ取得する(具象クラスを直接 new しない)。

### 登録フローの 2 ステップ化(C3)

プロトタイプの `addStep`(input / loading / form)を `WordRegistrationState` に追加する。

- **ステップ 1(input)**: 説明文
  「英単語を入力すると、発音記号・日本語訳・例文などを辞書から自動取得します。」、
  英単語欄(placeholder `serendipity`)+「自動入力」ボタン(Enter キーでも発火)、
  下に「スキップして手動で入力する」リンク(→ 空フォームへ)。
  空のまま自動入力 → エラー「英単語を入力してください。」
  ※プロトタイプ最下部の「プロトタイプ用デモ: ...」の注記は実装しない
- **loading**: スピナー +「辞書データを取得中...」。`WordInfoException` 時はステップ 1 に
  戻してエラー表示(文言例「辞書データの取得に失敗しました。通信環境を確認してください。」)
- **ステップ 2(form)**: Phase 1 のフォームを流用し、取得値をプレフィル。
  - 自動取得できた項目のラベル横に「自動入力」バッジ(10px、背景 #E2F3E8 / 文字 #1C7A3F。
    AppColors に追加)。ユーザーがその項目を**空にしたら**バッジを消す(プロトタイプ準拠)
  - fetch が null(未収録)→ 警告バナー「辞書に見つかりませんでした。手動で入力できます。」
    (背景 #FDF6E3 / 枠 #ECD9A0 / 文字 #8A6D1A。AppColors に追加)+ 全項目手動
  - `audioUrl` はフォームに出さず state に保持し、保存時に words へ書き込む
  - ボタン列: 登録する / 戻る(ステップ 1 へ)/ キャンセル
- プレフィルの実装: Phase 1 で View 側 TextEditingController にしているので、
  Notifier の state に `WordInfo? fetched` を持たせ、View がステップ遷移時に
  controller へ反映する(または controller を Notifier 管理に寄せる。実装時に判断)

### 音声再生とフォールバック(C4)

- `lib/utils/google_translate_url.dart`:
  `https://translate.google.com/?sl=en&tl=ja&text={word}&op=translate`(URL エンコード)
- `lib/providers/audio_player_provider.dart`: `AudioPlayer`(just_audio)を 1 インスタンス
  keepAlive で保持。`play(url)` は再生中なら止めてから `setUrl` → `play`。
  再生失敗(URL 切れ等)は SnackBar 等で軽く通知し、クラッシュさせない
- `lib/components/pronunciation_button.dart`: `audioUrl` が非空 → 円形の再生ボタン
  (28px、スピーカーアイコン、背景 inputBackground)。空 → 「発音を確認 ↗」リンク
  (テーブル行では「↗」のみ)を url_launcher で開く
- 配置(プロトタイプ準拠):
  - カード: フッター右端(28px ボタン or リンク)
  - テーブル: 「発音」列(56px、26px ボタン or ↗)をヘッダ・行に追加
  - クイズ: 英→日は表面の単語横(32px)、日→英は答え面の英単語横(28px)。
    audio なしのときは表面下に「発音を確認 ↗」リンク
  - クリックは行・カードのクリック(編集モーダル)に伝播させない

### 設定画面に DeepL キー欄(C5)

- `SettingsNotifier` に `deeplApiKey`(String、既定 ''、キー名 `deeplApiKey`)を追加
- 設定ビューに入力欄 + 説明文(例「DeepL API Free のキーを設定すると、
  自動入力時に英例文の日本語訳を取得します(未設定なら例文の和訳はスキップ)」)。
  `obscureText` は不要(ローカルアプリ・平文保存は確定済みの判断)

## 実装の順序とコミット計画

分割理由: データ層(C1・C2)を UI(C3〜C5)から切り離し、UI なしでテストだけで
検証できる状態を先に作る。C3 は C2 の WordInfoProvider 実装に、C5 は C2 の
DeepL クライアントと Phase 2 の設定画面に依存する。C4(音声)は C3 と独立。

### C1: `feat: EJDict を同梱し初回起動時に取り込む`

asset 追加 + EjdictDao + importer + 起動時実行 + テスト(パーサ: タブ分割・不正行スキップ・
重複単語の連結。in-memory DB への取込)。

検証: `flutter analyze` / `flutter test` / `flutter run -d macos`
(初回起動ログで取込件数を確認 → 再起動でスキップされること。
DB は `~/Library/Containers/<bundle id>/Data/...` 配下。迷ったら `drift` の DB パスをログ出力)

### C2: `feat: 辞書 API クライアントと WordInfoProvider 実装を追加`

FD/DeepL クライアント + キャッシュ DAO + DictionaryWordInfoProvider + テスト
(http は `MockClient`(package:http/testing)を使用。フィクスチャに「phonetics が空」
「example なし」「404」を含める。合成テストはフェイク実装で FD×EJDict×DeepL の組合せを検証)。

検証: `flutter analyze` / `flutter test`

### C3: `feat: 単語登録を 2 ステップ化し自動入力に対応`

検証: `flutter analyze` / `flutter test` / `flutter run -d macos` で実 API 手動確認:
- `serendipity` → IPA・品詞・訳(EJDict)・例文がプレフィルされ「自動入力」バッジが付く
- プレフィル値を空にするとバッジが消える
- 実在しない単語(例 `zzzzz`)→ 未収録バナー + 全項目手動
- 同じ単語を再度自動入力 → 2 回目はキャッシュから即時(ネットワークログで確認)
- Wi-Fi を切って自動入力 → ステップ 1 にエラー表示
- 「スキップして手動で入力する」「戻る」「キャンセル」の遷移

### C4: `feat: 発音再生と Google 翻訳リンクフォールバックを追加`

検証: `flutter analyze` / `flutter test` / `flutter run -d macos`:
- audio あり単語(例 `serendipity`)でカード・テーブル・クイズから再生できる
- audio なし単語で「発音を確認 ↗」が Google 翻訳をブラウザで開く
- 再生ボタンクリックで編集モーダルが開かない(伝播停止)

### C5: `feat: 設定画面に DeepL API キー欄を追加`

検証: `flutter analyze` / `flutter test` / `flutter run -d macos`:
- キー設定後の自動入力で日本語例文までプレフィルされる
- キー未設定・不正キーでも自動入力自体は成功し、例文和訳だけ空になる

## 実装時に判断が揺れそうな箇所(選択肢と推奨)

1. **EJDict 取込中の UX**
   - A(推奨): バックグラウンドで取り込み、UI はブロックしない。取込前に自動入力が
     呼ばれたら FutureProvider の完了を await(体感数秒)。初回起動が最速
   - B: 初回起動時に取込完了までローディングオーバーレイを出す。分かりやすいが
     取込に失敗した場合のリカバリ UI も必要になる
2. **FD 未収録・EJDict のみヒット時の扱い**(確定済みの推奨方針)
   - A(推奨): `japanese` のみの WordInfo を返してプレフィルする。UI は「返却 WordInfo の
     ipa・exampleEn・audioUrl がすべて空」のとき警告バナーを
     「発音記号・例文は辞書に見つかりませんでした(訳のみ自動入力)」に変える。
     EJDict は約 5〜6 万語で FD より収録が広く、訳プレフィルの価値が高い
   - B: プロトタイプ厳密準拠(FD 未収録なら即 null → 全項目手動)。シンプルだが
     EJDict にある訳を捨てることになる
3. **DeepL 失敗時の表示**
   - A(推奨): exampleJa 空のまま続行し、フォーム上部に小さく
     「例文の翻訳に失敗しました(手動で入力できます)」と表示。登録は妨げない
   - B: エラーダイアログ。翻訳は補助機能なので過剰
4. **キャッシュと EJDict の関係**: キャッシュするのは FD レスポンスのみ。EJDict は
   ローカル DB なのでキャッシュ不要。DeepL の結果は words に保存されるため再翻訳は
   同一単語の再登録時のみ発生(許容する。DeepL 結果のキャッシュは作らない)

## やらないこと(Phase 3 のスコープ外)

- JSON エクスポート/インポート(Phase 4)
- キーボードショートカット・アニメーション磨き込み(Phase 4)
- LLM による例文生成(`WordInfoProvider` の別実装。MVP 外)
- DeepL 使用量の表示・上限管理(Free プランは超過時に自動停止するため作らない)
- Free Dictionary キャッシュの有効期限・手動クリア(再フェッチしない方針のため作らない)
