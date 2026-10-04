import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_state.freezed.dart';

/// 課金(広告非表示の買い切り)の状態。設定画面の Pro セクションにそのまま使う。
@freezed
abstract class PurchaseState with _$PurchaseState {
  const factory PurchaseState({
    /// 課金を扱える環境か(iOS かつ SDK キーが設定済み)。
    /// false のときは設定画面に Pro セクションごと出さない。
    @Default(false) bool available,

    /// Pro が解禁されているか。広告の出し分けはこの 1 点で決まる。
    @Default(false) bool proUnlocked,

    /// 買い切り商品の表示価格(`¥600` のようにローカライズ済みの文字列)。
    /// 取得前・取得失敗は null。価格が無いときは購入させない。
    String? priceText,

    /// 購入処理の実行中か。
    @Default(false) bool purchasing,

    /// 復元処理の実行中か。
    @Default(false) bool restoring,

    /// 購入に失敗した(購入行に一時表示する)。
    @Default(false) bool purchaseFailed,

    /// 復元行の右端に一時表示する状況。文言は表示側が言語に合わせて出す。
    RestoreStatus? restoreStatus,
  }) = _PurchaseState;
}

/// 復元の状況(復元行の右端に一時表示する)。
enum RestoreStatus { checking, restored, notFound, failed }
