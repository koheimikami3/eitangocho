# 設計ドキュメント

CLAUDE.md から参照される設計判断の記録。コードだけからは意図が読み取りにくい判断と、
外部データソースの仕様をまとめる。

機能の仕様と UI の見た目(レイアウト・配色・寸法)は実装済みアプリと
[app_colors.dart](../lib/constants/app_colors.dart) / [app_palette.dart](../lib/constants/app_palette.dart) /
[app_dimensions.dart](../lib/constants/app_dimensions.dart) のデザイントークンが正基準。

## 外部データソース(LLM は使わない)

| データ | ソース | 備考 |
|---|---|---|
| IPA・品詞・英例文・発音音声 URL | Free Dictionary API (`api.dictionaryapi.dev/api/v2/entries/en/<word>`) | キー不要・無料。取得結果はローカル DB にキャッシュし再フェッチしない |
| 単語の日本語訳(語義) | EJDict-hand(パブリックドメイン英和辞書)をアプリに同梱、初回起動時に DB へ取込 | 複数語義の列挙に対応 |
| 例文の日本語訳 | DeepL API Free(月 50 万文字、超過時は停止で課金なし) | 文の翻訳のみに使う。単語訳には使わない |
| 発音確認 URL | `https://translate.google.com/?sl=en&tl=ja&text=<word>&op=translate` を自動生成 | audio が無い場合のフォールバック |

- 取得チェーン: Free Dictionary API → (未収録なら)手動入力フォールバック
- 品詞は enum(noun / verb / adjective / adverb / other)で保持し、表示時に日本語変換。
  複数品詞は「名詞・動詞」のように連結表示。バッジ色: 名詞=青、動詞=緑、形容詞=赤、
  副詞=紫、その他=グレー

## 確定済みの設計判断(ユーザー承認済み・変更しないこと)

実装当初に確定し、コードだけからは意図が読み取りにくい判断を記録する。
(パッケージ選定など pubspec / コードから自明なものは省略)

- **品詞(複数)の保存**: `partsOfSpeech` は enum 名の CSV(例 `'noun,verb'`)を
  TEXT カラムに保存し、TypeConverter で `List<PartOfSpeech>` に変換する。
- **品詞バッジの配色は測って決める**: 色相を 70 度以上離し、紫と青・赤と緑のように
  色覚特性で潰れる組には明度差(0.10〜0.12)を付ける。出番の多い品詞ほど淡く、
  まれな品詞ほど濃くするため、名詞=青 → 動詞=緑 → 形容詞=赤 → 副詞=紫 の割り当てにした
  (当初はプロトタイプのピル定義順のままで、名詞=紫 / 動詞=青 が赤緑色覚でほぼ同色だった)。
  文字は 10px なのでチップ背景に対して 4.5:1 以上を必須にし、テストで保証する。
  ライトの値は `PartOfSpeech` の定数、ダークは `AppPalette.posBadge` が持つ
  (macOS はライト固定で enum を直接引くため、ライトを二重に持たない)。
- **品詞の並び順には意味がある**: バッジ色は先頭の品詞で決まる。自動入力では
  Free Dictionary API が返した語義順(= その語の主用法が先頭。`run` なら動詞が先)
  をそのまま保存する。手動で選んだ分だけ enum の宣言順で後ろに足す
  (`PartOfSpeechSelection.ordered`)。チップのタップ順で保存すると、
  付け外ししただけでバッジ色が変わってしまうため。
- **DB スキーマ**: words / ejdict_entries / dictionary_cache_entries を schemaVersion 1 で
  一括定義。iCloud 同期の削除ログ(deleted_words)追加で schemaVersion 2 になった
  (当初は「マイグレーションを発生させない」方針だったが、削除の伝播に必要と判断して改訂)。
  マイグレーションはテーブル追加のみで、既存 3 テーブルには触れない。
- **クイズ実績**: 記録はするが UI 表示はしない。回答毎に `lastReviewedAt` を更新し、
  「覚えている」で `correctCount` +1。出題は学習済み全件シャッフル。
- **JSON エクスポート/インポート**: バックアップ兼デバイス間の手動移行手段。
  同じフォーマットを iCloud 同期のスナップショットにも使う。
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
- **バージョンは両プラットフォームで共通**(`pubspec.yaml` の 1 つを macOS / iOS の
  両方が読む)。1.0.0 は macOS のみ、**1.1.0 = iCloud 同期対応で macOS の 2 本目 /
  iOS の 1 本目**。ビルド番号は共通なので、どちらかに提出した番号は再利用せず
  単調増加させる(1.0.0(1)を macOS で提出済みのため 1.1.0 は +2 から)。
  片方だけ差し替えたいときは `--build-number` で明示する。

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
- **iPad**: ストアの対象デバイスは iPhone のみ(`TARGETED_DEVICE_FAMILY = 1`)。
  iPad 専用レイアウトが無く、対象に含めると 13 インチのスクリーンショットが必須に
  なるため。コード側は iPhone 相当の幅にコンテンツを固定して中央寄せしてあるので、
  iPad で動かす場合(互換モード)も破綻しない。向きは縦のみ。
- **輸出コンプライアンス**: `ITSAppUsesNonExemptEncryption = false` を Info.plist に
  持つ。暗号は OS の HTTPS / iCloud だけで独自実装が無く規制対象外のため、
  アップロードごとの回答を省ける。
- **学習中カードの並びは設定で 1 列 / 2 列**(既定 2 列、iOS のみ)。列数は
  `LearningCardLayout`(設定 enum)が持ち、`AppDimensions` には定数を置かない。
  カードヘッダの組み方も列数で変える: 2 列は単語が 1 行を占有して次の行に
  IPA(左)と品詞(右)、IPA が非表示なら品詞は左寄せ。1 列は幅に余裕があるので
  単語・IPA・品詞を 1 行に並べ、品詞だけ右端に寄せる。
  2 列の IPA と品詞は `Wrap` で組み、1 行に収まらないときは品詞を次の行へ落とす
  (`Row` で詰めると、品詞が多いカードで IPA の幅が潰れて数行に折り返す)。
  英例文の確保行数も列数で変える(2 列は 3 行、1 列は 2 行)。
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
