# Phase 1 実装計画: 基盤 + 単語 CRUD + 全単語テーブル

> 前提・確定済み設計判断・パッケージバージョンは [overview.md](overview.md) を先に読むこと。
> UI の正は `docs/prototype/design/eitangocho.html`(以下「プロトタイプ」)。
> この計画書は**読むだけで実装に着手できる解像度**を意図している。

## ゴール

- 依存パッケージ・リント(pedantic_mono)・コード生成の基盤を整える
- drift の全スキーマ(schemaVersion 1)と WordDao を確定・実装する
- `WordInfoProvider` 抽象(Phase 3 で実装)の型を確定する
- 透明タイトルバー + サイドバー + ツールバーのアプリシェルを作る
- 全単語テーブル(検索・学習済みトグル)、手動登録フォーム、編集モーダル・
  右クリックメニュー・削除確認ダイアログを実装する

**ブランチ名: `feature/phase1-foundation`**(main から作成。実装の最初のステップとして checkout)

## 作成・変更するファイル(完全リスト)

`*.g.dart` / `*.freezed.dart` は build_runner の生成物(コミットに含める)。以下では省略する。

### 変更

| ファイル | 内容 | コミット |
|---|---|---|
| `pubspec.yaml` / `pubspec.lock` | 依存追加(overview.md の Phase 1 列) | C1 |
| `analysis_options.yaml` | pedantic_mono + custom_lint へ置換 | C1 |
| `macos/Runner/MainFlutterWindow.swift` | 透明タイトルバー・ウィンドウサイズ | C3 |
| `lib/main.dart` | ProviderScope + EitangochoApp 起動に書き換え | C3 |
| `test/widget_test.dart` | 削除(flutter create のカウンターテスト) | C3 |

### 作成

| ファイル | 内容 | コミット |
|---|---|---|
| `lib/enums/part_of_speech.dart` | 品詞 enum(ラベル・バッジ色) | C2 |
| `lib/constants/app_colors.dart` | 配色定数(プロトタイプから抽出) | C2 |
| `lib/constants/app_dimensions.dart` | 寸法定数 | C2 |
| `lib/db/converters/part_of_speech_list_converter.dart` | 品詞 CSV ⇔ List 変換 | C2 |
| `lib/db/tables.dart` | 全テーブル定義 | C2 |
| `lib/db/app_database.dart` | AppDatabase(schemaVersion 1) | C2 |
| `lib/db/daos/word_dao.dart` | WordDao | C2 |
| `lib/providers/database_provider.dart` | AppDatabase のグローバル Provider | C2 |
| `lib/features/word_registration/domain/word_info.dart` | WordInfo(Freezed) | C2 |
| `lib/features/word_registration/domain/word_info_provider.dart` | WordInfoProvider 抽象 | C2 |
| `lib/features/word_registration/domain/word_info_exception.dart` | 取得失敗例外 | C2 |
| `test/db/word_dao_test.dart` | DAO 単体テスト | C2 |
| `test/db/converters/part_of_speech_list_converter_test.dart` | Converter テスト | C2 |
| `lib/app/eitangocho_app.dart` | MaterialApp(テーマ) | C3 |
| `lib/app/main_page.dart` | シェル(サイドバー + ツールバー + ビュー切替) | C3 |
| `lib/app/main_page_state.dart` | MainPageState(Freezed) | C3 |
| `lib/app/main_page_notifier.dart` | MainPageNotifier(@riverpod) | C3 |
| `lib/app/widgets/app_sidebar.dart` | サイドバー | C3 |
| `lib/app/widgets/sidebar_item.dart` | サイドバー項目(1 行) | C3 |
| `lib/app/widgets/main_toolbar.dart` | ツールバー | C3 |
| `lib/app/widgets/toolbar_search_field.dart` | 検索フィールド | C3 |
| `lib/components/app_filled_button.dart` | 塗りボタン(色指定可) | C3 |
| `lib/components/app_outlined_button.dart` | 枠線ボタン(文字色指定可) | C3 |
| `test/app/main_page_test.dart` | シェル表示・ビュー切替 smoke | C3 |
| `lib/components/labeled_text_field.dart` | ラベル付き入力欄 | C4 |
| `lib/components/pos_chip_selector.dart` | 品詞チップ複数選択 | C4 |
| `lib/features/word_registration/presentation/word_registration_view.dart` | 登録フォーム | C4 |
| `lib/features/word_registration/presentation/word_registration_state.dart` | State(Freezed) | C4 |
| `lib/features/word_registration/presentation/word_registration_notifier.dart` | Notifier | C4 |
| `test/features/word_registration/presentation/word_registration_notifier_test.dart` | バリデーション・保存テスト | C4 |
| `lib/features/word/data/word_list_provider.dart` | 単語リスト Stream + 検索フィルタ | C5 |
| `lib/features/word/presentation/all_words_view.dart` | 全単語テーブル | C5 |
| `lib/features/word/presentation/widgets/word_table_header.dart` | テーブルヘッダ行 | C5 |
| `lib/features/word/presentation/widgets/word_table_row.dart` | テーブル 1 行 | C5 |
| `lib/features/word/presentation/widgets/pos_badge.dart` | 品詞バッジ(ピル) | C5 |
| `lib/features/word/presentation/widgets/learned_checkbox.dart` | 学習済みチェック | C5 |
| `test/features/word/presentation/all_words_view_test.dart` | 表示・検索・トグルのウィジェットテスト | C5 |
| `lib/features/word/presentation/widgets/edit_word_dialog.dart` | 編集モーダル | C6 |
| `lib/features/word/presentation/widgets/delete_confirm_dialog.dart` | 削除確認ダイアログ | C6 |
| `lib/features/word/presentation/widgets/word_context_menu.dart` | 右クリックメニュー表示ヘルパ | C6 |

