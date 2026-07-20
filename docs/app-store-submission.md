# Mac App Store 公開手順書

シンプル英単語帳(eitangocho)を Mac App Store に公開するための、ビルド → アップロード →
掲載情報 → 審査提出までの手順をまとめる。個人開発者アカウントでの公開を前提とする。

> 現状のリポジトリ設定(既に整っているもの):
> - Bundle ID: `com.kohei.mikami.eitangocho`
> - バージョン: `1.0.0+1`(pubspec.yaml。`CFBundleShortVersionString`=1.0.0 / `CFBundleVersion`=1)
> - 表示名: シンプル英単語帳(`CFBundleDisplayName` / `CFBundleName`)
> - Release entitlements: App Sandbox + `network.client` + `files.user-selected.read-write`
> - アプリアイコン: `AppIcon.appiconset` に 16〜1024px 配置済み
> - デプロイメントターゲット: macOS 10.15
>
> したがって残りは主に **Apple 側の登録作業** と **署名・アップロード・掲載情報の入力**。

---

## 全体の流れ

```
0. Apple Developer Program 登録(未登録なら。年 $99・審査に数日)
        ↓
1. 証明書・App ID・プロファイルの準備(Apple Developer / Xcode)
        ↓
2. App Store Connect でアプリレコード作成
        ↓
3. リリースビルドの最終確認(ローカル)
        ↓
4. アーカイブ作成 → 署名 → アップロード(Xcode Organizer または Transporter)
        ↓
5. 掲載情報(メタデータ・スクリーンショット・プライバシー)入力
        ↓
6. ビルドを紐付けて審査提出
        ↓
7. 審査通過 → 公開(自動 or 手動リリース)
```

所要時間の目安: Developer 登録の審査待ちを除けば、初回は掲載情報の準備込みで半日〜1日。

---

## 0. Apple Developer Program への登録(未登録の場合)

- <https://developer.apple.com/programs/> から加入。**年額 11,800 円(US$99)**。
- 個人(Individual)で登録可。法人格は不要。
- 登録には Apple ID の二要素認証が必要。本人確認で **数時間〜数日** かかることがある。
- ここが公開までのボトルネックになりやすいので最初に着手する。

> すでに加入済みの場合はこの節を飛ばす。

---

## 1. 証明書・App ID・プロファイルの準備

Xcode に Apple ID を追加しておけば、**署名まわりの多くは Xcode が自動生成**してくれる。
手動でやる場合の内訳も併記する。

### 1-1. Xcode に Apple ID を追加

Xcode → Settings → Accounts → 左下「+」→ Apple ID でログイン。
チーム(Personal Team ではなく **有料の Developer チーム**)が表示されることを確認。

### 1-2. App ID の登録

<https://developer.apple.com/account/resources/identifiers/list> →「+」→ App IDs → App。

- Description: 任意(例: `Eitangocho`)
- Bundle ID: **Explicit** で `com.kohei.mikami.eitangocho`(リポジトリと一致させる)
- Capabilities: 本アプリは App Sandbox のみで特別な Capability は不要
  (iCloud / Push などは使わないのでチェック不要)

### 1-3. 署名証明書(Xcode 自動管理を推奨)

Xcode で `macos/Runner.xcworkspace` を開き、Runner ターゲット → Signing & Capabilities:

- **Automatically manage signing** を ON
- Team: 有料 Developer チームを選択
- これで配布に必要な証明書
  (`3rd Party Mac Developer Application` / `3rd Party Mac Developer Installer`
  ≒ 現行名 `Apple Distribution` / `Mac Installer Distribution`)と
  プロビジョニングプロファイルが自動作成される。

> 手動管理する場合は Developer サイトの Certificates で Distribution 証明書と
> Installer 証明書を作成し、Mac App Store 用の Provisioning Profile を紐付ける。
> 特別な理由がなければ自動管理で十分。

---

## 2. App Store Connect でアプリレコードを作成

<https://appstoreconnect.apple.com/> → マイApp → 「+」→ 新規App。

| 項目 | 入力内容 |
|---|---|
| プラットフォーム | **macOS** |
| 名前 | シンプル英単語帳(ストア表示名。31 文字以内・既存と重複不可) |
| プライマリ言語 | 日本語 |
| バンドルID | 手順 1-2 で作った `com.kohei.mikami.eitangocho` を選択 |
| SKU | 任意の内部管理用文字列(例: `EITANGOCHO001`。ユーザーには見えない) |
| ユーザーアクセス | フルアクセスのまま可 |

作成後、アプリの詳細ページで後述の掲載情報を埋めていく。

---

## 3. リリースビルドの最終確認(ローカル)

アップロード前に、クリーンな状態でリリースビルドが通り実際に動くことを確認する。

```bash
# クリーンビルド
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 解析・テスト(CLAUDE.md の完了前チェックに準拠)
flutter analyze
flutter test

# リリースビルド
flutter build macos --release
```

- `build/macos/Build/Products/Release/シンプル英単語帳.app`(または `eitangocho.app`)を
  直接起動し、サンドボックス下で自動入力・音声再生・エクスポート/インポートが動くことを確認。
  → 詳細な確認項目は `docs/release-checklist.md` の「リリースビルドの実機確認」を参照。
