import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:signals_lint/src/lints/definitions.dart';
import 'package:signals_lint/src/lints/extensions.dart';

const TypeChecker buildContextType = TypeChecker.fromName(
  'BuildContext',
  packageName: 'flutter',
);

class SignalsAvoidCreateInBuildMethod extends DartLintRule {
  const SignalsAvoidCreateInBuildMethod() : super(code: lintCode);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addExpression(
      (node) {
        if (node.staticType?.isSignal() != true) return;

        final hasMatch = node.hierarchyMatches((node) {
          if (node is! Expression || node.staticType?.isSignal() != true) {
            return false;
          }
          if (node is InstanceCreationExpression &&
              node.isWidgetBuildMember()) {
            return true;
          }
          final checkCreatesSignal = switch (node) {
            PropertyAccess(:final realTarget) => realTarget,
            Identifier() => node,
            InvocationExpression(:final function) => function,
            _ => null,
          };
          return checkCreatesSignal != null &&
              node.isWidgetBuildMember() &&
              createsSignal(checkCreatesSignal);
        });

        if (hasMatch) {
          reporter.atNode(node, code);
        }
      },
    );
  }

  bool createsSignal(Expression expression) {
    return expression.hierarchyMatches((node) {
      return (node is InstanceCreationExpression &&
              node.thisOrAncestorOfType<VariableDeclaration>() != null) ||
          node.isIdentifier() ||
          node.createsSignal() ||
          (node is FunctionExpression && node.body.createsSignal());
    });
  }
}
