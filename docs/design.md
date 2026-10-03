# 設計ドキュメント

コードを読んでも分からず、戻すと事故が再発する判断だけを置く。
機能仕様と UI(レイアウト・配色・寸法)は実装済みアプリとデザイントークン
(`lib/constants/app_colors.dart` / `app_palette.dart` / `app_dimensions.dart`)が正。

## 書き方(溜め込まないためのルール)

- 1 項目は「規則 + 理由」を数行で書く。経緯・「当初は〜」・実測値・日付・
  事故の顛末は書かない(git log / PR に残る)
- 1 ファイルで完結する理由は、そのコードのコメントに書く。ここに置くのは、
  複数箇所にまたがる判断と、コードに痕跡が残らない判断(ストア・Xcode・運用)だけ
- 追記せず、既存の項目を書き換える。判断が覆ったら古い記述は消す
- 残作業・実装済みの報告・リリース履歴は書かない(履歴は [release-notes.md](release-notes.md))

## 外部データソース(LLM は使わない)

| データ | ソース |
|---|---|
| IPA(米音優先)・品詞・英例文 | kaikki.org(Wiktionary を構造化した静的 JSONL) |
| 英例文 + 対訳 | Tatoeba(`api.tatoeba.org/unstable/sentences`) |
| 単語の日本語訳 | EJDict-hand(同梱、初回起動時に DB へ取込)。未収録なら kaikki の `translations`(ja のみ) |
| 例文の日本語訳(予備) | DeepL API Free(設定 UI は隠してある。コードとチェーンは残す) |
| 発音 | Google 翻訳の URL を生成して開く(音声は再生しない) |

- **取得の失敗で登録を止めない**。何も得られなかったときだけ例外にする
  (EJDict も空なら「未収録」)。kaikki と EJDict が両方空でも Tatoeba は引く
  (`run out of` のように kaikki の見出しがずれる句があるため)
- **例文は Tatoeba を優先**し、空振りしたときだけ kaikki の英例文を使う。
  Tatoeba の検索はステミングで別の語の文を返すので、**語形フィルタ
  (`word_form_matcher.dart`)は必ず通す**
- **kaikki は差し替え可能な前提で使う**。ダンプから誰でも再生成できるので
  ベンダーロックインが無い。落ちたら Wiktionary REST(品詞・例文)+ ipa-dict の
  同梱(IPA)に `WordInfoProvider` の差し替えで移す
- 句動詞も単語と同じ経路で引ける(kaikki は空白を含む見出しをそのまま配信する)。
  見出し語は保存・照合の前に `normalizeHeadword` で正規化する
- **非商用限定のソース(Wordnik、Merriam-Webster)は使わない**。広告・課金と両立しない

## データ・同期

- **品詞の並び順には意味がある**。バッジ色は先頭の品詞で決まる。辞書の語義順を
  そのまま保存し、手動で足した分は enum の宣言順で後ろに付ける
  (`PartOfSpeechSelection.ordered`)
- **DB のテーブル変更は追加だけにする**。iCloud 同期の JSON フォーマットと既存端末の
  データを壊さないため。音声 URL(`audioUrl`)のように使わなくなった項目も、
  カラム・フィールド・エクスポート項目は残して空で運用する
- **重複登録はアプリ層で止め、DB に UNIQUE 制約は置かない**(既存端末に重複が
  残っていると、マイグレーションと iCloud インポートが失敗しうる)。判定は
  trim + 小文字化で、削除ログ・同期マージのキーと同じ規則にする
- **iCloud 同期**: コンテナ上の JSON スナップショット 1 個を「読んでマージ → 全体を
  書き戻す」。競合は単語ごとに `updatedAt` が新しい方を採る(手動インポートと同じ
  `WordExportService`)。削除はトゥームストーン(`deleted_words`、180 日保持)で伝える
  - `lastReviewedAt` だけは単語の勝敗と切り離して新しい方を採る。クイズの回答は
    `updatedAt` を動かさないので、そのままだと伝わらず、端末ごとに出題の一巡がずれる
  - 削除と更新が同じ時刻なら削除を勝たせる(DateTime が秒精度のため)
  - 自分の削除ログを尊重するのは同期のときだけ。手動インポートはファイルの内容を復元する
  - 同期する契機: 起動時・有効化時・フォアグラウンド復帰時(最短 60 秒)・ローカル変更後
    (drift の `tableUpdates`、5 秒デバウンス)・手動。iOS はサスペンドするので、
    フォアグラウンド復帰時の同期が必須
  - クラウド側の変更は監視しない(`NSMetadataQuery` は使わない)
  - **端末のコピーが最新版でなければ読み書きしない**。古いコピーを書き戻すと、他端末の
    新しい版が競合版に追いやられて届かなくなる。読む前にダウンロードを頼んで待ち、
    待ちきれなければ見送って 1 回だけ再試行する
  - 競合版も取り込んでから、書き戻しの成功後に取り込んだ分だけ片付ける。
    削除ログの保持期間より古い競合版は取り込まない(掃除済みの削除を知らず単語が復活する)