- **AI 機能はストア配布に含めない**規約のため、`--dart-define=ENABLE_AI=true` を **付けない**
  こと(デフォルトで無効)。

### バージョン番号の確認

- `pubspec.yaml` の `version: 1.0.0+1` を確認。
  - `1.0.0` = ユーザー向けバージョン(`CFBundleShortVersionString`)
  - `+1` = ビルド番号(`CFBundleVersion`)
- **再アップロードのたびにビルド番号(+N)を必ず上げる**。同一ビルド番号は受け付けられない。
  修正して再提出する場合は `1.0.0+2` のように上げる。

---

## 4. アーカイブ作成 → アップロード

Flutter の `flutter build macos` はアーカイブ(.xcarchive)や署名済み .pkg までは作らないため、
**Xcode でアーカイブ**するのが最も確実。

### 4-1. Xcode でアーカイブ

1. `open macos/Runner.xcworkspace` で Xcode を開く。
2. スキームのビルド先(ターゲットデバイス)を **「My Mac」** に、ビルド構成が
   **Release** になっていることを確認(Product → Scheme → Edit Scheme → Archive が Release)。
3. メニュー **Product → Archive** を実行。
   - Archive メニューが無効な場合、実行先が「My Mac」になっているか確認。
4. 完了すると **Organizer** ウィンドウにアーカイブが表示される。

### 4-2. アップロード

Organizer で該当アーカイブを選択 → **Distribute App**:

- 配布方法: **App Store Connect**
- 送信先: **Upload**
- 署名: Automatically manage signing(手順 1-3)のまま進める
- 検証が通ればアップロードが実行される。

