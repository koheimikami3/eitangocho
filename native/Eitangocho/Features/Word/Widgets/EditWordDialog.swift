import EitangochoData
import EitangochoWordInfo
import SwiftUI

/// 単語の編集ダイアログ(Flutter 版の showEditWordDialog)。
///
/// 高さは固定の上限を持たず、ウィンドウに収まる範囲まで広げる。それでも入り切らないときは
/// 入力欄だけをスクロールさせ、保存・キャンセル・削除は常に下端に見えるようにする。
struct EditWordDialog: View {
  let word: Word
  let store: WordStore
  let language: TranslationLanguage
  let dismiss: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @Environment(\.appOverlay) private var overlay
  @Environment(\.analytics) private var analytics

  @State private var wordText: String
  @State private var ipa: String
  @State private var meaning: String
  @State private var exampleEn: String
  @State private var exampleTranslation: String
  @State private var partsOfSpeech: Set<PartOfSpeech>
  @State private var errorMessage: String?

  private static let horizontalPadding: CGFloat = 24

  init(word: Word, store: WordStore, language: TranslationLanguage, dismiss: @escaping () -> Void) {
    self.word = word
    self.store = store
    self.language = language
    self.dismiss = dismiss
    _wordText = State(initialValue: word.word)
    _ipa = State(initialValue: word.ipa)
    _meaning = State(initialValue: word.meaning)
    _exampleEn = State(initialValue: word.exampleEn)
    _exampleTranslation = State(initialValue: word.exampleTranslation)
    _partsOfSpeech = State(initialValue: Set(word.partsOfSpeech))
  }

  /// 例文の訳の欄を出すか。英語の語義では出さないが、切り替える前に
  /// 登録した例文の訳がある単語では、消さずに直せるよう出す。
  private var showsExampleTranslation: Bool {
    language.translatesExamples || !word.exampleTranslation.isEmpty
  }

  var body: some View {
    AppDialogSurface(cornerRadius: 13) {
      VStack(spacing: 0) {
        ViewThatFits(in: .vertical) {
          fields
          ScrollView { fields }
        }
        HStack(spacing: px(10)) {
          AppFilledButton(label: String(localized: .save)) { Task { await save() } }
          AppOutlinedButton(label: String(localized: .cancel), action: dismiss)
          Spacer(minLength: 0)
          AppOutlinedButton(
            label: String(localized: .deleteEllipsis), textColor: colors.danger,
            hoverBackground: colors.dangerHoverBackground
          ) {
            DeleteConfirmDialog.present(word, store: store, overlay: overlay, onDeleted: dismiss)
          }
        }
        .padding(EdgeInsets(top: px(16), leading: px(Self.horizontalPadding), bottom: px(22), trailing: px(Self.horizontalPadding)))
      }
      .frame(width: px(AppDimensions.formWidth + Self.horizontalPadding * 2))
    }
    // 編集は主画面の切り替えではないが、Flutter 版と同じく画面として数える。
    .onAppear { analytics.logScreenView("word_edit") }
  }

  private var fields: some View {
    VStack(alignment: .leading, spacing: 0) {
      AppText(.editWordTitle, style: AppTextStyle(size: 16, weight: .w700))
        .foregroundStyle(colors.textPrimary)
      Spacer().frame(height: px(16))
      HStack(alignment: .top, spacing: px(14)) {
        LabeledTextField(label: String(localized: .fieldWord), text: $wordText)
        LabeledTextField(label: String(localized: .fieldIpa), text: $ipa)
      }
      Spacer().frame(height: px(16))
      LabeledTextField(label: String(localized: language.meaningFieldLabel), text: $meaning, lineLimit: 1...Int.max)
      Spacer().frame(height: px(16))
      AppText(.fieldPartsOfSpeech, style: AppTextStyle(size: 12, weight: .w600))
        .foregroundStyle(colors.textSecondary)
      Spacer().frame(height: px(5))
      PosChipSelector(selected: partsOfSpeech) { pos in
        if partsOfSpeech.contains(pos) { partsOfSpeech.remove(pos) } else { partsOfSpeech.insert(pos) }
      }
      Spacer().frame(height: px(16))
      LabeledTextField(label: String(localized: .fieldExampleEn), text: $exampleEn, lineLimit: 2...Int.max)
      if showsExampleTranslation {
        Spacer().frame(height: px(16))
        LabeledTextField(
          label: String(localized: .fieldExampleTranslation(String(localized: language.shortLabel))),
          text: $exampleTranslation, lineLimit: 2...Int.max)
      }
      if let errorMessage {
        Spacer().frame(height: px(16))
        AppText(errorMessage, style: AppTextStyle(size: 12))
          .foregroundStyle(colors.danger)
      }
    }
    .padding(EdgeInsets(top: px(22), leading: px(Self.horizontalPadding), bottom: 0, trailing: px(Self.horizontalPadding)))
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func save() async {
    let headword = normalizeHeadword(wordText)
    let trimmedMeaning = meaning.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !headword.isEmpty, !trimmedMeaning.isEmpty else {
      errorMessage = String(localized: .errorRequiredFields(String(localized: language.shortLabel)))
      return
    }
    // 単語名を既存の単語に書き換えられると重複ができるため、登録時と同じく止める(自分自身は除く)。
    if let duplicate = await store.duplicate(of: headword, excluding: word.id) {
      errorMessage = String(localized: .errorDuplicate(duplicate.word))
      return
    }
    await store.update(
      word,
      WordEdit(
        word: headword,
        meaning: trimmedMeaning,
        ipa: ipa.trimmingCharacters(in: .whitespacesAndNewlines),
        // 編集前の並びを保ち、足した品詞だけ規定の順で後ろに置く
        // (押した順で保存すると、付け外しだけでバッジの色が変わる)。
        partsOfSpeech: partsOfSpeech.ordered(basedOn: word.partsOfSpeech),
        exampleEn: exampleEn.trimmingCharacters(in: .whitespacesAndNewlines),
        exampleTranslation: exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
      ))
    dismiss()
  }

  @MainActor
  static func present(_ word: Word, store: WordStore, language: TranslationLanguage, overlay: AppOverlay?) {
    overlay?.present { dismiss in
      EditWordDialog(word: word, store: store, language: language, dismiss: dismiss)
    }
  }
}
