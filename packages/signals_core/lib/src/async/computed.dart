import '../core/signals.dart';
import 'future.dart';

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
FutureSignal<T> computedFrom<T, A>(
  List<ReadonlySignal<A>> signals,
  Future<T> Function(List<A> args) fn, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool lazy = true,
}) {
  return FutureSignal<T>(
    () => fn(signals.map((e) => e()).toList()),
    dependencies: signals,
    initialValue: initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    lazy: lazy,
  );
}

/// [computedFrom] for one signal.
FutureSignal<T> computedFrom1<T, A>(
  ReadonlySignal<A> signal1,
  Future<T> Function(A value1) fn, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool lazy = true,
}) {
  return FutureSignal<T>(
    () => fn(signal1()),
    dependencies: [signal1],
    initialValue: initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    lazy: lazy,
  );
}

/// [computedFrom] for two signals.
FutureSignal<T> computedFrom2<T, A, B>(
  ReadonlySignal<A> signal1,
  ReadonlySignal<B> signal2,
  Future<T> Function(
    A value1,
    B value2,
  ) fn, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool lazy = true,
}) {
  return FutureSignal<T>(
    () => fn(signal1(), signal2()),
    dependencies: [signal1, signal2],
    initialValue: initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    lazy: lazy,
  );
}

/// [computedFrom] for three signals.
FutureSignal<T> computedFrom3<T, A, B, C>(
  ReadonlySignal<A> signal1,
  ReadonlySignal<B> signal2,
  ReadonlySignal<C> signal3,
  Future<T> Function(
    A value1,
    B value2,
    C value3,
  ) fn, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool lazy = true,
}) {
  return FutureSignal<T>(
    () => fn(signal1(), signal2(), signal3()),
    dependencies: [signal1, signal2, signal3],
    initialValue: initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    lazy: lazy,
  );
}

/// [computedFrom] for four signals.
FutureSignal<T> computedFrom4<T, A, B, C, D>(
  ReadonlySignal<A> signal1,
  ReadonlySignal<B> signal2,
  ReadonlySignal<C> signal3,
  ReadonlySignal<D> signal4,
  Future<T> Function(
    A value1,
    B value2,
    C value3,
    D value4,
  ) fn, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool lazy = true,
}) {
  return FutureSignal<T>(
    () => fn(signal1(), signal2(), signal3(), signal4()),
    dependencies: [signal1, signal2, signal3, signal4],
    initialValue: initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    lazy: lazy,
  );
}

/// [computedFrom] for five signals.
FutureSignal<T> computedFrom5<T, A, B, C, D, E>(
  ReadonlySignal<A> signal1,
  ReadonlySignal<B> signal2,
  ReadonlySignal<C> signal3,
  ReadonlySignal<D> signal4,
  ReadonlySignal<E> signal5,
  Future<T> Function(
    A value1,
    B value2,
    C value3,
    D value4,
    E value5,
  ) fn, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  bool lazy = true,
}) {
  return FutureSignal<T>(
    () => fn(signal1(), signal2(), signal3(), signal4(), signal5()),
    dependencies: [signal1, signal2, signal3, signal4, signal5],
    initialValue: initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    lazy: lazy,
  );
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
FutureSignal<T> computedAsync<T>(
  Future<T> Function() fn, {
  T? initialValue,
  String? debugLabel,
  bool autoDispose = false,
  List<ReadonlySignal<dynamic>> dependencies = const [],
  bool lazy = true,
}) {
  return FutureSignal<T>(
    fn,
    dependencies: dependencies,
    initialValue: initialValue,
    debugLabel: debugLabel,
    autoDispose: autoDispose,
    lazy: lazy,
  );
}