## コミット計画(実装順序・依存関係・検証)

順序は C1 → C6。各コミット時点で `flutter analyze`(警告 0)と `flutter test`(全パス)を通すこと。

### C1: `chore: 依存パッケージ追加と pedantic_mono への切替`

他の全コミットの前提(依存とリント)を先に固める。

- `pubspec.yaml` に overview.md の「導入フェーズ 1」のパッケージを追加
- `analysis_options.yaml` を以下に置換:

```yaml
include: package:pedantic_mono/analysis_options.yaml

analyzer:
  plugins:
    - custom_lint
```

- 検証: `flutter pub get` 成功 → `flutter analyze`。
  既存 `lib/main.dart`(カウンターアプリ)が pedantic_mono の lint に違反する場合は
  最小修正で警告 0 にする(C3 で全面書き換えするので凝らない)

### C2: `feat: drift スキーマ・WordDao・WordInfoProvider 抽象を追加`

UI から独立して検証できる土台。DB・enum・定数・抽象 IF と、そのテスト。

- 後述の「コード定義」のとおり実装し、`dart run build_runner build --delete-conflicting-outputs` を実行
- 検証: `flutter analyze` / `flutter test`(word_dao_test・converter_test がパス)

### C3: `feat: アプリシェル(透明タイトルバー・サイドバー・ツールバー)を追加`

画面骨格。コンテンツ領域は C4/C5 実装までプレースホルダ(`Center(Text('未実装'))` 等)でよい。

- `MainFlutterWindow.swift` 変更、`lib/main.dart` 書き換え、`lib/app/` 一式、共通ボタン 2 種
- `test/widget_test.dart` を削除し `test/app/main_page_test.dart` を追加
  (テストでは `databaseProvider` を in-memory DB で override する)
