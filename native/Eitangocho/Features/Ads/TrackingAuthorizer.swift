import Foundation

/// ATT(トラッキング許可)を「いつ要求するか」を決める(Flutter 版の TrackingAuthorizer と同じ規則)。
///
/// **アプリがアクティブになるまで要求しない。** iOS 15 以降、非アクティブ中に要求してもダイアログは出ず、
/// 現在の状態がそのまま返るだけで終わる。Flutter 版の 1.5.0 (5) が Guideline 2.1 でリジェクトされたのは
/// これで、当時は広告枠の最初のフレームで要求していた。「最初のフレームを描いた」は「アクティブになった」ではない。
///
/// ダイアログが出せなかったときは、以後アクティブに戻るたびに要求し直す。1 回の起動で 1 回きりにすると、
/// 出せなかった起動では誰も拾わない。
///
/// **ATT の失敗でアプリを止めない**(辞書・広告・レビューと同じ方針)。最悪でも非パーソナライズ広告は出せる。
final class TrackingAuthorizer {
  private let client: any TrackingClient
  /// アプリが今アクティブか(iOS は `UIApplication.applicationState == .active`)。
  private let isActive: () -> Bool

  /// アクティブになってから要求するまでの待ち時間。
  ///
  /// アクティブ化の直後はシステムのオーバーレイ(インストール直後の UI や TestFlight のシート)が
  /// 消え切っていないことがあり、そこに重ねると ATT はやはり黙って出ないまま返る。ひと呼吸置いてから要求する。
  private let activationDelay: Duration

  /// アクティブになるのを待つ上限。アクティブ化の知らせが来ない環境で永久に止まらないための保険。
  /// ここで諦めて要求し、それでも出なければ次にアクティブへ戻ったときに出し直される。
  private let activationTimeout: Duration

  /// 許可の状態が確定したか(= もうダイアログを出す必要がないか)。
  private var settled = false

  /// ダイアログを出せなかったので、次にアクティブへ戻ったら出し直すか。
  private var retryOnActivation = false

  /// 実行中の要求。二重に走らせないために持つ。
  ///
  /// **ATT を重ねて呼ぶと以後ダイアログが出なくなる**(1 回目が非アクティブ中だった場合に顕著)。
  /// 打ち切り(タイムアウト)で先へ進むと OS 側の要求を残したまま再試行と重なるので、打ち切らずに単一化する。
  private var inFlight: Task<Void, Never>?

  /// アクティブ化を待っている間だけ non-nil。
  private var awaitingActivation: OneShotSignal?

  /// アクティブ化を待っているか(テストが待ちに入ったことを確かめるため)。
  var isAwaitingActivation: Bool { awaitingActivation != nil }

  /// `activationDelay` と `activationTimeout` は既定値が本番の値で、テストからだけ縮める
  /// (`ReviewPrompter.promptDelay` と同じ)。
  init(
    client: any TrackingClient, isActive: @escaping () -> Bool, activationDelay: Duration = .milliseconds(500),
    activationTimeout: Duration = .seconds(10)
  ) {
    self.client = client
    self.isActive = isActive
    self.activationDelay = activationDelay
    self.activationTimeout = activationTimeout
  }

  /// 必要なら ATT のダイアログを出す。確定するか、出せないと分かるまで待つ。
  ///
  /// 出せなかった場合も戻る(呼び出し側は広告 SDK の初期化へ進んでよい)。トラッキング未許可として
  /// 非パーソナライズ広告が出るだけで、ダイアログは次にアクティブへ戻ったときに出し直される。
  func ensureRequested() async {
    if settled { return }
    if let inFlight {
      await inFlight.value
      return
    }
    let task = Task {
      await run()
      // 待っていた側の再開を待たずに外す(Flutter 版の whenComplete と同じ)。再開までの間に
      // アクティブへ戻ったとき、実行中とみなして出し直しを見送らないように。
      inFlight = nil
    }
    inFlight = task
    await task.value
  }

  /// アプリがアクティブになったときに呼ぶ(iOS の scenePhase が active になったとき)。
  func appDidBecomeActive() {
    // アクティブ化待ちの最中ならそれを解く。
    if let awaitingActivation {
      awaitingActivation.fire()
      return
    }
    guard !settled, retryOnActivation, inFlight == nil else { return }
    adLogger.info("アクティブに戻ったので ATT を要求し直します")
    Task { await ensureRequested() }
  }

  private func run() async {
    if await client.isSettled() {
      settled = true
      retryOnActivation = false
      adLogger.info("ATT は回答済みのため要求しません")
      return
    }

    await waitUntilActive()

    settled = await client.request()
    retryOnActivation = !settled
    adLogger.info(
      "\(self.settled ? "ATT のダイアログに回答がありました" : "ATT のダイアログが出ませんでした。次にアクティブへ戻ったら出し直します", privacy: .public)"
    )
  }

  private func waitUntilActive() async {
    if !isActive() {
      adLogger.info("アプリがアクティブになるのを待ちます")
      let signal = OneShotSignal()
      awaitingActivation = signal
      if !(await signal.wait(timeout: activationTimeout)) {
        adLogger.info("アクティブ化を待ちきれませんでした。そのまま要求します")
      }
      awaitingActivation = nil
    }
    if activationDelay > .zero {
      try? await Task.sleep(for: activationDelay)
    }
  }
}
