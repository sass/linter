// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';

import '../lint.dart';
import '../rule.dart';

/// A lint rule that reports on empty style rules.
///
/// A style rule is considered "empty" if it contains no "outputting" children
/// statements. For example, a variable declaration does not, itself, output
/// anything in compiled CSS.
class NoEmptyStyleRule extends Rule {
  NoEmptyStyleRule() : super('no_empty_style_rule');

  @override
  List<Lint> visitStyleRule(StyleRule node) {
    var lint = <Lint>[];

    // A StyleRule has style declarations if it is non-empty (`every` will
    // always return `true` on an empty list), and if it contains anything
    // other than these non-outputting rules.
    var hasStyleDeclaration = !node.children.every((child) =>
        child is DebugRule ||
        child is ErrorRule ||
        child is FunctionRule ||
        child is MixinRule ||
        child is SilentComment ||
        child is VariableDeclaration ||
        child is WarnRule);

    if (!hasStyleDeclaration) {
      lint.add(
          Lint(rule: this, span: node.span, message: 'Style rule is empty.'));
    }

    return lint..addAll(super.visitStyleRule(node));
  }
}
