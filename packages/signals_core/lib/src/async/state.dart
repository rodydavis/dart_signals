/// Error builder for [AsyncState]
///
/// The `Function` below stands for one of two types:
/// - (dynamic) -> FutureOr
/// - (dynamic, StackTrace) -> FutureOr
typedef AsyncErrorBuilder<E> = Function;

/// Value builder for [AsyncState]
typedef AsyncDataBuilder<E, T> = E Function(
  T value,
);

/// Generic builder for [AsyncState]
typedef AsyncStateBuilder<E> = E Function();

/// {@template state}
/// `AsyncState` is class commonly used with Future/Stream signals to represent the states the signal can be in.
///
/// ## AsyncSignal
///
/// `AsyncState` is the default state if you want to create a `AsyncSignal` directly:
///
/// ```dart
/// final s = asyncSignal(AsyncState.data(1));
/// s.value = AsyncState.loading(); // or AsyncLoading();
/// s.value = AsyncState.error('Error', null); // or AsyncError();
/// ```
///
/// ## AsyncState
///
/// `AsyncState` is a sealed union made up of `AsyncLoading`, `AsyncData` and `AsyncError`.
///
/// ### .future
///
/// Sometimes you need to await a signal value in a async function until a value is completed and in this case use the .future getter.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// s.value = AsyncState.data(1);
/// await s.future; // Waits until data or error is set
/// ```
///
/// ### .isCompleted
///
/// Returns true if the future has completed with an error or value:
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// s.value = AsyncState.data(1);
/// print(s.isCompleted); // true
/// ```
///
/// ### .hasValue
///
/// Returns true if the state has a value - `AsyncData`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.hasValue); // false
/// s.value = AsyncState.data(1);
/// print(s.hasValue); // true
/// ```
///
/// ### .hasError
///
/// Returns true if the state has a error - `AsyncError`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.hasError); // false
/// s.value = AsyncState.error('error');
/// print(s.hasError); // true
/// ```
///
/// ### .isRefreshing
///
/// Returns true if the state is refreshing - `AsyncDataRefreshing` or `AsyncErrorRefreshing`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isRefreshing); // false
/// s.value = AsyncState.errorRefreshing('error');
/// print(s.isRefreshing); // true
/// s.value = AsyncState.dataRefreshing(1);
/// print(s.isRefreshing); // true
/// ```
///
/// ### .isReloading
///
/// Returns true if the state is refreshing - `AsyncDataReloading` or `AsyncErrorReloading`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isReloading); // false
/// s.value = AsyncState.dataReloading(1);
/// print(s.isReloading); // true
/// s.value = AsyncState.errorReloading('error');
/// print(s.isReloading); // true
/// ```
///
/// ### .requireValue
///
/// Force unwrap the value of the state
/// and throw an error if it has an error or is null - `AsyncData`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.requireValue); // 1
/// ```
///
/// ### .value
///
/// Return the current value if exists - `AsyncData`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.value); // 1 or null
/// ```
///
/// ### .error
///
/// Return the current error if exists - `AsyncError`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.error('error'));
/// print(s.error); // 'error' or null
/// ```
///
/// ### .stackTrace
///
/// Return the current stack trace if exists - `AsyncError`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.error('error', StackTrace(...)));
/// print(s.stackTrace); // StackTrace(...) or null
/// ```
///
/// ### .map
///
/// If you want to handle the states of the signal `map` will enforce all branching.
///
/// ```dart
/// final signal = asyncSignal<int>(AsyncState.data(1));
/// signal.value.map(
///  data: (value) => 'Value: $value',
///  error: (error, stackTrace) => 'Error: $error',
///  loading: () => 'Loading...',
/// );
/// ```
///
/// ### .maybeMap
///
/// If you want to handle some of the states of the signal `maybeMap` will provide a default and optional overrides.
///
/// ```dart
/// final signal = asyncSignal<int>(AsyncState.data(1));
/// signal.value.maybeMap(
///  data: (value) => 'Value: $value',
///  orElse: () => 'Loading...',
/// );
/// ```
///
/// ### Pattern Matching
///
/// Instead of `map` and `maybeMap` it is also possible to use [dart switch expressions](https://dart.dev/language/patterns) to handle the branching.
///
/// ```dart
/// final signal = asyncSignal<int>(AsyncState.data(1));
/// final value = switch (signal.value) {
///     AsyncData<int> data => 'value: ${data.value}',
///     AsyncError<int> error => 'error: ${error.error}',
///     AsyncLoading<int>() => 'loading',
/// };
/// ```
/// @link https://dartsignals.dev/async/state
/// {@endtemplate}
sealed class AsyncState<T> {
  const AsyncState();

  /// Create a state with a value that is reloading
  factory AsyncState.dataReloading(T data) {
    return AsyncDataReloading<T>(data);
  }

