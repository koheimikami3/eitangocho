import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'banner_ad_height_notifier.g.dart';

/// バナー広告が実際に占めている高さ。コンテンツの下余白に足すために公開する。
///
/// アンカー型アダプティブバナーの高さは端末ごとに Google が返す値で決まり、
/// 読み込みが終わるまで分からない。読み込み前・失敗時・シートに覆われて
/// いる間は 0 で、そのときはタブバーの高さだけを空ければよい。
///
/// keepAlive にするのは、書き手(バナー)と読み手(シェル)が別ウィジェット
/// のため。購読者が一瞬でも居ない状態で書くと autoDispose が値ごと捨て、
/// 次に読んだときは初期値に戻ってしまう。
@Riverpod(keepAlive: true)
class BannerAdHeight extends _$BannerAdHeight {
  @override
  double build() => 0;

  void update(double height) => state = height;
}