- 検証: `flutter analyze` / `flutter test` / `flutter run -d macos` で手動確認:
  - ウィンドウが 1200x780 で開き、タイトルバーが透明でサイドバー(#F0F0F3)が
    信号機ボタンの背後まで届いている
  - サイドバーに「単語帳」ラベル、「全単語」「単語を登録」項目、
    フッター「ローカル DB に保存済み」が表示される
  - 項目クリックでビューが切り替わり、選択中項目に背景(rgba(0,0,0,0.09))が付く
  - ツールバーにビュータイトルと「＋ 単語を登録」ボタンが表示される

### C4: `feat: 単語の手動登録フォームを追加`

テーブル(C5)の動作確認にデータが必要なので、登録を先に作る。

- 登録フォーム(プロトタイプの「ステップ 2」相当。自動入力バッジ・未収録バナーなし)
- 検証: `flutter analyze` / `flutter test`(notifier テスト)/ `flutter run -d macos`:
  - 「＋ 単語を登録」またはサイドバー「単語を登録」でフォームが開く
  - 英単語・日本語訳が空のまま「登録する」→ 赤字「英単語と日本語訳は必須です。」
  - 品詞チップの選択がトグルできる(選択時: 青背景・白文字)
  - 登録すると全単語ビューに遷移する(C5 実装前はプレースホルダ表示のままでよい)

### C5: `feat: 全単語テーブル(検索・学習済みトグル)を追加`

- 検証: `flutter analyze` / `flutter test`(ウィジェットテスト)/ `flutter run -d macos`:
  - C4 で登録した単語が新しい順に表示される
  - 学習済みチェックの ON/OFF が即時反映され、ON の行は背景 #FAFAFB になる
  - ツールバー検索(英単語の部分一致は大文字小文字無視、日本語訳の部分一致)で行が絞られる
  - アプリを再起動してもデータが残っている(drift 永続化の確認)

### C6: `feat: 単語の編集モーダル・コンテキストメニュー・削除確認を追加`

- 検証: `flutter analyze` / `flutter test` / `flutter run -d macos`:
  - 行クリックで編集モーダルが開き、既存値がプレフィルされている
  - 編集保存で行が更新される(必須バリデーションはフォームと同じ)
  - 右クリックで「編集...」「削除...」メニュー
  - 削除は「「{単語}」を削除しますか?」ダイアログを挟み、「削除する」で行が消える
  - モーダル内「削除...」からも同じ確認ダイアログに到達する

Phase 1 完了時に `git diff main` を確認し、意図しない変更がないことを見てから main にマージする。

## コード定義

### pubspec.yaml(追加部分)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  drift: ^2.34.2
  drift_flutter: ^0.3.1
  flutter_riverpod: ^3.3.2
  freezed_annotation: ^3.1.0
  json_annotation: ^4.12.0
  riverpod_annotation: ^4.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.15.2
  custom_lint: ^0.8.1
  drift_dev: ^2.34.4
  freezed: ^3.2.5
  json_serializable: ^6.14.0
  pedantic_mono: ^1.37.0
  riverpod_generator: ^4.0.4
  riverpod_lint: ^3.1.4
```

(`flutter_lints` は削除する)

### lib/enums/part_of_speech.dart

```dart
import 'package:flutter/material.dart';

/// 品詞。DB には [name] を CSV 連結した文字列で保存する
/// (PartOfSpeechListConverter 参照)。
/// バッジ色はプロトタイプの PILLS 定義に準拠。
enum PartOfSpeech {
  verb('動詞', Color(0xFFE3EDFB), Color(0xFF1C56A8)),
  noun('名詞', Color(0xFFEEE7FA), Color(0xFF5B3BA8)),
  adjective('形容詞', Color(0xFFFBE7E7), Color(0xFFA83B3B)),
  adverb('副詞', Color(0xFFDFF1EC), Color(0xFF1F6F5C)),
  other('その他', Color(0xFFECECEF), Color(0xFF55555C));

  const PartOfSpeech(this.label, this.badgeBackground, this.badgeForeground);

  /// 表示用の日本語ラベル
  final String label;
  final Color badgeBackground;
  final Color badgeForeground;
}

/// 複数品詞の表示用連結(例: 「動詞・名詞」)
extension PartOfSpeechListLabel on List<PartOfSpeech> {
  String get joinedLabel => map((p) => p.label).join('・');
}
```

### lib/constants/app_colors.dart(プロトタイプから抽出した値)

```dart
import 'package:flutter/material.dart';

/// 配色定数。値は docs/prototype/design/eitangocho.html から抽出したもの。
abstract final class AppColors {
  static const accent = Color(0xFF0A6EE0);          // 主要アクション
  static const accentHover = Color(0xFF0B63C6);
  static const danger = Color(0xFFC03030);          // 削除系
  static const dangerHover = Color(0xFFA82828);
  static const dangerHoverBackground = Color(0xFFFDF2F2);
  static const textPrimary = Color(0xFF1D1D1F);
  static const textSecondary = Color(0x99000000);   // rgba(0,0,0,0.6)
  static const textTertiary = Color(0x73000000);    // rgba(0,0,0,0.45)
  static const textDisabled = Color(0x4D000000);    // rgba(0,0,0,0.3)
  static const sidebarBackground = Color(0xFFF0F0F3);
  static const sidebarSelected = Color(0x17000000); // rgba(0,0,0,0.09)
  static const inputBackground = Color(0xFFF7F7F8);
  static const tableHeaderBackground = Color(0xFFFAFAFB);
  static const learnedRowBackground = Color(0xFFFAFAFB);
  static const rowHoverBackground = Color(0xFFF2F6FC);
  static const border = Color(0x14000000);          // rgba(0,0,0,0.08)
  static const borderStrong = Color(0x24000000);    // rgba(0,0,0,0.14)
  static const inputBorder = Color(0x26000000);     // rgba(0,0,0,0.15)
}
```

(Phase 3 で自動入力バッジ #E2F3E8 / #1C7A3F、未収録バナー #FDF6E3 / #ECD9A0 / #8A6D1A を追加する)

### lib/constants/app_dimensions.dart

```dart
/// 寸法定数。値は docs/prototype/design/eitangocho.html から抽出したもの。
abstract final class AppDimensions {
  static const sidebarWidth = 212.0;
  static const toolbarHeight = 52.0;
  static const contentPadding = 20.0;
  static const formWidth = 560.0;   // 登録フォーム・編集モーダルの幅
  static const cardMinWidth = 260.0; // Phase 2 のカードグリッド用
  static const gridGap = 14.0;
}
```

### lib/db/converters/part_of_speech_list_converter.dart

```dart
import 'package:drift/drift.dart';
import 'package:eitangocho/enums/part_of_speech.dart';

/// List<PartOfSpeech> を 'verb,noun' 形式の CSV で保存する。
/// 未知のトークンはデシリアライズ時に黙って捨てる(将来 enum を削除しても
/// 読み込みが失敗しないようにするための防御)。
class PartOfSpeechListConverter
    extends TypeConverter<List<PartOfSpeech>, String> {
  const PartOfSpeechListConverter();

  @override
  List<PartOfSpeech> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final byName = PartOfSpeech.values.asNameMap();
    return fromDb.split(',').map((name) => byName[name]).nonNulls.toList();
  }

  @override
  String toSql(List<PartOfSpeech> value) =>
      value.map((p) => p.name).join(',');
}
```

### lib/db/tables.dart(schemaVersion 1・以後マイグレーション不要)

```dart
import 'package:drift/drift.dart';
import 'package:eitangocho/db/converters/part_of_speech_list_converter.dart';

