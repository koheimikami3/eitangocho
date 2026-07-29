# 設計ドキュメント

CLAUDE.md から参照される詳細仕様。UI の見た目(レイアウト・配色・寸法)は実装済みアプリと
[app_colors.dart](../lib/constants/app_colors.dart) / [app_dimensions.dart](../lib/constants/app_dimensions.dart)
のデザイントークンが正基準(当初は HTML プロトタイプを正としていたが、実装完了に伴い廃止)。

## 機能仕様(MVP スコープ)

1. **学習中リスト**: カードグリッド表示。日本語訳はクリックで表示(隠し状態がデフォルト)。
   チェックで学習済みにしてリストから消える
2. **全単語リスト**: テーブル表示。学習済みチェックの ON/OFF も可能
3. **フラッシュクイズ**: 学習済み単語からシャッフル出題。表面=英単語+IPA、
   裏面=訳+例文。「忘れていた」を選ぶと学習中リストに戻る。
   完了画面に「忘れていた単語」の一覧を表示
4. **単語登録**: 2 ステップフロー
   - Step 1: 英単語を入力 → 「自動入力」で辞書データ取得(またはスキップして手動入力)
   - Step 2: 取得結果がプレフィルされたフォームで確認・修正 → 保存
   - 辞書未収録時は警告バナー + 全項目手動入力にフォールバック
5. **編集・削除**: カード / テーブル行のクリックで編集モーダル。右クリックで
   コンテキストメニュー(編集 / 削除)。削除は確認ダイアログを挟む
6. **音声再生**: 辞書 API の audio(mp3 URL)があればアプリ内再生ボタン、
   無ければ Google 翻訳 URL への外部リンクにフォールバック。
   クイズでは英単語の発音ボタンのみ(英→日は表面、日→英は答え面に配置)
7. **空状態**: 学習中 0 件、クイズ対象 0 件それぞれに案内 + 導線ボタンあり

## 外部データソース(LLM は MVP では使わない)

| データ | ソース | 備考 |
|---|---|---|
| IPA・品詞・英例文・発音音声 URL | Free Dictionary API (`api.dictionaryapi.dev/api/v2/entries/en/<word>`) | キー不要・無料。取得結果はローカル DB にキャッシュし再フェッチしない |
| 単語の日本語訳(語義) | EJDict-hand(パブリックドメイン英和辞書)をアプリに同梱、初回起動時に DB へ取込 | 複数語義の列挙に対応 |
| 例文の日本語訳 | DeepL API Free(月 50 万文字、超過時は停止で課金なし) | 文の翻訳のみに使う。単語訳には使わない |
| 発音確認 URL | `https://translate.google.com/?sl=en&tl=ja&text=<word>&op=translate` を自動生成 | audio が無い場合のフォールバック |

- 取得チェーン: Free Dictionary API → (未収録なら)手動入力フォールバック
- 品詞は enum(verb / noun / adjective / adverb / other)で保持し、表示時に日本語変換。
  複数品詞は「動詞・名詞」のように連結表示。バッジ色: 動詞=青、形容詞=赤、名詞=紫

## データ設計の要点

- 単語レコードに `updatedAt` を必ず持たせる(iCloud 同期の競合解決に使う)
- クイズ履歴用に `lastReviewedAt` / 正答回数のカラムも検討
- JSON エクスポート/インポート機能を持つ(バックアップ兼デバイス間の手動移行手段)。
  同じフォーマットを iCloud 同期のスナップショットにも使う

## 開発フェーズ

- **Phase 1**: DB スキーマ(drift)、単語 CRUD、全単語テーブル表示
- **Phase 2**: 学習中/学習済みフィルタ、カードビュー、フラッシュクイズ
- **Phase 3**: 自動入力(Free Dictionary API + EJDict + DeepL)、音声再生
- **Phase 4**: JSON エクスポート/インポート、ショートカット、磨き込み、ストア提出
- **Phase 5**: iOS 版(タブバーシェル・ダークモード)、iCloud 同期

## 確定済みの設計判断(ユーザー承認済み・変更しないこと)

