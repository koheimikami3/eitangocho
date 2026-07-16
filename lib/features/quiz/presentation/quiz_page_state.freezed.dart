// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuizPageState {

 QuizPhase get phase;/// セッション開始時に学習済み単語をシャッフルしたスナップショット。
/// セッション中の learned 変更・編集・削除は進行に影響させない。
 List<Word> get questions; int get index; bool get revealed; int get okCount; List<Word> get forgotWords;
/// Create a copy of QuizPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizPageStateCopyWith<QuizPageState> get copyWith => _$QuizPageStateCopyWithImpl<QuizPageState>(this as QuizPageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizPageState&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.index, index) || other.index == index)&&(identical(other.revealed, revealed) || other.revealed == revealed)&&(identical(other.okCount, okCount) || other.okCount == okCount)&&const DeepCollectionEquality().equals(other.forgotWords, forgotWords));
}


@override
int get hashCode => Object.hash(runtimeType,phase,const DeepCollectionEquality().hash(questions),index,revealed,okCount,const DeepCollectionEquality().hash(forgotWords));

@override
String toString() {
  return 'QuizPageState(phase: $phase, questions: $questions, index: $index, revealed: $revealed, okCount: $okCount, forgotWords: $forgotWords)';
}


}

/// @nodoc
abstract mixin class $QuizPageStateCopyWith<$Res>  {
  factory $QuizPageStateCopyWith(QuizPageState value, $Res Function(QuizPageState) _then) = _$QuizPageStateCopyWithImpl;
@useResult
$Res call({
 QuizPhase phase, List<Word> questions, int index, bool revealed, int okCount, List<Word> forgotWords
});




}
/// @nodoc
class _$QuizPageStateCopyWithImpl<$Res>
    implements $QuizPageStateCopyWith<$Res> {
  _$QuizPageStateCopyWithImpl(this._self, this._then);

  final QuizPageState _self;
  final $Res Function(QuizPageState) _then;

/// Create a copy of QuizPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? questions = null,Object? index = null,Object? revealed = null,Object? okCount = null,Object? forgotWords = null,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as QuizPhase,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<Word>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,revealed: null == revealed ? _self.revealed : revealed // ignore: cast_nullable_to_non_nullable
as bool,okCount: null == okCount ? _self.okCount : okCount // ignore: cast_nullable_to_non_nullable
as int,forgotWords: null == forgotWords ? _self.forgotWords : forgotWords // ignore: cast_nullable_to_non_nullable
as List<Word>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuizPageState].
extension QuizPageStatePatterns on QuizPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuizPageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuizPageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuizPageState value)  $default,){
final _that = this;
switch (_that) {
case _QuizPageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuizPageState value)?  $default,){
final _that = this;
switch (_that) {
case _QuizPageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QuizPhase phase,  List<Word> questions,  int index,  bool revealed,  int okCount,  List<Word> forgotWords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuizPageState() when $default != null:
return $default(_that.phase,_that.questions,_that.index,_that.revealed,_that.okCount,_that.forgotWords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QuizPhase phase,  List<Word> questions,  int index,  bool revealed,  int okCount,  List<Word> forgotWords)  $default,) {final _that = this;
switch (_that) {
case _QuizPageState():
return $default(_that.phase,_that.questions,_that.index,_that.revealed,_that.okCount,_that.forgotWords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QuizPhase phase,  List<Word> questions,  int index,  bool revealed,  int okCount,  List<Word> forgotWords)?  $default,) {final _that = this;
switch (_that) {
case _QuizPageState() when $default != null:
return $default(_that.phase,_that.questions,_that.index,_that.revealed,_that.okCount,_that.forgotWords);case _:
  return null;

}
}

}

/// @nodoc


class _QuizPageState implements QuizPageState {
  const _QuizPageState({this.phase = QuizPhase.empty, final  List<Word> questions = const <Word>[], this.index = 0, this.revealed = false, this.okCount = 0, final  List<Word> forgotWords = const <Word>[]}): _questions = questions,_forgotWords = forgotWords;
  

@override@JsonKey() final  QuizPhase phase;
/// セッション開始時に学習済み単語をシャッフルしたスナップショット。
/// セッション中の learned 変更・編集・削除は進行に影響させない。
 final  List<Word> _questions;
/// セッション開始時に学習済み単語をシャッフルしたスナップショット。
/// セッション中の learned 変更・編集・削除は進行に影響させない。
@override@JsonKey() List<Word> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override@JsonKey() final  int index;
@override@JsonKey() final  bool revealed;
@override@JsonKey() final  int okCount;
 final  List<Word> _forgotWords;
@override@JsonKey() List<Word> get forgotWords {
  if (_forgotWords is EqualUnmodifiableListView) return _forgotWords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forgotWords);
}


/// Create a copy of QuizPageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizPageStateCopyWith<_QuizPageState> get copyWith => __$QuizPageStateCopyWithImpl<_QuizPageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizPageState&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.index, index) || other.index == index)&&(identical(other.revealed, revealed) || other.revealed == revealed)&&(identical(other.okCount, okCount) || other.okCount == okCount)&&const DeepCollectionEquality().equals(other._forgotWords, _forgotWords));
}


@override
int get hashCode => Object.hash(runtimeType,phase,const DeepCollectionEquality().hash(_questions),index,revealed,okCount,const DeepCollectionEquality().hash(_forgotWords));

@override
String toString() {
  return 'QuizPageState(phase: $phase, questions: $questions, index: $index, revealed: $revealed, okCount: $okCount, forgotWords: $forgotWords)';
}


}

/// @nodoc
abstract mixin class _$QuizPageStateCopyWith<$Res> implements $QuizPageStateCopyWith<$Res> {
  factory _$QuizPageStateCopyWith(_QuizPageState value, $Res Function(_QuizPageState) _then) = __$QuizPageStateCopyWithImpl;
@override @useResult
$Res call({
 QuizPhase phase, List<Word> questions, int index, bool revealed, int okCount, List<Word> forgotWords
});




}
/// @nodoc
class __$QuizPageStateCopyWithImpl<$Res>
    implements _$QuizPageStateCopyWith<$Res> {
  __$QuizPageStateCopyWithImpl(this._self, this._then);

  final _QuizPageState _self;
  final $Res Function(_QuizPageState) _then;

/// Create a copy of QuizPageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? questions = null,Object? index = null,Object? revealed = null,Object? okCount = null,Object? forgotWords = null,}) {
  return _then(_QuizPageState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as QuizPhase,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<Word>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,revealed: null == revealed ? _self.revealed : revealed // ignore: cast_nullable_to_non_nullable
as bool,okCount: null == okCount ? _self.okCount : okCount // ignore: cast_nullable_to_non_nullable
as int,forgotWords: null == forgotWords ? _self._forgotWords : forgotWords // ignore: cast_nullable_to_non_nullable
as List<Word>,
  ));
}


}

// dart format on
