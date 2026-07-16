# Phase 2 実装計画: 学習中カードビュー + フラッシュクイズ + 設定画面

> 前提・確定済み設計判断は [overview.md](overview.md)、Phase 1 の成果物は [phase1.md](phase1.md) を参照。
> UI の正は `docs/prototype/design/eitangocho.html`。
> 本計画は設計書レベル。**設計判断は確定済み**だが、ファイル分割・ウィジェット粒度は
> Phase 1 完了時点のコードベースに合わせて実装時に微調整してよい。

## ゴール

- 学習中(未学習)単語のカードグリッドビュー(訳の隠し/表示、空状態)
- フラッシュクイズ(シャッフル出題 → 答え表示 → 覚えている/忘れていた → 完了画面)
- クイズ実績の記録(lastReviewedAt / correctCount。UI 表示はしない)
- 設定画面(クイズ方向・IPA 表示)+ shared_preferences

**ブランチ名: `feature/phase2-learning-quiz`**(Phase 1 マージ後の main から作成)

## pubspec に追加するもの

- dependencies: `shared_preferences: ^2.5.5`

## 作成・変更するファイル(想定。実装時に微調整可)

### 変更

- `pubspec.yaml` / `pubspec.lock`(C3)
- `lib/app/main_page_state.dart`: `MainView` に `learning` / `quiz` / `settings` を追加。
  既定ビューを `learning` に変更(プロトタイプの初期表示は「学習中」)(C1)
- `lib/app/main_page.dart` / `lib/app/widgets/app_sidebar.dart`:
  ナビ項目追加(学習中=未学習件数、フラッシュクイズ=学習済み件数)、ビュー出し分け追加(C1〜C3)
- `lib/app/widgets/main_toolbar.dart`: タイトル追加(学習中の単語 / フラッシュクイズ / 設定)。
  検索フィールドは学習中・全単語ビューのみ表示(プロトタイプ準拠)(C1)
- `lib/db/daos/word_dao.dart`: `recordQuizResult` 追加(C2)
- `lib/features/word_registration/presentation/word_registration_notifier.dart`:
  保存後の遷移先を学習中ビューに変更(プロトタイプ準拠に戻す)(C1)

### 作成

- `lib/features/word/data/`: 学習中のみ・学習済みのみ・各件数の派生 Provider
  (Phase 1 の `wordListProvider` から派生。DB への追加クエリは作らない)(C1)
- `lib/features/word/presentation/learning_words_view.dart` + `widgets/`:
  `word_card.dart`(1 枚のカード)、`word_card_grid.dart`、
  `learning_empty_state.dart`、`reveal_japanese_button.dart` 等(C1)
- `lib/features/quiz/presentation/`: `quiz_view.dart`、`quiz_page_state.dart`、
  `quiz_page_notifier.dart`、`widgets/`(`quiz_card.dart`、`quiz_answer_buttons.dart`、
  `quiz_result_view.dart`、`quiz_empty_state.dart` 等)(C2)
- `lib/features/settings/presentation/settings_view.dart` + `widgets/`(C3)
- `lib/features/settings/data/settings_notifier.dart`(shared_preferences ラッパー)(C3)
- テスト: `word_dao_test`(recordQuizResult 追加分)、`quiz_page_notifier_test`、
  `learning_words_view_test`、`settings_notifier_test`(C1〜C3)

## 設計

### 学習中カードビュー(プロトタイプ「学習中リスト」準拠)

- グリッド: `repeat(auto-fill, minmax(260px, 1fr))` 相当 → 横幅から列数を計算する
  `SliverGrid` / `LayoutBuilder`(`AppDimensions.cardMinWidth` / `gridGap` を使用)
- 冒頭の案内文(12px / textTertiary):
  「チェックを入れると学習済みになり、このリストから消えます。カードをクリックすると編集できます(右クリックでメニュー)。」
- カード構成(上から): 単語(17px bold)+ IPA(12px 等幅 / textTertiary、
  **設定 showIpa=OFF なら非表示**)+ 右端に品詞バッジ /
  訳エリア / 英例文(13px)+ 訳表示時のみ日本語例文(12px)、例文なしは
  textDisabled で「例文なし」 / フッター(上 border): 「学習済みにする」チェックボックス
- 訳エリア: 未表示時は破線 border の「日本語訳を表示」ボタン(12px / rgba(0,0,0,0.4))、
  クリックで訳(13px、背景 inputBackground)に置き換わり、再クリックで隠す。
  トグルはカードウィジェットのローカル state(overview.md の方針どおり)
