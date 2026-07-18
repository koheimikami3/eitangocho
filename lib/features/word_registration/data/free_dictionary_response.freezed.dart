// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'free_dictionary_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FreeDictionaryEntry {

 String? get word; String? get phonetic; List<FdPhonetic> get phonetics; List<FdMeaning> get meanings;
/// Create a copy of FreeDictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreeDictionaryEntryCopyWith<FreeDictionaryEntry> get copyWith => _$FreeDictionaryEntryCopyWithImpl<FreeDictionaryEntry>(this as FreeDictionaryEntry, _$identity);

  /// Serializes this FreeDictionaryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreeDictionaryEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.phonetic, phonetic) || other.phonetic == phonetic)&&const DeepCollectionEquality().equals(other.phonetics, phonetics)&&const DeepCollectionEquality().equals(other.meanings, meanings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,phonetic,const DeepCollectionEquality().hash(phonetics),const DeepCollectionEquality().hash(meanings));

@override
String toString() {
  return 'FreeDictionaryEntry(word: $word, phonetic: $phonetic, phonetics: $phonetics, meanings: $meanings)';
}


}

/// @nodoc
abstract mixin class $FreeDictionaryEntryCopyWith<$Res>  {
  factory $FreeDictionaryEntryCopyWith(FreeDictionaryEntry value, $Res Function(FreeDictionaryEntry) _then) = _$FreeDictionaryEntryCopyWithImpl;
@useResult
$Res call({
 String? word, String? phonetic, List<FdPhonetic> phonetics, List<FdMeaning> meanings
});




}
/// @nodoc
class _$FreeDictionaryEntryCopyWithImpl<$Res>
    implements $FreeDictionaryEntryCopyWith<$Res> {
  _$FreeDictionaryEntryCopyWithImpl(this._self, this._then);

  final FreeDictionaryEntry _self;
  final $Res Function(FreeDictionaryEntry) _then;

/// Create a copy of FreeDictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = freezed,Object? phonetic = freezed,Object? phonetics = null,Object? meanings = null,}) {
  return _then(_self.copyWith(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,phonetic: freezed == phonetic ? _self.phonetic : phonetic // ignore: cast_nullable_to_non_nullable
as String?,phonetics: null == phonetics ? _self.phonetics : phonetics // ignore: cast_nullable_to_non_nullable
as List<FdPhonetic>,meanings: null == meanings ? _self.meanings : meanings // ignore: cast_nullable_to_non_nullable
as List<FdMeaning>,
  ));
}

}


