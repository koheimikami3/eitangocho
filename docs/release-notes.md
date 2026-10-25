# リリースノート

App Store / Mac App Store の「このバージョンの新機能」に掲載した文面を、そのまま記録する。
**提出のたびにここへ追記すること。** ストア側の文面は後から遡って読むのが手間なため、
リポジトリ内に控えを持つ。

書き方の決まり:

- 「〜しました。」の短い行を並べる。1 行 1 項目で、2〜4 行に収める
- **内部の仕組みには触れない**。データソース名(kaikki / Tatoeba / EJDict)や
  クラス名は書かず、利用者から見て何が変わったかだけを書く
- **iOS と macOS で入った内容が違うときは文面を分ける**。同じなら同じ文面でよい
  (1.3.0 は共通、1.2.0 と 1.6.0 は別文面)
- 半角英数の前後には空白を入れる(`Mac と iPhone`、`iPhone 版`)
- **初版にはリリースノートを書けない**(App Store Connect に入力欄が無い)。
  macOS の 1.0.0 と iOS の 1.1.0 が該当し、空欄が正しい
- **バージョンは両プラットフォームで共通のため、片方にしか出さないものがある**。
  1.1.0・1.4.0・1.5.0 は iOS だけで、macOS には出していない
- **見出しの build 表記が使用済みビルド番号の台帳を兼ねる**。番号は全履歴を通じて
  単調増加で再利用しない(理由と提出手順は [design.md](design.md))。リジェクトで
  捨てた番号や、iOS が自動で繰り上げた番号も必ず書く。次に使うのは最大値 + 1

---

## 2.11.1 (iOS build 24 / macOS build 26)

iOS は build 24、macOS は build 26 で出した。macOS は iOS より後に、2.10.0 以来のリリースとして出した
(2.11.0 から Xcode 27 の lipo の不具合でビルドできず、Flutter 3.47.8 で解消したため)。
macOS は build 25 をアップロードしたあと、サイドバーのフラッシュクイズの件数を消す変更を足して
build 26 で出し直した(build 25 は使用済み)。
タグは iOS が `v2.11.1`、macOS が `v2.11.1-macos`。

### iOS

アプリの変更は繁体字の訳の取得漏れの修正だけ(apple・dog・water など、北京語の訳が lang_code zh で来る語)。
主目的はストアの掲載内容(スクリーンショット・アプリ名・説明文など)の更新
(スクリーンショットなどは公開中のバージョンでは差し替えられないため)。
修正は繁体字の訳を使う利用者にしか関係しないので、繁體中文の文面にだけ書いた。

日本語:

```
App Store の掲載内容を更新しました。
```

繁體中文:

```
更新了 App Store 頁面的內容。
修正了部分單字無法自動填入中文翻譯的問題。
```

Español:

```
Actualizamos el contenido de nuestra página en la App Store.
```

Français:

```
Mise à jour du contenu de notre page App Store.
```

English:

```
Updated our App Store page.
```

### macOS

文面には 2.11.0 の変更のうち macOS に届くものを含めた。「一部の画面」は、訳を表示したときの英例文の全文表示、
カードのホバー時の枠、学習中リストの上の説明文の削除、例文の訳が取れなかったときのバナー表示、登録後も登録画面に
留まる変更、設定画面のスクロールバーの位置、サイドバーのフラッシュクイズの件数の削除。
繁体字の訳の取得漏れの修正と、掲載内容の更新は書いていない。

日本語:

```
ダークモードに対応しました。
品詞を色分けして表示するようにしました。
一部の画面のデザインを見やすく調整しました。
```

繁體中文:

```
新增深色模式。
詞性改為以不同顏色分開顯示。
調整了部分畫面的設計，使其更易於閱讀。
```

Español:

```
Añadimos el modo oscuro.
Ahora cada categoría gramatical se muestra con su propio color.
Ajustamos el diseño de algunas pantallas para que sean más fáciles de leer.
```

Français:

```
Ajout du mode sombre.
Affichage de chaque catégorie grammaticale avec sa propre couleur.
Ajustement du design de certaines pages pour une meilleure lisibilité.
```

English:

```
Added dark mode.
Each part of speech now has its own color.
Improved the design of some screens for readability.
```

---

## 2.11.0 (build 23)

