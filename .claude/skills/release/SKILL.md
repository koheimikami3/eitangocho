---
name: release
description: 新バージョンの実装が完了したあと、審査提出までのリリース作業(完了検証・バージョン更新・main へのマージ・リリースノート作成と確認・Archive 前の config-only ビルド)を順に進める。「リリース作業」「提出準備」「/release」で使う。
disable-model-invocation: true
---

# リリース作業

新バージョンの実装が終わってから審査提出までの定型作業。上から順に進め、
**ユーザーの確認が要る所(★)では必ず止めて返事を待つ**。

作業前に `docs/design.md` の「ビルド・提出」節と、`docs/release-notes.md` 冒頭の
「書き方の決まり」を読むこと(番号の規則・文面の規則はそちらが正)。

## 1. 状況の確認

- `git status --short` と `git branch --show-current` で、未コミットの変更と今のブランチを見る。
  ユーザーが手元で編集中のファイル(CLAUDE.md など)は触らず、コミットにも含めない
- 実装ブランチ(`integration/<version>` など)が main にマージ済みかを確かめる
- 前回のリリース以降の変更を洗い出す。前回のバージョン更新コミットを起点にする:
  ```
  git log --oneline --grep="bump the version" -n 2
  git log --oneline --no-merges <前回の bump コミット>..HEAD
  ```

## 2. バージョンとビルド番号(★)

- 次のバージョンと、**どちらのプラットフォームに出すか**(両方 / iOS のみ / macOS のみ)を
  ユーザーに確認する。バージョンは既定でマイナーを 1 つ上げる(例: 1.6.0 → 1.7.0)
- ビルド番号は `docs/release-notes.md` の見出しに書かれた最大値 + 1
  (pubspec が次の番号を持つ。全履歴で単調増加、再利用しない)
- すでに pubspec が新バージョンになっていれば、この節は確認だけで飛ばす

## 3. 完了時の検証

Dart のコードを変えているリリースなら、ここで 1 回だけ実行する(途中では回さない)。

```
flutter analyze
flutter test -r failures-only
```

失敗したら先に進まず、結果を全文そのままユーザーに見せる。

## 4. バージョン更新と main へのマージ

- 実装ブランチ上で `pubspec.yaml` の `version:` を `<version>+<build>` に書き換え、
  `chore: bump the version to <version>+<build>` でコミットする
- main に `--no-ff` でマージし、確認を挟まずに `git branch -d <branch>` で削除する
- push はしない(ユーザーが求めたときだけ)

## 5. リリースノート(★)

1 で洗い出した変更から、`docs/release-notes.md` の決まりに沿って文面案を作る。

- 利用者から見た変化だけを書く。内部の仕組み・データソース名・クラス名は書かない
- 項目は抽象的かつ簡潔に。細かな不具合修正は「細かな表示の不具合を修正しました。」
  のようにまとめ、並び替えの種類などの細部は括弧で列挙しない
- iOS と macOS で入った内容が違えば文面を分け、同じなら共通にする
- 片方にしか出さない版は、そのことを本文に書く

**案をチャットで見せるだけで止める。ファイルの編集・コミット・マージはしない。**
「OK」をもらったら、1 回でまとめて行う:

1. `docs/release-notes-<version>` ブランチを切る
2. `docs/release-notes.md` の先頭(最初の `---` の直後)に `## <version> (build <build>)` の節を追記する。
   直前の版の書式に揃え、補足(共通の文面か、片方だけの版か等)を本文に 1〜2 行添える
3. `docs: add the <version> release notes` でコミットし、main に `--no-ff` でマージして
   ブランチを削除する

## 6. Archive 前の設定の再生成

Xcode の Archive は、前回生成した xcconfig の古いバージョンを使ってしまうため、
出すプラットフォームの分だけ実行する(ネイティブの設定を書き換えるだけで、
ビルド成果物は作らない)。

```
flutter build ios --config-only
flutter build macos --config-only
```

終わったら、Xcode で Archive → 提出するようユーザーに伝える
(Archive と提出はユーザーが行う)。

## 7. 提出後

ユーザーから次の報告があったら、`docs/release-notes.md` の見出しの build 表記を直す
(見出しが使用済みビルド番号の台帳を兼ねるため)。

- iOS で Xcode がビルド番号を自動で繰り上げた
- リジェクトされて番号を捨て、再提出した(捨てた番号も書く)

このときも 5 と同じく、文面を見せて確認をとってからコミット・マージする。
