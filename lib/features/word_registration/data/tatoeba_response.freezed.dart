// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tatoeba_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TatoebaSearchResponse {

 List<TatoebaSentence> get data;
/// Create a copy of TatoebaSearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TatoebaSearchResponseCopyWith<TatoebaSearchResponse> get copyWith => _$TatoebaSearchResponseCopyWithImpl<TatoebaSearchResponse>(this as TatoebaSearchResponse, _$identity);

  /// Serializes this TatoebaSearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TatoebaSearchResponse&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'TatoebaSearchResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class $TatoebaSearchResponseCopyWith<$Res>  {
  factory $TatoebaSearchResponseCopyWith(TatoebaSearchResponse value, $Res Function(TatoebaSearchResponse) _then) = _$TatoebaSearchResponseCopyWithImpl;
@useResult
$Res call({
 List<TatoebaSentence> data
});




}
/// @nodoc
class _$TatoebaSearchResponseCopyWithImpl<$Res>
    implements $TatoebaSearchResponseCopyWith<$Res> {
  _$TatoebaSearchResponseCopyWithImpl(this._self, this._then);

  final TatoebaSearchResponse _self;
  final $Res Function(TatoebaSearchResponse) _then;

/// Create a copy of TatoebaSearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<TatoebaSentence>,
  ));
}

}


/// Adds pattern-matching-related methods to [TatoebaSearchResponse].
extension TatoebaSearchResponsePatterns on TatoebaSearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TatoebaSearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TatoebaSearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TatoebaSearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _TatoebaSearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TatoebaSearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TatoebaSearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TatoebaSentence> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TatoebaSearchResponse() when $default != null:
return $default(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TatoebaSentence> data)  $default,) {final _that = this;
switch (_that) {
case _TatoebaSearchResponse():
return $default(_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TatoebaSentence> data)?  $default,) {final _that = this;
switch (_that) {
case _TatoebaSearchResponse() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TatoebaSearchResponse implements TatoebaSearchResponse {
  const _TatoebaSearchResponse({final  List<TatoebaSentence> data = const <TatoebaSentence>[]}): _data = data;
  factory _TatoebaSearchResponse.fromJson(Map<String, dynamic> json) => _$TatoebaSearchResponseFromJson(json);

 final  List<TatoebaSentence> _data;
@override@JsonKey() List<TatoebaSentence> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of TatoebaSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TatoebaSearchResponseCopyWith<_TatoebaSearchResponse> get copyWith => __$TatoebaSearchResponseCopyWithImpl<_TatoebaSearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TatoebaSearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TatoebaSearchResponse&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'TatoebaSearchResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class _$TatoebaSearchResponseCopyWith<$Res> implements $TatoebaSearchResponseCopyWith<$Res> {
  factory _$TatoebaSearchResponseCopyWith(_TatoebaSearchResponse value, $Res Function(_TatoebaSearchResponse) _then) = __$TatoebaSearchResponseCopyWithImpl;
@override @useResult
$Res call({
 List<TatoebaSentence> data
});




}
/// @nodoc
class __$TatoebaSearchResponseCopyWithImpl<$Res>
    implements _$TatoebaSearchResponseCopyWith<$Res> {
  __$TatoebaSearchResponseCopyWithImpl(this._self, this._then);

  final _TatoebaSearchResponse _self;
  final $Res Function(_TatoebaSearchResponse) _then;

/// Create a copy of TatoebaSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_TatoebaSearchResponse(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<TatoebaSentence>,
  ));
}


}


/// @nodoc
mixin _$TatoebaSentence {

 String? get text; List<TatoebaTranslation> get translations;
/// Create a copy of TatoebaSentence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TatoebaSentenceCopyWith<TatoebaSentence> get copyWith => _$TatoebaSentenceCopyWithImpl<TatoebaSentence>(this as TatoebaSentence, _$identity);

  /// Serializes this TatoebaSentence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TatoebaSentence&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.translations, translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(translations));

@override
String toString() {
  return 'TatoebaSentence(text: $text, translations: $translations)';
}


}

/// @nodoc
abstract mixin class $TatoebaSentenceCopyWith<$Res>  {
  factory $TatoebaSentenceCopyWith(TatoebaSentence value, $Res Function(TatoebaSentence) _then) = _$TatoebaSentenceCopyWithImpl;
@useResult
$Res call({
 String? text, List<TatoebaTranslation> translations
});




}
/// @nodoc
class _$TatoebaSentenceCopyWithImpl<$Res>
    implements $TatoebaSentenceCopyWith<$Res> {
  _$TatoebaSentenceCopyWithImpl(this._self, this._then);

  final TatoebaSentence _self;
  final $Res Function(TatoebaSentence) _then;

/// Create a copy of TatoebaSentence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? translations = null,}) {
  return _then(_self.copyWith(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<TatoebaTranslation>,
  ));
}

}


