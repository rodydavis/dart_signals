import 'package:example/main.dart';
import 'package:signals/signals.dart';

class Abc {
  final x = Signal(4);
  final y = Counter(1).x;

  Signal get externalGetter => Signal(1);
}