実装当初に確定し、コードだけからは意図が読み取りにくい判断を記録する。
(パッケージ選定など pubspec / コードから自明なものは省略)

- **品詞(複数)の保存**: `partsOfSpeech` は enum 名の CSV(例 `'verb,noun'`)を
  TEXT カラムに保存し、TypeConverter で `List<PartOfSpeech>` に変換する。
- **DB スキーマ**: words / ejdict_entries / dictionary_cache_entries を schemaVersion 1 で
  一括定義。iCloud 同期の削除ログ(deleted_words)追加で schemaVersion 2 になった
  (当初は「マイグレーションを発生させない」方針だったが、削除の伝播に必要と判断して改訂)。
  マイグレーションはテーブル追加のみで、既存 3 テーブルには触れない。
- **クイズ実績**: 記録はするが UI 表示はしない。回答毎に `lastReviewedAt` を更新し、
  「覚えている」で `correctCount` +1。出題は学習済み全件シャッフル。
- **設定値の保存先**: `shared_preferences`。DeepL API キーも含め平文保存を許容する
  (ローカル個人アプリのため。キーはコードには埋め込まない → 設定画面から入力)。
- **ウィンドウ**: 透明タイトルバー(MainFlutterWindow.swift の
  `titlebarAppearsTransparent` + `fullSizeContentView`)。
- **EJDict 同梱**: テキストを 1 ファイルに結合して asset 同梱し、初回起動時に drift へ
  バッチ INSERT する。
- **Debug ビルドの分離**: debug のみ Bundle ID に `.dev` サフィックスを付け、表示名も
  変えて(macOS は「(Dev)」、iOS は「 dev」)、サンドボックスコンテナ(単語 DB)と
  iCloud コンテナをストア配布版と分離する(開発ビルドが本番データを触らないため)。
  設定は macos/Runner/Configs/{Debug,Release,AppInfo}.xcconfig と
  ios/Flutter/{Debug,Release}.xcconfig。
  entitlements のコンテナ ID にも `$(BUNDLE_ID_SUFFIX)` を埋めて構成ごとに切り替える。

## iOS 版の設計判断

- **シェルの選択はプラットフォームで行い、画面幅では分岐しない**: macOS はサイドバー、
  iOS はタブバー。`uiScale` 既定 1.5 により macOS の論理幅は実測の 2/3 になるため、
  幅を基準にするとデスクトップがタブバー版に落ちてしまう。
- **iOS の画面は macOS と別ファイルにする**: 2 列カード ⇔ グリッド、行リスト ⇔ 8 列テーブル、
  ボトムシート ⇔ ダイアログと構造が異なり、共通化すると分岐だらけになるため。
  Provider・Notifier・DAO は共有し、presentation だけ分ける。
- **削除導線**: macOS は右クリックメニュー、iOS は編集シート内の「この単語を削除...」。
  iOS に長押しメニューは置かない(デザイン準拠)。
- **`uiScale` は macOS 専用**: iOS は OS の文字サイズ設定に委ねる。
  MediaQuery.size の差し替えはセーフエリア計算と噛み合わない。
- **ダークモードは iOS 専用**: `AppPalette`(ライト/ダーク)を `context.palette` で引く。
  macOS はリリース済みの外観を変えないため `AppColors` のライト固定のまま。
- **iPad**: 当面は iPhone 相当の幅にコンテンツを固定して中央寄せ。縦向きのみ。
- **iOS の表示名は「英単語帳」**(Debug は「英単語帳 dev」)。ホーム画面のアイコン
  ラベルは全角 6〜7 文字を超えると省略されるため、macOS の「シンプル英単語帳」より
  短くした。App Store の掲載名は App Store Connect 側で別に決められるので、
  ストア上の名前は揃えられる。iOS だけ Info.plist に表示名そのもの
  (`$(APP_DISPLAY_NAME)`)を持たせているのは、xcconfig が値の先頭空白を捨てるため、
  macOS と同じサフィックス方式では名前と「dev」の間に空白を入れられないから。