/// Adds pattern-matching-related methods to [FreeDictionaryEntry].
extension FreeDictionaryEntryPatterns on FreeDictionaryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FreeDictionaryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FreeDictionaryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FreeDictionaryEntry value)  $default,){
final _that = this;
switch (_that) {
case _FreeDictionaryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FreeDictionaryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FreeDictionaryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? word,  String? phonetic,  List<FdPhonetic> phonetics,  List<FdMeaning> meanings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FreeDictionaryEntry() when $default != null:
return $default(_that.word,_that.phonetic,_that.phonetics,_that.meanings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? word,  String? phonetic,  List<FdPhonetic> phonetics,  List<FdMeaning> meanings)  $default,) {final _that = this;
switch (_that) {
case _FreeDictionaryEntry():
return $default(_that.word,_that.phonetic,_that.phonetics,_that.meanings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? word,  String? phonetic,  List<FdPhonetic> phonetics,  List<FdMeaning> meanings)?  $default,) {final _that = this;
switch (_that) {
case _FreeDictionaryEntry() when $default != null:
return $default(_that.word,_that.phonetic,_that.phonetics,_that.meanings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FreeDictionaryEntry implements FreeDictionaryEntry {
  const _FreeDictionaryEntry({this.word, this.phonetic, final  List<FdPhonetic> phonetics = const <FdPhonetic>[], final  List<FdMeaning> meanings = const <FdMeaning>[]}): _phonetics = phonetics,_meanings = meanings;
  factory _FreeDictionaryEntry.fromJson(Map<String, dynamic> json) => _$FreeDictionaryEntryFromJson(json);

@override final  String? word;
@override final  String? phonetic;
 final  List<FdPhonetic> _phonetics;
@override@JsonKey() List<FdPhonetic> get phonetics {
  if (_phonetics is EqualUnmodifiableListView) return _phonetics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_phonetics);
}

 final  List<FdMeaning> _meanings;
@override@JsonKey() List<FdMeaning> get meanings {
  if (_meanings is EqualUnmodifiableListView) return _meanings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meanings);
}


/// Create a copy of FreeDictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FreeDictionaryEntryCopyWith<_FreeDictionaryEntry> get copyWith => __$FreeDictionaryEntryCopyWithImpl<_FreeDictionaryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreeDictionaryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FreeDictionaryEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.phonetic, phonetic) || other.phonetic == phonetic)&&const DeepCollectionEquality().equals(other._phonetics, _phonetics)&&const DeepCollectionEquality().equals(other._meanings, _meanings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,phonetic,const DeepCollectionEquality().hash(_phonetics),const DeepCollectionEquality().hash(_meanings));

@override
String toString() {
  return 'FreeDictionaryEntry(word: $word, phonetic: $phonetic, phonetics: $phonetics, meanings: $meanings)';
}


}

/// @nodoc
abstract mixin class _$FreeDictionaryEntryCopyWith<$Res> implements $FreeDictionaryEntryCopyWith<$Res> {
  factory _$FreeDictionaryEntryCopyWith(_FreeDictionaryEntry value, $Res Function(_FreeDictionaryEntry) _then) = __$FreeDictionaryEntryCopyWithImpl;
@override @useResult
$Res call({
 String? word, String? phonetic, List<FdPhonetic> phonetics, List<FdMeaning> meanings
});




}
/// @nodoc
class __$FreeDictionaryEntryCopyWithImpl<$Res>
    implements _$FreeDictionaryEntryCopyWith<$Res> {
  __$FreeDictionaryEntryCopyWithImpl(this._self, this._then);

  final _FreeDictionaryEntry _self;
  final $Res Function(_FreeDictionaryEntry) _then;

/// Create a copy of FreeDictionaryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = freezed,Object? phonetic = freezed,Object? phonetics = null,Object? meanings = null,}) {
  return _then(_FreeDictionaryEntry(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,phonetic: freezed == phonetic ? _self.phonetic : phonetic // ignore: cast_nullable_to_non_nullable
as String?,phonetics: null == phonetics ? _self._phonetics : phonetics // ignore: cast_nullable_to_non_nullable
as List<FdPhonetic>,meanings: null == meanings ? _self._meanings : meanings // ignore: cast_nullable_to_non_nullable
as List<FdMeaning>,
  ));
}


}


/// @nodoc
mixin _$FdPhonetic {

 String? get text; String? get audio;
/// Create a copy of FdPhonetic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FdPhoneticCopyWith<FdPhonetic> get copyWith => _$FdPhoneticCopyWithImpl<FdPhonetic>(this as FdPhonetic, _$identity);

  /// Serializes this FdPhonetic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FdPhonetic&&(identical(other.text, text) || other.text == text)&&(identical(other.audio, audio) || other.audio == audio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,audio);

@override
String toString() {
  return 'FdPhonetic(text: $text, audio: $audio)';
}


}

/// @nodoc
abstract mixin class $FdPhoneticCopyWith<$Res>  {
  factory $FdPhoneticCopyWith(FdPhonetic value, $Res Function(FdPhonetic) _then) = _$FdPhoneticCopyWithImpl;
@useResult
$Res call({
 String? text, String? audio
});




}
/// @nodoc
class _$FdPhoneticCopyWithImpl<$Res>
    implements $FdPhoneticCopyWith<$Res> {
  _$FdPhoneticCopyWithImpl(this._self, this._then);

  final FdPhonetic _self;
  final $Res Function(FdPhonetic) _then;

/// Create a copy of FdPhonetic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? audio = freezed,}) {
  return _then(_self.copyWith(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FdPhonetic].
extension FdPhoneticPatterns on FdPhonetic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FdPhonetic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FdPhonetic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FdPhonetic value)  $default,){
final _that = this;
switch (_that) {
case _FdPhonetic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FdPhonetic value)?  $default,){
final _that = this;
switch (_that) {
case _FdPhonetic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? text,  String? audio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FdPhonetic() when $default != null:
return $default(_that.text,_that.audio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? text,  String? audio)  $default,) {final _that = this;
switch (_that) {
case _FdPhonetic():
return $default(_that.text,_that.audio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? text,  String? audio)?  $default,) {final _that = this;
switch (_that) {
case _FdPhonetic() when $default != null:
return $default(_that.text,_that.audio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FdPhonetic implements FdPhonetic {
  const _FdPhonetic({this.text, this.audio});
  factory _FdPhonetic.fromJson(Map<String, dynamic> json) => _$FdPhoneticFromJson(json);

@override final  String? text;
@override final  String? audio;

/// Create a copy of FdPhonetic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FdPhoneticCopyWith<_FdPhonetic> get copyWith => __$FdPhoneticCopyWithImpl<_FdPhonetic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FdPhoneticToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FdPhonetic&&(identical(other.text, text) || other.text == text)&&(identical(other.audio, audio) || other.audio == audio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,audio);

@override
String toString() {
  return 'FdPhonetic(text: $text, audio: $audio)';
}


}

/// @nodoc
abstract mixin class _$FdPhoneticCopyWith<$Res> implements $FdPhoneticCopyWith<$Res> {
  factory _$FdPhoneticCopyWith(_FdPhonetic value, $Res Function(_FdPhonetic) _then) = __$FdPhoneticCopyWithImpl;
@override @useResult
$Res call({
 String? text, String? audio
});




}
/// @nodoc
class __$FdPhoneticCopyWithImpl<$Res>
    implements _$FdPhoneticCopyWith<$Res> {
  __$FdPhoneticCopyWithImpl(this._self, this._then);

  final _FdPhonetic _self;
  final $Res Function(_FdPhonetic) _then;

/// Create a copy of FdPhonetic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? audio = freezed,}) {
  return _then(_FdPhonetic(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FdMeaning {

 String? get partOfSpeech; List<FdDefinition> get definitions;
/// Create a copy of FdMeaning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FdMeaningCopyWith<FdMeaning> get copyWith => _$FdMeaningCopyWithImpl<FdMeaning>(this as FdMeaning, _$identity);

  /// Serializes this FdMeaning to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FdMeaning&&(identical(other.partOfSpeech, partOfSpeech) || other.partOfSpeech == partOfSpeech)&&const DeepCollectionEquality().equals(other.definitions, definitions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partOfSpeech,const DeepCollectionEquality().hash(definitions));

@override
String toString() {
  return 'FdMeaning(partOfSpeech: $partOfSpeech, definitions: $definitions)';
}


}

/// @nodoc
abstract mixin class $FdMeaningCopyWith<$Res>  {
  factory $FdMeaningCopyWith(FdMeaning value, $Res Function(FdMeaning) _then) = _$FdMeaningCopyWithImpl;
@useResult
$Res call({
 String? partOfSpeech, List<FdDefinition> definitions
});




}
/// @nodoc
class _$FdMeaningCopyWithImpl<$Res>
    implements $FdMeaningCopyWith<$Res> {
  _$FdMeaningCopyWithImpl(this._self, this._then);

  final FdMeaning _self;
  final $Res Function(FdMeaning) _then;

/// Create a copy of FdMeaning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partOfSpeech = freezed,Object? definitions = null,}) {
  return _then(_self.copyWith(
partOfSpeech: freezed == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String?,definitions: null == definitions ? _self.definitions : definitions // ignore: cast_nullable_to_non_nullable
as List<FdDefinition>,
  ));
}

}


/// Adds pattern-matching-related methods to [FdMeaning].
extension FdMeaningPatterns on FdMeaning {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FdMeaning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FdMeaning() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FdMeaning value)  $default,){
final _that = this;
switch (_that) {
case _FdMeaning():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FdMeaning value)?  $default,){
final _that = this;
switch (_that) {
case _FdMeaning() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? partOfSpeech,  List<FdDefinition> definitions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FdMeaning() when $default != null:
return $default(_that.partOfSpeech,_that.definitions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? partOfSpeech,  List<FdDefinition> definitions)  $default,) {final _that = this;
switch (_that) {
case _FdMeaning():
return $default(_that.partOfSpeech,_that.definitions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? partOfSpeech,  List<FdDefinition> definitions)?  $default,) {final _that = this;
switch (_that) {
case _FdMeaning() when $default != null:
return $default(_that.partOfSpeech,_that.definitions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FdMeaning implements FdMeaning {
  const _FdMeaning({this.partOfSpeech, final  List<FdDefinition> definitions = const <FdDefinition>[]}): _definitions = definitions;
  factory _FdMeaning.fromJson(Map<String, dynamic> json) => _$FdMeaningFromJson(json);

@override final  String? partOfSpeech;
 final  List<FdDefinition> _definitions;
@override@JsonKey() List<FdDefinition> get definitions {
  if (_definitions is EqualUnmodifiableListView) return _definitions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_definitions);
}


/// Create a copy of FdMeaning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FdMeaningCopyWith<_FdMeaning> get copyWith => __$FdMeaningCopyWithImpl<_FdMeaning>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FdMeaningToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FdMeaning&&(identical(other.partOfSpeech, partOfSpeech) || other.partOfSpeech == partOfSpeech)&&const DeepCollectionEquality().equals(other._definitions, _definitions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partOfSpeech,const DeepCollectionEquality().hash(_definitions));

@override
String toString() {
  return 'FdMeaning(partOfSpeech: $partOfSpeech, definitions: $definitions)';
}


}

/// @nodoc
abstract mixin class _$FdMeaningCopyWith<$Res> implements $FdMeaningCopyWith<$Res> {
  factory _$FdMeaningCopyWith(_FdMeaning value, $Res Function(_FdMeaning) _then) = __$FdMeaningCopyWithImpl;
@override @useResult
$Res call({
 String? partOfSpeech, List<FdDefinition> definitions
});




}
/// @nodoc
class __$FdMeaningCopyWithImpl<$Res>
    implements _$FdMeaningCopyWith<$Res> {
  __$FdMeaningCopyWithImpl(this._self, this._then);

  final _FdMeaning _self;
  final $Res Function(_FdMeaning) _then;

/// Create a copy of FdMeaning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partOfSpeech = freezed,Object? definitions = null,}) {
  return _then(_FdMeaning(
partOfSpeech: freezed == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String?,definitions: null == definitions ? _self._definitions : definitions // ignore: cast_nullable_to_non_nullable
as List<FdDefinition>,
  ));
}


}


/// @nodoc
mixin _$FdDefinition {

 String? get definition; String? get example;
/// Create a copy of FdDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FdDefinitionCopyWith<FdDefinition> get copyWith => _$FdDefinitionCopyWithImpl<FdDefinition>(this as FdDefinition, _$identity);

  /// Serializes this FdDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FdDefinition&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.example, example) || other.example == example));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,definition,example);

@override
String toString() {
  return 'FdDefinition(definition: $definition, example: $example)';
}


}

/// @nodoc
abstract mixin class $FdDefinitionCopyWith<$Res>  {
  factory $FdDefinitionCopyWith(FdDefinition value, $Res Function(FdDefinition) _then) = _$FdDefinitionCopyWithImpl;
@useResult
$Res call({
 String? definition, String? example
});




}
/// @nodoc
class _$FdDefinitionCopyWithImpl<$Res>
    implements $FdDefinitionCopyWith<$Res> {
  _$FdDefinitionCopyWithImpl(this._self, this._then);

  final FdDefinition _self;
  final $Res Function(FdDefinition) _then;

/// Create a copy of FdDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? definition = freezed,Object? example = freezed,}) {
  return _then(_self.copyWith(
definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,example: freezed == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FdDefinition].
extension FdDefinitionPatterns on FdDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FdDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FdDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FdDefinition value)  $default,){
final _that = this;
switch (_that) {
case _FdDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FdDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _FdDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? definition,  String? example)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FdDefinition() when $default != null:
return $default(_that.definition,_that.example);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? definition,  String? example)  $default,) {final _that = this;
switch (_that) {
case _FdDefinition():
return $default(_that.definition,_that.example);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? definition,  String? example)?  $default,) {final _that = this;
switch (_that) {
case _FdDefinition() when $default != null:
return $default(_that.definition,_that.example);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FdDefinition implements FdDefinition {
  const _FdDefinition({this.definition, this.example});
  factory _FdDefinition.fromJson(Map<String, dynamic> json) => _$FdDefinitionFromJson(json);

@override final  String? definition;
@override final  String? example;

/// Create a copy of FdDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FdDefinitionCopyWith<_FdDefinition> get copyWith => __$FdDefinitionCopyWithImpl<_FdDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FdDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FdDefinition&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.example, example) || other.example == example));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,definition,example);

@override
String toString() {
  return 'FdDefinition(definition: $definition, example: $example)';
}


}

/// @nodoc
abstract mixin class _$FdDefinitionCopyWith<$Res> implements $FdDefinitionCopyWith<$Res> {
  factory _$FdDefinitionCopyWith(_FdDefinition value, $Res Function(_FdDefinition) _then) = __$FdDefinitionCopyWithImpl;
@override @useResult
$Res call({
 String? definition, String? example
});




}
/// @nodoc
class __$FdDefinitionCopyWithImpl<$Res>
    implements _$FdDefinitionCopyWith<$Res> {
  __$FdDefinitionCopyWithImpl(this._self, this._then);

  final _FdDefinition _self;
  final $Res Function(_FdDefinition) _then;

/// Create a copy of FdDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? definition = freezed,Object? example = freezed,}) {
  return _then(_FdDefinition(
definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,example: freezed == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