iOS のみ(macOS は出していない。Xcode 27 の lipo の不具合で、Flutter 3.44 では macOS をビルドできないため)。
macOS 27 で Xcode 26 が起動しなくなったため、この版から Xcode 27.1(iOS 27.1 SDK)でビルドしている。
「一部の画面」は全単語リストの品詞の位置と、訳を表示したときの英例文の全文表示。「細かな不具合」は
キーボードの角丸の外側に背景が見えていたことと、発音確認の画面がスクロールできなかったこと。

日本語:

```
品詞を色分けして表示するようにしました。
一部の画面のデザインを見やすく調整しました。
細かな不具合を修正しました。
```

繁體中文:

```
詞性改為以不同顏色分開顯示。
調整了部分畫面的設計，使其更易於閱讀。
修正了一些小問題。
```

Español:

```
Ahora cada categoría gramatical se muestra con su propio color.
Ajustamos el diseño de algunas pantallas para que sean más fáciles de leer.
Corregimos pequeños errores.
```

Français:

```
Affichage de chaque catégorie grammaticale avec sa propre couleur.
Ajustement du design de certaines pages pour une meilleure lisibilité.
Correction de petits bugs.
```

English:

```
Each part of speech now has its own color.
Improved the design of some screens for readability.
Fixed minor bugs.
```

---

## 2.10.0 (build 22)

iOS・macOS 共通。新機能の欄は 5 言語ぶん入れる。macOS は 2.8.0 以来のリリースだが、2.9.0 の変更(Pro の値下げ、
Pro・バナー広告まわりの調整)は macOS に関係しないため文面は分けない。「一部の画面」は検索欄のアイコン、
設定画面のタイトル位置、チェックボックスの位置、1 列カードの並びなど。発音記号の書体・大きさの変更は
フォントの変更に含めた。Pro のお礼の文言を短くした変更と、レビュー依頼の計測の追加は掲載していない。

日本語:

```
アプリ全体のフォントを変更しました。
一部の画面のデザインを見やすく調整しました。
```

繁體中文:

```
更換了整個 App 的字型。
調整了部分畫面的設計，使其更易於閱讀。
```

Español:

```
Cambiamos la fuente de toda la app.
Ajustamos el diseño de algunas pantallas para que sean más fáciles de leer.
```

Français:

```
Nouvelle police dans toute l'app.
Ajustement du design de certaines pages pour une meilleure lisibilité.
```

English:

```
Changed the app's font.
Improved the design of some screens for readability.
```

---

## 2.9.0 (build 21)

iOS のみ(macOS は出していない。利用者から見える変化が無いため)。2.8.0 と同じく新機能の欄は 5 言語ぶん入れる。
Pro の値下げは App Store Connect での価格変更で、ビルドの変更ではない。「一部の画面」は設定画面の Pro の表示と、
バナー広告まわり(タブバーとの一体化・影の調整)。クイズ結果に置いた Pro への導線は、1.5.0 の「作者の他のアプリ」と
同じく宣伝の色が濃いため掲載していない。

日本語:

```
広告を非表示にできる Pro を値下げしました。この機会にぜひご購入をご検討ください。
一部の画面のデザインを見やすく調整しました。
```

繁體中文:

```
可移除廣告的 Pro 降價了，歡迎趁此機會考慮購買。
調整了部分畫面的設計，使其更易於閱讀。
```

Español:

```
Bajamos el precio de Pro, que quita los anuncios. ¡Aprovecha para comprarlo!
Ajustamos el diseño de algunas pantallas para que sean más fáciles de leer.
```

Français:

```
Baisse du prix de Pro, qui supprime les pubs. Profitez-en pour l'acheter !
Ajustement du design de certaines pages pour une meilleure lisibilité.
```

English:

```
Lowered the price of Pro, which removes ads. Consider purchasing it!
Improved the design of some screens for readability.
```
---

## 2.8.0 (build 20)

両プラットフォームに出したが、利用者から見える変化は iOS の入力まわり(キーボードとタブバー、英字キーボード、
「完了」キー、欄の外のタップで閉じる)だけなので文面を分ける。
計測の追加と、検索を英単語だけに一致させた変更は掲載していない。

build 19 で提出したが、審査中に取り下げた(番号は使用済み)。対応外の言語の端末向けの英語対応
(英語の語義、アプリ名・ATT の英語化)を入れて build 20 で出し直した。今回から英語(米国)の掲載を足し、
プライマリ言語を英語にしたので、新機能の欄は 5 言語ぶん入れる。英語の語義は対応外の言語の利用者にしか
関係しないので、英語の文面にだけ書いた。アプリ名・ATT の英語化はどの言語の文面にも書いていない。

