import AVFoundation
import os

/// 端末の読み上げ(AVSpeechSynthesizer)で英単語の発音を流す。発音の確かめ方が「端末の読み上げ」のときに使う。
///
/// 読み上げ器は 1 つを持ち続ける(読み上げ中に解放されると途中で止まるため)。
final class PronunciationSpeaker: NSObject {
  private let synthesizer = AVSpeechSynthesizer()

  #if os(iOS)
    private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "pronunciation")
    /// 読み上げの前の音声セッションの種類。読み終えたら戻す(広告の動画などの鳴り方を変えないため)。
    private var previousCategory: AVAudioSession.Category?

    override init() {
      super.init()
      synthesizer.delegate = self
    }
  #endif

  func speak(_ word: String) {
    // 連打されたら前の読み上げを止めて読み直す。
    if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
    #if os(iOS)
      activateAudioSession()
    #endif
    let utterance = AVSpeechUtterance(string: word)
    utterance.voice = Self.voice()
    synthesizer.speak(utterance)
  }

  /// 使う声。en-US の声のうち品質の最も高いもの(高品質の声は利用者が OS の設定で入れたときだけある)。
  ///
  /// 同じ品質なら OS が en-US の既定にしている声を使う。ノベルティ音声(Bad News など)と
  /// パーソナルボイスは発音の確認に向かないので除く。OS の設定で声を足したときに追従するよう、毎回選び直す。
  private static func voice() -> AVSpeechSynthesisVoice? {
    let language = "en-US"
    let systemDefault = AVSpeechSynthesisVoice(language: language)
    let best = AVSpeechSynthesisVoice.speechVoices()
      .filter {
        $0.language == language && !$0.voiceTraits.contains(.isNoveltyVoice)
          && !$0.voiceTraits.contains(.isPersonalVoice)
      }
      .max { $0.quality.rawValue < $1.quality.rawValue }
    guard let best else { return systemDefault }
    if let systemDefault, systemDefault.quality == best.quality { return systemDefault }
    return best
  }

  #if os(iOS)
    /// 消音スイッチが入っていても鳴らし、他のアプリの音は読み上げの間だけ下げる
    /// (ボタンを押す = 音を聞くつもりなので、消音中に黙ると壊れているように見える)。
    private func activateAudioSession() {
      let session = AVAudioSession.sharedInstance()
      if previousCategory == nil { previousCategory = session.category }
      do {
        try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try session.setActive(true)
      } catch {
        Self.logger.error("音声セッションを切り替えられませんでした: \(String(describing: error), privacy: .public)")
      }
    }

    /// 読み終えたら音声セッションを元に戻し、下げていた他のアプリの音を戻す。
    /// 連打で前の読み上げを止めたとき(次の読み上げが控えている)は戻さない。
    fileprivate func restoreAudioSessionIfIdle() {
      guard !synthesizer.isSpeaking, let category = previousCategory else { return }
      previousCategory = nil
      let session = AVAudioSession.sharedInstance()
      do {
        try session.setActive(false, options: .notifyOthersOnDeactivation)
        try session.setCategory(category)
      } catch {
        Self.logger.error("音声セッションを戻せませんでした: \(String(describing: error), privacy: .public)")
      }
    }
  #endif
}

#if os(iOS)
  extension PronunciationSpeaker: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
      Task { @MainActor in self.restoreAudioSessionIfIdle() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
      Task { @MainActor in self.restoreAudioSessionIfIdle() }
    }
  }
#endif
