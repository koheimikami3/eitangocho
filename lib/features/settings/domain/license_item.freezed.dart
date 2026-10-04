// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'license_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LicenseItem {

 String get name;/// 一覧に出す種別(`MIT License` など)。判別できなければ null で、
/// 表示側が件数表記(licenseCount)に置き換える。
 String? get summary;/// 詳細画面に出す全文。1 要素 = 1 ライセンス。
 List<String> get texts;
/// Create a copy of LicenseItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LicenseItemCopyWith<LicenseItem> get copyWith => _$LicenseItemCopyWithImpl<LicenseItem>(this as LicenseItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LicenseItem&&(identical(other.name, name) || other.name == name)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.texts, texts));
}


@override
int get hashCode => Object.hash(runtimeType,name,summary,const DeepCollectionEquality().hash(texts));

@override
String toString() {
  return 'LicenseItem(name: $name, summary: $summary, texts: $texts)';
}


}

/// @nodoc
abstract mixin class $LicenseItemCopyWith<$Res>  {
  factory $LicenseItemCopyWith(LicenseItem value, $Res Function(LicenseItem) _then) = _$LicenseItemCopyWithImpl;
@useResult
$Res call({
 String name, String? summary, List<String> texts
});




}
/// @nodoc
class _$LicenseItemCopyWithImpl<$Res>
    implements $LicenseItemCopyWith<$Res> {
  _$LicenseItemCopyWithImpl(this._self, this._then);

  final LicenseItem _self;
  final $Res Function(LicenseItem) _then;

/// Create a copy of LicenseItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? summary = freezed,Object? texts = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,texts: null == texts ? _self.texts : texts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [LicenseItem].
extension LicenseItemPatterns on LicenseItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LicenseItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LicenseItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LicenseItem value)  $default,){
final _that = this;
switch (_that) {
case _LicenseItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LicenseItem value)?  $default,){
final _that = this;
switch (_that) {
case _LicenseItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? summary,  List<String> texts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LicenseItem() when $default != null:
return $default(_that.name,_that.summary,_that.texts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? summary,  List<String> texts)  $default,) {final _that = this;
switch (_that) {
case _LicenseItem():
return $default(_that.name,_that.summary,_that.texts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? summary,  List<String> texts)?  $default,) {final _that = this;
switch (_that) {
case _LicenseItem() when $default != null:
return $default(_that.name,_that.summary,_that.texts);case _:
  return null;

}
}

}

/// @nodoc


class _LicenseItem implements LicenseItem {
  const _LicenseItem({required this.name, required this.summary, required final  List<String> texts}): _texts = texts;
  

@override final  String name;
/// 一覧に出す種別(`MIT License` など)。判別できなければ null で、
/// 表示側が件数表記(licenseCount)に置き換える。
@override final  String? summary;
/// 詳細画面に出す全文。1 要素 = 1 ライセンス。
 final  List<String> _texts;
/// 詳細画面に出す全文。1 要素 = 1 ライセンス。
@override List<String> get texts {
  if (_texts is EqualUnmodifiableListView) return _texts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_texts);
}


/// Create a copy of LicenseItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LicenseItemCopyWith<_LicenseItem> get copyWith => __$LicenseItemCopyWithImpl<_LicenseItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LicenseItem&&(identical(other.name, name) || other.name == name)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._texts, _texts));
}


@override
int get hashCode => Object.hash(runtimeType,name,summary,const DeepCollectionEquality().hash(_texts));

@override
String toString() {
  return 'LicenseItem(name: $name, summary: $summary, texts: $texts)';
}


}

/// @nodoc
abstract mixin class _$LicenseItemCopyWith<$Res> implements $LicenseItemCopyWith<$Res> {
  factory _$LicenseItemCopyWith(_LicenseItem value, $Res Function(_LicenseItem) _then) = __$LicenseItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String? summary, List<String> texts
});




}
/// @nodoc
class __$LicenseItemCopyWithImpl<$Res>
    implements _$LicenseItemCopyWith<$Res> {
  __$LicenseItemCopyWithImpl(this._self, this._then);

  final _LicenseItem _self;
  final $Res Function(_LicenseItem) _then;

/// Create a copy of LicenseItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? summary = freezed,Object? texts = null,}) {
  return _then(_LicenseItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,texts: null == texts ? _self._texts : texts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
