import 'dart:async';

import 'package:eitangocho/app/eitangocho_app.dart';
import 'package:eitangocho/features/analytics/data/analytics_initializer.dart';
import 'package:eitangocho/features/settings/data/data_source_licenses.dart';
import 'package:eitangocho/features/sync/data/icloud_file_store.dart';
import 'package:eitangocho/features/sync/data/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // Firebase のネイティブ呼び出しは runApp より前に binding を要する。
  WidgetsFlutterBinding.ensureInitialized();
  // 計測は起動を待たせない(初期化の完了を待つ画面は無い)。
  unawaited(initializeAnalytics());

  // 辞書・例文データの出典をライセンス一覧に載せる(pub パッケージの分は
  // Flutter が自動収集するが、同梱データと外部 API 由来の分は自分で足す)。
  registerDataSourceLicenses();

  runApp(
    ProviderScope(
      overrides: [
        // クラウド保管先の実装はここでだけ決める。テストやウィジェット
        // テストではインメモリ実装に差し替えられるよう、Provider 自体は
        // 実装を持たない(sync_service.dart 参照)。
        cloudFileStoreProvider.overrideWithValue(const IcloudFileStore()),
      ],
      child: const EitangochoApp(),
    ),
  );
}
