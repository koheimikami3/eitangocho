# 設計ドキュメント

CLAUDE.md から参照される設計判断の記録。コードだけからは意図が読み取りにくい判断と、
外部データソースの仕様をまとめる。

機能の仕様と UI の見た目(レイアウト・配色・寸法)は実装済みアプリと
[app_colors.dart](../lib/constants/app_colors.dart) / [app_palette.dart](../lib/constants/app_palette.dart) /
[app_dimensions.dart](../lib/constants/app_dimensions.dart) のデザイントークンが正基準。

## 外部データソース(LLM は使わない)

| データ | ソース | 選定理由 |
|---|---|---|
| IPA(米音優先)・品詞・英例文 | kaikki.org (`kaikki.org/dictionary/English/meaning/<頭字>/<頭2字>/<単語>.jsonl`) | Wiktionary を構造化した静的 JSONL。キー不要・無料で、3 項目が 1 リクエストで揃う |
| 英例文 + 対訳 | Tatoeba (`api.tatoeba.org/unstable/sentences`) | 訳文が対でぶら下がる唯一のソース。学習者向けの短文が多い |
| 単語の日本語訳(語義) | EJDict-hand(パブリックドメイン英和辞書)をアプリに同梱、初回起動時に DB へ取込 | 英和辞典の語義で、kaikki の訳語列挙より情報量が多い。オフラインで確実 |
| 例文の日本語訳(予備) | DeepL API Free | Tatoeba が空振りしたときのみ。設定 UI は隠してあり実質使わない(下記) |
| 発音確認 URL | `https://translate.google.com/?sl=en&tl=ja&text=<word>&op=translate` を自動生成 | 発音確認の唯一の導線。全単語で外部ブラウザに開く |

- 取得チェーン: kaikki → Tatoeba → (どちらも無ければ)手動入力フォールバック。
  EJDict は常に引く。例文は Tatoeba を優先し、空振り時だけ kaikki の英例文を使う
- kaikki の取得結果はローカル DB にキャッシュし再フェッチしない。Tatoeba は
  登録時に 1 回引くだけでキャッシュのヒット率が低いため保存しない
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
  辞書(kaikki)が返した語義順(= その語の主用法が先頭。`run` なら動詞が先)
  をそのまま保存する。手動で選んだ分だけ enum の宣言順で後ろに足す
  (`PartOfSpeechSelection.ordered`)。チップのタップ順で保存すると、
  付け外ししただけでバッジ色が変わってしまうため。
- **辞書ソースを Free Dictionary から kaikki に替えた**: 理由は 2 つ。(1) FD は
  ラップ元である Wiktionary のデータを一部しか返しておらず、同一 59 語で英例文の
  取得率が FD 76% に対し Wiktionary 直取り 88% だった。(2) FD 自体が不安定で、
  `phrase` / `impact` / `actual` / `season` のような常用語でも 502 を返す時間帯が
  あった。kaikki(wiktextract)は Wiktionary のダンプから生成された静的 JSONL で、
  IPA・品詞・例文が 1 リクエストで揃う。**ダンプから誰でも再生成できるため
  ベンダーロックインが無い**のが最大の利点で、サイトが落ちたら Wiktionary REST
  (品詞・例文)と ipa-dict の同梱(IPA)に移せる。`WordInfoProvider` 実装の
  差し替えで済むよう、この 2 つは移行先候補として控えに置く。
  - 大文字小文字を区別する。`september` は 404 で `September` が 200 なので、
    404 なら頭大文字で引き直す
  - 生の JSONL は 1 語 20〜170KB あるため、使う項目だけに詰め直してキャッシュする
    (`apple` で 168KB → 約 1KB)。文献引用(`type: quotation`)は捨てる
  - IPA は方言タグ(`US` / `General-American`)で米音を優先し、`[...]` の異音表記は
    使わない。品詞は kaikki の略号(`adj` / `adv`)で来る
- **辞書の取得失敗で登録フロー全体を止めない**: kaikki が落ちていても EJDict の訳が
  あれば `WordInfoException` を投げずに続行する。何も得られなかったときだけ投げる。
  FD 時代は 502 のたびに登録そのものができなくなっていた。「取得できない」を
  「辞書に未収録」と誤解させないため、EJDict も miss なら例外にする