> **Transporter を使う代替ルート**: Organizer の Distribute で
> 「Export」して署名済み `.pkg` を書き出し、Mac App Store の
> [Transporter](https://apps.apple.com/app/transporter/id1450874784) アプリで
> ドラッグ&ドロップアップロードすることもできる。Xcode 直アップロードで問題なければ不要。

### 4-3. 処理待ち

アップロード後、App Store Connect 側で **10〜30 分ほど「処理中」** になる。
処理完了するとアプリの「TestFlight」/「App Store」→ ビルド欄に表示され、選択可能になる。
処理中に警告メール(ITMS-xxxx)が届くことがあるので確認する。

---

## 5. 掲載情報(メタデータ)の入力

App Store Connect のアプリ詳細ページで、バージョン `1.0` の情報を埋める。
**★ は審査提出に必須の項目。**

### 5-1. App 情報(全バージョン共通)

| 項目 | 内容・メモ |
|---|---|
| ★ サブタイトル | 任意(30 字以内)。例: 「自分だけの英単語帳とクイズ」 |
| ★ カテゴリ | プライマリ: **教育(Education)**。セカンダリは任意 |
| ★ コンテンツ配信権 | 「第三者コンテンツを含まない」を選択(自作のため) |
| ★ 年齢制限指定 | アンケートに回答。本アプリは不適切表現なし → 4+ 想定 |

### 5-2. プライバシー(★ 必須・要 URL)

- **プライバシーポリシー URL** が必須。データ収集をしていなくても URL は求められる。
  - GitHub Pages / Gist / 個人サイトなどに 1 ページ用意すれば可。
  - 内容の骨子: 「本アプリはユーザーデータを収集・送信しません。単語データは
    端末内(ローカル DB)にのみ保存されます。自動入力機能でのみ、ユーザーが入力した
    英単語を外部辞書 API(dictionaryapi.dev)および翻訳 API(DeepL)へ送信します。
    DeepL API キーは端末内にのみ保存されます。」
- **App のプライバシー(データ収集の申告)**:
  - 「データを収集しません(Data Not Collected)」を選択できる想定。
  - 判断根拠: 本アプリはアナリティクス・アカウント・トラッキングを持たず、サーバも持たない。
    外部送信は「機能提供のためユーザー操作で辞書/翻訳 API に単語を送る」だけで、
    開発者がユーザーに紐づけて収集・保持するデータは無い。
  - ⚠ DeepL / Free Dictionary への送信は「第三者 API の利用」であり、開発者による
    データ収集とは別概念。申告フォームは「あなた(開発者)が収集するか」を問うている。
    迷う場合は「収集しない」で申告し、審査で指摘があれば対応する。

### 5-3. バージョンごとの情報(1.0)

| 項目 | 内容・メモ |
|---|---|
| ★ プロモーションテキスト | 任意(170 字・審査不要でいつでも変更可) |
| ★ 説明(Description) | アプリの機能説明。下書き案を後述 |
| ★ キーワード | カンマ区切り 100 字(例: 英単語,単語帳,英語,学習,クイズ,ボキャブラリー) |
| サポート URL | ★ 必須。問い合わせ先ページ(GitHub リポジトリ or Issue でも可) |
| マーケティング URL | 任意 |
| ★ スクリーンショット | 後述(5-4) |
| ★ ビルド | 手順 4 でアップロードしたビルドを選択 |
| 著作権 | 例: `2026 Kohei Mikami` |
| バージョン | 1.0 |

#### 説明文の下書き案

```
シンプル英単語帳は、自分だけの英単語帳を作って覚えられる macOS アプリです。

■ 主な機能
・英単語を登録するだけで、発音記号・品詞・例文・発音音声を自動入力
・学習中/学習済みを切り替えながら、覚えたい単語だけに集中
・学習済みの単語からランダム出題されるフラッシュクイズ
・「忘れていた」単語は自動で学習中リストに復帰
・日本語訳はワンクリックで表示/非表示、クイズにも活用
・JSON でのバックアップ・書き出し/読み込み
・キーボードショートカット対応

■ プライバシー
すべてのデータは端末内に保存され、外部サーバには送信しません。
(自動入力機能のみ、入力した単語を辞書・翻訳サービスに送信します)
```

### 5-4. スクリーンショット(★ 必須)

- macOS App は **1280×800、1440×900、2560×1600、2880×1800** のいずれかの解像度で、
  **最低 1 枚(最大 10 枚)**。Retina 実寸(例 2560×1600)推奨。
- 撮り方: `flutter run -d macos` またはリリース .app を起動し、ウィンドウを整えて
  `⌘⇧4` → Space でウィンドウキャプチャ。必要なら指定解像度にリサイズ。
- おすすめ構図(4〜5 枚):
  1. 学習中カードビュー(カードが並んだ状態)
  2. フラッシュクイズ出題中(表面)
  3. 単語登録の自動入力結果(Step2)
  4. 全単語テーブルビュー
  5. 設定画面
- 文言や配色は実装済みアプリの見た目(= UI の正基準)そのままで撮る。

---

## 6. 審査提出

1. すべての ★ 項目が埋まると、右上の **「審査へ提出」** が有効になる。
2. 「輸出コンプライアンス」の質問:
   - 「暗号化を使用していますか?」→ 本アプリは HTTPS 通信(OS 標準)のみで、
     独自の暗号化実装は持たない。通常は **「該当する免除に当てはまる(標準暗号のみ)」**
     を選ぶ。年次自己分類レポートの提出は不要なケースが多い(表示された指示に従う)。
3. 提出後、ステータスが「審査待ち(Waiting for Review)」→「審査中」→「承認」と進む。
   初回審査は **1〜3 日程度**が目安。

### リリース方法の選択

- **自動リリース**: 承認後すぐ公開。
- **手動リリース**: 承認後、任意のタイミングで自分で公開ボタンを押す(推奨。初公開を
  コントロールできる)。

---

## 7. よくある審査上の注意点

- **クラッシュ**: 提出ビルドが起動直後に落ちないか、クリーンな環境で再確認。
- **サンドボックス違反**: ファイル保存/読込は必ずシステムのファイルダイアログ経由
  (本アプリは `user-selected.read-write` のみ)。任意パスへの直接書き込みは審査で弾かれる。
- **プライバシー整合性**: 説明・プライバシーポリシー・データ収集申告の三者で
  「外部 API に単語を送る」記述が矛盾しないようにする。
- **機能の完全性**: DeepL API キー未設定でも例文和訳以外は正常に動くこと(キー任意である旨を
  説明かアプリ内で示す)。審査者はキーを持たないため、キー必須にすると詰まる。
- **メタデータ拒否(Metadata Rejected)**: スクショやテキストの不備は比較的軽微な差し戻し。
  指摘箇所を直して再提出すれば、ビルド再アップロードは不要なことが多い。

---

## 提出前チェックリスト

### Apple 側
- [ ] Apple Developer Program 加入済み
- [ ] App ID `com.kohei.mikami.eitangocho` 登録済み
- [ ] Xcode の署名(自動管理)が Developer チームで解決している
- [ ] App Store Connect にアプリレコード作成済み

### ビルド
- [ ] `flutter analyze` / `flutter test` パス
- [ ] `flutter build macos --release` 成功、リリース .app が実機で一通り動く
- [ ] `--dart-define=ENABLE_AI=true` を **付けていない**
- [ ] バージョン/ビルド番号が既存アップロードと重複しない
- [ ] Xcode でアーカイブ → App Store Connect にアップロード → 処理完了

### 掲載情報
- [ ] カテゴリ(教育)・年齢制限・コンテンツ配信権
- [ ] プライバシーポリシー URL / サポート URL 用意
- [ ] データ収集申告(「収集しない」想定)
- [ ] 説明・キーワード・(任意)サブタイトル/プロモテキスト
- [ ] スクリーンショット 4〜5 枚(指定解像度)
- [ ] ビルドを紐付け

### 提出
- [ ] 輸出コンプライアンス回答
- [ ] リリース方法(手動推奨)選択
- [ ] 審査へ提出

---

## 参考リンク

- App 配布(Flutter 公式): <https://docs.flutter.dev/deployment/macos>
- App Store Connect ヘルプ: <https://developer.apple.com/help/app-store-connect/>
- スクリーンショット仕様: <https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/>
