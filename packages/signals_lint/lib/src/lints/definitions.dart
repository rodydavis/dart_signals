import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const lintCode = LintCode(
  name: 'signals_avoid_create_in_build_method',
  problemMessage: _errorMessage,
  correctionMessage: _correctionMessage,
  errorSeverity: ErrorSeverity.WARNING,
);

const _errorMessage = '''
This expression causes a new Signal instance to be created on every build, 
instead of accessing an existing one.
''';

const _correctionMessage = '''
Create the new signals outside the build() method in the class or globally.

For StatelessWidgets you can define the signals as a static variable, pass in 
from the constructor or declare globally.

```diff
+ final counter = signal(0);
...
@override
Widget build(BuildContext context) {
- final counter = signal(0);
  return ...;   
}
```
''';

const signalTypes = [
  TypeChecker.fromName(
    'Signal',
    packageName: 'signals_core',
  ),
  TypeChecker.fromName(
    'Computed',
    packageName: 'signals_core',
  ),
  TypeChecker.fromName(
    'SignalValueNotifier',
    packageName: 'signals_flutter',
  ),
  TypeChecker.fromName(
    'SignalValueListenable',
    packageName: 'signals_flutter',
  ),
];

const widgetClasses = [
  TypeChecker.fromName('State', packageName: 'flutter'),
  TypeChecker.fromName('StatelessWidget', packageName: 'flutter'),
];

const buildMethodName = 'build';