- カードクリック → 編集モーダル、右クリック → コンテキストメニュー(Phase 1 の
  `edit_word_dialog` / `word_context_menu` を再利用)。チェックボックスはクリック伝播させない
- カードの発音ボタン/リンク(プロトタイプ右下)は **Phase 3 で追加**(フッターはチェックのみ)
- 空状態(学習中 0 件): 中央に「学習中の単語はありません。\n単語を登録しましょう。」+
  「＋ 単語を登録」ボタン(AppFilledButton → 登録ビューへ)
- 検索はツールバー検索を適用(未学習のみを対象にフィルタ。プロトタイプ準拠)

### フラッシュクイズ

**状態モデル**(State + Notifier ペア。名称は規約どおり QuizPageState / QuizPageNotifier):

```dart
enum QuizPhase { empty, active, done }

@freezed
abstract class QuizPageState with _$QuizPageState {
  const factory QuizPageState({
    required QuizPhase phase,
    /// セッション開始時に学習済み単語をシャッフルしたスナップショット。
    /// セッション中の learned 変更・編集は進行に影響させない
    @Default(<Word>[]) List<Word> questions,
    @Default(0) int index,
    @Default(false) bool revealed,
    @Default(0) int okCount,
    @Default(<Word>[]) List<Word> forgotWords,
  }) = _QuizPageState;
}
```

**ロジック(プロトタイプの startQuiz / quizAnswer / quizForgot 準拠)**:

- サイドバーの「フラッシュクイズ」クリックで**常に新セッションを開始**
  (`questions = 学習済み全件をシャッフル`)。ビューを離れたらセッションは破棄
- 学習済み 0 件 → `phase: empty`: 「復習対象の単語がまだありません。\n単語を学習済みにするとここに表示されます。」+「学習中リストへ」ボタン(outlined)
- 出題カード(幅 480、中央配置): 進捗「{index+1} / {総数}」(12px) /
  表面(32px bold)+ IPA(13px 等幅。**英→日のときのみ表示**、プロトタイプ準拠) /
  「答えを表示」(filled、幅いっぱい)
- 答え表示後: カード内に区切り線 + 裏面(18px)+ 例文(英 + 日、13px)。
  ボタン列「忘れていた」(danger 文字の outlined)/「覚えている」(filled)、
  下に注記「「忘れていた」を選ぶと学習中リストに戻ります」(11px)
- 回答処理:
  - 覚えている → `WordDao.recordQuizResult(id, knew: true)`(lastReviewedAt = now、correctCount + 1)
  - 忘れていた → `WordDao.setLearned(id, isLearned: false)` +
    `recordQuizResult(id, knew: false)`(lastReviewedAt のみ更新)+ forgotWords に追加
  - 最終問題に回答したら `phase: done`
- 完了画面: 「復習完了」(22px bold)+「覚えている {ok}語 / 忘れていた {ng}語」 /
  忘れていた単語があればリスト(ヘッダ「忘れていた単語(学習中リストに戻りました)」、
  各行: 単語 w600 + 訳) / ボタン「もう一度」(filled、新セッション開始)+
  「学習中リストへ」(outlined)
- 発音ボタン(表面/答え面)は **Phase 3 で追加**

**WordDao に追加**:

```dart
/// クイズ回答を実績として記録する。knew のとき correctCount を +1。
/// updatedAt は同期の競合解決用の「内容変更」を意味させたいので、
/// 実績記録では更新しない…か、常に更新するかは実装時に決める(下記「揺れそうな箇所」参照)
Future<void> recordQuizResult(int id, {required bool knew});
```

### 設定画面

- `SettingsNotifier`(`@Riverpod(keepAlive: true)` class):
  shared_preferences を包み、`QuizDirection`(enum: `enToJa` / `jaToEn`、既定 enToJa)と
  `showIpa`(bool、既定 true)を公開。`SharedPreferencesAsync` を使用し、
  build 時に読み込み。キー名: `quizDirection` / `showIpa`
- 設定ビュー(プロトタイプに画面デザインなし。既存フォーム様式に合わせる):
  幅 560・左上寄せで「クイズの出題方向」(ラジオまたはセグメント: 英語 → 日本語 / 日本語 → 英語)、
  「発音記号(IPA)を表示」(スイッチ)。保存ボタンは置かず変更即保存
