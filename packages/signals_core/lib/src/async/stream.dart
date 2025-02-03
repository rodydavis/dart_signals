import 'dart:async';

import '../core/signals.dart';
import 'signal.dart';
import 'state.dart';

/// {@template stream}
/// Stream signals can be created by extension or method.
///
/// ### streamSignal
///
/// ```dart
/// final stream = () async* {
///     yield 1;
/// };
/// final s = streamSignal(() => stream);
/// ```
///
/// ### toSignal()
///
/// ```dart
/// final stream = () async* {
///     yield 1;
/// };
/// final s = stream.toSignal();
/// ```
///
/// ## .value, .peek()
///
/// Returns [`AsyncState<T>`](/dart/async/state) for the value and can handle the various states.
///
/// The `value` getter returns the value of the stream if it completed successfully.
///
/// > .peek() can also be used to not subscribe in an effect
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// final value = s.value.value; // 1 or null
/// ```
///
/// ## .reset()
///
/// The `reset` method resets the stream to its initial state to recall on the next evaluation.
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// s.reset();
/// ```
///
/// ## .refresh()
///
/// Refresh the stream value by setting `isLoading` to true, but maintain the current state (AsyncData, AsyncLoading, AsyncError).
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// s.refresh();
/// print(s.value.isLoading); // true
/// ```
///
/// ## .reload()
///
/// Reload the stream value by setting the state to `AsyncLoading` and pass in the value or error as data.
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// s.reload();
/// print(s.value is AsyncLoading); // true
/// ```
///
/// ## Dependencies
///
/// By default the callback will be called once and the stream will be cached unless a signal is read in the callback.
///
/// ```dart
/// final count = signal(0);
/// final s = streamSignal(() async* {
///     final value = count();
///     yield value;
/// });
///
/// await s.future; // 0
/// count.value = 1;
/// await s.future; // 1
/// ```
///
/// If there are signals that need to be tracked across an async gap then use the `dependencies` when creating the `streamSignal` to [`reset`](#.reset()) every time any signal in the dependency array changes.
///
/// ```dart
/// final count = signal(0);
/// final s = streamSignal(
///     () async* {
///         final value = count();
///         yield value;
///     },
///     dependencies: [count],
/// );
/// s.value; // state with count 0
/// count.value = 1; // resets the future
/// s.value; // state with count 1
/// ```
/// @link https://dartsignals.dev/async/stream
/// {@endtemplate}
class StreamSignal<T> extends AsyncSignal<T> {
  late final Computed<Stream<T>> _stream;
  bool _fetching = false;
  StreamSubscription<T>? _subscription;
  final void Function()? _onDone;
  bool _done = false;
  EffectCleanup? _cleanup;

  /// Check if the signal is done
  bool get isDone => _done;

  /// Cancel the subscription on error
  final bool? cancelOnError;

  /// List of dependencies to recompute the stream
  final List<ReadonlySignal<dynamic>> dependencies;

  /// First value of the stream
  Future<T> get last => _stream.value.last;

  /// Last value of the stream
  Future<T> get first => _stream.value.first;

  /// {@template stream}
  /// Stream signals can be created by extension or method.
  ///
  /// ### streamSignal
  ///
  /// ```dart
  /// final stream = () async* {
  ///     yield 1;
  /// };
  /// final s = streamSignal(() => stream);
  /// ```
  ///
  /// ### toSignal()
  ///
  /// ```dart
  /// final stream = () async* {
  ///     yield 1;
  /// };
  /// final s = stream.toSignal();
  /// ```
  ///
  /// ## .value, .peek()
  ///
  /// Returns [`AsyncState<T>`](/dart/async/state) for the value and can handle the various states.
  ///
  /// The `value` getter returns the value of the stream if it completed successfully.
  ///
  /// > .peek() can also be used to not subscribe in an effect
  ///
  /// ```dart
  /// final stream = (int value) async* {
  ///     yield value;
  /// };
  /// final s = streamSignal(() => stream);
  /// final value = s.value.value; // 1 or null
  /// ```
  ///
  /// ## .reset()
  ///
  /// The `reset` method resets the stream to its initial state to recall on the next evaluation.
  ///
  /// ```dart
  /// final stream = (int value) async* {
  ///     yield value;
  /// };
  /// final s = streamSignal(() => stream);
  /// s.reset();
  /// ```
  ///
  /// ## .refresh()
  ///
  /// Refresh the stream value by setting `isLoading` to true, but maintain the current state (AsyncData, AsyncLoading, AsyncError).
  ///
  /// ```dart
  /// final stream = (int value) async* {
  ///     yield value;
  /// };
  /// final s = streamSignal(() => stream);
  /// s.refresh();
  /// print(s.value.isLoading); // true
  /// ```
  ///
  /// ## .reload()
  ///
  /// Reload the stream value by setting the state to `AsyncLoading` and pass in the value or error as data.
  ///
  /// ```dart
  /// final stream = (int value) async* {
  ///     yield value;
  /// };
  /// final s = streamSignal(() => stream);
  /// s.reload();
  /// print(s.value is AsyncLoading); // true
  /// ```
  ///
  /// ## Dependencies
  ///
  /// By default the callback will be called once and the stream will be cached unless a signal is read in the callback.
  ///
  /// ```dart
  /// final count = signal(0);
  /// final s = streamSignal(() async* {
  ///     final value = count();
  ///     yield value;
  /// });
  ///
  /// await s.future; // 0
  /// count.value = 1;
  /// await s.future; // 1
  /// ```
  ///
  /// If there are signals that need to be tracked across an async gap then use the `dependencies` when creating the `streamSignal` to [`reset`](#.reset()) every time any signal in the dependency array changes.
  ///
  /// ```dart
  /// final count = signal(0);
  /// final s = streamSignal(
  ///     () async* {
  ///         final value = count();
  ///         yield value;
  ///     },
  ///     dependencies: [count],
  /// );
  /// s.value; // state with count 0
  /// count.value = 1; // resets the future
  /// s.value; // state with count 1
  /// ```
  /// @link https://dartsignals.dev/async/stream
  /// {@endtemplate}
  StreamSignal(
    Stream<T> Function() fn, {
    this.cancelOnError,
    super.debugLabel,
    T? initialValue,
    this.dependencies = const [],
    void Function()? onDone,
    bool lazy = true,
    super.autoDispose,
  })  : _onDone = onDone,
        _stream = computed(
          () {
            for (final dep in dependencies) {
              dep.value;
            }
            return fn();
          },
        ),
        super(initialValue != null
            ? AsyncState.data(initialValue)
            : AsyncState.loading()) {
    if (!lazy) value;
  }