  /// Create a state with a value that is refreshing
  @Deprecated("Use `AsyncState.dataReloading` instead.")
  factory AsyncState.dataRefreshing(T data) {
    return AsyncDataRefreshing<T>(data);
  }

  /// Create a state with a value
  factory AsyncState.data(T data) {
    return AsyncData<T>(data);
  }

  /// Create a state with an error that is reloading
  factory AsyncState.errorReloading(Object error, [StackTrace? stackTrace]) {
    return AsyncErrorReloading<T>(error, stackTrace ?? StackTrace.current);
  }

  /// Create a state with an error that is refreshing
  @Deprecated("Use `AsyncState.errorReloading` instead.")
  factory AsyncState.errorRefreshing(Object error, [StackTrace? stackTrace]) {
    return AsyncErrorRefreshing<T>(error, stackTrace ?? StackTrace.current);
  }

  /// Create a state with an error
  factory AsyncState.error(Object error, [StackTrace? stackTrace]) {
    return AsyncError<T>(error, stackTrace ?? StackTrace.current);
  }

  /// Create a loading state
  factory AsyncState.loading() {
    return AsyncLoading<T>();
  }

  /// Returns true if the state has a value
  bool get hasValue;

  /// Returns true if the state has an error
  bool get hasError;

  /// Check if the state is a loading state
  bool get isLoading;

  /// Returns true if the state is refreshing with a loading flag,
  ///  has a value or error and is not the loading state
  @Deprecated("Use `isReloading` instead.")
  bool get isRefreshing;

  /// Returns true if the state is reloading with having a value or error,
  /// and is the loading state
  bool get isReloading;

  /// Force unwrap the value of the state.
  ///
  /// This will throw an error if the state does not have a value.
  T get requireValue;

  /// Returns the value of the state.
  T? get value;

  /// Returns the error of the state.
  Object? get error;

  /// Returns the stack trace of the state.
  StackTrace? get stackTrace;

  /// Map the state to a value.
  ///
  /// ```dart
  /// final signal = StreamSignal<int>();
  /// signal.value.map(
  ///  data: (value) => 'Value: $value',
  ///  error: (error, stackTrace) => 'Error: $error',
  ///  loading: () => 'Loading...',
  /// );
  /// ```
  ///
  /// The error `Function` below can be one of two types:
  /// - (dynamic) -> FutureOr
  /// - (dynamic, StackTrace) -> FutureOr
  E map<E>({
    required AsyncDataBuilder<E, T> data,
    required AsyncErrorBuilder<E> error,
    required AsyncStateBuilder<E> loading,
    AsyncStateBuilder<E>? reloading,
    AsyncStateBuilder<E>? refreshing,
  }) {
    if (isRefreshing) if (refreshing != null) return refreshing();
    if (isReloading) if (reloading != null) return reloading();
    if (hasValue) return data(value as T);
    if (hasError) {
      if (error is Function(dynamic, dynamic)) {
        return error(this.error, stackTrace);
      } else if (error is Function(dynamic)) {
        return error(this.error);
      } else {
        return error();
      }
    }
    return loading();
  }

  /// Map the state to a value with optional or else.
  ///
  /// ```dart
  /// final signal = StreamSignal<int>();
  /// signal.value.maybeMap(
  ///  data: (value) => 'Value: $value',
  ///  orElse: () => 'Loading...',
  /// );
  /// ```
  ///
  /// The error `Function` below can be one of two types:
  /// - (dynamic) -> FutureOr
  /// - (dynamic, StackTrace) -> FutureOr
  E maybeMap<E>({
    AsyncDataBuilder<E, T>? data,
    AsyncErrorBuilder<E>? error,
    AsyncStateBuilder<E>? loading,
    AsyncStateBuilder<E>? reloading,
    AsyncStateBuilder<E>? refreshing,
    required AsyncStateBuilder<E> orElse,
  }) {
    if (isRefreshing) if (refreshing != null) return refreshing();
    if (isReloading) if (reloading != null) return reloading();
    if (hasValue) if (data != null) return data(value as T);
    if (hasError) {
      if (error != null) {
        if (error is Function(Object, StackTrace?)) {
          return error(this.error as Object, stackTrace);
        } else if (error is Function(Object)) {
          return error(this.error as Object);
        } else {
          return error();
        }
      }
    }
    if (isLoading) if (loading != null) return loading();
    return orElse();
  }

  @override
  bool operator ==(covariant AsyncState<T> other);

  @override
  int get hashCode;
}

/// A loading state with a value. Signals the query conditions that led to the data
/// has changed and is being reloaded.
class AsyncDataReloading<T> extends AsyncData<T> implements AsyncLoading<T> {
  /// Create a state with a value that is reloading
  const AsyncDataReloading(super.data);

