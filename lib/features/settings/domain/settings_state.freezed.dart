// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 QuizDirection get quizDirection; bool get showIpa;/// DeepL API Free のキー。未設定(空)なら例文の和訳をスキップする。
/// ローカル個人アプリとして平文保存を許容する(確定済みの設計判断)。
 String get deeplApiKey;/// UI 全体の拡大率(EitangochoApp がブラウザズーム相当で適用する)
 double get uiScale;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.quizDirection, quizDirection) || other.quizDirection == quizDirection)&&(identical(other.showIpa, showIpa) || other.showIpa == showIpa)&&(identical(other.deeplApiKey, deeplApiKey) || other.deeplApiKey == deeplApiKey)&&(identical(other.uiScale, uiScale) || other.uiScale == uiScale));
}


@override
int get hashCode => Object.hash(runtimeType,quizDirection,showIpa,deeplApiKey,uiScale);

@override
String toString() {
  return 'SettingsState(quizDirection: $quizDirection, showIpa: $showIpa, deeplApiKey: $deeplApiKey, uiScale: $uiScale)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 QuizDirection quizDirection, bool showIpa, String deeplApiKey, double uiScale
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quizDirection = null,Object? showIpa = null,Object? deeplApiKey = null,Object? uiScale = null,}) {
  return _then(_self.copyWith(
quizDirection: null == quizDirection ? _self.quizDirection : quizDirection // ignore: cast_nullable_to_non_nullable
as QuizDirection,showIpa: null == showIpa ? _self.showIpa : showIpa // ignore: cast_nullable_to_non_nullable
as bool,deeplApiKey: null == deeplApiKey ? _self.deeplApiKey : deeplApiKey // ignore: cast_nullable_to_non_nullable
as String,uiScale: null == uiScale ? _self.uiScale : uiScale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QuizDirection quizDirection,  bool showIpa,  String deeplApiKey,  double uiScale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.quizDirection,_that.showIpa,_that.deeplApiKey,_that.uiScale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QuizDirection quizDirection,  bool showIpa,  String deeplApiKey,  double uiScale)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.quizDirection,_that.showIpa,_that.deeplApiKey,_that.uiScale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QuizDirection quizDirection,  bool showIpa,  String deeplApiKey,  double uiScale)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.quizDirection,_that.showIpa,_that.deeplApiKey,_that.uiScale);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.quizDirection = QuizDirection.enToJa, this.showIpa = true, this.deeplApiKey = '', this.uiScale = AppDimensions.defaultUiScale});
  

@override@JsonKey() final  QuizDirection quizDirection;
@override@JsonKey() final  bool showIpa;
/// DeepL API Free のキー。未設定(空)なら例文の和訳をスキップする。
/// ローカル個人アプリとして平文保存を許容する(確定済みの設計判断)。
@override@JsonKey() final  String deeplApiKey;
/// UI 全体の拡大率(EitangochoApp がブラウザズーム相当で適用する)
@override@JsonKey() final  double uiScale;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.quizDirection, quizDirection) || other.quizDirection == quizDirection)&&(identical(other.showIpa, showIpa) || other.showIpa == showIpa)&&(identical(other.deeplApiKey, deeplApiKey) || other.deeplApiKey == deeplApiKey)&&(identical(other.uiScale, uiScale) || other.uiScale == uiScale));
}


@override
int get hashCode => Object.hash(runtimeType,quizDirection,showIpa,deeplApiKey,uiScale);

@override
String toString() {
  return 'SettingsState(quizDirection: $quizDirection, showIpa: $showIpa, deeplApiKey: $deeplApiKey, uiScale: $uiScale)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 QuizDirection quizDirection, bool showIpa, String deeplApiKey, double uiScale
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quizDirection = null,Object? showIpa = null,Object? deeplApiKey = null,Object? uiScale = null,}) {
  return _then(_SettingsState(
quizDirection: null == quizDirection ? _self.quizDirection : quizDirection // ignore: cast_nullable_to_non_nullable
as QuizDirection,showIpa: null == showIpa ? _self.showIpa : showIpa // ignore: cast_nullable_to_non_nullable
as bool,deeplApiKey: null == deeplApiKey ? _self.deeplApiKey : deeplApiKey // ignore: cast_nullable_to_non_nullable
as String,uiScale: null == uiScale ? _self.uiScale : uiScale // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