  /// Execute the stream
  Future<void> execute(Stream<T> src) async {
    if (_done || _fetching) return;
    _fetching = true;
    _subscription = src.listen(
      setValue,
      onError: setError,
      onDone: _finish,
      cancelOnError: cancelOnError,
    );
  }

  Future<void> _finish() async {
    _done = true;
    _onDone?.call();
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Check if the subscription is paused
  bool get isPaused => _subscription?.isPaused ?? false;

  /// Pause the subscription
  void pause([Future<void>? resume]) {
    _subscription?.pause(resume);
    set(value, force: true);
  }

  /// Resume the subscription
  void resume() {
    _subscription?.resume();
    set(value, force: true);
  }

  /// Cancel the subscription
  Future<void> cancel() async {
    await _finish();
  }

  @override
  Future<void> reload() async {
    super.reload();
    _stream.recompute();
    _fetching = false;
    _done = false;
    _subscription?.cancel();
    _subscription = null;
    await execute(_stream.value);
  }

  @override
  @Deprecated("Use `reload` instead.")
  Future<void> refresh() async {
    super.refresh();
    _stream.recompute();
    _fetching = false;
    _done = false;
    _subscription?.cancel();
    _subscription = null;
    await execute(_stream.value);
  }

  @override
  void reset([AsyncState<T>? value]) {
    super.reset(value);
    _fetching = false;
    _done = false;
    _subscription?.cancel();
    _subscription = null;
    init();
  }

  @override
  void dispose() {
    super.dispose();
    _cleanup?.call();
    _subscription?.cancel();
  }

  @override
  AsyncState<T> get value {
    _cleanup ??= _stream.subscribe((src) {
      reset();
      execute(src);
    });
    return super.value;
  }

  @override
  void setError(Object error, [StackTrace? stackTrace]) {
    super.setError(error, stackTrace);
    if (cancelOnError == true) {
      _finish();
    }
  }
}

/// {@template stream}
/// Stream signals can be created by extension or method.
///
/// ### streamSignal
///
/// ```dart
/// final stream = () async* {
///     yield 1;
/// };
/// final s = streamSignal(() => stream);
/// ```
///
/// ### toSignal()
///
/// ```dart
/// final stream = () async* {
///     yield 1;
/// };
/// final s = stream.toSignal();
/// ```
///
/// ## .value, .peek()
///
/// Returns [`AsyncState<T>`](/dart/async/state) for the value and can handle the various states.
///
/// The `value` getter returns the value of the stream if it completed successfully.
///
/// > .peek() can also be used to not subscribe in an effect
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// final value = s.value.value; // 1 or null
/// ```
///
/// ## .reset()
///
/// The `reset` method resets the stream to its initial state to recall on the next evaluation.
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// s.reset();
/// ```
///
/// ## .refresh()
///
/// Refresh the stream value by setting `isLoading` to true, but maintain the current state (AsyncData, AsyncLoading, AsyncError).
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// s.refresh();
/// print(s.value.isLoading); // true
/// ```
///
/// ## .reload()
///
/// Reload the stream value by setting the state to `AsyncLoading` and pass in the value or error as data.
///
/// ```dart
/// final stream = (int value) async* {
///     yield value;
/// };
/// final s = streamSignal(() => stream);
/// s.reload();
/// print(s.value is AsyncLoading); // true
/// ```
///
/// ## Dependencies
///
/// By default the callback will be called once and the stream will be cached unless a signal is read in the callback.
///
/// ```dart
/// final count = signal(0);
/// final s = streamSignal(() async* {
///     final value = count();
///     yield value;
/// });
///
/// await s.future; // 0
/// count.value = 1;
/// await s.future; // 1
/// ```
///
/// If there are signals that need to be tracked across an async gap then use the `dependencies` when creating the `streamSignal` to [`reset`](#.reset()) every time any signal in the dependency array changes.
///
/// ```dart
/// final count = signal(0);
/// final s = streamSignal(
///     () async* {
///         final value = count();
///         yield value;
///     },
///     dependencies: [count],
/// );
/// s.value; // state with count 0
/// count.value = 1; // resets the future
/// s.value; // state with count 1
/// ```
/// @link https://dartsignals.dev/async/stream
/// {@endtemplate}
StreamSignal<T> streamSignal<T>(
  Stream<T> Function() callback, {
  T? initialValue,
  String? debugLabel,
  List<ReadonlySignal<dynamic>> dependencies = const [],
  void Function()? onDone,
  bool? cancelOnError,
  bool lazy = true,
  bool autoDispose = false,
}) {
  return StreamSignal(
    callback,
    initialValue: initialValue,
    debugLabel: debugLabel,
    dependencies: dependencies,
    onDone: onDone,
    cancelOnError: cancelOnError,
    lazy: lazy,
    autoDispose: autoDispose,
  );
}
