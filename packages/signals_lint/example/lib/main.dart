import 'package:example/newfile.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SignalsMixin {
  late final counter = createSignal(1);

  Signal field() => counter;
  Signal get sameFileGetter => Signal(1);
  var abc = Abc().externalGetter;

  @override
  Widget build(BuildContext context) {
    var counter3 = Counter(1);
    final counterX = () => sameFileGetter;
    final counter2 = sameFileGetter;
    final third = counter3.y;
    final other = Counter(2).y;
    final nun = counter3.externalGetter;
    final n = Signal(1);
    return Text('Count: $counter');
  }
}

class Counter extends ValueNotifier<int> {
  Counter(super.value);

  final x = Signal(4);
  final y = Counter(1).x;

  Signal get externalGetter => Signal(1);
}
