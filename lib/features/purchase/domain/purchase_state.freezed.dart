// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseState {

/// 課金を扱える環境か(iOS かつ SDK キーが設定済み)。
/// false のときは設定画面に Pro セクションごと出さない。
 bool get available;/// Pro が解禁されているか。広告の出し分けはこの 1 点で決まる。
 bool get proUnlocked;/// 買い切り商品の表示価格(`¥600` のようにローカライズ済みの文字列)。
/// 取得前・取得失敗は null。価格が無いときは購入させない。
 String? get priceText;/// 購入処理の実行中か。
 bool get purchasing;/// 復元処理の実行中か。
 bool get restoring;/// 購入に失敗した(購入行に一時表示する)。
 bool get purchaseFailed;/// 復元行の右端に一時表示する状況。文言は表示側が言語に合わせて出す。
 RestoreStatus? get restoreStatus;
/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseStateCopyWith<PurchaseState> get copyWith => _$PurchaseStateCopyWithImpl<PurchaseState>(this as PurchaseState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseState&&(identical(other.available, available) || other.available == available)&&(identical(other.proUnlocked, proUnlocked) || other.proUnlocked == proUnlocked)&&(identical(other.priceText, priceText) || other.priceText == priceText)&&(identical(other.purchasing, purchasing) || other.purchasing == purchasing)&&(identical(other.restoring, restoring) || other.restoring == restoring)&&(identical(other.purchaseFailed, purchaseFailed) || other.purchaseFailed == purchaseFailed)&&(identical(other.restoreStatus, restoreStatus) || other.restoreStatus == restoreStatus));
}


@override
int get hashCode => Object.hash(runtimeType,available,proUnlocked,priceText,purchasing,restoring,purchaseFailed,restoreStatus);

@override
String toString() {
  return 'PurchaseState(available: $available, proUnlocked: $proUnlocked, priceText: $priceText, purchasing: $purchasing, restoring: $restoring, purchaseFailed: $purchaseFailed, restoreStatus: $restoreStatus)';
}


}