### iOS

日本語:

```
入力欄の使い勝手を改善しました。
```

繁體中文:

```
改善了輸入欄位的使用體驗。
```

Español:

```
Mejoramos la facilidad de uso de los campos de texto.
```

Français:

```
Amélioration de l'ergonomie des champs de saisie.
```

English:

```
Improved the usability of input fields.
Added English definitions for languages without translations.
```

### macOS

日本語:

```
今後の機能改善に向けて、アプリ内部の仕組みを整えました。
```

繁體中文:

```
為了日後改善功能，調整了 App 的內部架構。
```

Español:

```
Mejoramos el funcionamiento interno de la app para futuras mejoras.
```

Français:

```
Amélioration du fonctionnement interne de l'app en vue de futures évolutions.
```

English:

```
Improved the app's internals for future updates.
Added English definitions for languages without translations.
```

---

## 2.7.0 (build 18)

iOS・macOS 共通。今回からスペイン語・フランス語のローカリゼーションがあり、新機能の欄は 4 言語ぶん入れる
(スペイン語はメキシコ・スペイン、フランス語はフランス・カナダの掲載にそれぞれ同じ文面)。

日本語:

```
スペイン語とフランス語に対応しました。
```

繁體中文:

```
新增西班牙文與法文介面與翻譯。
```

Español:

```
Añadimos el español y el francés para la interfaz y las traducciones.
```

Français:

```
Ajout de l'espagnol et du français pour l'interface et les traductions.
```

---

## 2.6.0 (build 17)

macOS のみ(iOS は出していない)。2.5.0 と同じく新機能の欄は日本語と繁體中文の 2 言語ぶん入れる。

日本語:

```
学習中カードの表示を調整しました。
発音の確認ウィンドウを ⌘W で閉じられるようにしました。
```

繁體中文:

```
調整了學習中卡片的顯示方式。
發音確認視窗可用 ⌘W 關閉。
```

カードの調整は、単語・発音記号・品詞を別々の行に分け、長い単語が省略されないようにしたもの。
v4 への DB 移行で列が既にあると失敗する不具合の修正は掲載していない。ストア版では
古い版に戻せないため利用者には起きない(開発機で旧ストア版と同居したときだけ起きた)。

---

## 2.5.0 (build 16)

両プラットフォームに出したが、macOS は 2.3.0 以来のリリースで 2.4.0 のクイズの変更も含むため、
文面を分ける。今回から繁體中文のローカリゼーションがあり、新機能の欄も 2 言語ぶん入れる。

### iOS

日本語:

```
繁体字中国語に対応しました。
訳の言語を設定で選べるようにしました。
```

繁體中文:

```
新增繁體中文介面與繁體中文翻譯。
可在設定中選擇翻譯語言。
```

### macOS

日本語:

```
クイズを 10 問ずつ出題するようにしました。
まだ出題していない単語や、しばらく出ていない単語から出題するようにしました。
繁体字中国語に対応しました。
訳の言語を設定で選べるようにしました。
```

繁體中文:

```
測驗改為每次 10 題。
優先出題尚未出過或較久沒出過的單字。
新增繁體中文介面與繁體中文翻譯。
可在設定中選擇翻譯語言。
```

日本語・繁体字以外の端末で画面が英語になる変更は掲載していない。影響は端末の言語の並びで
日本語より上に別の言語を置いている日本語話者だけで、訳は日本語のまま使えるため
(問い合わせが来たら「設定 → 英単語帳 → 言語」で戻せると案内する)。
英語画面での品詞ボタンの 2 段表示と、「作者の他のアプリ」のサブリスのアイコン差し替えも掲載していない。

---

## 2.4.0 (build 15)

iOS のみ(macOS は提出し損ねたため出していない。build 15 は使用済みとして扱う。
macOS には 2.5.0 でまとめて出した)。

```
クイズを 10 問ずつ出題するようにしました。
まだ出題していない単語や、しばらく出ていない単語から出題するようにしました。
```

クイズの出題状況の端末間同期と、レビュー依頼の契機(登録 50 / 100 語)の追加は掲載していない。

---

## 2.3.0 (build 14)

iOS・macOS 共通。

```
今後の機能改善に向けて、アプリ内部の仕組みを整えました。
```

