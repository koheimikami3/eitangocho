import 'package:eitangocho/app/eitangocho_app.dart';
import 'package:eitangocho/features/sync/data/icloud_file_store.dart';
import 'package:eitangocho/features/sync/data/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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
