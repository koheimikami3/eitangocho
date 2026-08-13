// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kaikki_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KaikkiEntry {

 String? get word; String? get pos; List<KaikkiSound> get sounds; List<KaikkiSense> get senses; List<KaikkiTranslation> get translations;
/// Create a copy of KaikkiEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KaikkiEntryCopyWith<KaikkiEntry> get copyWith => _$KaikkiEntryCopyWithImpl<KaikkiEntry>(this as KaikkiEntry, _$identity);

  /// Serializes this KaikkiEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KaikkiEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.pos, pos) || other.pos == pos)&&const DeepCollectionEquality().equals(other.sounds, sounds)&&const DeepCollectionEquality().equals(other.senses, senses)&&const DeepCollectionEquality().equals(other.translations, translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,pos,const DeepCollectionEquality().hash(sounds),const DeepCollectionEquality().hash(senses),const DeepCollectionEquality().hash(translations));

@override
String toString() {
  return 'KaikkiEntry(word: $word, pos: $pos, sounds: $sounds, senses: $senses, translations: $translations)';
}


}

/// @nodoc
abstract mixin class $KaikkiEntryCopyWith<$Res>  {
  factory $KaikkiEntryCopyWith(KaikkiEntry value, $Res Function(KaikkiEntry) _then) = _$KaikkiEntryCopyWithImpl;
@useResult
$Res call({
 String? word, String? pos, List<KaikkiSound> sounds, List<KaikkiSense> senses, List<KaikkiTranslation> translations
});




}
/// @nodoc
class _$KaikkiEntryCopyWithImpl<$Res>
    implements $KaikkiEntryCopyWith<$Res> {
  _$KaikkiEntryCopyWithImpl(this._self, this._then);

  final KaikkiEntry _self;
  final $Res Function(KaikkiEntry) _then;

/// Create a copy of KaikkiEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = freezed,Object? pos = freezed,Object? sounds = null,Object? senses = null,Object? translations = null,}) {
  return _then(_self.copyWith(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,pos: freezed == pos ? _self.pos : pos // ignore: cast_nullable_to_non_nullable
as String?,sounds: null == sounds ? _self.sounds : sounds // ignore: cast_nullable_to_non_nullable
as List<KaikkiSound>,senses: null == senses ? _self.senses : senses // ignore: cast_nullable_to_non_nullable
as List<KaikkiSense>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<KaikkiTranslation>,
  ));
}

}


