import 'package:flutter/material.dart';

/// アプリ全体の [RouteObserver]。[MaterialApp] の navigatorObservers に渡す。
///
/// 「自分の上に別の画面が積まれた / 戻ってきた」を知るための Flutter 標準の
/// 仕組み。今のところ用途はバナー広告 1 つで、シートや全画面遷移に覆われて
/// いる間だけ自分をツリーから外すために使う。
///
/// Provider ではなく素のグローバルにしているのは、[MaterialApp] を組み立てる
/// 時点で必要な値であり、購読側(RouteAware)と同じ 1 個であることが
/// 保証されないと機能しないため。差し替える理由も無い。
final appRouteObserver = RouteObserver<ModalRoute<void>>();
