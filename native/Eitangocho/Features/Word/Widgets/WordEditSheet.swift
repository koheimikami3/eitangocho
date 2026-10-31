#if os(iOS)
  import EitangochoData
  import EitangochoWordInfo
  import SwiftUI

  /// iOS 版の単語編集シート(Flutter 版の WordEditSheet。macOS 版の EditWordDialog に当たる)。
  ///
  /// 削除はこのシートの最下部の「この単語を削除...」からだけ行う(iOS には右クリックが無く、
  /// デザイン上も長押しメニューを持たないため、ここが唯一の削除の導線)。
  struct WordEditSheet: View {
    let word: Word
    let store: WordStore
    let language: TranslationLanguage
    let dismiss: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.appOverlay) private var overlay
    @State private var wordText: String
    @State private var ipa: String
    @State private var meaning: String
    @State private var exampleEn: String
    @State private var exampleTranslation: String
    @State private var partsOfSpeech: Set<PartOfSpeech>
    @State private var errorMessage: String?

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

    /// 例文の訳の欄を出すか。英語の語義では出さないが、切り替える前に登録した例文の訳がある単語では、消さずに直せるよう出す。
    private var showsExampleTranslation: Bool {
      language.translatesExamples || !word.exampleTranslation.isEmpty
    }

    var body: some View {
      let languageLabel = String(localized: language.shortLabel)
      MobileSheet(
        title: String(localized: .editWordTitle), leftLabel: String(localized: .cancel), onLeft: dismiss,
        rightLabel: String(localized: .save), onRight: { Task { await save() } }
      ) {
        VStack(alignment: .leading, spacing: 0) {
          MobileFormRows {
            MobileLabeledField(label: String(localized: .fieldWord), text: $wordText, asciiKeyboard: true, correction: false)
            // IPA は ASCII ではないので英字キーボードにしない。
            MobileLabeledField(label: String(localized: .fieldIpa), text: $ipa)
            MobileLabeledField(label: String(localized: language.meaningFieldLabel), text: $meaning, lineLimit: 1...Int.max)
            VStack(alignment: .leading, spacing: 7) {
              MobileFieldLabel(label: String(localized: .fieldPartsOfSpeech))
              MobilePosChipSelector(selected: partsOfSpeech) { pos in
                if partsOfSpeech.contains(pos) { partsOfSpeech.remove(pos) } else { partsOfSpeech.insert(pos) }
              }
            }
            MobileLabeledField(
              label: String(localized: .fieldExampleEn), text: $exampleEn, lineLimit: 2...Int.max, asciiKeyboard: true)
            if showsExampleTranslation {
              MobileLabeledField(
                label: String(localized: .fieldExampleTranslation(languageLabel)), text: $exampleTranslation,
                lineLimit: 2...Int.max)
            }
          }
          if let errorMessage {
            AppText(errorMessage, style: AppTextStyle(size: 12))
              .foregroundStyle(palette.danger)
              .padding(.top, 14)
          }
          deleteButton
            .padding(.top, 24)
        }
      }
    }

    private var deleteButton: some View {
      MobilePressable(action: confirmDelete) { pressed in
        let shape = RoundedRectangle(cornerRadius: 11)
        AppText(.deleteThisWord, style: AppTextStyle(size: 15, weight: .w600))
          .foregroundStyle(palette.danger)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 13)
          .background(shape.fill(pressed ? palette.dangerSoft : palette.surface))
          .overlay(shape.strokeBorder(palette.dangerLine, lineWidth: 1))
      }
    }

    private func confirmDelete() {
      MobileDeleteConfirmDialog.present(word, store: store, overlay: overlay, onDeleted: dismiss)
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
      // 書けなかったら閉じない(閉じると入力が失われる)。
      let saved = await store.update(
        word,
        WordEdit(
          word: headword,
          meaning: trimmedMeaning,
          ipa: ipa.trimmingCharacters(in: .whitespacesAndNewlines),
          // 編集前の並びを保ち、足した品詞だけ規定の順で後ろに置く(押した順で保存すると、付け外しだけでバッジの色が変わる)。
          partsOfSpeech: partsOfSpeech.ordered(basedOn: word.partsOfSpeech),
          exampleEn: exampleEn.trimmingCharacters(in: .whitespacesAndNewlines),
          exampleTranslation: exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
        ))
      if saved { dismiss() }
    }
  }
#endif
