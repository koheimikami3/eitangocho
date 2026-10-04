// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_export.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WordExportFile {

 int get version;@UtcDateTimeConverter() DateTime get exportedAt; List<WordExportEntry> get words; List<WordDeletionEntry> get deletions;
/// Create a copy of WordExportFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordExportFileCopyWith<WordExportFile> get copyWith => _$WordExportFileCopyWithImpl<WordExportFile>(this as WordExportFile, _$identity);

  /// Serializes this WordExportFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordExportFile&&(identical(other.version, version) || other.version == version)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&const DeepCollectionEquality().equals(other.words, words)&&const DeepCollectionEquality().equals(other.deletions, deletions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,exportedAt,const DeepCollectionEquality().hash(words),const DeepCollectionEquality().hash(deletions));

@override
String toString() {
  return 'WordExportFile(version: $version, exportedAt: $exportedAt, words: $words, deletions: $deletions)';
}


}

/// @nodoc
abstract mixin class $WordExportFileCopyWith<$Res>  {
  factory $WordExportFileCopyWith(WordExportFile value, $Res Function(WordExportFile) _then) = _$WordExportFileCopyWithImpl;
@useResult
$Res call({
 int version,@UtcDateTimeConverter() DateTime exportedAt, List<WordExportEntry> words, List<WordDeletionEntry> deletions
});




}
/// @nodoc
class _$WordExportFileCopyWithImpl<$Res>
    implements $WordExportFileCopyWith<$Res> {
  _$WordExportFileCopyWithImpl(this._self, this._then);

  final WordExportFile _self;
  final $Res Function(WordExportFile) _then;

/// Create a copy of WordExportFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? exportedAt = null,Object? words = null,Object? deletions = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,words: null == words ? _self.words : words // ignore: cast_nullable_to_non_nullable
as List<WordExportEntry>,deletions: null == deletions ? _self.deletions : deletions // ignore: cast_nullable_to_non_nullable
as List<WordDeletionEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [WordExportFile].
extension WordExportFilePatterns on WordExportFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordExportFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordExportFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordExportFile value)  $default,){
final _that = this;
switch (_that) {
case _WordExportFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordExportFile value)?  $default,){
final _that = this;
switch (_that) {
case _WordExportFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version, @UtcDateTimeConverter()  DateTime exportedAt,  List<WordExportEntry> words,  List<WordDeletionEntry> deletions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordExportFile() when $default != null:
return $default(_that.version,_that.exportedAt,_that.words,_that.deletions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version, @UtcDateTimeConverter()  DateTime exportedAt,  List<WordExportEntry> words,  List<WordDeletionEntry> deletions)  $default,) {final _that = this;
switch (_that) {
case _WordExportFile():
return $default(_that.version,_that.exportedAt,_that.words,_that.deletions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version, @UtcDateTimeConverter()  DateTime exportedAt,  List<WordExportEntry> words,  List<WordDeletionEntry> deletions)?  $default,) {final _that = this;
switch (_that) {
case _WordExportFile() when $default != null:
return $default(_that.version,_that.exportedAt,_that.words,_that.deletions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordExportFile implements WordExportFile {
  const _WordExportFile({required this.version, @UtcDateTimeConverter() required this.exportedAt, required final  List<WordExportEntry> words, final  List<WordDeletionEntry> deletions = const <WordDeletionEntry>[]}): _words = words,_deletions = deletions;
  factory _WordExportFile.fromJson(Map<String, dynamic> json) => _$WordExportFileFromJson(json);

@override final  int version;
@override@UtcDateTimeConverter() final  DateTime exportedAt;
 final  List<WordExportEntry> _words;
@override List<WordExportEntry> get words {
  if (_words is EqualUnmodifiableListView) return _words;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_words);
}

 final  List<WordDeletionEntry> _deletions;
@override@JsonKey() List<WordDeletionEntry> get deletions {
  if (_deletions is EqualUnmodifiableListView) return _deletions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deletions);
}


/// Create a copy of WordExportFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordExportFileCopyWith<_WordExportFile> get copyWith => __$WordExportFileCopyWithImpl<_WordExportFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordExportFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordExportFile&&(identical(other.version, version) || other.version == version)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&const DeepCollectionEquality().equals(other._words, _words)&&const DeepCollectionEquality().equals(other._deletions, _deletions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,exportedAt,const DeepCollectionEquality().hash(_words),const DeepCollectionEquality().hash(_deletions));

@override
String toString() {
  return 'WordExportFile(version: $version, exportedAt: $exportedAt, words: $words, deletions: $deletions)';
}


}

/// @nodoc
abstract mixin class _$WordExportFileCopyWith<$Res> implements $WordExportFileCopyWith<$Res> {
  factory _$WordExportFileCopyWith(_WordExportFile value, $Res Function(_WordExportFile) _then) = __$WordExportFileCopyWithImpl;
@override @useResult
$Res call({
 int version,@UtcDateTimeConverter() DateTime exportedAt, List<WordExportEntry> words, List<WordDeletionEntry> deletions
});




}
/// @nodoc
class __$WordExportFileCopyWithImpl<$Res>
    implements _$WordExportFileCopyWith<$Res> {
  __$WordExportFileCopyWithImpl(this._self, this._then);

  final _WordExportFile _self;
  final $Res Function(_WordExportFile) _then;

/// Create a copy of WordExportFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? exportedAt = null,Object? words = null,Object? deletions = null,}) {
  return _then(_WordExportFile(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,words: null == words ? _self._words : words // ignore: cast_nullable_to_non_nullable
as List<WordExportEntry>,deletions: null == deletions ? _self._deletions : deletions // ignore: cast_nullable_to_non_nullable
as List<WordDeletionEntry>,
  ));
}


}


/// @nodoc
mixin _$WordDeletionEntry {

 String get word;@UtcDateTimeConverter() DateTime get deletedAt;
/// Create a copy of WordDeletionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordDeletionEntryCopyWith<WordDeletionEntry> get copyWith => _$WordDeletionEntryCopyWithImpl<WordDeletionEntry>(this as WordDeletionEntry, _$identity);

  /// Serializes this WordDeletionEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordDeletionEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,deletedAt);

@override
String toString() {
  return 'WordDeletionEntry(word: $word, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $WordDeletionEntryCopyWith<$Res>  {
  factory $WordDeletionEntryCopyWith(WordDeletionEntry value, $Res Function(WordDeletionEntry) _then) = _$WordDeletionEntryCopyWithImpl;
@useResult
$Res call({
 String word,@UtcDateTimeConverter() DateTime deletedAt
});




}
/// @nodoc
class _$WordDeletionEntryCopyWithImpl<$Res>
    implements $WordDeletionEntryCopyWith<$Res> {
  _$WordDeletionEntryCopyWithImpl(this._self, this._then);

  final WordDeletionEntry _self;
  final $Res Function(WordDeletionEntry) _then;

/// Create a copy of WordDeletionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = null,Object? deletedAt = null,}) {
  return _then(_self.copyWith(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,deletedAt: null == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WordDeletionEntry].
extension WordDeletionEntryPatterns on WordDeletionEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordDeletionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordDeletionEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordDeletionEntry value)  $default,){
final _that = this;
switch (_that) {
case _WordDeletionEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordDeletionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WordDeletionEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String word, @UtcDateTimeConverter()  DateTime deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordDeletionEntry() when $default != null:
return $default(_that.word,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String word, @UtcDateTimeConverter()  DateTime deletedAt)  $default,) {final _that = this;
switch (_that) {
case _WordDeletionEntry():
return $default(_that.word,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String word, @UtcDateTimeConverter()  DateTime deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _WordDeletionEntry() when $default != null:
return $default(_that.word,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordDeletionEntry implements WordDeletionEntry {
  const _WordDeletionEntry({required this.word, @UtcDateTimeConverter() required this.deletedAt});
  factory _WordDeletionEntry.fromJson(Map<String, dynamic> json) => _$WordDeletionEntryFromJson(json);

@override final  String word;
@override@UtcDateTimeConverter() final  DateTime deletedAt;

/// Create a copy of WordDeletionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordDeletionEntryCopyWith<_WordDeletionEntry> get copyWith => __$WordDeletionEntryCopyWithImpl<_WordDeletionEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordDeletionEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordDeletionEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,deletedAt);

@override
String toString() {
  return 'WordDeletionEntry(word: $word, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$WordDeletionEntryCopyWith<$Res> implements $WordDeletionEntryCopyWith<$Res> {
  factory _$WordDeletionEntryCopyWith(_WordDeletionEntry value, $Res Function(_WordDeletionEntry) _then) = __$WordDeletionEntryCopyWithImpl;
@override @useResult
$Res call({
 String word,@UtcDateTimeConverter() DateTime deletedAt
});




}
/// @nodoc
class __$WordDeletionEntryCopyWithImpl<$Res>
    implements _$WordDeletionEntryCopyWith<$Res> {
  __$WordDeletionEntryCopyWithImpl(this._self, this._then);

  final _WordDeletionEntry _self;
  final $Res Function(_WordDeletionEntry) _then;

/// Create a copy of WordDeletionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = null,Object? deletedAt = null,}) {
  return _then(_WordDeletionEntry(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,deletedAt: null == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$WordExportEntry {

 String get word;@JsonKey(name: 'japanese') String get meaning; String get ipa; List<String> get partsOfSpeech; String get exampleEn;@JsonKey(name: 'exampleJa') String get exampleTranslation;/// 訳の言語(words.translation_language と同じ値)。v2.5.0 より前の版が
/// 書いたファイルには無いので、無ければ日本語として読む。未知の値も
/// そのまま持ち回す(新しい版が足した言語を古い版で消さないため)。
 String get translationLanguage; String get audioUrl; bool get isLearned;@NullableUtcDateTimeConverter() DateTime? get lastReviewedAt; int get correctCount;@NullableUtcDateTimeConverter() DateTime? get createdAt;@NullableUtcDateTimeConverter() DateTime? get updatedAt;
/// Create a copy of WordExportEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordExportEntryCopyWith<WordExportEntry> get copyWith => _$WordExportEntryCopyWithImpl<WordExportEntry>(this as WordExportEntry, _$identity);

  /// Serializes this WordExportEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordExportEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.ipa, ipa) || other.ipa == ipa)&&const DeepCollectionEquality().equals(other.partsOfSpeech, partsOfSpeech)&&(identical(other.exampleEn, exampleEn) || other.exampleEn == exampleEn)&&(identical(other.exampleTranslation, exampleTranslation) || other.exampleTranslation == exampleTranslation)&&(identical(other.translationLanguage, translationLanguage) || other.translationLanguage == translationLanguage)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.isLearned, isLearned) || other.isLearned == isLearned)&&(identical(other.lastReviewedAt, lastReviewedAt) || other.lastReviewedAt == lastReviewedAt)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,meaning,ipa,const DeepCollectionEquality().hash(partsOfSpeech),exampleEn,exampleTranslation,translationLanguage,audioUrl,isLearned,lastReviewedAt,correctCount,createdAt,updatedAt);

@override
String toString() {
  return 'WordExportEntry(word: $word, meaning: $meaning, ipa: $ipa, partsOfSpeech: $partsOfSpeech, exampleEn: $exampleEn, exampleTranslation: $exampleTranslation, translationLanguage: $translationLanguage, audioUrl: $audioUrl, isLearned: $isLearned, lastReviewedAt: $lastReviewedAt, correctCount: $correctCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WordExportEntryCopyWith<$Res>  {
  factory $WordExportEntryCopyWith(WordExportEntry value, $Res Function(WordExportEntry) _then) = _$WordExportEntryCopyWithImpl;
@useResult
$Res call({
 String word,@JsonKey(name: 'japanese') String meaning, String ipa, List<String> partsOfSpeech, String exampleEn,@JsonKey(name: 'exampleJa') String exampleTranslation, String translationLanguage, String audioUrl, bool isLearned,@NullableUtcDateTimeConverter() DateTime? lastReviewedAt, int correctCount,@NullableUtcDateTimeConverter() DateTime? createdAt,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$WordExportEntryCopyWithImpl<$Res>
    implements $WordExportEntryCopyWith<$Res> {
  _$WordExportEntryCopyWithImpl(this._self, this._then);

  final WordExportEntry _self;
  final $Res Function(WordExportEntry) _then;

/// Create a copy of WordExportEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = null,Object? meaning = null,Object? ipa = null,Object? partsOfSpeech = null,Object? exampleEn = null,Object? exampleTranslation = null,Object? translationLanguage = null,Object? audioUrl = null,Object? isLearned = null,Object? lastReviewedAt = freezed,Object? correctCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,ipa: null == ipa ? _self.ipa : ipa // ignore: cast_nullable_to_non_nullable
as String,partsOfSpeech: null == partsOfSpeech ? _self.partsOfSpeech : partsOfSpeech // ignore: cast_nullable_to_non_nullable
as List<String>,exampleEn: null == exampleEn ? _self.exampleEn : exampleEn // ignore: cast_nullable_to_non_nullable
as String,exampleTranslation: null == exampleTranslation ? _self.exampleTranslation : exampleTranslation // ignore: cast_nullable_to_non_nullable
as String,translationLanguage: null == translationLanguage ? _self.translationLanguage : translationLanguage // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,isLearned: null == isLearned ? _self.isLearned : isLearned // ignore: cast_nullable_to_non_nullable
as bool,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordExportEntry].
extension WordExportEntryPatterns on WordExportEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordExportEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordExportEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordExportEntry value)  $default,){
final _that = this;
switch (_that) {
case _WordExportEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordExportEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WordExportEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String word, @JsonKey(name: 'japanese')  String meaning,  String ipa,  List<String> partsOfSpeech,  String exampleEn, @JsonKey(name: 'exampleJa')  String exampleTranslation,  String translationLanguage,  String audioUrl,  bool isLearned, @NullableUtcDateTimeConverter()  DateTime? lastReviewedAt,  int correctCount, @NullableUtcDateTimeConverter()  DateTime? createdAt, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordExportEntry() when $default != null:
return $default(_that.word,_that.meaning,_that.ipa,_that.partsOfSpeech,_that.exampleEn,_that.exampleTranslation,_that.translationLanguage,_that.audioUrl,_that.isLearned,_that.lastReviewedAt,_that.correctCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String word, @JsonKey(name: 'japanese')  String meaning,  String ipa,  List<String> partsOfSpeech,  String exampleEn, @JsonKey(name: 'exampleJa')  String exampleTranslation,  String translationLanguage,  String audioUrl,  bool isLearned, @NullableUtcDateTimeConverter()  DateTime? lastReviewedAt,  int correctCount, @NullableUtcDateTimeConverter()  DateTime? createdAt, @NullableUtcDateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WordExportEntry():
return $default(_that.word,_that.meaning,_that.ipa,_that.partsOfSpeech,_that.exampleEn,_that.exampleTranslation,_that.translationLanguage,_that.audioUrl,_that.isLearned,_that.lastReviewedAt,_that.correctCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String word, @JsonKey(name: 'japanese')  String meaning,  String ipa,  List<String> partsOfSpeech,  String exampleEn, @JsonKey(name: 'exampleJa')  String exampleTranslation,  String translationLanguage,  String audioUrl,  bool isLearned, @NullableUtcDateTimeConverter()  DateTime? lastReviewedAt,  int correctCount, @NullableUtcDateTimeConverter()  DateTime? createdAt, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WordExportEntry() when $default != null:
return $default(_that.word,_that.meaning,_that.ipa,_that.partsOfSpeech,_that.exampleEn,_that.exampleTranslation,_that.translationLanguage,_that.audioUrl,_that.isLearned,_that.lastReviewedAt,_that.correctCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WordExportEntry implements WordExportEntry {
  const _WordExportEntry({required this.word, @JsonKey(name: 'japanese') required this.meaning, this.ipa = '', final  List<String> partsOfSpeech = const <String>[], this.exampleEn = '', @JsonKey(name: 'exampleJa') this.exampleTranslation = '', this.translationLanguage = 'ja', this.audioUrl = '', this.isLearned = false, @NullableUtcDateTimeConverter() this.lastReviewedAt, this.correctCount = 0, @NullableUtcDateTimeConverter() this.createdAt, @NullableUtcDateTimeConverter() this.updatedAt}): _partsOfSpeech = partsOfSpeech;
  factory _WordExportEntry.fromJson(Map<String, dynamic> json) => _$WordExportEntryFromJson(json);

@override final  String word;
@override@JsonKey(name: 'japanese') final  String meaning;
@override@JsonKey() final  String ipa;
 final  List<String> _partsOfSpeech;
@override@JsonKey() List<String> get partsOfSpeech {
  if (_partsOfSpeech is EqualUnmodifiableListView) return _partsOfSpeech;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_partsOfSpeech);
}

@override@JsonKey() final  String exampleEn;
@override@JsonKey(name: 'exampleJa') final  String exampleTranslation;
/// 訳の言語(words.translation_language と同じ値)。v2.5.0 より前の版が
/// 書いたファイルには無いので、無ければ日本語として読む。未知の値も
/// そのまま持ち回す(新しい版が足した言語を古い版で消さないため)。
@override@JsonKey() final  String translationLanguage;
@override@JsonKey() final  String audioUrl;
@override@JsonKey() final  bool isLearned;
@override@NullableUtcDateTimeConverter() final  DateTime? lastReviewedAt;
@override@JsonKey() final  int correctCount;
@override@NullableUtcDateTimeConverter() final  DateTime? createdAt;
@override@NullableUtcDateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of WordExportEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordExportEntryCopyWith<_WordExportEntry> get copyWith => __$WordExportEntryCopyWithImpl<_WordExportEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WordExportEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordExportEntry&&(identical(other.word, word) || other.word == word)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.ipa, ipa) || other.ipa == ipa)&&const DeepCollectionEquality().equals(other._partsOfSpeech, _partsOfSpeech)&&(identical(other.exampleEn, exampleEn) || other.exampleEn == exampleEn)&&(identical(other.exampleTranslation, exampleTranslation) || other.exampleTranslation == exampleTranslation)&&(identical(other.translationLanguage, translationLanguage) || other.translationLanguage == translationLanguage)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.isLearned, isLearned) || other.isLearned == isLearned)&&(identical(other.lastReviewedAt, lastReviewedAt) || other.lastReviewedAt == lastReviewedAt)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,meaning,ipa,const DeepCollectionEquality().hash(_partsOfSpeech),exampleEn,exampleTranslation,translationLanguage,audioUrl,isLearned,lastReviewedAt,correctCount,createdAt,updatedAt);

@override
String toString() {
  return 'WordExportEntry(word: $word, meaning: $meaning, ipa: $ipa, partsOfSpeech: $partsOfSpeech, exampleEn: $exampleEn, exampleTranslation: $exampleTranslation, translationLanguage: $translationLanguage, audioUrl: $audioUrl, isLearned: $isLearned, lastReviewedAt: $lastReviewedAt, correctCount: $correctCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WordExportEntryCopyWith<$Res> implements $WordExportEntryCopyWith<$Res> {
  factory _$WordExportEntryCopyWith(_WordExportEntry value, $Res Function(_WordExportEntry) _then) = __$WordExportEntryCopyWithImpl;
@override @useResult
$Res call({
 String word,@JsonKey(name: 'japanese') String meaning, String ipa, List<String> partsOfSpeech, String exampleEn,@JsonKey(name: 'exampleJa') String exampleTranslation, String translationLanguage, String audioUrl, bool isLearned,@NullableUtcDateTimeConverter() DateTime? lastReviewedAt, int correctCount,@NullableUtcDateTimeConverter() DateTime? createdAt,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$WordExportEntryCopyWithImpl<$Res>
    implements _$WordExportEntryCopyWith<$Res> {
  __$WordExportEntryCopyWithImpl(this._self, this._then);

  final _WordExportEntry _self;
  final $Res Function(_WordExportEntry) _then;

/// Create a copy of WordExportEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = null,Object? meaning = null,Object? ipa = null,Object? partsOfSpeech = null,Object? exampleEn = null,Object? exampleTranslation = null,Object? translationLanguage = null,Object? audioUrl = null,Object? isLearned = null,Object? lastReviewedAt = freezed,Object? correctCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_WordExportEntry(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,ipa: null == ipa ? _self.ipa : ipa // ignore: cast_nullable_to_non_nullable
as String,partsOfSpeech: null == partsOfSpeech ? _self._partsOfSpeech : partsOfSpeech // ignore: cast_nullable_to_non_nullable
as List<String>,exampleEn: null == exampleEn ? _self.exampleEn : exampleEn // ignore: cast_nullable_to_non_nullable
as String,exampleTranslation: null == exampleTranslation ? _self.exampleTranslation : exampleTranslation // ignore: cast_nullable_to_non_nullable
as String,translationLanguage: null == translationLanguage ? _self.translationLanguage : translationLanguage // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,isLearned: null == isLearned ? _self.isLearned : isLearned // ignore: cast_nullable_to_non_nullable
as bool,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
