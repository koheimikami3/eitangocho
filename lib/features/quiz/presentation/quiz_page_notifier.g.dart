// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_page_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// フラッシュクイズの進行を管理する。プロトタイプの startQuiz / quizAnswer /
/// quizForgot のロジックに準拠する。
///
/// keepAlive にしているのは、サイドバーの onTap が `read().startQuiz()` で状態を
/// セットしてから selectView するため。自動破棄だと QuizView がマウントされる前に
/// (リスナー不在で)破棄され、startQuiz の結果が初期状態に戻ってしまう。
/// クイズビューへの入口は必ず startQuiz を呼ぶので「入場ごとに新セッション」は保たれる。

@ProviderFor(QuizPageNotifier)
final quizPageProvider = QuizPageNotifierProvider._();

/// フラッシュクイズの進行を管理する。プロトタイプの startQuiz / quizAnswer /
/// quizForgot のロジックに準拠する。
///
/// keepAlive にしているのは、サイドバーの onTap が `read().startQuiz()` で状態を
/// セットしてから selectView するため。自動破棄だと QuizView がマウントされる前に
/// (リスナー不在で)破棄され、startQuiz の結果が初期状態に戻ってしまう。
/// クイズビューへの入口は必ず startQuiz を呼ぶので「入場ごとに新セッション」は保たれる。
final class QuizPageNotifierProvider
    extends $NotifierProvider<QuizPageNotifier, QuizPageState> {
  /// フラッシュクイズの進行を管理する。プロトタイプの startQuiz / quizAnswer /
  /// quizForgot のロジックに準拠する。
  ///
  /// keepAlive にしているのは、サイドバーの onTap が `read().startQuiz()` で状態を
  /// セットしてから selectView するため。自動破棄だと QuizView がマウントされる前に
  /// (リスナー不在で)破棄され、startQuiz の結果が初期状態に戻ってしまう。
  /// クイズビューへの入口は必ず startQuiz を呼ぶので「入場ごとに新セッション」は保たれる。
  QuizPageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quizPageNotifierHash();

  @$internal
  @override
  QuizPageNotifier create() => QuizPageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuizPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuizPageState>(value),
    );
  }
}

String _$quizPageNotifierHash() => r'32450af6f6f1d51f4b973f8831fbc40db1a8cf63';

/// フラッシュクイズの進行を管理する。プロトタイプの startQuiz / quizAnswer /
/// quizForgot のロジックに準拠する。
///
/// keepAlive にしているのは、サイドバーの onTap が `read().startQuiz()` で状態を
/// セットしてから selectView するため。自動破棄だと QuizView がマウントされる前に
/// (リスナー不在で)破棄され、startQuiz の結果が初期状態に戻ってしまう。
/// クイズビューへの入口は必ず startQuiz を呼ぶので「入場ごとに新セッション」は保たれる。

abstract class _$QuizPageNotifier extends $Notifier<QuizPageState> {
  QuizPageState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<QuizPageState, QuizPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<QuizPageState, QuizPageState>,
              QuizPageState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
