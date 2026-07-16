// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_registration_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordRegistrationState {

 RegistrationStep get step;/// 自動入力の取得結果。手動入力(スキップ・未収録)のときは null。
/// audioUrl はフォームに出さず、保存時にここから words へ書き込む。
 WordInfo? get fetched;/// 自動入力したが辞書(FD・EJDict とも)未収録だった
 bool get notFound;/// 例文の DeepL 翻訳に失敗した(exampleJa 空のまま続行し警告を出す)
 bool get translationFailed; Set<PartOfSpeech> get selectedPartsOfSpeech; String? get errorMessage;
/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordRegistrationStateCopyWith<WordRegistrationState> get copyWith => _$WordRegistrationStateCopyWithImpl<WordRegistrationState>(this as WordRegistrationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordRegistrationState&&(identical(other.step, step) || other.step == step)&&(identical(other.fetched, fetched) || other.fetched == fetched)&&(identical(other.notFound, notFound) || other.notFound == notFound)&&(identical(other.translationFailed, translationFailed) || other.translationFailed == translationFailed)&&const DeepCollectionEquality().equals(other.selectedPartsOfSpeech, selectedPartsOfSpeech)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,step,fetched,notFound,translationFailed,const DeepCollectionEquality().hash(selectedPartsOfSpeech),errorMessage);

@override
String toString() {
  return 'WordRegistrationState(step: $step, fetched: $fetched, notFound: $notFound, translationFailed: $translationFailed, selectedPartsOfSpeech: $selectedPartsOfSpeech, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $WordRegistrationStateCopyWith<$Res>  {
  factory $WordRegistrationStateCopyWith(WordRegistrationState value, $Res Function(WordRegistrationState) _then) = _$WordRegistrationStateCopyWithImpl;
@useResult
$Res call({
 RegistrationStep step, WordInfo? fetched, bool notFound, bool translationFailed, Set<PartOfSpeech> selectedPartsOfSpeech, String? errorMessage
});


$WordInfoCopyWith<$Res>? get fetched;

}
/// @nodoc
class _$WordRegistrationStateCopyWithImpl<$Res>
    implements $WordRegistrationStateCopyWith<$Res> {
  _$WordRegistrationStateCopyWithImpl(this._self, this._then);

  final WordRegistrationState _self;
  final $Res Function(WordRegistrationState) _then;

/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? fetched = freezed,Object? notFound = null,Object? translationFailed = null,Object? selectedPartsOfSpeech = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as RegistrationStep,fetched: freezed == fetched ? _self.fetched : fetched // ignore: cast_nullable_to_non_nullable
as WordInfo?,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as bool,translationFailed: null == translationFailed ? _self.translationFailed : translationFailed // ignore: cast_nullable_to_non_nullable
as bool,selectedPartsOfSpeech: null == selectedPartsOfSpeech ? _self.selectedPartsOfSpeech : selectedPartsOfSpeech // ignore: cast_nullable_to_non_nullable
as Set<PartOfSpeech>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordInfoCopyWith<$Res>? get fetched {
    if (_self.fetched == null) {
    return null;
  }

  return $WordInfoCopyWith<$Res>(_self.fetched!, (value) {
    return _then(_self.copyWith(fetched: value));
  });
}
}