- 設定値は `shared_preferences` に平文で保存してよい(DeepL キーを含む)

## プラットフォーム

- **iOS の画面は macOS と別ファイルに分ける**。Provider・Notifier・DAO は共有し、
  presentation だけを分ける。削除の導線は macOS が右クリック、iOS が編集シート
  (長押しメニューは置かない)
- `uiScale` は macOS 専用。iOS は OS の文字サイズ設定に従う。ダークモードは iOS 専用
- iOS のストア対象は iPhone のみ・縦向きのみ(iPad を含めると 13 インチの
  スクリーンショットが必須になる)。最低 OS は iOS 15.0
- `ITSAppUsesNonExemptEncryption = false`(独自の暗号実装が無い)
- **CocoaPods は使わない(SPM のみ)**。ネイティブ SDK を含むパッケージは、
  SPM に対応した版以降しか選べない
- **発音**: iOS はアプリ内 WebView(シート)、macOS はアプリ内の別ウィンドウに置いた
  ネイティブの WKWebView(`macos/Runner/PronunciationWindowPlugin.swift`)で開く。
  macOS の platform view はジェスチャに未対応で、Flutter の画面に埋め込むと再生ボタンを
  押せないため。外部ブラウザは予備で、開くときは `LaunchMode.externalApplication` を
  明示する(既定だと iOS ではアプリ内 Safari になる)
  - debug の iOS で hot restart した後に出る WebView のアサーションは無害
    (ネイティブ側の WKWebView が生き残るため。コールドスタートでは出ない)
- **コントラスト**: デザインの色が 4.5:1 に届かないときは、色相を保ったまま明度を
  下げ、テストで 4.5:1 を保証する(品詞バッジ、`AppColors.accentOnSoft`)。
  例外は iOS の青 2 値で、押せる面は `accent` のベタ + 白文字、押せる文字は
  `AppPalette.accentOnSoft`(発音ボタンの淡い地の上では 4.5:1 未満)。青を 2 値に
  揃えるデザイン判断を優先したため、明度を下げて規約に合わせ直さない

## ビルド・提出

- **Debug と Release の分離**: debug は Bundle ID に `.dev` を付け、表示名・アイコン
  (`AppIcon-dev`)・iCloud コンテナを分けて、本番のデータを触らない。設定は
  `macos/Runner/Configs/*.xcconfig` と `ios/Flutter/*.xcconfig`
  - pbxproj では、変数を含む値を引用符で囲む(囲まないとパースエラーになる)
- **表示名**: macOS は `PRODUCT_NAME`(= `.app` のファイル名)で決まる。Dock・Finder は
  `CFBundleDisplayName` を見ないため。実行ファイル名は `EXECUTABLE_NAME` で ASCII に
  固定する。iOS は `APP_DISPLAY_NAME` で「英単語帳」(ホーム画面で省略されない長さ)
- **バージョンは pubspec の 1 つを両プラットフォームで共有する**。片方にしか出さない
  版もある
- **ビルド番号は全履歴を通じて単調増加で、再利用しない**(macOS の制約。iOS は
  バージョン内で一意なら通る)。pubspec が次の番号を持つ。iOS は Xcode が自動で
  繰り上げるが、macOS は繰り上げない。使った番号は
  [release-notes.md](release-notes.md) の見出しに記録する
- **pubspec のバージョンを変えたら、Archive の前に `flutter build ios|macos --config-only`
  を実行する**。Xcode 単体の Archive は、前回生成した xcconfig の古い値を使う。
  macOS は `tool/verify_flutter_version.sh` がずれを検知してビルドを止める
  (書き直しても同じビルドには反映されないので、直さずに止める。ビルド番号は比較しない)
- iOS の JSON 書き出しは自前の `DocumentExportPlugin.swift` で行う
  (`file_selector_ios` に保存パネルが無いため)。iCloud のネイティブ実装は `shared/` に置き、
  両プロジェクトから参照する

## アプリアイコン

- **正基準は `shared/AppIcon.icon` / `shared/AppIcon-dev.icon`(Icon Composer 形式)**。
  ios / macos 両プロジェクトから同じファイルを参照する。片方だけ直す事故を防ぐため、
  `IcloudFileStorePlugin.swift` と同じく `shared/` に 1 個だけ置く
- **アセットカタログにフラット PNG を併置しない。** `.icon` は同名の appiconset を
  完全に置き換え、旧 OS 向けの絵も `.icon` から actool が描く。併置しても成果物には
  入らないので「旧 OS 用の予備」にならない
  (`ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS` は代替アイコン用の設定で、無関係)
- **名前は `APP_ICON_NAME`(Release `AppIcon` / Debug `AppIcon-dev`)と揃える。**
  揃っていない `.icon` は使われない