/// Adds pattern-matching-related methods to [TatoebaSentence].
extension TatoebaSentencePatterns on TatoebaSentence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TatoebaSentence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TatoebaSentence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TatoebaSentence value)  $default,){
final _that = this;
switch (_that) {
case _TatoebaSentence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TatoebaSentence value)?  $default,){
final _that = this;
switch (_that) {
case _TatoebaSentence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? text,  List<TatoebaTranslation> translations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TatoebaSentence() when $default != null:
return $default(_that.text,_that.translations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? text,  List<TatoebaTranslation> translations)  $default,) {final _that = this;
switch (_that) {
case _TatoebaSentence():
return $default(_that.text,_that.translations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? text,  List<TatoebaTranslation> translations)?  $default,) {final _that = this;
switch (_that) {
case _TatoebaSentence() when $default != null:
return $default(_that.text,_that.translations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TatoebaSentence implements TatoebaSentence {
  const _TatoebaSentence({this.text, final  List<TatoebaTranslation> translations = const <TatoebaTranslation>[]}): _translations = translations;
  factory _TatoebaSentence.fromJson(Map<String, dynamic> json) => _$TatoebaSentenceFromJson(json);

@override final  String? text;
 final  List<TatoebaTranslation> _translations;
@override@JsonKey() List<TatoebaTranslation> get translations {
  if (_translations is EqualUnmodifiableListView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translations);
}


/// Create a copy of TatoebaSentence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TatoebaSentenceCopyWith<_TatoebaSentence> get copyWith => __$TatoebaSentenceCopyWithImpl<_TatoebaSentence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TatoebaSentenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TatoebaSentence&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._translations, _translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_translations));

@override
String toString() {
  return 'TatoebaSentence(text: $text, translations: $translations)';
}


}

/// @nodoc
abstract mixin class _$TatoebaSentenceCopyWith<$Res> implements $TatoebaSentenceCopyWith<$Res> {
  factory _$TatoebaSentenceCopyWith(_TatoebaSentence value, $Res Function(_TatoebaSentence) _then) = __$TatoebaSentenceCopyWithImpl;
@override @useResult
$Res call({
 String? text, List<TatoebaTranslation> translations
});




}
/// @nodoc
class __$TatoebaSentenceCopyWithImpl<$Res>
    implements _$TatoebaSentenceCopyWith<$Res> {
  __$TatoebaSentenceCopyWithImpl(this._self, this._then);

  final _TatoebaSentence _self;
  final $Res Function(_TatoebaSentence) _then;

/// Create a copy of TatoebaSentence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? translations = null,}) {
  return _then(_TatoebaSentence(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<TatoebaTranslation>,
  ));
}


}


/// @nodoc
mixin _$TatoebaTranslation {

 String? get lang; String? get text;
/// Create a copy of TatoebaTranslation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TatoebaTranslationCopyWith<TatoebaTranslation> get copyWith => _$TatoebaTranslationCopyWithImpl<TatoebaTranslation>(this as TatoebaTranslation, _$identity);

  /// Serializes this TatoebaTranslation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TatoebaTranslation&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lang,text);

@override
String toString() {
  return 'TatoebaTranslation(lang: $lang, text: $text)';
}


}

/// @nodoc
abstract mixin class $TatoebaTranslationCopyWith<$Res>  {
  factory $TatoebaTranslationCopyWith(TatoebaTranslation value, $Res Function(TatoebaTranslation) _then) = _$TatoebaTranslationCopyWithImpl;
@useResult
$Res call({
 String? lang, String? text
});




}
/// @nodoc
class _$TatoebaTranslationCopyWithImpl<$Res>
    implements $TatoebaTranslationCopyWith<$Res> {
  _$TatoebaTranslationCopyWithImpl(this._self, this._then);

  final TatoebaTranslation _self;
  final $Res Function(TatoebaTranslation) _then;

/// Create a copy of TatoebaTranslation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lang = freezed,Object? text = freezed,}) {
  return _then(_self.copyWith(
lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TatoebaTranslation].
extension TatoebaTranslationPatterns on TatoebaTranslation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TatoebaTranslation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TatoebaTranslation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TatoebaTranslation value)  $default,){
final _that = this;
switch (_that) {
case _TatoebaTranslation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TatoebaTranslation value)?  $default,){
final _that = this;
switch (_that) {
case _TatoebaTranslation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? lang,  String? text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TatoebaTranslation() when $default != null:
return $default(_that.lang,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? lang,  String? text)  $default,) {final _that = this;
switch (_that) {
case _TatoebaTranslation():
return $default(_that.lang,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? lang,  String? text)?  $default,) {final _that = this;
switch (_that) {
case _TatoebaTranslation() when $default != null:
return $default(_that.lang,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TatoebaTranslation implements TatoebaTranslation {
  const _TatoebaTranslation({this.lang, this.text});
  factory _TatoebaTranslation.fromJson(Map<String, dynamic> json) => _$TatoebaTranslationFromJson(json);

@override final  String? lang;
@override final  String? text;

/// Create a copy of TatoebaTranslation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TatoebaTranslationCopyWith<_TatoebaTranslation> get copyWith => __$TatoebaTranslationCopyWithImpl<_TatoebaTranslation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TatoebaTranslationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TatoebaTranslation&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lang,text);

@override
String toString() {
  return 'TatoebaTranslation(lang: $lang, text: $text)';
}


}

/// @nodoc
abstract mixin class _$TatoebaTranslationCopyWith<$Res> implements $TatoebaTranslationCopyWith<$Res> {
  factory _$TatoebaTranslationCopyWith(_TatoebaTranslation value, $Res Function(_TatoebaTranslation) _then) = __$TatoebaTranslationCopyWithImpl;
@override @useResult
$Res call({
 String? lang, String? text
});




}
/// @nodoc
class __$TatoebaTranslationCopyWithImpl<$Res>
    implements _$TatoebaTranslationCopyWith<$Res> {
  __$TatoebaTranslationCopyWithImpl(this._self, this._then);

  final _TatoebaTranslation _self;
  final $Res Function(_TatoebaTranslation) _then;

/// Create a copy of TatoebaTranslation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lang = freezed,Object? text = freezed,}) {
  return _then(_TatoebaTranslation(
lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