/// Adds pattern-matching-related methods to [WordRegistrationState].
extension WordRegistrationStatePatterns on WordRegistrationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordRegistrationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordRegistrationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordRegistrationState value)  $default,){
final _that = this;
switch (_that) {
case _WordRegistrationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordRegistrationState value)?  $default,){
final _that = this;
switch (_that) {
case _WordRegistrationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegistrationStep step,  WordInfo? fetched,  bool notFound,  bool translationFailed,  Set<PartOfSpeech> selectedPartsOfSpeech,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordRegistrationState() when $default != null:
return $default(_that.step,_that.fetched,_that.notFound,_that.translationFailed,_that.selectedPartsOfSpeech,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegistrationStep step,  WordInfo? fetched,  bool notFound,  bool translationFailed,  Set<PartOfSpeech> selectedPartsOfSpeech,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _WordRegistrationState():
return $default(_that.step,_that.fetched,_that.notFound,_that.translationFailed,_that.selectedPartsOfSpeech,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegistrationStep step,  WordInfo? fetched,  bool notFound,  bool translationFailed,  Set<PartOfSpeech> selectedPartsOfSpeech,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _WordRegistrationState() when $default != null:
return $default(_that.step,_that.fetched,_that.notFound,_that.translationFailed,_that.selectedPartsOfSpeech,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _WordRegistrationState implements WordRegistrationState {
  const _WordRegistrationState({this.step = RegistrationStep.input, this.fetched, this.notFound = false, this.translationFailed = false, final  Set<PartOfSpeech> selectedPartsOfSpeech = const <PartOfSpeech>{}, this.errorMessage}): _selectedPartsOfSpeech = selectedPartsOfSpeech;
  

@override@JsonKey() final  RegistrationStep step;
/// 自動入力の取得結果。手動入力(スキップ・未収録)のときは null。
/// audioUrl はフォームに出さず、保存時にここから words へ書き込む。
@override final  WordInfo? fetched;
/// 自動入力したが辞書(FD・EJDict とも)未収録だった
@override@JsonKey() final  bool notFound;
/// 例文の DeepL 翻訳に失敗した(exampleJa 空のまま続行し警告を出す)
@override@JsonKey() final  bool translationFailed;
 final  Set<PartOfSpeech> _selectedPartsOfSpeech;
@override@JsonKey() Set<PartOfSpeech> get selectedPartsOfSpeech {
  if (_selectedPartsOfSpeech is EqualUnmodifiableSetView) return _selectedPartsOfSpeech;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedPartsOfSpeech);
}

@override final  String? errorMessage;

/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordRegistrationStateCopyWith<_WordRegistrationState> get copyWith => __$WordRegistrationStateCopyWithImpl<_WordRegistrationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordRegistrationState&&(identical(other.step, step) || other.step == step)&&(identical(other.fetched, fetched) || other.fetched == fetched)&&(identical(other.notFound, notFound) || other.notFound == notFound)&&(identical(other.translationFailed, translationFailed) || other.translationFailed == translationFailed)&&const DeepCollectionEquality().equals(other._selectedPartsOfSpeech, _selectedPartsOfSpeech)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,step,fetched,notFound,translationFailed,const DeepCollectionEquality().hash(_selectedPartsOfSpeech),errorMessage);

@override
String toString() {
  return 'WordRegistrationState(step: $step, fetched: $fetched, notFound: $notFound, translationFailed: $translationFailed, selectedPartsOfSpeech: $selectedPartsOfSpeech, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$WordRegistrationStateCopyWith<$Res> implements $WordRegistrationStateCopyWith<$Res> {
  factory _$WordRegistrationStateCopyWith(_WordRegistrationState value, $Res Function(_WordRegistrationState) _then) = __$WordRegistrationStateCopyWithImpl;
@override @useResult
$Res call({
 RegistrationStep step, WordInfo? fetched, bool notFound, bool translationFailed, Set<PartOfSpeech> selectedPartsOfSpeech, String? errorMessage
});


@override $WordInfoCopyWith<$Res>? get fetched;

}
/// @nodoc
class __$WordRegistrationStateCopyWithImpl<$Res>
    implements _$WordRegistrationStateCopyWith<$Res> {
  __$WordRegistrationStateCopyWithImpl(this._self, this._then);

  final _WordRegistrationState _self;
  final $Res Function(_WordRegistrationState) _then;

/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? fetched = freezed,Object? notFound = null,Object? translationFailed = null,Object? selectedPartsOfSpeech = null,Object? errorMessage = freezed,}) {
  return _then(_WordRegistrationState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as RegistrationStep,fetched: freezed == fetched ? _self.fetched : fetched // ignore: cast_nullable_to_non_nullable
as WordInfo?,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as bool,translationFailed: null == translationFailed ? _self.translationFailed : translationFailed // ignore: cast_nullable_to_non_nullable
as bool,selectedPartsOfSpeech: null == selectedPartsOfSpeech ? _self._selectedPartsOfSpeech : selectedPartsOfSpeech // ignore: cast_nullable_to_non_nullable
as Set<PartOfSpeech>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordInfoCopyWith<$Res>? get fetched {
    if (_self.fetched == null) {
    return null;
  }

  return $WordInfoCopyWith<$Res>(_self.fetched!, (value) {
    return _then(_self.copyWith(fetched: value));
  });
}
}

// dart format on
