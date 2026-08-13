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
| 単語の日本語訳(予備) | kaikki の `translations`(1.4.0) | EJDict が未収録の見出し(句動詞がほぼこれ)を埋める。既に引いている JSONL の中にあり追加リクエストが要らない |
| 例文の日本語訳(予備) | DeepL API Free | Tatoeba が空振りしたときのみ。設定 UI は隠してあり実質使わない(下記) |
| 発音確認 URL | `https://translate.google.com/?sl=en&tl=ja&text=<word>&op=translate` を自動生成 | 発音確認の唯一の導線。iOS はアプリ内の WebView、macOS は外部ブラウザで開く(1.2.0 以降。下記) |

- 取得チェーン: kaikki → Tatoeba → (どちらも無ければ)手動入力フォールバック。
  EJDict は常に引く。例文は Tatoeba を優先し、空振り時だけ kaikki の英例文を使う。
  日本語訳は EJDict を優先し、未収録のときだけ kaikki の訳語に落とす
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
- **例文の長さは「下限以上の中で最短」で決める(1.4.0 で 3 語 → 6 語)**:
  - **短さを決めているのは下限ではなくソートの方**。下限は「これを下回る文は
    後回し」であって上限ではないので、下げると例文は短くなる
  - 当初の下限 3 語では `He is diligent.` / `Are ghosts real?` /
    `Tom is reluctant.` が選ばれ、例文として文脈が足りていなかった
    (実測 25 語で平均 4.2 語)。6 語にすると平均 6.0 語になり、
    `Yoshiko is very diligent in knitting.` のような文に変わる
  - **8 語まで上げない**。7/25 が下限に届かず降格するうえ、`negligible` で
    21 語の文が選ばれる。学習中カードの英例文は 2 行固定なので切れる
  - **候補の取得件数も 10 → 30 に増やす**。下限を上げたぶん、下限を満たす文が
    候補に入る確率を上げる必要がある。副次的に、10 件では語形フィルタを通る文が
    1 つも無く例文ゼロだった語(`gradual`)も拾えるようになった
  - **長短の比較は文字数ではなく語数**。下限を語数で見ているので基準を揃える
    (文字数だと、語数が少なく 1 語が長い文が「長い文」として勝つ)
  - **kaikki 側の下限 4 語は据え置き**。あちらは `obtain permission` のような
    断片を除くためのハード条件で目的が違い、上げると例文が丸ごと消える
- **例文は必ず語形フィルタを通す**(`word_form_matcher.dart`): Tatoeba の検索は
  ステミングするため、`negligible` で引くと `negligence` の文しか返らないことが
  ある(引用符で囲んでも無効)。kaikki 側も語義ごとに派生語の文が混ざる。
  フィルタを通さないと別の単語の例文を登録してしまう。見出し語化は行わないので、
  活用形で登録された単語は空振りする(原形で登録する前提)