- **例文は Tatoeba を第一候補にする**: 訳文が対で付いてくるので、DeepL を呼ばずに
  英例文と和訳が同時に埋まる。kaikki の例文は語義説明が目的で、`obtain permission`
  のような句の断片や文献引用が混ざり単語帳には向かない。実測(70 語)で
  Tatoeba が 86%、kaikki が残り 10% を拾い、例文ゼロは 4% だった
- **例文は必ず語形フィルタを通す**(`word_form_matcher.dart`): Tatoeba の検索は
  ステミングするため、`negligible` で引くと `negligence` の文しか返らないことが
  ある(引用符で囲んでも無効)。kaikki 側も語義ごとに派生語の文が混ざる。
  フィルタを通さないと別の単語の例文を登録してしまう。見出し語化は行わないので、
  活用形で登録された単語は空振りする(原形で登録する前提)
- **DeepL の設定 UI は隠した(コードは残す)**: API キーを用意できる利用者がほぼ
  おらず、欄があるだけで何のことか分からず混乱を招いていた。Tatoeba が訳を返す
  ようになり、DeepL の出番は「Tatoeba が空振りして kaikki の例文を採った」数%
  だけになった。設定値・`DeeplClient`・チェーン内の翻訳ステップは残してあり、
  コメントアウトを外せば戻せる。既にキーを保存済みの端末では動き続ける
- **発音は音声再生をやめて Google 翻訳リンクに一本化した**: Free Dictionary API の
  音声配信(`api.dictionaryapi.dev/media/...`)のオリジンが落ちており、mp3 の代わりに
  502 が返る。鳴る単語は Cloudflare が期限切れコピーを返しているだけで(`cf-cache-status:
  STALE`)、同じ URL が数十分で 200 → 502 に変わる。単語ごとにファイルが有る / 無いの
  差ではないため、登録時に生存確認して URL を選び直しても意味がない。
  復活させるなら端末内蔵の TTS(`AVSpeechSynthesizer`)が第一候補。
  **辞書ソースを kaikki に替えた際に `audioUrl` の取得もやめた**(kaikki も
  Wiktionary REST も音声 URL を返さず、復活案が端末内蔵 TTS である以上不要)。
  カラム・`WordInfo` のフィールド・エクスポート項目は残してあり、以後は常に空。
  既存データと iCloud 同期の JSON フォーマットを壊さないため。
- **DB スキーマ**: words / ejdict_entries / dictionary_cache_entries を schemaVersion 1 で
  一括定義。iCloud 同期の削除ログ(deleted_words)追加で schemaVersion 2 になった
  (当初は「マイグレーションを発生させない」方針だったが、削除の伝播に必要と判断して改訂)。
  辞書ソースの入れ替えで schemaVersion 3 になった。**テーブル構造は一貫して
  追加のみで、既存 3 テーブルの定義には触れていない**。v3 は
  `dictionary_cache_entries` の行を消すだけ(Free Dictionary の生レスポンスが
  入っており kaikki のパーサでは読めないため。次の自動入力で入れ直される)。
- **クイズ実績**: 記録はするが UI 表示はしない。回答毎に `lastReviewedAt` を更新し、
  「覚えている」で `correctCount` +1。出題は学習済み全件シャッフル。
- **JSON エクスポート/インポート**: バックアップ兼デバイス間の手動移行手段。
  同じフォーマットを iCloud 同期のスナップショットにも使う。
- **設定値の保存先**: `shared_preferences`。DeepL API キーも含め平文保存を許容する
  (ローカル個人アプリのため。キーはコードには埋め込まない → 設定画面から入力。
  ただし現在その入力欄は隠してある。上記)。
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
- **バージョン番号は両プラットフォームで共通**(`pubspec.yaml` の 1 つを macOS / iOS の
  両方が読む)。1.0.0 は macOS のみ、**1.1.0 = iCloud 同期対応で macOS の 2 本目 /
  iOS の 1 本目**。ビルド番号は App Store 側ではプラットフォームごとに独立して
  採番できるが、pubspec が 1 つしか持てないため、片方だけ出し直したいときは
  `--build-number` で明示する。

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

