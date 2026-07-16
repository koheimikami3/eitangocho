// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MainPageState {

 MainView get view; String get searchQuery;
/// Create a copy of MainPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MainPageStateCopyWith<MainPageState> get copyWith => _$MainPageStateCopyWithImpl<MainPageState>(this as MainPageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MainPageState&&(identical(other.view, view) || other.view == view)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,view,searchQuery);

@override
String toString() {
  return 'MainPageState(view: $view, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $MainPageStateCopyWith<$Res>  {
  factory $MainPageStateCopyWith(MainPageState value, $Res Function(MainPageState) _then) = _$MainPageStateCopyWithImpl;
@useResult
$Res call({
 MainView view, String searchQuery
});




}
/// @nodoc
class _$MainPageStateCopyWithImpl<$Res>
    implements $MainPageStateCopyWith<$Res> {
  _$MainPageStateCopyWithImpl(this._self, this._then);

  final MainPageState _self;
  final $Res Function(MainPageState) _then;

/// Create a copy of MainPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? view = null,Object? searchQuery = null,}) {
  return _then(_self.copyWith(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as MainView,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MainPageState].
extension MainPageStatePatterns on MainPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MainPageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MainPageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MainPageState value)  $default,){
final _that = this;
switch (_that) {
case _MainPageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MainPageState value)?  $default,){
final _that = this;
switch (_that) {
case _MainPageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MainView view,  String searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MainPageState() when $default != null:
return $default(_that.view,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MainView view,  String searchQuery)  $default,) {final _that = this;
switch (_that) {
case _MainPageState():
return $default(_that.view,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MainView view,  String searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _MainPageState() when $default != null:
return $default(_that.view,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _MainPageState implements MainPageState {
  const _MainPageState({this.view = MainView.allWords, this.searchQuery = ''});
  

@override@JsonKey() final  MainView view;
@override@JsonKey() final  String searchQuery;

/// Create a copy of MainPageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MainPageStateCopyWith<_MainPageState> get copyWith => __$MainPageStateCopyWithImpl<_MainPageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MainPageState&&(identical(other.view, view) || other.view == view)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,view,searchQuery);

@override
String toString() {
  return 'MainPageState(view: $view, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$MainPageStateCopyWith<$Res> implements $MainPageStateCopyWith<$Res> {
  factory _$MainPageStateCopyWith(_MainPageState value, $Res Function(_MainPageState) _then) = __$MainPageStateCopyWithImpl;
@override @useResult
$Res call({
 MainView view, String searchQuery
});




}
/// @nodoc
class __$MainPageStateCopyWithImpl<$Res>
    implements _$MainPageStateCopyWith<$Res> {
  __$MainPageStateCopyWithImpl(this._self, this._then);

  final _MainPageState _self;
  final $Res Function(_MainPageState) _then;

/// Create a copy of MainPageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? view = null,Object? searchQuery = null,}) {
  return _then(_MainPageState(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as MainView,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