- **句動詞(1.4.0)は kaikki と Tatoeba だけで成立し、日本語訳は手入力になる**:
  - kaikki は空白入りの見出しをそのまま配信する。**2 文字プレフィックスも
    空白込み**(`a la carte` は `/a/a%20/a%20la%20carte.jsonl`)なので、
    単語と同じパス組み立てで引ける。**クライアントに分岐は要らない**
  - Tatoeba も `give up` / `look forward to` / `put off` で対訳付きの短文を返す
  - **EJDict-hand には句動詞が実質無い**(複合語見出し 6770 件は
    `Adam's apple` のような名詞句が中心)。常用句動詞 30 語での実測は
    品詞 29/30・例文と対訳 30/30・IPA 6/30 に対し、**EJDict からの訳は 0/30**
  - **訳は kaikki の `translations` で埋める**(同 30 語で 20/30)。EJDict が
    未収録のときだけ落ちる予備なので、単語 1 語の挙動は変わらない。
    - **既に引いている JSONL の中にあり、追加リクエストは要らない**。全言語ぶん
      入っている(`give up` は 1 品詞に 243 件)ので、キャッシュへ詰め直す時点で
      `lang_code == 'ja'` だけに絞る
    - 同じ訳語が語義ごとに重複して来るため畳み、EJDict と同じ ` / ` で連結する。
      **並びは kaikki が返した順のままで語義の主従は反映されない**
      (`give up` は「降服する」が先頭に来る)。必須項目の欄が長大にならないよう
      5 件で打ち切る
    - 残る 10/30(`figure out` `put up with` `set up` `go on` `take care of` 等)は
      依然として空。訳が空のときは警告バナーで手入力を促す
      (`WordRegistrationState.warningMessage`)。kaikki は英語定義(`glosses`)を
      9/10 で持っており参考表示の候補になるが、第 1 語義が主用法とは限らず
      (`give in` は「To collapse or fall」が先頭)、効果を見てから判断する
  - **kaikki と EJDict が両方空振りでも Tatoeba は引く**。kaikki の見出しが
    入力とずれる句があるため(`run out of` は Wiktionary の見出しが `run out`
    なので 404)。以前はここで打ち切っており、例文も対訳もある語で空のフォームが
    開いていた。単語 1 語では kaikki がほぼ埋めるので、この経路に来るのは
    実質そういう句と綴り間違いだけ。全部空振りなら従来どおり未収録扱いにする
  - 語形フィルタは複合語では**先頭語だけ規則変化を許し、後続のトークンは
    その形のまま**求める(副詞・前置詞は活用しないため)。語順と隣接は問わない:
    `The wedding was put off.` の受動態や `give it up` の目的語割り込みを
    落とさないため。**先頭語が不規則変化する文(`He gave up.`)は拾えない**
    が、Tatoeba は候補を 10 件取るので原形の文が残る
  - 見出し語は保存・照合の前に `normalizeHeadword`(`lib/utils/headword.dart`)で
    語間の連続空白を 1 つに畳む。`give  up` は kaikki が 404 になるうえ、
    trim + 小文字化だけの重複判定をすり抜けて 2 件登録できてしまうため
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
- **1.2.0 で発音の導線をスピーカーボタン + アプリ内 WebView にした**: それまでは
  「発音を確認 ↗」というテキストリンクで外部ブラウザに飛ばしていた。矢印だけの
  compact 表示は iOS で 44pt のタップ領域に届かず、何が開くかも読めなかった
  (macOS は Tooltip で補っていた)。外部ブラウザに出ると 1 語確認するたびに
  アプリへ戻る操作が要る点も含め、2 つまとめて直した。
  - ボタンの寸法・配色はデザインの発音ボタン(淡いアクセント地 + 濃い青の
    スピーカー)に従う。形は置き場所で変える: macOS はカード=26px ピル「発音」/
    テーブル=28px 角丸アイコン / クイズ=32px ピル「発音を聞く」、iOS は
    カード・一覧=34px 円形アイコン / クイズ=ピル「発音を聞く」
  - **アイコンは `Icons.volume_up` ではなく `SpeakerIcon`(CustomPainter)**。
    Material のものは音波が 3 本でデザインと形が違う
  - **文字色はデザインの `#1e7fd6` を測り直して `#176AB4` に変えた**。淡い地
    (白 + アクセント 10%)に対して #1e7fd6 は 3.77:1(hover 3.43:1)しか出ず、
    12〜13px の文字には足りない。色相を保ったまま明度だけ下げて 5.08:1 にし、
    品詞バッジと同じくテストで 4.5:1 を保証する。ダーク(`#7EC2FF`)は元から足りている
  - **iOS のアイコンボタンのタップ領域は 44pt 幅 × 34pt 高**。デザインは負マージンで
    行を膨らませずに 44pt 四方を作っているが、Flutter は親の矩形の外をヒットテスト
    しないため同じ手が使えない(広げた分が死に領域になる)。高さも 44pt にすると
    学習中カードのフッタが間延びしたため、行の高さに響かない幅だけ広げ、高さは
    円の直径に合わせた。あわせてフッタの上下の余白を 8 → 6 に詰めている
    - **円はタップ領域の右端に揃える**(1.3.0 で中央寄せから変更)。この形は常に
      行・カードフッタの末尾に置かれるため、中央寄せだと円の右端がコンテンツの
      右端より 6pt 内側に入り、行の端に接する左のチェックボックスに対して
      左寄りに見えていた。幅を広げたぶんは左に伸ばす(隣との間隔が広がるだけ)
  - **WebView はデザインには無く、ユーザー判断による追加。ただし iOS 限定**。
    編集シートと同じ `MobileSheet` に `webview_flutter`(Flutter 公式)を載せる。
  - **macOS はアプリ内 WebView を諦めて外部ブラウザのままにした**。パッケージは
    4.9.0 で macOS が endorsed になっており表示自体はできるが、**Flutter の
    platform view が macOS ではまだジェスチャに対応していない**ため、埋め込むと
    Google 翻訳の再生ボタンを押せない(表示はされるのに操作が届かない)。
    公式ドキュメントの Version note に明記されている
    (<https://docs.flutter.dev/platform-integration/macos/platform-views>)。
    加えて `uiScale` の `Transform.scale` 配下になるため描画も甘くなる。
    Flutter 側が対応したら iOS と同じダイアログに載せ替えられる。
    macOS サンドボックスの `network.client` は設定済みなので、その際も
    entitlements の変更は不要
  - **外部ブラウザを開くのは macOS だけで、iOS には置かない**。当初は WebView が
    Google 側の制限を受けた場合の逃げ道として iOS のシートにも「ブラウザで開く」を
    置いていたが、問題なく表示・再生できることを確認したうえで UI を単純にするため
    外した。**`LaunchMode.externalApplication` を明示すること**: 既定の
    `platformDefault` は iOS では SFSafariViewController(アプリ内 Safari)になり、
    アプリ内 WebView と役割が重複するうえ、読み込みに失敗すると「完了」でも
    閉じられない画面に閉じ込められる(実機で確認済み)
  - **読み込み中のインジケータは色を明示する**。既定は `ColorScheme.primary` で、
    `colorSchemeSeed` から導出された濃紺になりアクセント色と食い違う
  - **debug の iOS では hot restart 後に WebView のアサーションが出るが実害はない**。
    `didReceiveAuthenticationChallenge`(HTTPS の証明書検証で毎回呼ばれる)が、
    hot restart で作り直された Dart 側の管理表に無い ID で飛んでくるため。
    ネイティブの WKWebView は hot restart では破棄されず生き残るのが理由で、
    コールドスタートでは起きない。`assert` は release では除去され、debug でも
    プラグイン側が握り潰すのでクラッシュしない
  - **`onWebResourceError` をそのままエラー画面にしない**。WKWebView は遷移が
    差し替わるたびに中断(`NSURLErrorCancelled` = -999)を失敗として通知するため、
    Google 翻訳のリダイレクトだけで「読み込めませんでした」になる。中断は無視し、
    一度読み込みが完了した後の失敗でも画面を捨てない(広告・計測の失敗で
    ページごと消える方が困る)。エラー時はその場で引き直せるよう再読み込みを置く
- **同じ単語の重複登録はエラーで止める(1.3.0)**: それまで何度でも同じ単語を
  登録できた。単語帳で同じ見出しが 2 件並ぶのは事故なので、警告して続行させず
  登録そのものを止める。
  - **突き合わせは trim + 小文字化**(`WordDao._matchKey`)。削除ログのキー・
    `WordExportService._mergeKey` と同じ規則で、`Apple` と `apple` を
    別単語にしない
  - **チェックは登録の 2 箇所と編集**。登録は「自動入力」の前(登録できない
    単語のために辞書へ通信しない)と保存の直前(確認フォームでも英単語を
    書き換えられるため)。編集は自分自身を `excludeId` で除いて同じ判定をする
  - **DB に UNIQUE 制約は置かない**。既存端末に既に重複が残っている可能性が
    あり、制約を足すとマイグレーションと iCloud インポートが失敗しうる。
    抑止はアプリ層(`WordDao.findByWord` を使う検証)だけで行う。
    同期・インポートのマージは従来どおり `updatedAt` 勝ちのままで変えない
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
  **アイコンも配色を反転した `AppIcon-dev` に差し替える**(青地に白 ⇔ 白地に青)。
  Dock やホーム画面に本番版と dev 版が並ぶため、名前だけでなく見た目でも
  区別できるようにする。`APP_ICON_NAME` を xcconfig で定義し、pbxproj の
  `ASSETCATALOG_COMPILER_APPICON_NAME` から参照する
  (pbxproj は変数を含む値を引用符で囲まないとパースエラーになる)。
  **iOS のアイコンだけアルファチャンネルを落とす**(App Store Connect が弾くため)。
  macOS は角丸の外側が透過なのでアルファを残す。
- **バージョン番号は両プラットフォームで共通**(`pubspec.yaml` の 1 つを macOS / iOS の
  両方が読む)。**そのため片方にしか出さないバージョンができる**: 初版は
  macOS が 1.0.0、iOS が 1.1.0(iCloud 同期対応)で、**1.1.0 は macOS に出して
  いない**。macOS の 2 本目は 1.2.0 になる。掲載したリリースノートは
  [release-notes.md](release-notes.md) に控えがある。
  **ビルド番号は提出のたびに pubspec で必ず上げる**。
  当初は「Xcode の Manage Version and Build Number が自動で繰り上げるので
  手では上げない」としていたが、**1.2.0 の macOS アップロードが弾かれて
  誤りと判明した**(繰り上がらないまま build 1 のまま提出された)。
  - **macOS はアプリの全履歴を通じてビルド番号が単調増加でなければならない**。
    iOS はマーケティングバージョン内でユニークなら足りる(1.1.0 の build 1 と
    1.2.0 の build 1 が共存できる)が、macOS はバージョンをまたいだ再利用も
    許さない。同じ pubspec を両者が読むため、**厳しい方の macOS に合わせて
    一度使った番号は二度と使わない**運用にする
  - 1.2.0 の macOS 提出でこの制約に当たり、`1.2.0+1` → `1.2.0+2` に上げ直した
    (iOS の 1.2.0 は build 1 のまま通っている)
  - CI などアップロードを Xcode 以外で行う場合は `--build-number` で明示する
  - **pubspec を上げたら、Xcode で Archive する前に `flutter build ios|macos
    --config-only` を実行する**。Info.plist の `CFBundleShortVersionString` /
    `CFBundleVersion` は `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` を
    参照しており、その実体である `ios/Flutter/Generated.xcconfig` と
    `macos/Flutter/ephemeral/Flutter-Generated.xcconfig` は Flutter ツールが
    ビルドを走らせたときだけ pubspec から書き出される(どちらも gitignore 対象の
    生成物)。Xcode 単体の Archive は pubspec を読まないため、前回ビルド時の
    古い値でアーカイブされる。1.3.0 で実際に 1.2.0 のままアーカイブされた
    (`flutter test` / `flutter analyze` では再生成されない)

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
  カードヘッダの組み方も列数で変える: 2 列は単語・IPA・品詞をそれぞれ独立した
  行に積む。1 列は幅に余裕があるので単語・IPA・品詞を 1 行に並べ、品詞だけ
  右端に寄せる。英例文は列数によらず 2 行を確保する。
  - **2 列のヘッダは長さに関わらず 1 項目 1 行にする(1.4.0)**。当初は `Wrap` で
    組み、IPA と品詞が収まるときだけ同じ行に並べていたが、単語ごとにヘッダが
    2 行にも 3 行にもなって並びが揃わなかった。行が固定になったぶん品詞は
    左寄せになる(IPA 非表示時の従来の位置と同じ)
  - **2 列の IPA は折り返さず、字を縮めて 1 行に収める**
    (`MobileShrinkingIpaText`)。11px から 8px まで下げ、そこでも溢れる分だけ
    末尾を省略する。`FittedBox` は下限が無く読めない大きさまで潰れるので使わない。
    **計測の `TextPainter` には `MediaQuery.textScalerOf` を渡すこと**
    (iOS は OS の文字サイズ設定に従うため、倍率がずれると縮小判定が狂う)。
    1 列は単語と同じ行でベースラインを揃える必要があるため縮小しない
  - **英例文を 2 列でも 2 行にした(1.4.0)**。当初は 2 列だけ 3 行にしていたが、
    辞書から入る例文は 2 列幅でも 2 行に収まるものが大半で、3 行目はほぼ
    空白になっていた
- **macOS の表示名は `PRODUCT_NAME`(= `.app` のファイル名)で決める**。
  macOS の Dock・Finder・⌘Tab はアプリのラベルに `CFBundleDisplayName` を使わず
  **バンドルのファイル名**を使うため、Info.plist に日本語名を入れても
  `PRODUCT_NAME = eitangocho` のままでは「eitangocho」と表示されていた
  (1.0.0 のストア配布版がこの状態)。`PRODUCT_NAME` を
  「シンプル英単語帳$(APP_DISPLAY_SUFFIX)」にして解決し、Info.plist の
  `CFBundleName` / `CFBundleDisplayName` もこの値を参照させて定義箇所を 1 つにした。
  **実行ファイル名だけは `EXECUTABLE_NAME` で ASCII に固定する**
  (クラッシュログや配布ツールのログに日本語のプロセス名が出ると扱いにくい)。
  RunnerTests の `TEST_HOST` も同じ名前を組み立てている。
  iOS はこの問題が起きない(下記のとおり `CFBundleDisplayName` がそのまま効く)。
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

## 広告の設計判断(1.4.0)

- **広告は iOS のみ**。デザイン(`英単語帳アプリ.dc.html`)の macOS 側に広告枠が
  無く、`google_mobile_ads` も macOS 非対応(呼べば `MissingPluginException`)。
  分岐は `AppPlatform.isIOS` で行い、`adsEnabledProvider` が false を返す。
- **枠はデザインにある 3 つすべて**: タブバー上の常設バナー / 登録・編集シートの
  最下部バナー / クイズ結果の 300×250 レクタングル。当初は 1 枠だけ入れて実機で
  確かめる計画だったが、ユーザー判断で 3 枠同時に入れた。
  「広告を非表示にする」課金(デザインの Pro セクション)は分離したまま
  (広告本体より作業量が大きい)。表示は `adsEnabledProvider` の真偽値 1 点で
  分岐させてあり、購入状態は後からそこに混ぜられる。
- **ユニットは配置ごとに分ける**(`AdUnitIds` の getter も配置ごと)。AdMob では
  レポート・自動更新の間隔・eCPM の下限・配信停止がすべてユニット単位で、
  1 つを使い回すとどの枠が稼いでいるのか後から分けられない。詳細設定
  (広告の種類 / 自動更新 / eCPM 下限)は 3 つとも既定のまま。実績が無いうちに
  Floor を上げても埋まらなくなるだけで逆効果のため。
- **共通処理は `MobileAdSlot` に集約**。3 枠とも「`adsEnabled` を待つ → サイズを
  決める → 読み込む → 失敗したら再試行 → 破棄」が同じで、違うのは要求サイズと
  枠の装飾だけ。装飾は `builder` に任せ、**枠を消したいときはこのウィジェットごと
  ツリーから外す**(覆われたとき・キーボードが出たときの消し方が 1 つになる)。
- **`google_mobile_ads` は 9.x**。本プロジェクトは CocoaPods を使っておらず
  (`ios/Podfile` が無い)、SPM 対応は 8.0.0 以降のため 8.0.0 未満は選べない。
  SPM が解決したネイティブ SDK のバージョンは `Package.resolved` で固定する。
- **広告ユニット ID は Dart 定数に直書き**(`ad_unit_ids.dart`)。DeepL の API
  キーと違い広告 ID は AdMob が発行する公開値で、秘匿する意味も設定画面から
  入力させる意味も無い。**debug は Google 公式のテスト ID**にする(開発中に本番
  ユニットを叩くと無効なトラフィックとみなされ、アカウントごと停止されうる)。
  アプリ ID 側も同じ方針で `ios/Flutter/{Debug,Release}.xcconfig` に置き、
  Info.plist の `GADApplicationIdentifier` から参照する
  (`BUNDLE_ID_SUFFIX` / `APP_ICON_NAME` と同じ仕組み)。
- **広告ユニット ID が空なら SDK を初期化しない**。`GAD_APPLICATION_IDENTIFIER`
  が空のまま初期化すると GMA SDK はアプリ ID 不正で例外を投げる。ユニット ID が
  空なら初期化ごと見送ることで、ID を用意する前でも「広告が出ないだけで動く
  release ビルド」になる(AdMob 登録待ちの間に実際に使った)。枠を増やすときも、
  ユニットを作ってから配線すれば同じ保険が効く。
- **辞書の取得失敗と同じく、広告の失敗で本体を止めない**。ATT・初期化・読み込みの
  例外は握って `adsEnabled` を false にするだけにする。
- **トラッキング同意は ATT のみ**(EEA 向けの UMP は入れない)。要求は
  **初回フレームを描いた後・`notDetermined` のときだけ 1 回**。アプリがアクティブに
  なる前に要求してもダイアログは出ないまま返る。**SDK の初期化より前**に済ませる
  のは、初期化後にトラッキング可否が変わってもその回の広告リクエストに
  反映されないため。応答の内容は見ない(拒否でも非パーソナライズ広告は出せる)。
- **サイズはアンカー型アダプティブ**。固定 320×50 より収益を狙う。幅は画面幅では
  なく `AppDimensions.mobileContentMaxWidth` に合わせる(iPad ではシェルがこの幅に
  絞っており、広告だけがはみ出すため)。
  **大きさは枠の性格で使い分ける**(実機で見て決めた):
  - タブバー上は**通常サイズ**(`getCurrentOrientationAnchoredAdaptiveBannerAdSize`)。
    大型は端末高の 15%(実測 118pt・枠込み 135pt)あり、全画面に常駐する枠としては
    大きすぎた。**この API は 8.0.0 で非推奨**だが、Google が用意する「幅に追従する
    小さめのバナー」は現状これだけなので `ignore` を付けて使う。削除されたら固定の
    `AdSize.banner` か、`getInlineAdaptiveBannerAdSize`(maxHeight 指定可)に移す
  - シート内は**大型**(`getLargeAnchoredAdaptiveBannerAdSize`)のまま。開いている
    間だけ出るもので、フォームの下は元から余っており圧迫しない
- **高さが確定するまで枠ごと出さない**。アダプティブの高さは端末ごとに Google が
  返すまで分からない。先に空の枠を置くと、広告が付かない端末で下端に意味の無い
  帯が残る。確定した高さは `bannerAdHeightProvider` に流し、シェルがコンテンツの
  下余白(タブバーの高さ + バナー高)に足す。**この Provider は keepAlive**:
  書き手(バナー)と読み手(シェル)が別ウィジェットのため、購読者が一瞬でも
  居ない状態で書くと autoDispose が値ごと捨ててしまう。
- **覆われている間はツリーから外す**。登録・編集シートは画面高の 88% を占め、
  バナーを完全に隠す。隠れた広告のインプレッションを稼がないよう、上に画面が
  積まれたら広告を破棄し、戻ったら読み込み直す。検知は **`RouteObserver`**
  (`lib/app/app_route_observer.dart`)で行う。シート側に「今開いている」を
  報告させると導線を足すたびに書き漏らすうえ、ライセンス画面のような全画面
  プッシュも同じ扱いにできるため。
- **デザイン準拠**: 背景 `palette.surfaceHeader`、上境界 `palette.borderAlpha(8)`、
  パディング 8/12。デザイン左上の黄色い「広告」バッジは枠を示すプレースホルダで
  実装しない(AdChoices は AdMob 側が描く)。

### 枠ごとの判断

- **シート内バナーはキーボードが出ている間は消す**。`MobileSheet` はキーボードの
  高さだけ持ち上がるため、最下部に固定した広告が入力欄とキーの間に挟まる。
  フォーム操作の指が広告に当たるのは AdMob の無効なクリックにあたるため、
  デザインにない挙動だが隠す方を取る。判定は `MediaQuery.viewInsetsOf`。
  置き場所は `MobileSheet` の `footer`(スクロール領域の外側。デザインの
  `flex-shrink:0` に対応)で、下の余白だけ厚い(22px)のはシートの下端が
  ホームインジケータに接するため。
- **シート内バナーは編集シートにも出す**(デザインにあるのは登録シートのみ)。
  作りが同じで、開く頻度は編集の方が高いというユーザー判断。
- **クイズ結果のレクタングルだけ固定サイズ**。300×250 は寸法が決まった
  フォーマットで幅に追従しないため、アダプティブではなく `AdSize.mediumRectangle`。
  デザインの枠は幅いっぱいだが、実物は 300pt 固定なので**枠を広告幅に合わせて
  中央寄せ**する(幅いっぱいの枠にすると左右に白帯が残る)。上の余白は広告自身が
  持ち、読み込めなければ高さごと消えて元のレイアウトに戻る。
- **クイズ結果ではタブバー上のバナーを引っ込める**
  (`tabBarBannerVisibleProvider`)。並べると 385pt(画面の 44%)が広告になり、
  忘れていた単語の一覧が読めなくなる。大きい方を優先する。ただし
  **レクタングルのユニットが未設定なら引っ込めない**(広告がゼロの画面を
  作っても意味がないため)。
- **コード外に必要な作業**(AdMob のアプリ登録と 3 ユニットの作成は済み):
  App Store Connect のプライバシー申告(トラッキング / 識別子 / 使用状況データ)、
  プライバシーポリシーへの AdMob と IDFA の記載、app-ads.txt の配信ドメインと
  マーケティング URL のドメイン一致。**ネイティブの GMA SDK は SPM 経由で入る
  ため `NOTICES` に載らない**(pub パッケージ分は自動収集される)。表示義務の
  有無は未確認で、必要なら `registerDataSourceLicenses` と同じ要領で足す。

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
  (デザインは発音ボタンの文字色にも同じ値を当てているが、そちらは淡い地に
  載せるためコントラストを測って `#176AB4` に振り直した。上記)
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