## ライセンス表示

設定画面の「情報」セクション(バージョン + ライセンス)から、ライセンス一覧 →
全文へプッシュ遷移する。**ストア配布前に必須**(下記の帰属表示義務は有料化・
広告表示でも免除されない)。

- **一覧は自前で組む**。Flutter 標準の `showLicensePage` は Material の見た目で
  独自デザインから浮くため、`LicenseRegistry` から読んで自前の画面に流す
  (`license_list_provider.dart`)。pub パッケージ分は Flutter が自動収集し、
  同梱データと外部 API 由来の帰属情報だけ `registerDataSourceLicenses` で足す
- **一覧の副題(`MIT License` 等)は本文から推測している**。`LicenseEntry` は
  本文しか持たず種別を教えてくれないため。判別できないものは件数表記に落とす
- **パッケージのライセンスはビルド時生成の `NOTICES` から来る**ので、
  `flutter test` では 0 件になる(実ビルドでは 216 パッケージ / 1645 ブロック)。
  ウィジェットテストでは Provider を差し替えて検証する
- **バージョンはネイティブのバンドルから取る**(`package_info_plus`)。
  定数で持つと pubspec と二重管理になり上げ忘れる
- **遷移の形はプラットフォームで変える**(デザインどおり)。iOS はプッシュ遷移で
  一覧 → 全文の 2 画面、macOS は 520px のモーダル。macOS は全文も同じダイアログ内で
  一覧と入れ替える(ウィンドウ全体を覆う遷移を挟むと設定画面から遠くなるため)
- iOS の戻るボタンの色はデザインの `#1e7fd6` ではなく `palette.accent`(`#429FF0`)。
  `#1e7fd6` はデザイン内で広告 / Pro の導線に付く色で役割が違う
- **データ書き出しのボタン名は macOS だけ `...` を残す**(デザインからは消えたが
  ユーザー判断で維持)。ダイアログが開くことを示す macOS の慣習に沿う

### 各ソースのライセンスと必要な表示

| ソース | ライセンス | 商用利用 | 必要な表示 |
|---|---|---|---|
| kaikki / Wiktionary | CC BY-SA 4.0 + GFDL | 可 | 帰属表示 + Wiktionary へのリンク。kaikki は Ylonen 2022 の引用と kaikki.org へのリンクを希望 |
| Tatoeba | CC BY 2.0 FR | 可 | `sentences are from Tatoeba (https://tatoeba.org), released under CC-BY 2.0 FR`(公式の推奨文。テキストは投稿者個人のクレジット不要) |
| EJDict-hand | CC0 / パブリックドメイン | 可 | 不要 |

CC BY-SA の ShareAlike はデータの改変物に及ぶもので、表示するだけのアプリの
ソースコードには及ばない。**非商用限定のソース(Wordnik、Merriam-Webster)は
この理由で候補から外した**。将来の広告表示・課金と両立しなくなるため。

## 将来構想(実装しないが設計で考慮)

- iPad 専用レイアウト: 現状は iPhone 相当幅に固定しているだけ
- 同期のバックグラウンド実行・変更通知(`NSMetadataQuery`)
- LLM 統合(例文生成): `WordInfoProvider` の追加実装として。Ollama(ローカル)優先
- **多言語化(日本語以外の訳を出す)**: 必要なピースは現構成のまま揃う。
  - 単語の訳: kaikki の `translations`(`apple` で 306 言語、常用語で 60 前後)。
    EJDict に相当する辞書が無い言語はこれで代替する。`KaikkiEntry` は今のところ
    この項目を読み飛ばしている
  - 例文の訳: Tatoeba の `trans:lang` を差し替えるだけ。ただしコーパスの厚みは
    言語差が大きい(英 204 万文 / 日 25 万 / 中 8.9 万 / 韓 1.6 万)。同一 20 語での
    実測カバレッジは仏独葡 20/20、西中伊 19/20 に対し韓 13/20。薄い言語では
    「例文の訳は付かず、英例文と単語訳だけ」になる想定が要る
  - `WordInfoProvider` に言語パラメータを足す形にすれば、層の構成は変えずに済む