/// 登録単語。updatedAt は将来の iCloud 同期の競合解決に使うため必ず更新する。
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get ipa => text().withDefault(const Constant(''))();

  /// 日本語訳(必須)
  TextColumn get japanese => text()();
  TextColumn get partsOfSpeech => text()
      .map(const PartOfSpeechListConverter())
      .withDefault(const Constant(''))();
  TextColumn get exampleEn => text().withDefault(const Constant(''))();
  TextColumn get exampleJa => text().withDefault(const Constant(''))();

  /// 辞書 API の発音 mp3 URL。空なら Google 翻訳リンクにフォールバック(Phase 3)
  TextColumn get audioUrl => text().withDefault(const Constant(''))();
  BoolColumn get isLearned => boolean().withDefault(const Constant(false))();

  /// クイズ実績(Phase 2 で更新開始。UI には出さない)
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// EJDict-hand(英和辞書)。Phase 3 の初回起動時取込で投入する。
class EjdictEntries extends Table {
  TextColumn get word => text()();

  /// EJDict の訳文字列(複数語義は原文のまま保持)
  TextColumn get meanings => text()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}

/// Free Dictionary API のレスポンスキャッシュ(成功時のみ保存し再フェッチしない)。
/// Phase 3 で利用する。
class DictionaryCacheEntries extends Table {
  TextColumn get word => text()();
  TextColumn get responseJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}
