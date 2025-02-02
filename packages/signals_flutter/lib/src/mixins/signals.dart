import 'dart:async';
import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../signals_core.dart';

typedef _SignalMetadata = ({
  bool? local,
  ReadonlySignal<dynamic> target,
  ({Function cb, EffectCleanup cleanup})? listener,
});

/// Signals mixin that will automatically rebuild the widget tree when any of
/// the signals change and dispose of any signals and effects created locally.
///
/// ```dart
/// class MyWidget extends StatefulWidget {
///  ...
/// }
///
/// class _MyWidget extends State<MyWidget> with SignalsMixin {
///   late var _signal = this.createSignal(0);
///   late var _computed = this.createComputed(() => _signal() * 2);
///
///   @override
///   void initState() {
///     super.initState();
///     this.createEffect(() {
///       print('count: $_signal, double: $_computed');
///     });
///   }
///   ...
/// }
/// ```
mixin SignalsMixin<T extends StatefulWidget> on State<T> {
  final _signals = HashMap.of(<int, _SignalMetadata>{});
  EffectCleanup? _cleanup;
  final _effects = <EffectCleanup>[];

  /// Dispose and remove signal
  void disposeSignal(int id) {
    final s = _signals.remove(id);
    if (s == null) return;
    s.target.dispose();
    s.listener?.cleanup();
  }

  Future<void> _rebuild() async {
    if (!mounted) return;

    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    setState(() {});
    return;
  }

  void _setup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cb = effect(() {
        for (final s in _signals.values.where((e) => e.local != null)) {
          s.target.value;
        }
        _rebuild();
      });
      _cleanup?.call();
      _cleanup = cb;
    });
  }

  void _watch(ReadonlySignal<dynamic> target, bool local) {
    if (_signals[target.globalId]?.local != null) {
      return;
    }
    final listener = _signals[target.globalId]?.listener;
    _signals[target.globalId] = (
      local: local,
      target: target,
      listener: listener,
    );
    _setup();
  }

  void _unwatch(ReadonlySignal<dynamic> target) {
    if (!_signals.containsKey(target.globalId)) return;
    final listener = _signals[target.globalId]?.listener;
    _signals[target.globalId] = (
      local: null,
      target: target,
      listener: listener,
    );
    _setup();
  }

  /// Async Computed is syntax sugar around [FutureSignal].
  ///
  /// _Inspired by [computedFrom](https://ngxtension.netlify.app/utilities/signals/computed-from/) from Angular NgExtension._
  ///
  /// computedFrom takes a list of [signals] and a [callback] function to
  /// compute the value of the signal every time one of the [signals] changes.
  ///
  /// ```dart
  /// final movieId = signal('id');
  /// late final movie = computedFrom([movieId], (args) => fetchMovie(args.first));
  /// ```
  ///
  /// Since all dependencies are passed in as arguments there is no need to worry about calling the signals before any async gaps with await.
  FutureSignal<S> createComputedFrom<S, A>(
    List<ReadonlySignal<A>> signals,
    Future<S> Function(List<A> args) fn, {
    S? initialValue,
    String? debugLabel,
    bool lazy = true,
  }) {
    return _bindLocal(computedFrom<S, A>(
      signals,
      fn,
      initialValue: initialValue,
      debugLabel: debugLabel,
      lazy: lazy,
    ));
  }

  /// [createComputedFrom] for one signal.
  FutureSignal<S> createComputedFrom1<S, A>(
    ReadonlySignal<A> signal1,
    Future<S> Function(A value1) fn, {
    S? initialValue,
    String? debugLabel,
    bool lazy = true,
  }) {
    return _bindLocal(computedFrom1<S, A>(
      signal1,
      fn,
      initialValue: initialValue,
      debugLabel: debugLabel,
      lazy: lazy,
    ));
  }

  /// [createComputedFrom] for two signals.
  FutureSignal<S> createComputedFrom2<S, A, B>(
    ReadonlySignal<A> signal1,
    ReadonlySignal<B> signal2,
    Future<S> Function(A value1, B value2) fn, {
    S? initialValue,
    String? debugLabel,
    bool lazy = true,
  }) {
    return _bindLocal(computedFrom2<S, A, B>(
      signal1,
      signal2,
      fn,
      initialValue: initialValue,
      debugLabel: debugLabel,
      lazy: lazy,
    ));
  }

  /// [createComputedFrom] for three signals.
  FutureSignal<S> createComputedFrom3<S, A, B, C>(
    ReadonlySignal<A> signal1,
    ReadonlySignal<B> signal2,
    ReadonlySignal<C> signal3,
    Future<S> Function(A value1, B value2, C value3) fn, {
    S? initialValue,
    String? debugLabel,
    bool lazy = true,
  }) {
    return _bindLocal(computedFrom3<S, A, B, C>(
      signal1,
      signal2,
      signal3,
      fn,
      initialValue: initialValue,
      debugLabel: debugLabel,
      lazy: lazy,
    ));
  }

  /// [createComputedFrom] for four signals.
  FutureSignal<S> createComputedFrom4<S, A, B, C, D>(
    ReadonlySignal<A> signal1,
    ReadonlySignal<B> signal2,
    ReadonlySignal<C> signal3,
    ReadonlySignal<D> signal4,
    Future<S> Function(A value1, B value2, C value3, D value4) fn, {
    S? initialValue,
    String? debugLabel,
    bool lazy = true,
  }) {
    return _bindLocal(computedFrom4<S, A, B, C, D>(
      signal1,
      signal2,
      signal3,
      signal4,
      fn,
      initialValue: initialValue,
      debugLabel: debugLabel,
      lazy: lazy,
    ));
  }

  /// [createComputedFrom] for five signals.
  FutureSignal<S> createComputedFrom5<S, A, B, C, D, E>(
    ReadonlySignal<A> signal1,
    ReadonlySignal<B> signal2,
    ReadonlySignal<C> signal3,
    ReadonlySignal<D> signal4,
    ReadonlySignal<E> signal5,
    Future<S> Function(A value1, B value2, C value3, D value, E value5) fn, {
    S? initialValue,
    String? debugLabel,
    bool lazy = true,
  }) {
    return _bindLocal(computedFrom5<S, A, B, C, D, E>(
      signal1,
      signal2,
      signal3,
      signal4,
      signal5,
      fn,
      initialValue: initialValue,
      debugLabel: debugLabel,
      lazy: lazy,
    ));
  }

  /// Async Computed is syntax sugar around [FutureSignal].
  ///
  /// _Inspired by [computedAsync](https://ngxtension.netlify.app/utilities/signals/computed-async/) from Angular NgExtension._
  ///
  /// computedAsync takes a [callback] function to compute the value
  /// of the signal. This callback is converted into a [Computed] signal.
  ///
  /// ```dart
  /// final movieId = signal('id');
  /// late final movie = computedAsync(() => fetchMovie(movieId()));
  /// ```
  ///
  /// **It is important that signals are called before any async gaps with await.**
  ///
  /// Any signal that is read inside the callback will be tracked as a dependency and the computed signal will be re-evaluated when any of the dependencies change.
  FutureSignal<S> createComputedAsync<S>(
    Future<S> Function() fn, {
    S? initialValue,
    String? debugLabel,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    bool lazy = true,
  }) {
    return _bindLocal(computedAsync<S>(
      fn,
      dependencies: dependencies,
      initialValue: initialValue,
      debugLabel: debugLabel,
      lazy: lazy,
    ));
  }

  /// Create a signal from a future
  FutureSignal<S> createFutureSignal<S>(
    Future<S> Function() fn, {
    S? initialValue,
    String? debugLabel,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    bool lazy = true,
  }) {
    return _bindLocal(futureSignal<S>(
      fn,
      initialValue: initialValue,
      debugLabel: debugLabel,
      dependencies: dependencies,
      lazy: lazy,
    ));
  }

  /// Create a signals from a stream
  StreamSignal<S> createStreamSignal<S>(
    Stream<S> Function() callback, {
    S? initialValue,
    String? debugLabel,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    void Function()? onDone,
    bool? cancelOnError,
    bool lazy = true,
  }) {
    return _bindLocal(streamSignal<S>(
      callback,
      initialValue: initialValue,
      debugLabel: debugLabel,
      dependencies: dependencies,
      onDone: onDone,
      cancelOnError: cancelOnError,
      lazy: lazy,
    ));
  }

  /// Create a signal holding an async value
  AsyncSignal<S> createAsyncSignal<S>(
    AsyncState<S> value, {
    String? debugLabel,
  }) {
    return _bindLocal(asyncSignal<S>(
      value,
      debugLabel: debugLabel,
    ));
  }

  /// Create a signal<T> and watch for changes
  Signal<V> createSignal<V>(
    V val, {
    String? debugLabel,
  }) {
    return _bindLocal(signal<V>(
      val,
      debugLabel: debugLabel,
    ));
  }

  /// Create a [ListSignal]<T> and watch for changes
  ListSignal<V> createListSignal<V>(
    List<V> list, {
    String? debugLabel,
  }) {
    return _bindLocal(ListSignal<V>(
      list,
      debugLabel: debugLabel,
    ));
  }

  /// Create a [SetSignal]<T> and watch for changes
  SetSignal<V> createSetSignal<V>(
    Set<V> set, {
    String? debugLabel,
  }) {
    return _bindLocal(SetSignal<V>(
      set,
      debugLabel: debugLabel,
    ));
  }

  /// Create a [QueueSignal]<T> and watch for changes
  QueueSignal<V> createQueueSignal<V>(
    Queue<V> queue, {
    String? debugLabel,
  }) {
    return _bindLocal(QueueSignal<V>(
      queue,
      debugLabel: debugLabel,
    ));
  }

  /// Create a [MapSignal]<T> and watch for changes
  MapSignal<K, V> createMapSignal<K, V>(
    Map<K, V> value, {
    String? debugLabel,
  }) {
    return _bindLocal(MapSignal<K, V>(
      value,
      debugLabel: debugLabel,
    ));
  }

  /// Create a computed<T> and watch for changes
  Computed<V> createComputed<V>(
    V Function() cb, {
    String? debugLabel,
  }) {
    return _bindLocal(computed<V>(
      cb,
      debugLabel: debugLabel,
    ));
  }

  S _bindLocal<V, S extends ReadonlySignal<V>>(S val) {
    _watch(val, true);
    return val;
  }

  /// Bind an existing signal<T> and watch for changes
  S bindSignal<V, S extends ReadonlySignal<V>>(S val) {
    _watch(val, false);
    return val;
  }

  /// Unbind an existing signal<T> changes
  S unbindSignal<V, S extends ReadonlySignal<V>>(S val) {
    _unwatch(val);
    return val;
  }

  /// Watch signal value
  V watchSignal<V, S extends ReadonlySignal<V>>(S val) {
    return bindSignal(val).value;
  }

  /// Unwatch an existing signal<T> value changes
  V unwatchSignal<V, S extends ReadonlySignal<V>>(S val) {
    return unbindSignal(val).value;
  }

  /// Watch signal value
  void listenSignal(
    ReadonlySignal<dynamic> target,
    void Function() callback, {
    String? debugLabel,
  }) {
    final current = _signals[target.globalId];
    if (current?.listener?.cb.hashCode == callback.hashCode) return;
    current?.listener?.cleanup();
    final cb = createEffect(
      callback,
      debugLabel: debugLabel,
    );
    _signals[target.globalId] = (
      local: current?.local,
      target: target,
      listener: (cb: callback, cleanup: cb),
    );
  }

  /// Stop listening to a signal value
  void unlistenSignal(
    ReadonlySignal<dynamic> target,
    void Function() callback,
  ) {
    final current = _signals[target.globalId];
    if (current != null) {
      current.listener?.cleanup();
      _signals[target.globalId] = (
        local: current.local,
        target: target,
        listener: null,
      );
    }
  }

  /// Create a effect.
  ///
  /// Do not call inside the build method.
  ///
  /// Calling this method in build() will create a new
  /// effect every render.
  EffectCleanup createEffect(
    dynamic Function() cb, {
    String? debugLabel,
    dynamic Function()? onDispose,
  }) {
    final s = effect(
      cb,
      debugLabel: debugLabel,
      onDispose: onDispose,
    );
    _effects.add(s);
    return () {
      _effects.remove(s);
      s();
    };
  }

  /// Reset all stored signals and effects
  void clearSignalsAndEffects() {
    _cleanup?.call();
    _cleanup = null;
    final local = _signals //
        .values
        .where((e) => e.local == true)
        .map((e) => e.target);
    for (final s in local) {
      s.dispose();
    }
    for (final cb in _effects) {
      cb();
    }
    _effects.clear();
    _signals.clear();
  }

  @override
  void dispose() {
    clearSignalsAndEffects();
    super.dispose();
  }
}
