import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/features/ads/domain/ad_unit_ids.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_bar_banner_visible_provider.g.dart';

/// タブバー上のバナーを出してよい画面か。
///
/// 隠すのはクイズ結果だけ。あそこには 300x250 のレクタングルが出るため、
/// 両方並べると画面の 4 割が広告になり、忘れていた単語の一覧がほとんど
/// 読めなくなる。大きい方(レクタングル)を優先する。
///
/// レクタングルのユニットが未設定なら隠さない。広告がゼロの画面を作っても
/// 意味がないため。
/// 依存する 2 つの State は select せず丸ごと watch する(Provider 同士では
/// select が使えない)。この Provider 自身の値が変わったときだけ購読側は
/// 再構築されるため、実害は無い。
@riverpod
bool tabBarBannerVisible(Ref ref) {
  if (AdUnitIds.quizRectangle.isEmpty) return true;
  if (ref.watch(mainPageProvider).view != MainView.quiz) return true;
  return ref.watch(quizPageProvider).phase != QuizPhase.done;
}