```

### lib/db/app_database.dart

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:eitangocho/db/converters/part_of_speech_list_converter.dart';
import 'package:eitangocho/db/daos/word_dao.dart';
import 'package:eitangocho/db/tables.dart';
import 'package:eitangocho/enums/part_of_speech.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Words, EjdictEntries, DictionaryCacheEntries],
  daos: [WordDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'eitangocho'));

  /// テスト用(NativeDatabase.memory() を渡す)
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
```

### lib/db/daos/word_dao.dart

```dart
import 'package:drift/drift.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/db/tables.dart';

part 'word_dao.g.dart';

/// Words テーブルへのクエリを集約する(presentation 層から DB を直接触らない規約)。
/// createdAt / updatedAt の付与は呼び出し側でなく DAO が責任を持つ。
@DriftAccessor(tables: [Words])
class WordDao extends DatabaseAccessor<AppDatabase> with _$WordDaoMixin {
  WordDao(super.db);

  /// 登録日時の新しい順(同時刻は id の新しい順)
  Stream<List<Word>> watchAll() => (select(words)
        ..orderBy([
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.desc(t.id),
        ]))
      .watch();

  Future<int> insertWord(WordsCompanion entry) {
    final now = DateTime.now();
    return into(words).insert(
      entry.copyWith(createdAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> updateWord(int id, WordsCompanion entry) async {
    await (update(words)..where((t) => t.id.equals(id))).write(
      entry.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteWord(int id) =>
      (delete(words)..where((t) => t.id.equals(id))).go();

  Future<void> setLearned(int id, {required bool isLearned}) =>
      (update(words)..where((t) => t.id.equals(id))).write(
        WordsCompanion(
          isLearned: Value(isLearned),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // Phase 2 で recordQuizResult(id, {required bool knew}) を追加する
  // (lastReviewedAt = now、knew なら correctCount + 1)
}
```

### lib/providers/database_provider.dart

```dart
import 'package:eitangocho/db/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
```

### lib/features/word_registration/domain/word_info.dart

```dart
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_info.freezed.dart';

/// WordInfoProvider が返す単語情報。取得できなかった項目は空文字 / 空リスト。
@freezed
abstract class WordInfo with _$WordInfo {
  const factory WordInfo({
    required String word,
    @Default('') String ipa,
    @Default(<PartOfSpeech>[]) List<PartOfSpeech> partsOfSpeech,
    @Default('') String japanese,
    @Default('') String exampleEn,
    @Default('') String exampleJa,
    @Default('') String audioUrl,
  }) = _WordInfo;
}
```

### lib/features/word_registration/domain/word_info_provider.dart

```dart
import 'package:eitangocho/features/word_registration/domain/word_info.dart';

/// 単語情報の自動取得を抽象化する(将来 LLM 実装への差し替えを可能にするため)。
/// 実装は Phase 3 の DictionaryWordInfoProvider(Free Dictionary + EJDict + DeepL)。
abstract interface class WordInfoProvider {
  /// 辞書に未収録の場合は null を返す。
  /// ネットワーク等の失敗は [WordInfoException] を投げる。
  Future<WordInfo?> fetch(String word);
}
```

### lib/features/word_registration/domain/word_info_exception.dart

```dart
/// WordInfoProvider の取得失敗(ネットワーク・API エラー等)。
/// 「辞書に未収録」は例外ではなく fetch の null 返却で表現する。
class WordInfoException implements Exception {
  const WordInfoException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'WordInfoException: $message';
}
```

### macos/Runner/MainFlutterWindow.swift(awakeFromNib に追記)

```swift
override func awakeFromNib() {
  let flutterViewController = FlutterViewController()
  let windowFrame = self.frame
  self.contentViewController = flutterViewController
  self.setFrame(windowFrame, display: true)

  // プロトタイプ準拠: サイドバーが信号機ボタンの背後まで届く見た目にするため
  // タイトルバーを透明化し、コンテンツをウィンドウ全面に広げる
  self.titlebarAppearsTransparent = true
  self.titleVisibility = .hidden
  self.styleMask.insert(.fullSizeContentView)
  self.setContentSize(NSSize(width: 1200, height: 780))
  self.minSize = NSSize(width: 900, height: 600)

  RegisterGeneratedPlugins(registry: flutterViewController)
  super.awakeFromNib()
}
```