  @override
  bool get isLoading => true;

  @override
  bool get isReloading => true;

  @override
  // ignore: hash_and_equals
  bool operator ==(covariant AsyncState other) {
    return other is AsyncDataReloading<T> && other.value == value;
  }
}

/// A loading state with a value. Signals the query conditions that led to the data
/// has remained the same and is being refreshed
@Deprecated("Use `AsyncDataReloading` instead.")
class AsyncDataRefreshing<T> extends AsyncData<T> implements AsyncLoading<T> {
  /// Create a state with a value that is refreshing
  const AsyncDataRefreshing(super.data);

  @override
  bool get isLoading => true;

  @override
  @Deprecated("Use `isReloading` instead.")
  bool get isRefreshing => true;

  @override
  // ignore: hash_and_equals
  bool operator ==(covariant AsyncState other) {
    return other is AsyncDataRefreshing<T> && other.value == value;
  }
}

/// State for an [AsyncState] with a value
class AsyncData<T> extends AsyncState<T> {
  /// State for an [AsyncState] with a value
  const AsyncData(T data) : value = data;

  @override
  bool get hasValue => true;

  @override
  bool get hasError => false;

  @override
  final T value;

  @override
  bool get isLoading => false;

  @override
  @Deprecated("Use `isReloading` instead.")
  bool get isRefreshing => false;

  @override
  bool get isReloading => false;

  @override
  T get requireValue => value;

  @override
  Object? get error => null;

  @override
  StackTrace? get stackTrace => null;

  @override
  bool operator ==(covariant AsyncState other) {
    if (other is AsyncData<T>) {
      return other.value == value;
    }
    return false;
  }

  @override
  int get hashCode =>
      value.hashCode ^
      isLoading.hashCode ^
      isRefreshing.hashCode ^
      isReloading.hashCode;
}

/// A loading state with an error. Signal the query conditions that led to the error
/// has changed and is being reloaded.
class AsyncErrorReloading<T> extends AsyncError<T> implements AsyncLoading<T> {
  /// Create a state with an error that is reloading
  const AsyncErrorReloading(super.error, super.stackTrace);

  @override
  bool get isLoading => true;

  @override
  bool get isReloading => true;

  @override
  // ignore: hash_and_equals
  bool operator ==(covariant AsyncState other) {
    return other is AsyncErrorReloading<T> &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }
}

/// A loading state with an error. Signal the query conditions that led to the error
/// has remained the same and is being refreshed.
@Deprecated("Use `AsyncErrorReloading` instead.")
class AsyncErrorRefreshing<T> extends AsyncError<T> implements AsyncLoading<T> {
  /// Create a state with an error that is refreshing
  const AsyncErrorRefreshing(super.error, super.stackTrace);

  @override
  bool get isLoading => true;

  @override
  @Deprecated("Use `isReloading` instead.")
  bool get isRefreshing => true;

  @override
  // ignore: hash_and_equals
  bool operator ==(covariant AsyncState other) {
    return other is AsyncErrorRefreshing<T> &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }
}

/// State for an [AsyncState] with an error
class AsyncError<T> extends AsyncState<T> {
  /// State for an [AsyncState] with an error
  const AsyncError(this.error, this.stackTrace);

  @override
  bool get hasValue => false;

  @override
  bool get hasError => true;

  @override
  T? get value => null;

  @override
  bool get isLoading => false;

  @override
  @Deprecated("Use `isReloading` instead.")
  bool get isRefreshing => false;

  @override
  bool get isReloading => false;

  @override
  T get requireValue =>
      throw UnsupportedError('Error state does not have a value');

  @override
  final Object error;

  @override
  final StackTrace stackTrace;

  @override
  bool operator ==(covariant AsyncState other) {
    return other is AsyncError<T> &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }

  @override
  int get hashCode =>
      error.hashCode ^
      stackTrace.hashCode ^
      isLoading.hashCode ^
      isRefreshing.hashCode ^
      isReloading.hashCode;
}

/// State for an [AsyncState] with a loading state
class AsyncLoading<T> extends AsyncState<T> {
  /// State for an [AsyncState] with a loading state
  const AsyncLoading();

  @override
  bool get hasValue => false;

  @override
  bool get hasError => false;

  @override
  T? get value => null;

  @override
  bool get isLoading => true;

  @override
  @Deprecated("Use `isReloading` instead.")
  bool get isRefreshing => false;

  @override
  bool get isReloading => false;

  @override
  T get requireValue =>
      throw UnsupportedError('Loading state does not have a value');

  @override
  Object? get error => null;

  @override
  StackTrace? get stackTrace => null;

  @override
  bool operator ==(covariant AsyncState other) {
    return other is AsyncLoading;
  }

  @override
  int get hashCode => 0;
}