- **最低 OS は iOS 15.0**: Flutter テンプレート既定の 13.0 から引き上げた。13 / 14 は
  実機もシミュレータも手元に無く動作保証できないうえ、書き出しパネルに使う
  `UIDocumentPickerViewController(forExporting:asCopy:)` が iOS 14 以降のため。
  15 なら iPhone 6s 以降が対象になり、実質的に失うユーザーはいない。
- **JSON の書き出しは自前の MethodChannel**: `file_selector_ios` は `openFile` /
  `openFiles` しか実装しておらず、`getSaveLocation` を呼ぶと UnimplementedError に
  なる。iCloud 同期と同じ方針で、書き出しパネルだけを
  `ios/Runner/DocumentExportPlugin.swift` に持つ(macOS では不要なので `shared/` に
  置かない)。読み込みは `file_selector` のままだが、iOS の document picker は
  拡張子ではなく UTI で絞り込むため `XTypeGroup` に
  `uniformTypeIdentifiers` が必須。

## iCloud 同期の設計判断

- **方式**: アプリの iCloud コンテナに置いた JSON スナップショット 1 個。
  「読んでマージ → 全体を書き戻す」の 1 パスで双方向。競合解決は語単位の
  `updatedAt` 勝ちで、手動インポートと同じ `WordExportService` のロジックを使う。
- **ネイティブ層は自前の MethodChannel**: 必要な操作がコンテナ URL 取得・1 ファイルの
  読み書き・更新日時の 3 つだけで、更新の止まった外部パッケージを増やすより小さい。
  実装は `shared/IcloudFileStorePlugin.swift` に置き、両 Xcode プロジェクトから参照する。
- **削除の伝播**: `deleted_words`(トゥームストーン)。`words` は物理削除のままにし、
  一覧・検索・クイズの全クエリに除外条件を入れずに済ませる。
  保持期間は 180 日で、同期時に古いログを掃除する。
- **削除と更新の引き分けは削除の勝ち**: drift の DateTime は秒精度で保存されるため、
  編集直後に同じ秒で削除すると `updatedAt == deletedAt` になりうる。引き分けを
  更新の勝ちにすると、消したはずの単語が次の同期で復活する。
- **ローカル削除ログの尊重は同期時のみ**: 同期では自分の削除を復活させないために
  尊重するが、手動インポート(バックアップ復元)ではファイルの内容を復元するのが
  ユーザーの期待に沿うため尊重しない(`importJson` の `respectLocalDeletions`)。
- **同期の契機は 5 つ**: 起動時・有効化時・フォアグラウンド復帰時・ローカル変更後
  (デバウンス 5 秒)・「今すぐ同期」。当初は起動時・有効化時・「今すぐ同期」だけで
  実装したが、それだと登録した単語が次にアプリを開き直すまで上がらず、iOS ↔ macOS で
  実用に耐えなかったため復帰と変更後を足した。
- **復帰トリガが iOS では必須**: iOS はアプリを終了させずサスペンドするため、ホームに
  戻して開き直しても Flutter は再起動されず、起動時同期が走らない。
- **復帰トリガには最短間隔(60 秒)を置く**: macOS はウィンドウを行き来する度に
  `resumed` が来るため、ガードが無いとフォーカスを移すだけで書き戻しが走る。
- **ローカル変更の検知は drift の更新通知**(`tableUpdates` の words / deleted_words)。
  DAO の呼び出し元 9 箇所に同期呼び出しを散らすと、単語を変更する導線を足すたびに
  書き漏らすため。同期が有効な間だけ購読する。
- **クラウド側の変更監視はしない**: `NSMetadataQuery` は使わない。他端末の変更は
  上記の契機で取りに行く。

## 将来構想(実装しないが設計で考慮)

- iPad 専用レイアウト: 現状は iPhone 相当幅に固定しているだけ
- 同期のバックグラウンド実行・変更通知(`NSMetadataQuery`)
- LLM 統合(例文生成): `WordInfoProvider` の追加実装として。Ollama(ローカル)優先