### lib/main.dart

```dart
import 'package:eitangocho/app/eitangocho_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: EitangochoApp()));
}
```

### アプリシェル(lib/app/)

**eitangocho_app.dart**: `MaterialApp(debugShowCheckedModeBanner: false, home: MainPage())`。
テーマは `ThemeData(scaffoldBackgroundColor: Colors.white, colorSchemeSeed: AppColors.accent)`。
`fontFamily` は指定しない(macOS では San Francisco が既定で使われ、日本語は Hiragino に
フォールバックする。もし Roboto 表示になる場合のみ `fontFamily: '.AppleSystemUIFont'` を指定)。

**main_page_state.dart / main_page_notifier.dart**:

```dart
/// シェルで切り替えるビュー。Phase 2 で learning / quiz / settings を追加する。
enum MainView { allWords, registration }

@freezed
abstract class MainPageState with _$MainPageState {
  const factory MainPageState({
    @Default(MainView.allWords) MainView view,
    @Default('') String searchQuery,
  }) = _MainPageState;
}

@riverpod
class MainPageNotifier extends _$MainPageNotifier {
  @override
  MainPageState build() => const MainPageState();

  void selectView(MainView view) => state = state.copyWith(view: view);
  void updateSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
}
```

- ビューを切り替えたら検索文字列はリセットしない(プロトタイプ準拠)
- 「単語を登録」に切り替えるときは WordRegistrationNotifier 側でフォームを初期化する

**main_page.dart**: `Scaffold` → `Row [ AppSidebar, Expanded(Column [ MainToolbar, Expanded(コンテンツ) ]) ]`。
コンテンツは `switch (state.view)` で `AllWordsView` / `WordRegistrationView` を出し分け。
メイン領域は白背景、サイドバーとの境界に 1px の `AppColors.border`。

**app_sidebar.dart**(プロトタイプのサイドバー仕様):

- 幅 212(`AppDimensions.sidebarWidth`)、背景 `sidebarBackground`、右端 1px border
- 最上部に高さ 52 の空き(信号機ボタン領域。Flutter 側には何も描かない)
- セクションラベル「単語帳」: 11px / bold / `textTertiary` 相当(rgba(0,0,0,0.42))、padding 左 18
- 項目(SidebarItem): 「全単語」(件数バッジ付き)、「単語を登録」(バッジなし)。
  Phase 2 でここに「学習中」「フラッシュクイズ」「設定」が加わる
- 最下部にフッター「ローカル DB に保存済み」: 11px / rgba(0,0,0,0.35)、上 border

**sidebar_item.dart**: 13px ラベル + 右端に 11px の件数。選択中は背景 `sidebarSelected` +
太字(w600)、角丸 6、margin 水平 10 / padding 6x10。ホバーで rgba(0,0,0,0.06)。
件数は `wordListProvider` の派生(全件数)を watch する。

**main_toolbar.dart**: 高さ 52、下 border。左にビュータイトル
(15px / bold: `全単語` / `単語を登録`)、右に検索フィールド(全単語ビューのみ)と
「＋ 単語を登録」ボタン(AppFilledButton)。

**toolbar_search_field.dart**: 幅 200、placeholder「検索」、背景 `inputBackground`、
角丸 7、13px。変更を `MainPageNotifier.updateSearchQuery` に流す。

**components/app_filled_button.dart / app_outlined_button.dart**:
プロトタイプのボタン様式(塗り: 白文字 13-14px w600 角丸 7-9 / 枠線: 白地 + borderStrong)。
色はコンストラクタ引数(既定 accent、削除系で danger を渡す)。ホバー色も引数化する。

### 登録フォーム(C4)

**word_registration_state.dart / notifier**:

```dart
@freezed
abstract class WordRegistrationState with _$WordRegistrationState {
  const factory WordRegistrationState({
    @Default(<PartOfSpeech>{}) Set<PartOfSpeech> selectedPartsOfSpeech,
    String? errorMessage,
  }) = _WordRegistrationState;
}
```