/// @nodoc
abstract mixin class $PurchaseStateCopyWith<$Res>  {
  factory $PurchaseStateCopyWith(PurchaseState value, $Res Function(PurchaseState) _then) = _$PurchaseStateCopyWithImpl;
@useResult
$Res call({
 bool available, bool proUnlocked, String? priceText, bool purchasing, bool restoring, bool purchaseFailed, RestoreStatus? restoreStatus
});




}
/// @nodoc
class _$PurchaseStateCopyWithImpl<$Res>
    implements $PurchaseStateCopyWith<$Res> {
  _$PurchaseStateCopyWithImpl(this._self, this._then);

  final PurchaseState _self;
  final $Res Function(PurchaseState) _then;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? proUnlocked = null,Object? priceText = freezed,Object? purchasing = null,Object? restoring = null,Object? purchaseFailed = null,Object? restoreStatus = freezed,}) {
  return _then(_self.copyWith(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,proUnlocked: null == proUnlocked ? _self.proUnlocked : proUnlocked // ignore: cast_nullable_to_non_nullable
as bool,priceText: freezed == priceText ? _self.priceText : priceText // ignore: cast_nullable_to_non_nullable
as String?,purchasing: null == purchasing ? _self.purchasing : purchasing // ignore: cast_nullable_to_non_nullable
as bool,restoring: null == restoring ? _self.restoring : restoring // ignore: cast_nullable_to_non_nullable
as bool,purchaseFailed: null == purchaseFailed ? _self.purchaseFailed : purchaseFailed // ignore: cast_nullable_to_non_nullable
as bool,restoreStatus: freezed == restoreStatus ? _self.restoreStatus : restoreStatus // ignore: cast_nullable_to_non_nullable
as RestoreStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseState].
extension PurchaseStatePatterns on PurchaseState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseState value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseState value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool available,  bool proUnlocked,  String? priceText,  bool purchasing,  bool restoring,  bool purchaseFailed,  RestoreStatus? restoreStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseState() when $default != null:
return $default(_that.available,_that.proUnlocked,_that.priceText,_that.purchasing,_that.restoring,_that.purchaseFailed,_that.restoreStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool available,  bool proUnlocked,  String? priceText,  bool purchasing,  bool restoring,  bool purchaseFailed,  RestoreStatus? restoreStatus)  $default,) {final _that = this;
switch (_that) {
case _PurchaseState():
return $default(_that.available,_that.proUnlocked,_that.priceText,_that.purchasing,_that.restoring,_that.purchaseFailed,_that.restoreStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool available,  bool proUnlocked,  String? priceText,  bool purchasing,  bool restoring,  bool purchaseFailed,  RestoreStatus? restoreStatus)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseState() when $default != null:
return $default(_that.available,_that.proUnlocked,_that.priceText,_that.purchasing,_that.restoring,_that.purchaseFailed,_that.restoreStatus);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseState implements PurchaseState {
  const _PurchaseState({this.available = false, this.proUnlocked = false, this.priceText, this.purchasing = false, this.restoring = false, this.purchaseFailed = false, this.restoreStatus});
  

/// 課金を扱える環境か(iOS かつ SDK キーが設定済み)。
/// false のときは設定画面に Pro セクションごと出さない。
@override@JsonKey() final  bool available;
/// Pro が解禁されているか。広告の出し分けはこの 1 点で決まる。
@override@JsonKey() final  bool proUnlocked;
/// 買い切り商品の表示価格(`¥600` のようにローカライズ済みの文字列)。
/// 取得前・取得失敗は null。価格が無いときは購入させない。
@override final  String? priceText;
/// 購入処理の実行中か。
@override@JsonKey() final  bool purchasing;
/// 復元処理の実行中か。
@override@JsonKey() final  bool restoring;
/// 購入に失敗した(購入行に一時表示する)。
@override@JsonKey() final  bool purchaseFailed;
/// 復元行の右端に一時表示する状況。文言は表示側が言語に合わせて出す。
@override final  RestoreStatus? restoreStatus;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseStateCopyWith<_PurchaseState> get copyWith => __$PurchaseStateCopyWithImpl<_PurchaseState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseState&&(identical(other.available, available) || other.available == available)&&(identical(other.proUnlocked, proUnlocked) || other.proUnlocked == proUnlocked)&&(identical(other.priceText, priceText) || other.priceText == priceText)&&(identical(other.purchasing, purchasing) || other.purchasing == purchasing)&&(identical(other.restoring, restoring) || other.restoring == restoring)&&(identical(other.purchaseFailed, purchaseFailed) || other.purchaseFailed == purchaseFailed)&&(identical(other.restoreStatus, restoreStatus) || other.restoreStatus == restoreStatus));
}


@override
int get hashCode => Object.hash(runtimeType,available,proUnlocked,priceText,purchasing,restoring,purchaseFailed,restoreStatus);

@override
String toString() {
  return 'PurchaseState(available: $available, proUnlocked: $proUnlocked, priceText: $priceText, purchasing: $purchasing, restoring: $restoring, purchaseFailed: $purchaseFailed, restoreStatus: $restoreStatus)';
}


}

/// @nodoc
abstract mixin class _$PurchaseStateCopyWith<$Res> implements $PurchaseStateCopyWith<$Res> {
  factory _$PurchaseStateCopyWith(_PurchaseState value, $Res Function(_PurchaseState) _then) = __$PurchaseStateCopyWithImpl;
@override @useResult
$Res call({
 bool available, bool proUnlocked, String? priceText, bool purchasing, bool restoring, bool purchaseFailed, RestoreStatus? restoreStatus
});




}
/// @nodoc
class __$PurchaseStateCopyWithImpl<$Res>
    implements _$PurchaseStateCopyWith<$Res> {
  __$PurchaseStateCopyWithImpl(this._self, this._then);

  final _PurchaseState _self;
  final $Res Function(_PurchaseState) _then;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? proUnlocked = null,Object? priceText = freezed,Object? purchasing = null,Object? restoring = null,Object? purchaseFailed = null,Object? restoreStatus = freezed,}) {
  return _then(_PurchaseState(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,proUnlocked: null == proUnlocked ? _self.proUnlocked : proUnlocked // ignore: cast_nullable_to_non_nullable
as bool,priceText: freezed == priceText ? _self.priceText : priceText // ignore: cast_nullable_to_non_nullable
as String?,purchasing: null == purchasing ? _self.purchasing : purchasing // ignore: cast_nullable_to_non_nullable
as bool,restoring: null == restoring ? _self.restoring : restoring // ignore: cast_nullable_to_non_nullable
as bool,purchaseFailed: null == purchaseFailed ? _self.purchaseFailed : purchaseFailed // ignore: cast_nullable_to_non_nullable
as bool,restoreStatus: freezed == restoreStatus ? _self.restoreStatus : restoreStatus // ignore: cast_nullable_to_non_nullable
as RestoreStatus?,
  ));
}


}

// dart format on