/// Adds pattern-matching-related methods to [KaikkiEntry].
extension KaikkiEntryPatterns on KaikkiEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KaikkiEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KaikkiEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KaikkiEntry value)  $default,){
final _that = this;
switch (_that) {
case _KaikkiEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KaikkiEntry value)?  $default,){
final _that = this;
switch (_that) {
case _KaikkiEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? word,  String? pos,  List<KaikkiSound> sounds,  List<KaikkiSense> senses,  List<KaikkiTranslation> translations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KaikkiEntry() when $default != null:
return $default(_that.word,_that.pos,_that.sounds,_that.senses,_that.translations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? word,  String? pos,  List<KaikkiSound> sounds,  List<KaikkiSense> senses,  List<KaikkiTranslation> translations)  $default,) {final _that = this;
switch (_that) {
case _KaikkiEntry():
return $default(_that.word,_that.pos,_that.sounds,_that.senses,_that.translations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? word,  String? pos,  List<KaikkiSound> sounds,  List<KaikkiSense> senses,  List<KaikkiTranslation> translations)?  $default,) {final _that = this;
switch (_that) {
case _KaikkiEntry() when $default != null:
return $default(_that.word,_that.pos,_that.sounds,_that.senses,_that.translations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KaikkiEntry implements KaikkiEntry {
  const _KaikkiEntry({this.word, this.pos, final  List<KaikkiSound> sounds = const <KaikkiSound>[], final  List<KaikkiSense> senses = const <KaikkiSense>[], final  List<KaikkiTranslation> translations = const <KaikkiTranslation>[]}): _sounds = sounds,_senses = senses,_translations = translations;
  factory _KaikkiEntry.fromJson(Map<String, dynamic> json) => _$KaikkiEntryFromJson(json);

@override final  String? word;
@override final  String? pos;
 final  List<KaikkiSound> _sounds;
@override@JsonKey() List<KaikkiSound> get sounds {
  if (_sounds is EqualUnmodifiableListView) return _sounds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sounds);
}

 final  List<KaikkiSense> _senses;
@override@JsonKey() List<KaikkiSense> get senses {
  if (_senses is EqualUnmodifiableListView) return _senses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_senses);
}

 final  List<KaikkiTranslation> _translations;
@override@JsonKey() List<KaikkiTranslation> get translations {
  if (_translations is EqualUnmodifiableListView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translations);
}


/// Create a copy of KaikkiEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KaikkiEntryCopyWith<_KaikkiEntry> get copyWith => __$KaikkiEntryCopyWithImpl<_KaikkiEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KaikkiEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaikkiEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.pos, pos) || other.pos == pos)&&const DeepCollectionEquality().equals(other._sounds, _sounds)&&const DeepCollectionEquality().equals(other._senses, _senses)&&const DeepCollectionEquality().equals(other._translations, _translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,pos,const DeepCollectionEquality().hash(_sounds),const DeepCollectionEquality().hash(_senses),const DeepCollectionEquality().hash(_translations));

@override
String toString() {
  return 'KaikkiEntry(word: $word, pos: $pos, sounds: $sounds, senses: $senses, translations: $translations)';
}


}

/// @nodoc
abstract mixin class _$KaikkiEntryCopyWith<$Res> implements $KaikkiEntryCopyWith<$Res> {
  factory _$KaikkiEntryCopyWith(_KaikkiEntry value, $Res Function(_KaikkiEntry) _then) = __$KaikkiEntryCopyWithImpl;
@override @useResult
$Res call({
 String? word, String? pos, List<KaikkiSound> sounds, List<KaikkiSense> senses, List<KaikkiTranslation> translations
});




}
/// @nodoc
class __$KaikkiEntryCopyWithImpl<$Res>
    implements _$KaikkiEntryCopyWith<$Res> {
  __$KaikkiEntryCopyWithImpl(this._self, this._then);

  final _KaikkiEntry _self;
  final $Res Function(_KaikkiEntry) _then;

/// Create a copy of KaikkiEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = freezed,Object? pos = freezed,Object? sounds = null,Object? senses = null,Object? translations = null,}) {
  return _then(_KaikkiEntry(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,pos: freezed == pos ? _self.pos : pos // ignore: cast_nullable_to_non_nullable
as String?,sounds: null == sounds ? _self._sounds : sounds // ignore: cast_nullable_to_non_nullable
as List<KaikkiSound>,senses: null == senses ? _self._senses : senses // ignore: cast_nullable_to_non_nullable
as List<KaikkiSense>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<KaikkiTranslation>,
  ));
}


}


/// @nodoc
mixin _$KaikkiSound {

 String? get ipa; List<String> get tags;
/// Create a copy of KaikkiSound
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KaikkiSoundCopyWith<KaikkiSound> get copyWith => _$KaikkiSoundCopyWithImpl<KaikkiSound>(this as KaikkiSound, _$identity);

  /// Serializes this KaikkiSound to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KaikkiSound&&(identical(other.ipa, ipa) || other.ipa == ipa)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ipa,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'KaikkiSound(ipa: $ipa, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $KaikkiSoundCopyWith<$Res>  {
  factory $KaikkiSoundCopyWith(KaikkiSound value, $Res Function(KaikkiSound) _then) = _$KaikkiSoundCopyWithImpl;
@useResult
$Res call({
 String? ipa, List<String> tags
});




}
/// @nodoc
class _$KaikkiSoundCopyWithImpl<$Res>
    implements $KaikkiSoundCopyWith<$Res> {
  _$KaikkiSoundCopyWithImpl(this._self, this._then);

  final KaikkiSound _self;
  final $Res Function(KaikkiSound) _then;

/// Create a copy of KaikkiSound
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ipa = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
ipa: freezed == ipa ? _self.ipa : ipa // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [KaikkiSound].
extension KaikkiSoundPatterns on KaikkiSound {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KaikkiSound value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KaikkiSound() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KaikkiSound value)  $default,){
final _that = this;
switch (_that) {
case _KaikkiSound():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KaikkiSound value)?  $default,){
final _that = this;
switch (_that) {
case _KaikkiSound() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? ipa,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KaikkiSound() when $default != null:
return $default(_that.ipa,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? ipa,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _KaikkiSound():
return $default(_that.ipa,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? ipa,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _KaikkiSound() when $default != null:
return $default(_that.ipa,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KaikkiSound implements KaikkiSound {
  const _KaikkiSound({this.ipa, final  List<String> tags = const <String>[]}): _tags = tags;
  factory _KaikkiSound.fromJson(Map<String, dynamic> json) => _$KaikkiSoundFromJson(json);

@override final  String? ipa;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of KaikkiSound
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KaikkiSoundCopyWith<_KaikkiSound> get copyWith => __$KaikkiSoundCopyWithImpl<_KaikkiSound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KaikkiSoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaikkiSound&&(identical(other.ipa, ipa) || other.ipa == ipa)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ipa,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'KaikkiSound(ipa: $ipa, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$KaikkiSoundCopyWith<$Res> implements $KaikkiSoundCopyWith<$Res> {
  factory _$KaikkiSoundCopyWith(_KaikkiSound value, $Res Function(_KaikkiSound) _then) = __$KaikkiSoundCopyWithImpl;
@override @useResult
$Res call({
 String? ipa, List<String> tags
});




}
/// @nodoc
class __$KaikkiSoundCopyWithImpl<$Res>
    implements _$KaikkiSoundCopyWith<$Res> {
  __$KaikkiSoundCopyWithImpl(this._self, this._then);

  final _KaikkiSound _self;
  final $Res Function(_KaikkiSound) _then;

/// Create a copy of KaikkiSound
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ipa = freezed,Object? tags = null,}) {
  return _then(_KaikkiSound(
ipa: freezed == ipa ? _self.ipa : ipa // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$KaikkiTranslation {

 String? get word;@JsonKey(name: 'lang_code') String? get langCode;
/// Create a copy of KaikkiTranslation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KaikkiTranslationCopyWith<KaikkiTranslation> get copyWith => _$KaikkiTranslationCopyWithImpl<KaikkiTranslation>(this as KaikkiTranslation, _$identity);

  /// Serializes this KaikkiTranslation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KaikkiTranslation&&(identical(other.word, word) || other.word == word)&&(identical(other.langCode, langCode) || other.langCode == langCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,langCode);

@override
String toString() {
  return 'KaikkiTranslation(word: $word, langCode: $langCode)';
}


}

/// @nodoc
abstract mixin class $KaikkiTranslationCopyWith<$Res>  {
  factory $KaikkiTranslationCopyWith(KaikkiTranslation value, $Res Function(KaikkiTranslation) _then) = _$KaikkiTranslationCopyWithImpl;
@useResult
$Res call({
 String? word,@JsonKey(name: 'lang_code') String? langCode
});




}
/// @nodoc
class _$KaikkiTranslationCopyWithImpl<$Res>
    implements $KaikkiTranslationCopyWith<$Res> {
  _$KaikkiTranslationCopyWithImpl(this._self, this._then);

  final KaikkiTranslation _self;
  final $Res Function(KaikkiTranslation) _then;

/// Create a copy of KaikkiTranslation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = freezed,Object? langCode = freezed,}) {
  return _then(_self.copyWith(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,langCode: freezed == langCode ? _self.langCode : langCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KaikkiTranslation].
extension KaikkiTranslationPatterns on KaikkiTranslation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KaikkiTranslation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KaikkiTranslation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KaikkiTranslation value)  $default,){
final _that = this;
switch (_that) {
case _KaikkiTranslation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KaikkiTranslation value)?  $default,){
final _that = this;
switch (_that) {
case _KaikkiTranslation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? word, @JsonKey(name: 'lang_code')  String? langCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KaikkiTranslation() when $default != null:
return $default(_that.word,_that.langCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? word, @JsonKey(name: 'lang_code')  String? langCode)  $default,) {final _that = this;
switch (_that) {
case _KaikkiTranslation():
return $default(_that.word,_that.langCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? word, @JsonKey(name: 'lang_code')  String? langCode)?  $default,) {final _that = this;
switch (_that) {
case _KaikkiTranslation() when $default != null:
return $default(_that.word,_that.langCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KaikkiTranslation implements KaikkiTranslation {
  const _KaikkiTranslation({this.word, @JsonKey(name: 'lang_code') this.langCode});
  factory _KaikkiTranslation.fromJson(Map<String, dynamic> json) => _$KaikkiTranslationFromJson(json);

@override final  String? word;
@override@JsonKey(name: 'lang_code') final  String? langCode;

/// Create a copy of KaikkiTranslation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KaikkiTranslationCopyWith<_KaikkiTranslation> get copyWith => __$KaikkiTranslationCopyWithImpl<_KaikkiTranslation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KaikkiTranslationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaikkiTranslation&&(identical(other.word, word) || other.word == word)&&(identical(other.langCode, langCode) || other.langCode == langCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,langCode);

@override
String toString() {
  return 'KaikkiTranslation(word: $word, langCode: $langCode)';
}


}

/// @nodoc
abstract mixin class _$KaikkiTranslationCopyWith<$Res> implements $KaikkiTranslationCopyWith<$Res> {
  factory _$KaikkiTranslationCopyWith(_KaikkiTranslation value, $Res Function(_KaikkiTranslation) _then) = __$KaikkiTranslationCopyWithImpl;
@override @useResult
$Res call({
 String? word,@JsonKey(name: 'lang_code') String? langCode
});




}
/// @nodoc
class __$KaikkiTranslationCopyWithImpl<$Res>
    implements _$KaikkiTranslationCopyWith<$Res> {
  __$KaikkiTranslationCopyWithImpl(this._self, this._then);

  final _KaikkiTranslation _self;
  final $Res Function(_KaikkiTranslation) _then;

/// Create a copy of KaikkiTranslation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = freezed,Object? langCode = freezed,}) {
  return _then(_KaikkiTranslation(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,langCode: freezed == langCode ? _self.langCode : langCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$KaikkiSense {

 List<KaikkiExample> get examples;
/// Create a copy of KaikkiSense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KaikkiSenseCopyWith<KaikkiSense> get copyWith => _$KaikkiSenseCopyWithImpl<KaikkiSense>(this as KaikkiSense, _$identity);

  /// Serializes this KaikkiSense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KaikkiSense&&const DeepCollectionEquality().equals(other.examples, examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(examples));

@override
String toString() {
  return 'KaikkiSense(examples: $examples)';
}


}

/// @nodoc
abstract mixin class $KaikkiSenseCopyWith<$Res>  {
  factory $KaikkiSenseCopyWith(KaikkiSense value, $Res Function(KaikkiSense) _then) = _$KaikkiSenseCopyWithImpl;
@useResult
$Res call({
 List<KaikkiExample> examples
});




}
/// @nodoc
class _$KaikkiSenseCopyWithImpl<$Res>
    implements $KaikkiSenseCopyWith<$Res> {
  _$KaikkiSenseCopyWithImpl(this._self, this._then);

  final KaikkiSense _self;
  final $Res Function(KaikkiSense) _then;

/// Create a copy of KaikkiSense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? examples = null,}) {
  return _then(_self.copyWith(
examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<KaikkiExample>,
  ));
}

}


/// Adds pattern-matching-related methods to [KaikkiSense].
extension KaikkiSensePatterns on KaikkiSense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KaikkiSense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KaikkiSense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KaikkiSense value)  $default,){
final _that = this;
switch (_that) {
case _KaikkiSense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KaikkiSense value)?  $default,){
final _that = this;
switch (_that) {
case _KaikkiSense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KaikkiExample> examples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KaikkiSense() when $default != null:
return $default(_that.examples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KaikkiExample> examples)  $default,) {final _that = this;
switch (_that) {
case _KaikkiSense():
return $default(_that.examples);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KaikkiExample> examples)?  $default,) {final _that = this;
switch (_that) {
case _KaikkiSense() when $default != null:
return $default(_that.examples);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KaikkiSense implements KaikkiSense {
  const _KaikkiSense({final  List<KaikkiExample> examples = const <KaikkiExample>[]}): _examples = examples;
  factory _KaikkiSense.fromJson(Map<String, dynamic> json) => _$KaikkiSenseFromJson(json);

 final  List<KaikkiExample> _examples;
@override@JsonKey() List<KaikkiExample> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}


/// Create a copy of KaikkiSense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KaikkiSenseCopyWith<_KaikkiSense> get copyWith => __$KaikkiSenseCopyWithImpl<_KaikkiSense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KaikkiSenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaikkiSense&&const DeepCollectionEquality().equals(other._examples, _examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_examples));

@override
String toString() {
  return 'KaikkiSense(examples: $examples)';
}


}

/// @nodoc
abstract mixin class _$KaikkiSenseCopyWith<$Res> implements $KaikkiSenseCopyWith<$Res> {
  factory _$KaikkiSenseCopyWith(_KaikkiSense value, $Res Function(_KaikkiSense) _then) = __$KaikkiSenseCopyWithImpl;
@override @useResult
$Res call({
 List<KaikkiExample> examples
});




}
/// @nodoc
class __$KaikkiSenseCopyWithImpl<$Res>
    implements _$KaikkiSenseCopyWith<$Res> {
  __$KaikkiSenseCopyWithImpl(this._self, this._then);

  final _KaikkiSense _self;
  final $Res Function(_KaikkiSense) _then;

/// Create a copy of KaikkiSense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? examples = null,}) {
  return _then(_KaikkiSense(
examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<KaikkiExample>,
  ));
}


}


/// @nodoc
mixin _$KaikkiExample {

 String? get text; String? get type; List<String> get tags;
/// Create a copy of KaikkiExample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KaikkiExampleCopyWith<KaikkiExample> get copyWith => _$KaikkiExampleCopyWithImpl<KaikkiExample>(this as KaikkiExample, _$identity);

  /// Serializes this KaikkiExample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KaikkiExample&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'KaikkiExample(text: $text, type: $type, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $KaikkiExampleCopyWith<$Res>  {
  factory $KaikkiExampleCopyWith(KaikkiExample value, $Res Function(KaikkiExample) _then) = _$KaikkiExampleCopyWithImpl;
@useResult
$Res call({
 String? text, String? type, List<String> tags
});




}
/// @nodoc
class _$KaikkiExampleCopyWithImpl<$Res>
    implements $KaikkiExampleCopyWith<$Res> {
  _$KaikkiExampleCopyWithImpl(this._self, this._then);

  final KaikkiExample _self;
  final $Res Function(KaikkiExample) _then;

/// Create a copy of KaikkiExample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? type = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [KaikkiExample].
extension KaikkiExamplePatterns on KaikkiExample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KaikkiExample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KaikkiExample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KaikkiExample value)  $default,){
final _that = this;
switch (_that) {
case _KaikkiExample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KaikkiExample value)?  $default,){
final _that = this;
switch (_that) {
case _KaikkiExample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? text,  String? type,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KaikkiExample() when $default != null:
return $default(_that.text,_that.type,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? text,  String? type,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _KaikkiExample():
return $default(_that.text,_that.type,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? text,  String? type,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _KaikkiExample() when $default != null:
return $default(_that.text,_that.type,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KaikkiExample implements KaikkiExample {
  const _KaikkiExample({this.text, this.type, final  List<String> tags = const <String>[]}): _tags = tags;
  factory _KaikkiExample.fromJson(Map<String, dynamic> json) => _$KaikkiExampleFromJson(json);

@override final  String? text;
@override final  String? type;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of KaikkiExample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KaikkiExampleCopyWith<_KaikkiExample> get copyWith => __$KaikkiExampleCopyWithImpl<_KaikkiExample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KaikkiExampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaikkiExample&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'KaikkiExample(text: $text, type: $type, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$KaikkiExampleCopyWith<$Res> implements $KaikkiExampleCopyWith<$Res> {
  factory _$KaikkiExampleCopyWith(_KaikkiExample value, $Res Function(_KaikkiExample) _then) = __$KaikkiExampleCopyWithImpl;
@override @useResult
$Res call({
 String? text, String? type, List<String> tags
});




}
/// @nodoc
class __$KaikkiExampleCopyWithImpl<$Res>
    implements _$KaikkiExampleCopyWith<$Res> {
  __$KaikkiExampleCopyWithImpl(this._self, this._then);

  final _KaikkiExample _self;
  final $Res Function(_KaikkiExample) _then;

/// Create a copy of KaikkiExample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? type = freezed,Object? tags = null,}) {
  return _then(_KaikkiExample(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
