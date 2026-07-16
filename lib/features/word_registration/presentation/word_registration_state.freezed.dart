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

 Set<PartOfSpeech> get selectedPartsOfSpeech; String? get errorMessage;
/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordRegistrationStateCopyWith<WordRegistrationState> get copyWith => _$WordRegistrationStateCopyWithImpl<WordRegistrationState>(this as WordRegistrationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordRegistrationState&&const DeepCollectionEquality().equals(other.selectedPartsOfSpeech, selectedPartsOfSpeech)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedPartsOfSpeech),errorMessage);

@override
String toString() {
  return 'WordRegistrationState(selectedPartsOfSpeech: $selectedPartsOfSpeech, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $WordRegistrationStateCopyWith<$Res>  {
  factory $WordRegistrationStateCopyWith(WordRegistrationState value, $Res Function(WordRegistrationState) _then) = _$WordRegistrationStateCopyWithImpl;
@useResult
$Res call({
 Set<PartOfSpeech> selectedPartsOfSpeech, String? errorMessage
});




}
/// @nodoc
class _$WordRegistrationStateCopyWithImpl<$Res>
    implements $WordRegistrationStateCopyWith<$Res> {
  _$WordRegistrationStateCopyWithImpl(this._self, this._then);

  final WordRegistrationState _self;
  final $Res Function(WordRegistrationState) _then;

/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedPartsOfSpeech = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
selectedPartsOfSpeech: null == selectedPartsOfSpeech ? _self.selectedPartsOfSpeech : selectedPartsOfSpeech // ignore: cast_nullable_to_non_nullable
as Set<PartOfSpeech>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<PartOfSpeech> selectedPartsOfSpeech,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordRegistrationState() when $default != null:
return $default(_that.selectedPartsOfSpeech,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<PartOfSpeech> selectedPartsOfSpeech,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _WordRegistrationState():
return $default(_that.selectedPartsOfSpeech,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<PartOfSpeech> selectedPartsOfSpeech,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _WordRegistrationState() when $default != null:
return $default(_that.selectedPartsOfSpeech,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _WordRegistrationState implements WordRegistrationState {
  const _WordRegistrationState({final  Set<PartOfSpeech> selectedPartsOfSpeech = const <PartOfSpeech>{}, this.errorMessage}): _selectedPartsOfSpeech = selectedPartsOfSpeech;
  

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordRegistrationState&&const DeepCollectionEquality().equals(other._selectedPartsOfSpeech, _selectedPartsOfSpeech)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedPartsOfSpeech),errorMessage);

@override
String toString() {
  return 'WordRegistrationState(selectedPartsOfSpeech: $selectedPartsOfSpeech, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$WordRegistrationStateCopyWith<$Res> implements $WordRegistrationStateCopyWith<$Res> {
  factory _$WordRegistrationStateCopyWith(_WordRegistrationState value, $Res Function(_WordRegistrationState) _then) = __$WordRegistrationStateCopyWithImpl;
@override @useResult
$Res call({
 Set<PartOfSpeech> selectedPartsOfSpeech, String? errorMessage
});




}
/// @nodoc
class __$WordRegistrationStateCopyWithImpl<$Res>
    implements _$WordRegistrationStateCopyWith<$Res> {
  __$WordRegistrationStateCopyWithImpl(this._self, this._then);

  final _WordRegistrationState _self;
  final $Res Function(_WordRegistrationState) _then;

/// Create a copy of WordRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedPartsOfSpeech = null,Object? errorMessage = freezed,}) {
  return _then(_WordRegistrationState(
selectedPartsOfSpeech: null == selectedPartsOfSpeech ? _self._selectedPartsOfSpeech : selectedPartsOfSpeech // ignore: cast_nullable_to_non_nullable
as Set<PartOfSpeech>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
