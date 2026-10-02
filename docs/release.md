# リリース設定

`/release` スキル(`~/.claude/skills/release/`)が読む、このアプリ固有の値。
手順そのものはスキル側にあり、ここには英単語帳だけの規則を書く。
設計上の理由は [design.md](design.md) の「ビルド・提出」。

## プラットフォーム

- iOS(App Store)と macOS(Mac App Store)
- **バージョンは pubspec の 1 つを両プラットフォームで共有する**が、片方にしか出さない版もある
  (1.1.0・1.4.0・1.5.0・2.0.0 は iOS のみ)。スキルの 2 では、どれに出すかを必ず確認する

## バージョンとビルド番号

- `pubspec.yaml` の `version:` を `<version>+<build>` にする。ほかに揃えるファイルは無い
- バンプのコミット: `chore: bump the version to <version>+<build>`
- **ビルド番号は全履歴を通じて単調増加で、再利用しない**(macOS の制約。iOS は
  バージョン内で一意なら通る)。次の番号は [release-notes.md](release-notes.md) の
  見出しに書かれた最大値 + 1
- 見出しが使用済みビルド番号の台帳を兼ねる。書式は `## <version> (build <build>)`、
  iOS と macOS で番号が違えば `## <version> (iOS build <n> / macOS build <m>)`
- 提出後、iOS で Xcode がビルド番号を自動で繰り上げた・リジェクトで番号を捨てた、という
  報告があれば見出しを直す(スキルの 8)。macOS は自動で繰り上がらない

## 完了時の検証

```
flutter analyze
flutter test -r failures-only
```

## リリースノート

- iOS と macOS で入った内容が違えば文面を分け、同じなら共通にする
- 片方にしか出さない版は、そのことを本文に書く

## Archive 前の手順

出すプラットフォームの分だけ、**macOS → iOS の順で**実行する:

```
flutter build macos --config-only
flutter build ios --config-only
```

macOS の実行は、iOS 側の生成パッケージ(`FlutterGeneratedPluginSwiftPackage`)の
最低 OS を Flutter の初期値 13.0 に戻す。Firebase は iOS 15.0 を要求するため、
iOS を後に実行して 15.0 に上げ直す(Flutter の既知の不具合 #162196)。

macOS は `tool/verify_flutter_version.sh` がビルド時に xcconfig のずれを検知して止める
(書き直しても同じビルドには反映されないため、直さずに止める)。止まったら
`flutter build macos --config-only` を実行してから Archive し直す。iOS をまだ
Archive していなければ、続けて `flutter build ios --config-only` も実行する。

## タグ本文の補足

片方のプラットフォームだけの版でもタグ名は `v<version>` のまま。本文に英語で添える例:

- `Released on both platforms. For macOS this is the first release since 1.7.0, because 2.0.0 was iOS only.`
- `Shipped as App Store build 6. Build 5 was rejected under Guideline 2.1 ...`
- iOS と macOS でビルド番号が違う場合は、両方の番号を書く
