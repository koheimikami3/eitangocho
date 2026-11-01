# リリース設定

`/release` スキル(`~/.claude/skills/release/`)が読む、このアプリ固有の値。
手順そのものはスキル側にあり、ここには英単語帳だけの規則を書く。
設計上の理由は [design.md](design.md) の「ビルド・提出」。

## プラットフォーム

- iOS(App Store)と macOS(Mac App Store)
- **両プラットフォームとも `native/` の Swift 版から出す**(macOS は 2.12.0 から、iOS はその次に出す版から)。
  リポジトリに pubspec があるのでスキルは `flutter.md` を読むが、下の値に従い、Xcode の手順(スキルの `xcode.md`)で進める。
  Flutter 版(`lib/`・`ios/`・`macos/`)は、戻す版が要るときだけ使う(下の「Flutter 版を出すとき」)
- **バージョンは 1 つを両プラットフォームで共有する**が、片方にしか出さない版もある
  (1.1.0・1.4.0・1.5.0・2.0.0 は iOS のみ、2.12.0 は macOS のみ)。スキルの 2 では、どれに出すかを必ず確認する

## バージョンとビルド番号

- `native/Configs/Shared.xcconfig` の `MARKETING_VERSION`(版)と `CURRENT_PROJECT_VERSION`(ビルド番号)を書き換える。
  両 OS で共通の値で、pbxproj にはバージョンを書いていない。pubspec は触らない
- バンプのコミット: `chore: bump the version to <version>+<build>`
- **ビルド番号は全履歴を通じて単調増加で、再利用しない**(macOS の制約。iOS は
  バージョン内で一意なら通る)。次の番号は [release-notes.md](release-notes.md) の
  見出しに書かれた最大値 + 1(両 OS を通す)
- 見出しが使用済みビルド番号の台帳を兼ねる。書式は `## <version> (build <build>)`、
  iOS と macOS で番号が違えば `## <version> (iOS build <n> / macOS build <m>)`
- 提出後、Xcode がビルド番号を自動で繰り上げた(Organizer から手で上げた場合)・リジェクトで番号を捨てた、という
  報告があれば見出しを直す(スキルの 9)

## 完了時の検証

`native/` のコードを変えた版では次を実行する(iOS を出す版は iOS のビルドも):

```
swift test --package-path native/Packages/EitangochoCore
xcodebuild test -project native/Eitangocho.xcodeproj -scheme Eitangocho -destination 'platform=macOS'
xcodebuild -project native/Eitangocho.xcodeproj -scheme Eitangocho -destination 'generic/platform=iOS Simulator' build
```

Flutter 版を出すときだけ、代わりに次を実行する:

```
flutter analyze
flutter test -r failures-only
```

## リリースノート

- iOS と macOS で入った内容が違えば文面を分け、同じなら共通にする
- 片方にしか出さない版は、そのことを本文に書く

## Archive 前の手順

設定の再生成は要らない。**手元で Release を Run しない**
(本番の Bundle ID のまま、この端末のストア版のデータと本番の iCloud を引き継いでしまう。Archive は Run しないのでよい)。

## Archive とアップロード

チーム ID は `M5WP527J7Y`(スキルの `ExportOptions.plist` の `TEAM_ID`)。
プロジェクトは `-project native/Eitangocho.xcodeproj`、スキームは `Eitangocho`(両 OS で 1 つのターゲット)。

| 出すもの | 行き先 | 確かめる entitlements |
|---|---|---|
| iOS | `generic/platform=iOS` | `native/Support/Eitangocho-iOS.entitlements`(App Group・iCloud。`icloud-container-environment` は書き出しで `Production` が足される) |
| macOS | `generic/platform=macOS` | `native/Support/Eitangocho-macOS.entitlements`(同上) |

- 両 OS とも、同梱のプロファイルが配布用で App Group を含み、`get-task-allow` が無いこと
- iOS は `MinimumOSVersion` が 18.0、`PrivacyInfo.xcprivacy`・`GoogleService-Info.plist` がある、
  Info.plist の `GADApplicationIdentifier` が本番(`native/Configs/Release.xcconfig` の値)・`SKAdNetworkItems`・
  `NSUserTrackingUsageDescription`・`FirebaseAutomaticScreenReportingEnabled = false`
- macOS は `lipo -archs` が `x86_64 arm64`(macOS 15 の Intel Mac にも配るため)、`LSMinimumSystemVersion` が 15.0
- Xcode の自動のビルド番号の繰り上げは使わない(ExportOptions で止めている)。番号は台帳どおりになる

## Flutter 版を出すとき(戻す版が要るときだけ)

Swift 版で直せない問題が出て Flutter 版に戻す版を出す場合に限る(戻し方は Swift 移行の計画の第 2.6 節)。

- バージョンは `pubspec.yaml` の `version:` を `<version>+<build>` にする。番号は上と同じ台帳から取る
- プロジェクトは `-workspace ios/Runner.xcworkspace`・スキーム `Runner`(entitlements は `ios/Runner/Runner.entitlements`)、
  macOS は `-workspace macos/Runner.xcworkspace`・スキーム `Runner`
- Archive の前に、出すプラットフォームの分だけ、**macOS → iOS の順で**実行する:

  ```
  flutter build macos --config-only
  flutter build ios --config-only
  ```

  macOS の実行は、iOS 側の生成パッケージ(`FlutterGeneratedPluginSwiftPackage`)の
  最低 OS を Flutter の初期値 13.0 に戻す。Firebase は iOS 15.0 を要求するため、
  iOS を後に実行して 15.0 に上げ直す(Flutter の既知の不具合 #162196)。
- macOS は `tool/verify_flutter_version.sh` がビルド時に xcconfig のずれを検知して止める
  (書き直しても同じビルドには反映されないため、直さずに止める)。止まったら
  `flutter build macos --config-only` を実行してから Archive し直す。iOS をまだ
  Archive していなければ、続けて `flutter build ios --config-only` も実行する

## タグ本文の補足

片方のプラットフォームだけの版でもタグ名は `v<version>` のまま。本文に英語で添える例:

- `Released on both platforms. For macOS this is the first release since 1.7.0, because 2.0.0 was iOS only.`
- `Shipped as App Store build 6. Build 5 was rejected under Guideline 2.1 ...`
- iOS と macOS でビルド番号が違う場合は、両方の番号を書く