- サイドバー最下部(フッターの上)に「設定」項目を追加(件数バッジなし)
- 反映先:
  - `quizDirection`: クイズの表面/裏面の入れ替え。`ja→en` のときは表面に IPA を出さない
    (プロトタイプの `quizIpa` ロジック準拠)。Phase 3 で発音ボタンの配置にも影響
    (英→日は表面、日→英は答え面)
  - `showIpa`: **学習中カードの IPA 表示のみ**に適用(プロトタイプの `decorate` が
    カードにのみ適用している挙動に準拠。テーブルの発音記号列は常時表示)

## 実装の順序とコミット計画

分割理由: 各コミットが「単独で起動・検証できる 1 機能」になるよう、
ビュー(C1)→ クイズ(C2)→ 設定(C3)の順に積む。C2 は C1 のナビ拡張に、
C3 は C2 のクイズ(方向設定の反映先)に依存する。

### C1: `feat: 学習中カードビューと空状態を追加`

ナビ拡張(学習中・クイズ・設定の項目追加とビュー枠)+ 学習中カードグリッド一式。
クイズ・設定ビューはプレースホルダでよい。登録後の遷移先を学習中に戻す。

検証: `flutter analyze` / `flutter test` / `flutter run -d macos`:
- 初期表示が「学習中の単語」ビューになる
- 未学習単語だけがカード表示され、チェックを入れるとカードが消え「全単語」では学習済みになっている
- 「日本語訳を表示」で訳と日本語例文が現れ、再クリックで隠れる
- 学習中 0 件で空状態と登録導線が出る
- サイドバーの件数(学習中=未学習数、全単語=総数、フラッシュクイズ=学習済み数)が正しい

### C2: `feat: フラッシュクイズとクイズ実績記録を追加`

QuizPageState / Notifier、出題 → 回答 → 完了画面、recordQuizResult(DAO テスト追加)。

検証: `flutter analyze` / `flutter test`(quiz_page_notifier_test: シャッフル出題数、
回答での進行、忘れていた → isLearned false + forgotWords、完了判定、実績カラム更新)/
`flutter run -d macos`:
- 学習済み単語数と同じ回数出題され、進捗表示が正しい
- 「忘れていた」にした単語が学習中リストに戻り、完了画面の一覧に載る
- 「もう一度」で新しいシャッフル順のセッションが始まる
- クイズ 0 件時の空状態と「学習中リストへ」導線

### C3: `feat: 設定画面(クイズ方向・IPA 表示)を追加`

pubspec(shared_preferences)+ SettingsNotifier + 設定ビュー + 反映。

検証: `flutter analyze` / `flutter test`(settings_notifier_test: 既定値・保存・再読込)/
`flutter run -d macos`:
- 日本語 → 英語に切り替えるとクイズの表面が訳・裏面が英単語になり、表面に IPA が出ない
- IPA 表示 OFF でカードから IPA が消える(テーブルには残る)
- アプリ再起動後も設定が保持されている

## 実装時に判断が揺れそうな箇所(選択肢と推奨)

1. **recordQuizResult で updatedAt を更新するか**
   - A(推奨): 更新しない。updatedAt は「単語内容の編集」を表すものとして予約し、
     将来の iCloud 同期(タイムスタンプ勝ち)でクイズ実績だけの端末が編集を上書きしない
     ようにする
   - B: 更新する。実装は単純だが、同期導入時に実績更新が内容変更として扱われる
2. **クイズセッション中に対象単語が編集・削除された場合**
   - A(推奨): スナップショット(`questions`)をそのまま出題し続ける。回答時の DAO 更新は
     id 指定なので削除済みなら単に効かない(drift の update/delete は対象 0 行でもエラーに
     ならない)。実装が最少
   - B: 出題前に毎回 DB を引き直す。整合するがセッションの意味が崩れる
3. **設定ビューのウィジェット**: Material の `RadioListTile` / `SwitchListTile` をそのまま使うか、
   プロトタイプのトーンに合わせた自作にするか
   - 推奨: まず Material 標準で実装し、見た目の磨き込みは Phase 4 に回す

## やらないこと(Phase 2 のスコープ外)

- 発音ボタン・Google 翻訳リンク(カード・クイズとも Phase 3)
- 登録の自動入力・2 ステップ化(Phase 3)
- DeepL キー入力欄(Phase 3 で設定画面に追加)
- クイズ実績の表示・出題順への反映(MVP 外。記録のみ)
- JSON エクスポート/インポート・ショートカット(Phase 4)
