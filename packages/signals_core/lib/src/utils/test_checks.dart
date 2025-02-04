import 'package:checks/context.dart';

import '../../signals_core.dart';

/// Extension on 'checks' test lib
extension SignalChecks<T> on Subject<ReadonlySignal<T>?> {
  /// Compare Signal<T>.peek() to ref T
  void peek(T other) {
    context.expect(() => prefixFirst('equals ', literal(other)), (actual) {
      if (actual?.peek() == other) return null;
      return Rejection(which: ['are not equal']);
    });
  }
}
