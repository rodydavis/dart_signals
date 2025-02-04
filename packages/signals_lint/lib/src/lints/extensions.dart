import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:signals_lint/src/lints/definitions.dart';

extension AstNodeX on AstNode {
  bool createsSignal() {
    if (this case Identifier(staticElement: final ExecutableElement element)) {
      if (element case PropertyAccessorElement(isSynthetic: false)) {
        return element.returnType.isSignal();
      }
    }
    return false;
  }

  bool isIdentifier() {
    final candidate = switch (this) {
      PrefixedIdentifier(:final prefix) => prefix.staticElement,
      Identifier(:final staticElement) => staticElement,
      _ => null,
    };
    return candidate?.declaration?.calledInBuild() ?? false;
  }

  bool hierarchyMatches(bool Function(AstNode node) predicate) =>
      thisOrAncestorMatching(predicate) != null;

  bool isWidgetBuildMember() => _isWidgetMember && _isBuildMember;

  bool get _isBuildMember => hierarchyMatches(
        (node) =>
            node is MethodDeclaration && node.name.lexeme == buildMethodName,
      );

  bool get _isWidgetMember {
    return parent != null &&
        parent!.hierarchyMatches((node) {
          if (node
              case ClassDeclaration(
                extendsClause: ExtendsClause(
                  superclass: NamedType(:final DartType type)
                )
              )) {
            return type.isTypeWidgetClass();
          }
          return false;
        });
  }
}

extension TypeX on DartType {
  bool isSignal() =>
      signalTypes.any((checker) => checker.isAssignableFromType(this));

  bool isTypeWidgetClass() =>
      widgetClasses.any((checker) => checker.isAssignableFromType(this));
}

extension ElementX on Element {
  bool calledInBuild() {
    final ancestor = thisOrAncestorMatching(
      (element) {
        if (element case MethodElement(name: buildMethodName)) {
          final widgetParent = element.enclosingElement.thisOrAncestorMatching(
              (element) => element._isElementWidgetClass());
          return widgetParent != null;
        }
        return false;
      },
    );
    return ancestor != null;
  }

  bool _isElementWidgetClass() =>
      widgetClasses.any((checker) => checker.isAssignableFrom(this));
}
