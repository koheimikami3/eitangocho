// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordInfo {

 String get word; String get ipa; List<PartOfSpeech> get partsOfSpeech; String get japanese; String get exampleEn; String get exampleJa; String get audioUrl;
/// Create a copy of WordInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordInfoCopyWith<WordInfo> get copyWith => _$WordInfoCopyWithImpl<WordInfo>(this as WordInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordInfo&&(identical(other.word, word) || other.word == word)&&(identical(other.ipa, ipa) || other.ipa == ipa)&&const DeepCollectionEquality().equals(other.partsOfSpeech, partsOfSpeech)&&(identical(other.japanese, japanese) || other.japanese == japanese)&&(identical(other.exampleEn, exampleEn) || other.exampleEn == exampleEn)&&(identical(other.exampleJa, exampleJa) || other.exampleJa == exampleJa)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,word,ipa,const DeepCollectionEquality().hash(partsOfSpeech),japanese,exampleEn,exampleJa,audioUrl);

@override
String toString() {
  return 'WordInfo(word: $word, ipa: $ipa, partsOfSpeech: $partsOfSpeech, japanese: $japanese, exampleEn: $exampleEn, exampleJa: $exampleJa, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class $WordInfoCopyWith<$Res>  {
  factory $WordInfoCopyWith(WordInfo value, $Res Function(WordInfo) _then) = _$WordInfoCopyWithImpl;
@useResult
$Res call({
 String word, String ipa, List<PartOfSpeech> partsOfSpeech, String japanese, String exampleEn, String exampleJa, String audioUrl
});




}
/// @nodoc
class _$WordInfoCopyWithImpl<$Res>
    implements $WordInfoCopyWith<$Res> {
  _$WordInfoCopyWithImpl(this._self, this._then);

  final WordInfo _self;
  final $Res Function(WordInfo) _then;

/// Create a copy of WordInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = null,Object? ipa = null,Object? partsOfSpeech = null,Object? japanese = null,Object? exampleEn = null,Object? exampleJa = null,Object? audioUrl = null,}) {
  return _then(_self.copyWith(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,ipa: null == ipa ? _self.ipa : ipa // ignore: cast_nullable_to_non_nullable
as String,partsOfSpeech: null == partsOfSpeech ? _self.partsOfSpeech : partsOfSpeech // ignore: cast_nullable_to_non_nullable
as List<PartOfSpeech>,japanese: null == japanese ? _self.japanese : japanese // ignore: cast_nullable_to_non_nullable
as String,exampleEn: null == exampleEn ? _self.exampleEn : exampleEn // ignore: cast_nullable_to_non_nullable
as String,exampleJa: null == exampleJa ? _self.exampleJa : exampleJa // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WordInfo].
extension WordInfoPatterns on WordInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordInfo value)  $default,){
final _that = this;
switch (_that) {
case _WordInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordInfo value)?  $default,){
final _that = this;
switch (_that) {
case _WordInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String word,  String ipa,  List<PartOfSpeech> partsOfSpeech,  String japanese,  String exampleEn,  String exampleJa,  String audioUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordInfo() when $default != null:
return $default(_that.word,_that.ipa,_that.partsOfSpeech,_that.japanese,_that.exampleEn,_that.exampleJa,_that.audioUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String word,  String ipa,  List<PartOfSpeech> partsOfSpeech,  String japanese,  String exampleEn,  String exampleJa,  String audioUrl)  $default,) {final _that = this;
switch (_that) {
case _WordInfo():
return $default(_that.word,_that.ipa,_that.partsOfSpeech,_that.japanese,_that.exampleEn,_that.exampleJa,_that.audioUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String word,  String ipa,  List<PartOfSpeech> partsOfSpeech,  String japanese,  String exampleEn,  String exampleJa,  String audioUrl)?  $default,) {final _that = this;
switch (_that) {
case _WordInfo() when $default != null:
return $default(_that.word,_that.ipa,_that.partsOfSpeech,_that.japanese,_that.exampleEn,_that.exampleJa,_that.audioUrl);case _:
  return null;

}
}

}

/// @nodoc


class _WordInfo implements WordInfo {
  const _WordInfo({required this.word, this.ipa = '', final  List<PartOfSpeech> partsOfSpeech = const <PartOfSpeech>[], this.japanese = '', this.exampleEn = '', this.exampleJa = '', this.audioUrl = ''}): _partsOfSpeech = partsOfSpeech;
  

@override final  String word;
@override@JsonKey() final  String ipa;
 final  List<PartOfSpeech> _partsOfSpeech;
@override@JsonKey() List<PartOfSpeech> get partsOfSpeech {
  if (_partsOfSpeech is EqualUnmodifiableListView) return _partsOfSpeech;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_partsOfSpeech);
}

@override@JsonKey() final  String japanese;
@override@JsonKey() final  String exampleEn;
@override@JsonKey() final  String exampleJa;
@override@JsonKey() final  String audioUrl;

/// Create a copy of WordInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordInfoCopyWith<_WordInfo> get copyWith => __$WordInfoCopyWithImpl<_WordInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordInfo&&(identical(other.word, word) || other.word == word)&&(identical(other.ipa, ipa) || other.ipa == ipa)&&const DeepCollectionEquality().equals(other._partsOfSpeech, _partsOfSpeech)&&(identical(other.japanese, japanese) || other.japanese == japanese)&&(identical(other.exampleEn, exampleEn) || other.exampleEn == exampleEn)&&(identical(other.exampleJa, exampleJa) || other.exampleJa == exampleJa)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl));
}


@override
int get hashCode => Object.hash(runtimeType,word,ipa,const DeepCollectionEquality().hash(_partsOfSpeech),japanese,exampleEn,exampleJa,audioUrl);

@override
String toString() {
  return 'WordInfo(word: $word, ipa: $ipa, partsOfSpeech: $partsOfSpeech, japanese: $japanese, exampleEn: $exampleEn, exampleJa: $exampleJa, audioUrl: $audioUrl)';
}


}

/// @nodoc
abstract mixin class _$WordInfoCopyWith<$Res> implements $WordInfoCopyWith<$Res> {
  factory _$WordInfoCopyWith(_WordInfo value, $Res Function(_WordInfo) _then) = __$WordInfoCopyWithImpl;
@override @useResult
$Res call({
 String word, String ipa, List<PartOfSpeech> partsOfSpeech, String japanese, String exampleEn, String exampleJa, String audioUrl
});




}
/// @nodoc
class __$WordInfoCopyWithImpl<$Res>
    implements _$WordInfoCopyWith<$Res> {
  __$WordInfoCopyWithImpl(this._self, this._then);

  final _WordInfo _self;
  final $Res Function(_WordInfo) _then;

/// Create a copy of WordInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = null,Object? ipa = null,Object? partsOfSpeech = null,Object? japanese = null,Object? exampleEn = null,Object? exampleJa = null,Object? audioUrl = null,}) {
  return _then(_WordInfo(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,ipa: null == ipa ? _self.ipa : ipa // ignore: cast_nullable_to_non_nullable
as String,partsOfSpeech: null == partsOfSpeech ? _self._partsOfSpeech : partsOfSpeech // ignore: cast_nullable_to_non_nullable
as List<PartOfSpeech>,japanese: null == japanese ? _self.japanese : japanese // ignore: cast_nullable_to_non_nullable
as String,exampleEn: null == exampleEn ? _self.exampleEn : exampleEn // ignore: cast_nullable_to_non_nullable
as String,exampleJa: null == exampleJa ? _self.exampleJa : exampleJa // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
