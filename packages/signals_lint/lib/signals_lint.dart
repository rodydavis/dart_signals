/// Signals linter
library signals_lint;

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/fixes/wrap_with_watch.dart';
import 'src/lints/avoid_create_in_build_method.dart';

PluginBase createPlugin() => _SignalsPlugin();

class _SignalsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        SignalsAvoidCreateInBuildMethod(),
      ];

  @override
  List<Assist> getAssists() => [
        WrapWithWatch(),
      ];
}