中身は Firebase Analytics の導入(アクティブユーザー数の計測)だけで、利用者から見える変化は無い。

---

## 2.2.1 (build 13)

iOS・macOS 共通。

```
Mac と iPhone のあいだで、変更が同期されないことがある不具合を修正しました。
```

---

## 2.2.0 (build 12)

### iOS

```
画面全体のデザインを見やすく調整しました。
細かな表示の不具合を修正しました。
```

### macOS

```
画面全体のデザインを刷新しました。
発音をアプリ内で確認できるようにしました。
ウィンドウ上部をドラッグして移動、ダブルクリックで拡大できるようにしました。
細かな表示の不具合を修正しました。
```

iOS はカード・入力欄をフラット寄りに調整。macOS はその意匠に揃えた。
「細かな表示の不具合」は起動直後の空表示のちらつき(両方)と、macOS の編集画面のボタンの見切れ。

---

## 2.1.0 (build 11)

iOS / macOS 共通の文面。macOS は 1.7.0 以来のリリースで、iOS と版を揃える。
2.0.0 のデザイン刷新は iOS のみだったため、macOS に届く変更はアイコンだけ。
「作者の他のアプリ」へのメトロノーム追加は、1.5.0 と同じ理由で掲載していない。

```
アプリアイコンを新しいデザインに変更しました。
```

---

## 2.0.0 (build 10)

iOS のみ(macOS は出していない。build 10 は使用済みとして扱う)。

```
画面全体のデザインを刷新しました。
```

見た目の全面的な作り直し(面を影で浮かせる「立体案」)。押したときの反応や
並び替えボタンの位置の変更などは、この 1 行に含めて個別には書いていない。

---

## 1.7.0 (build 9)

```
全単語の一覧を並び替えられるようにしました。
細かな表示の不具合を修正しました。
```

iOS / macOS 共通の文面。

---

## 1.6.0 (build 8)

### iOS

```
画面全体のデザインを見やすく調整しました。
```

### macOS

```
句動詞の登録に対応しました。
例文と入力欄の使い勝手を改善しました。
設定画面のレイアウトを整理しました。
App Store のレビューを設定画面から書けるようにしました。
```

1.6.0 のデザイン調整は iOS のみ。macOS は 1.3.0 以来のリリースで、iOS と版を揃える。
文面は 1.4.0・1.5.0 で入った変更のうち macOS に届くものをまとめたもの。

---

## 1.5.0 (iOS build 6 / macOS build 7)

iOS のみ(macOS は出していない。build 7 は使用済みとして扱う)。

```
広告を非表示にする Pro を追加しました(買い切り)。
設定画面のレイアウトを整理しました。
App Store のレビューを設定画面から書けるようにしました。
```

iOS は build 5 が
Guideline 2.1 でリジェクトされ(番号は使用済み)、再提出で 6 に自動で繰り上がった。
「作者の他のアプリ」(iOS のみ)は掲載していない。宣伝の色が濃く、
利用者から見た本アプリの変化ではないため。

---

## 1.4.0 (build 4)

iOS のみ(macOS は出していない)。

```
句動詞の登録に対応しました。
例文と入力欄の使い勝手を改善しました。
学習中カードの表示を調整しました。
アプリ内に広告を表示するようになりました。
```

---

## 1.3.0 (build 3)

iOS・macOS 共通。

```
同じ単語を重複して登録できないようにしました。
学習中カードの発音ボタンの位置を調整しました。
```

---

## 1.2.0 (iOS build 1 / macOS build 2)

### iOS

```
発音ボタンをスピーカーアイコンに変更しました。
発音の確認をアプリ内で行えるようになりました。
```

### macOS

```
iCloud 同期に対応しました。Mac と iPhone のあいだで単語が同期されます (設定から有効化)。
iPhone 版を公開しました。
```

**macOS だけ文面が iCloud 同期なのは、macOS にとってこれが 1.0.0 の次の版だから**。
1.1.0 は iOS にしか出しておらず、macOS の利用者はここで初めて iCloud 同期を受け取る。
発音導線の刷新(1.2.0 の中身)より、そちらを先に伝えている。

---

## 1.1.0 (iOS build 1)

**iOS の初版**(iCloud 同期対応の回。macOS には出していない)。
初版なのでリリースノートは書けない。

---

## 1.0.0 (build 1)

**macOS の初版**。初版なのでリリースノートは書けない。
