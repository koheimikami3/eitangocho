// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegistrationError {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationError()';
}


}

/// @nodoc
class $RegistrationErrorCopyWith<$Res>  {
$RegistrationErrorCopyWith(RegistrationError _, $Res Function(RegistrationError) __);
}


/// Adds pattern-matching-related methods to [RegistrationError].
extension RegistrationErrorPatterns on RegistrationError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DuplicateWordError value)?  duplicate,TResult Function( EmptyWordError value)?  emptyWord,TResult Function( FetchFailedError value)?  fetchFailed,TResult Function( RequiredFieldsError value)?  requiredFields,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DuplicateWordError() when duplicate != null:
return duplicate(_that);case EmptyWordError() when emptyWord != null:
return emptyWord(_that);case FetchFailedError() when fetchFailed != null:
return fetchFailed(_that);case RequiredFieldsError() when requiredFields != null:
return requiredFields(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DuplicateWordError value)  duplicate,required TResult Function( EmptyWordError value)  emptyWord,required TResult Function( FetchFailedError value)  fetchFailed,required TResult Function( RequiredFieldsError value)  requiredFields,}){
final _that = this;
switch (_that) {
case DuplicateWordError():
return duplicate(_that);case EmptyWordError():
return emptyWord(_that);case FetchFailedError():
return fetchFailed(_that);case RequiredFieldsError():
return requiredFields(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DuplicateWordError value)?  duplicate,TResult? Function( EmptyWordError value)?  emptyWord,TResult? Function( FetchFailedError value)?  fetchFailed,TResult? Function( RequiredFieldsError value)?  requiredFields,}){
final _that = this;
switch (_that) {
case DuplicateWordError() when duplicate != null:
return duplicate(_that);case EmptyWordError() when emptyWord != null:
return emptyWord(_that);case FetchFailedError() when fetchFailed != null:
return fetchFailed(_that);case RequiredFieldsError() when requiredFields != null:
return requiredFields(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String word)?  duplicate,TResult Function()?  emptyWord,TResult Function()?  fetchFailed,TResult Function()?  requiredFields,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DuplicateWordError() when duplicate != null:
return duplicate(_that.word);case EmptyWordError() when emptyWord != null:
return emptyWord();case FetchFailedError() when fetchFailed != null:
return fetchFailed();case RequiredFieldsError() when requiredFields != null:
return requiredFields();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String word)  duplicate,required TResult Function()  emptyWord,required TResult Function()  fetchFailed,required TResult Function()  requiredFields,}) {final _that = this;
switch (_that) {
case DuplicateWordError():
return duplicate(_that.word);case EmptyWordError():
return emptyWord();case FetchFailedError():
return fetchFailed();case RequiredFieldsError():
return requiredFields();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String word)?  duplicate,TResult? Function()?  emptyWord,TResult? Function()?  fetchFailed,TResult? Function()?  requiredFields,}) {final _that = this;
switch (_that) {
case DuplicateWordError() when duplicate != null:
return duplicate(_that.word);case EmptyWordError() when emptyWord != null:
return emptyWord();case FetchFailedError() when fetchFailed != null:
return fetchFailed();case RequiredFieldsError() when requiredFields != null:
return requiredFields();case _:
  return null;

}
}

}

/// @nodoc


class DuplicateWordError implements RegistrationError {
  const DuplicateWordError(this.word);
  

 final  String word;

/// Create a copy of RegistrationError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuplicateWordErrorCopyWith<DuplicateWordError> get copyWith => _$DuplicateWordErrorCopyWithImpl<DuplicateWordError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateWordError&&(identical(other.word, word) || other.word == word));
}


@override
int get hashCode => Object.hash(runtimeType,word);

@override
String toString() {
  return 'RegistrationError.duplicate(word: $word)';
}


}

/// @nodoc
abstract mixin class $DuplicateWordErrorCopyWith<$Res> implements $RegistrationErrorCopyWith<$Res> {
  factory $DuplicateWordErrorCopyWith(DuplicateWordError value, $Res Function(DuplicateWordError) _then) = _$DuplicateWordErrorCopyWithImpl;
@useResult
$Res call({
 String word
});




}
/// @nodoc
class _$DuplicateWordErrorCopyWithImpl<$Res>
    implements $DuplicateWordErrorCopyWith<$Res> {
  _$DuplicateWordErrorCopyWithImpl(this._self, this._then);

  final DuplicateWordError _self;
  final $Res Function(DuplicateWordError) _then;

/// Create a copy of RegistrationError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? word = null,}) {
  return _then(DuplicateWordError(
null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class EmptyWordError implements RegistrationError {
  const EmptyWordError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmptyWordError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationError.emptyWord()';
}


}




/// @nodoc


class FetchFailedError implements RegistrationError {
  const FetchFailedError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FetchFailedError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationError.fetchFailed()';
}


}




/// @nodoc


class RequiredFieldsError implements RegistrationError {
  const RequiredFieldsError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequiredFieldsError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationError.requiredFields()';
}


}




// dart format on
