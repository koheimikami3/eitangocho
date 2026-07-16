// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ejdict_importer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EJDict の初回取込。アプリ起動時に watch でキックし、バックグラウンドで実行する
/// (UI はブロックしない。自動入力側は本 Provider の完了を await する)。
/// 取込済みかは shared_preferences のフラグでなく DB の件数で判定する
/// (DB ファイル削除時に自動復旧できるようにするため)。戻り値は取り込んだ件数。

@ProviderFor(ejdictImport)
final ejdictImportProvider = EjdictImportProvider._();

/// EJDict の初回取込。アプリ起動時に watch でキックし、バックグラウンドで実行する
/// (UI はブロックしない。自動入力側は本 Provider の完了を await する)。
/// 取込済みかは shared_preferences のフラグでなく DB の件数で判定する
/// (DB ファイル削除時に自動復旧できるようにするため)。戻り値は取り込んだ件数。

final class EjdictImportProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// EJDict の初回取込。アプリ起動時に watch でキックし、バックグラウンドで実行する
  /// (UI はブロックしない。自動入力側は本 Provider の完了を await する)。
  /// 取込済みかは shared_preferences のフラグでなく DB の件数で判定する
  /// (DB ファイル削除時に自動復旧できるようにするため)。戻り値は取り込んだ件数。
  EjdictImportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ejdictImportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ejdictImportHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return ejdictImport(ref);
  }
}

String _$ejdictImportHash() => r'f879ccbd2fe5a587f6185e039bd737908eb745a5';
