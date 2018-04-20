import 'package:sass/src/ast/sass.dart';

import '../rule.dart';

/// A lint rule that reports on the existence of @debug directives.
///
/// These directives should not be found in Sass documents, for example checked
/// into source control.
class DebugDirectiveRule extends Rule {
  DebugDirectiveRule() : super('debug_directive_rule');

  @override
  void visitDebugRule(DebugRule node) {
    reportLint(node, '@debug directives should be removed.');
  }
}