- **前景は白 1 色のレイヤー 2 枚(カード)で、"abc" と横線は透過の抜き。**
  背景はレイヤーにせずキャンバスの Solid で指定する(Default `#429FF0` / Dark `#10304F`)。
  背景をレイヤーにすると Liquid Glass の対象になり、Dark / Mono の自動生成が崩れる
- **2 枚を統合しない。** 統合するとガラスのハイライトが一体化して奥行きが消える
- **dev は同じレイヤーのまま色だけ反転する**(背景 `#FFFFFF` / レイヤー `#429FF0`)。
  構造・位置・ガラス設定を本番と確実に揃えるため、Icon Composer で作り直さず
  `icon.json` の色指定だけを差し替える

## 計測

- Firebase Analytics(プロジェクト `eitangocho-8d6dd`)で、自動収集イベントだけを取る。
  **Firebase に登録するのは本番の Bundle ID だけ**で、debug は初期化しない。
  dev 用の Firebase プロジェクトは持たない(本番の計測に開発中の起動を混ぜないため)
- iOS と macOS は Bundle ID が同じなので、Firebase 上は 1 つの Apple アプリを共有する
- `firebase_options.dart` と `GoogleService-Info.plist` の値は公開値なのでコミットする
- `flutterfire configure` は pbxproj を丸ごと書き直して並び順を崩す。再実行したら、
  plist の追加分だけを残して他の差分は戻す

## 広告(iOS のみ)

- **広告・ATT・課金・レビューの失敗でアプリを止めない**。例外は握りつぶし、
  該当機能を無効にするだけにする
- ユニット ID と RevenueCat の SDK キーは公開値なので、コードに直書きする。
  **ID・キーが空なら SDK に一切触れない**(未登録でも動くビルドにするため)。
  debug は Google 公式のテスト ID を使う(本番ユニットを叩くとアカウント停止の恐れ)
- 広告ユニットは配置ごとに分ける(レポートと設定がユニット単位のため)
- **ATT の要求**(`TrackingAuthorizer`):
  - `AppLifecycleState.resumed` のあと 500 ms 待ってから要求する。最初のフレームは
    非アクティブのことがあり、その間の要求はダイアログを出さずに返る
  - ダイアログを出せなかったら、次にアクティブになったときに出し直す。
    SDK の初期化は止めない(非パーソナライズ広告で出す)
  - タイムアウトで打ち切らず、実行中の要求を 1 つに保つ。重ねて呼ぶと以後ダイアログが出なくなる
  - 購入状態の確定(`proUnlockedKnown`、最大 3 秒)を待ってから要求する。
    Pro のユーザーには ATT を聞かない
  - 検証は実機で、アプリを削除するかトラッキング許可をリセットしてから行う
- `adsEnabled` は購入状態を watch しない(`.future` を待つ呼び出し側が取り残される)。
  購入後に広告を消す役目は `MobileAdSlot` が持つ
- 覆われた画面の広告は破棄する(`RouteObserver`)。キーボードが出ているときは
  シート内の広告を消す(無効なクリックを避ける)

## 課金(iOS のみ)

- 買い切り 1 本で、解禁するのは広告の非表示だけ。**既存機能は有料化しない**。
  Pro 限定の機能を足すなら新しい機能で足す
- **ストア側の名前とコードを揃える**: 製品 ID `com.kohei.mikami.eitangocho.pro`
  (変更・再利用ができない)/ entitlement `pro` / offering `default` の
  `$rc_lifetime` パッケージ
- 購入状態の更新通知は購読し続ける(返金・他端末での購入は購入導線を通らない)。
  復元ボタンは購入済みでも押せるようにする
- debug では商品を取得できない(`.dev` の Bundle ID がストアに無い)。購入の確認は TestFlight で行う
- **未確認**: GMA / RevenueCat のネイティブ SDK は SPM 経由のため `NOTICES` に載らない。
  表示義務があるかは未確認

## ライセンス・レビュー

- **帰属表示はストア配布の必須要件**: kaikki / Wiktionary(CC BY-SA 4.0 + GFDL)と
  Tatoeba(CC BY 2.0 FR)。`registerDataSourceLicenses` で足す。EJDict(CC0)は表示不要。
  パッケージ分の `NOTICES` はビルド時に生成されるので、`flutter test` では 0 件になる
- **レビュー依頼**の契機は、クイズを最後まで終えた直後だけ(条件は `ReviewConfig`)。
  OS に年 3 回の上限があり、表示されたかは分からないので、呼べた時点で記録する。
  ダイアログはストア配布版でしか出ない

## 将来構想(実装しない)

- iPad 専用レイアウト / 同期のバックグラウンド実行
- LLM による例文生成(`WordInfoProvider` の追加実装として。Ollama を優先)
- 多言語化(kaikki の `translations` と Tatoeba の `trans:lang` の差し替えで成り立つ)