- テキスト 6 項目(英単語 / IPA / 日本語訳 / 英例文 / 日本語例文)は View 側の
  `TextEditingController` で保持する(Phase 3 でプレフィルが必要になったら
  Notifier からの初期値注入に拡張する)。品詞選択とエラーは State に持つ
- `Future<bool> save({required String word, required String ipa, ...})`:
  - `word.trim()` か `japanese.trim()` が空なら `errorMessage = '英単語と日本語訳は必須です。'`
    をセットして false
  - 品詞が未選択なら `{PartOfSpeech.other}` を補う(プロトタイプ準拠)
  - 全テキストは trim して `WordDao.insertWord` → true を返し、View 側で
    `MainPageNotifier.selectView(MainView.allWords)` に遷移
    (プロトタイプは「学習中」に遷移するが Phase 1 に学習中ビューはないため。
    Phase 2 で学習中ビュー追加時にプロトタイプどおり学習中遷移へ戻す)

**word_registration_view.dart**(プロトタイプ「ステップ 2」フォーム準拠):

- 幅 560、左上寄せ、padding 28
- フィールド構成(上から): 2 カラム(英単語 * / 発音記号 (IPA))→ 日本語訳 * →
  品詞(複数選択可)チップ → 英例文(2 行 textarea)→ 日本語例文(2 行 textarea)
- ラベルは 12px / w600 / `textSecondary`。placeholder は全て「手動で入力してください」
- エラーは 12px / `danger` でボタン列の上に表示
- ボタン列: 「登録する」(AppFilledButton)+「キャンセル」(テキストボタン、
  rgba(0,0,0,0.5) → ホバーで textPrimary)。キャンセルで全単語ビューへ戻る
- Phase 1 では「自動入力」バッジ・「戻る」ボタン・未収録バナーは作らない(Phase 3)

**components/labeled_text_field.dart**: ラベル(必須マーク `*` 含む文字列)+
TextField/textarea。ラベル横に任意の trailing ウィジェット(Phase 3 の自動入力バッジ用)を
置けるようにしておく。

**components/pos_chip_selector.dart**: `PartOfSpeech.values` のチップを横並び
(wrap, gap 8)。選択中: 背景 accent / 白文字、非選択: 白地 / rgba(0,0,0,0.65) /
枠 rgba(0,0,0,0.18)。ピル形状(角丸 99)、12px w600。

### 全単語テーブル(C5)

**word_list_provider.dart**:

```dart
@riverpod
Stream<List<Word>> wordList(Ref ref) =>
    ref.watch(databaseProvider).wordDao.watchAll();

/// ツールバー検索でフィルタした一覧。
/// 英単語は大文字小文字を無視した部分一致、日本語訳はそのまま部分一致(プロトタイプ準拠)。
@riverpod
List<Word> filteredWordList(Ref ref) {
  final words = ref.watch(wordListProvider).value ?? const <Word>[];
  final query = ref
      .watch(mainPageNotifierProvider.select((s) => s.searchQuery))
      .trim();
  if (query.isEmpty) return words;
  final lower = query.toLowerCase();
  return words
      .where((w) =>
          w.word.toLowerCase().contains(lower) || w.japanese.contains(query))
      .toList();
}
```

**all_words_view.dart**: 縦スクロール領域。先頭に固定ヘッダ行、以下 `filteredWordList` の行。
0 件時は特別な空状態を作らない(プロトタイプに全単語の空状態定義がないため。
ヘッダ行のみ表示)。

**word_table_header.dart / word_table_row.dart**:

- カラム構成(Phase 1): 学習済み 64px / 単語 140px / 発音記号 130px / 品詞 100px /
  日本語訳 flex 2 / 例文 flex 3。**「発音」列(56px)は Phase 3 で追加する**
- ヘッダ: 11px / bold / `textTertiary`、背景 `tableHeaderBackground`、下 border
- 行: padding 10x20、下 border(rgba(0,0,0,0.06))、13px。
  単語は w600 / `textPrimary`、IPA は等幅(`fontFamily: 'Menlo'`)12px /
  rgba(0,0,0,0.5)、日本語訳は rgba(0,0,0,0.75)、例文は 12px / `textSecondary`
  (英例文 + 改行 + 日本語例文。例文が空なら `textDisabled` で「例文なし」)
