import 'dart:async';

import '../core/signals.dart';
import '../mixins/event_sink.dart';
import 'state.dart';

/// {@template signal}
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
/// Returns true if a value has been set regardless of the state.
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
/// Returns true if a error has been set regardless of the state.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.hasError); // false
/// s.value = AsyncState.error('error', null);
/// print(s.hasError); // true
/// ```
///
/// ### .isRefreshing
///
/// Returns true if the state is refreshing with a loading flag, has a value or error and is not the loading state.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isRefreshing); // false
/// s.value = AsyncState.error('error', null, isLoading: true);
/// print(s.isRefreshing); // true
/// s.value = AsyncData(1, isLoading: true);
/// print(s.isRefreshing); // true
/// ```
///
/// ### .isReloading
///
/// Returns true if the state is reloading with having a value or error, and is the loading state.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isReloading); // false
/// s.value = AsyncState.loading(data: 1);
/// print(s.isReloading); // true
/// s.value = AsyncState.loading(error: ('error', null));
/// print(s.isReloading); // true
/// ```
///
/// ### .requireValue
///
/// Force unwrap the value of the state and throw an error if it has an error or is null.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.requireValue); // 1
/// ```
///
/// ### .value
///
/// Return the current value if exists.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.value); // 1 or null
/// ```
///
/// ### .error
///
/// Return the current error if exists.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.error('error', null));
/// print(s.error); // 'error' or null
/// ```
///
/// ### .stackTrace
///
/// Return the current stack trace if exists.
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
class AsyncSignal<T> extends Signal<AsyncState<T>>
    with EventSinkSignalMixin<T> {
  /// A [Signal] that stores value in [AsyncState]
  AsyncSignal(
    super.value, {
    super.debugLabel,
    super.autoDispose,
  }) : _initialValue = value;
  final AsyncState<T> _initialValue;
  bool _initialized = false;
  Completer<bool> _completer = Completer<bool>();

  /// The future of the signal completer
  Future<T> get future async {
    value;
    await _completer.future;
    return value.requireValue;
  }

  /// Returns true if the signal is completed an error or data
  bool get isCompleted {
    value;
    return _completer.isCompleted;
  }

  /// Set the error with optional stackTrace to [AsyncError]
  void setError(Object error, [StackTrace? stackTrace]) {
    batch(() {
      value = AsyncState.error(error, stackTrace);
      if (_completer.isCompleted) _completer = Completer<bool>();
      _completer.complete(true);
    });
  }

  /// Set the value to [AsyncData]
  void setValue(T value) {
    batch(() {
      this.value = AsyncState.data(value);
      if (_completer.isCompleted) _completer = Completer<bool>();
      _completer.complete(true);
    });
  }

  /// Set the loading state to [AsyncLoading]
  void setLoading([AsyncState<T>? state]) {
    batch(() {
      value = state ?? AsyncState.loading();
      _completer = Completer<bool>();
    });
  }

  /// Reset the signal to the initial value
  void reset([AsyncState<T>? value]) {
    batch(() {
      this.value = value ?? _initialValue;
      _initialized = false;
      if (_completer.isCompleted) _completer = Completer<bool>();
    });
  }

  /// Initialize the signal
  void init() async {
    if (_initialized) return;
    _initialized = true;
  }

  /// Reload the future
  Future<void> reload() async {
    value = switch (value) {
      AsyncData<T> data => AsyncDataReloading<T>(data.value),
      AsyncError<T> err => AsyncErrorReloading<T>(err.error, err.stackTrace),
      AsyncLoading<T>() => AsyncLoading<T>(),
    };
  }

  /// Refresh the future
  @Deprecated("Use `reload` instead.")
  Future<void> refresh() async {
    value = switch (value) {
      AsyncData<T> data => AsyncDataRefreshing<T>(data.value),
      AsyncError<T> err => AsyncErrorRefreshing<T>(err.error, err.stackTrace),
      AsyncLoading<T>() => AsyncLoading<T>(),
    };
  }

  @override
  AsyncState<T> get value {
    init();
    return super.value;
  }

  /// Returns the value of the signal
  T get requireValue => super.value.requireValue;
}

/// {@template signal}
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
/// Returns true if a value has been set regardless of the state.
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
/// Returns true if a error has been set regardless of the state.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.hasError); // false
/// s.value = AsyncState.error('error', null);
/// print(s.hasError); // true
/// ```
///
/// ### .isRefreshing
///
/// Returns true if the state is refreshing with a loading flag, has a value or error and is not the loading state.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isRefreshing); // false
/// s.value = AsyncState.error('error', null, isLoading: true);
/// print(s.isRefreshing); // true
/// s.value = AsyncData(1, isLoading: true);
/// print(s.isRefreshing); // true
/// ```
///
/// ### .isReloading
///
/// Returns true if the state is reloading with having a value or error, and is the loading state.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isReloading); // false
/// s.value = AsyncState.loading(data: 1);
/// print(s.isReloading); // true
/// s.value = AsyncState.loading(error: ('error', null));
/// print(s.isReloading); // true
/// ```
///
/// ### .requireValue
///
/// Force unwrap the value of the state and throw an error if it has an error or is null.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.requireValue); // 1
/// ```
///
/// ### .value
///
/// Return the current value if exists.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.value); // 1 or null
/// ```
///
/// ### .error
///
/// Return the current error if exists.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.error('error', null));
/// print(s.error); // 'error' or null
/// ```
///
/// ### .stackTrace
///
/// Return the current stack trace if exists.
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
AsyncSignal<T> asyncSignal<T>(
  AsyncState<T> value, {
  String? debugLabel,
  bool autoDispose = false,
}) {
  return AsyncSignal<T>(
    value,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
  );
}