- 学習済み行は背景 `learnedRowBackground`、ホバーで `rowHoverBackground`(MouseRegion)
- 行クリック → 編集モーダル(C6)。右クリック → コンテキストメニュー(C6)。
  チェックボックスのクリックは行クリックに伝播させない

**learned_checkbox.dart**: `Checkbox(activeColor: AppColors.accent)` を 14px 相当に
`Transform.scale` 等で調整。変更で `WordDao.setLearned` を呼ぶ。

**pos_badge.dart**: `List<PartOfSpeech>` を受け取りピル 1 個で表示
(ラベルは `joinedLabel`、色は**先頭の品詞**の badgeBackground / badgeForeground。
プロトタイプの pillFor が最初にマッチした品詞の色を使う挙動に準拠)。
11px / w600 / padding 2x8 / 角丸 99。

### 編集・削除(C6)

**edit_word_dialog.dart**: `showDialog` で表示。幅 560、角丸 13、padding 22x24。
タイトル「単語を編集」(16px bold)。フィールド構成は登録フォームと同一
(labeled_text_field / pos_chip_selector を再利用、既存値をプレフィル)。
StatefulWidget + ローカル TextEditingController で完結し、「保存」で必須バリデーション
(エラー文言「英単語と日本語訳は必須です。」)→ `WordDao.updateWord`。
ボタン列: 保存(filled)/ キャンセル(outlined)/ 右端に 削除...(danger outlined)。
「削除...」は delete_confirm_dialog を開き、確定されたら編集モーダルも閉じる。

**delete_confirm_dialog.dart**: 幅 380、中央寄せテキスト。
「「{word}」を削除しますか?」(15px bold)+「この操作は取り消せません。」
(12px / rgba(0,0,0,0.5))。ボタン: やめる(outlined)/ 削除する(danger filled)。
「削除する」で `WordDao.deleteWord`。

**word_context_menu.dart**: `GestureDetector.onSecondaryTapUp` の
`details.globalPosition` を使い `showMenu` で「編集...」「削除...」(削除は赤文字)を表示する
ヘルパ関数。見た目は Material 標準でよい(磨き込みは Phase 4)。

## テスト計画

| テスト | 内容 |
|---|---|
| `test/db/word_dao_test.dart` | `AppDatabase.forTesting(NativeDatabase.memory())` を使用。insert → watchAll に反映・createdAt/updatedAt 付与、並び順(新しい順)、update でフィールドと updatedAt が更新、delete で消える、setLearned のトグル |
| `test/db/converters/part_of_speech_list_converter_test.dart` | 空 ⇔ 空リスト、単一、複数の roundtrip、未知トークンが無視される |
| `test/app/main_page_test.dart` | `databaseProvider` を in-memory override。サイドバー項目・タイトル表示、項目クリックでビュー切替 |
| `test/features/word_registration/presentation/word_registration_notifier_test.dart` | 必須バリデーション(word / japanese 空で errorMessage)、保存で DAO に insert される、品詞未選択時に other が補われる |
| `test/features/word/presentation/all_words_view_test.dart` | DAO に 2 件投入して行表示、検索でフィルタ、チェックで isLearned 反転 |

drift のテストは macOS ホストのシステム SQLite で動くため追加セットアップ不要。
ウィジェットテストは `ProviderScope(overrides: [databaseProvider.overrideWithValue(...)])` を使う。

## やらないこと(Phase 1 のスコープ外)

- 学習中ビュー・カードグリッド・「日本語訳を表示」トグル(Phase 2)
- フラッシュクイズ・クイズ実績の更新(Phase 2)
- 設定画面・shared_preferences(Phase 2)
- 登録の 2 ステップ化・自動入力・WordInfoProvider の実装(Phase 3)
- 音声再生・テーブルの「発音」列・Google 翻訳リンク(Phase 3)
- EJDict の asset 同梱・初回取込(Phase 3。テーブル定義だけ Phase 1 で作る)
- JSON エクスポート/インポート・キーボードショートカット・アニメーション(Phase 4)
- iOS 対応・iCloud 同期・LLM 統合(MVP 外)
