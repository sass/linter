// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:charcode/charcode.dart';

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';

import '../lint.dart';
import '../rule.dart';

/// A lint rule that reports on using null in a binary expression.
///
/// In the Sass language, `null` is falsey, meaning binary operation expressions
/// treat it as `false`. For brevity, `@if index(...) { ... }` is preferred to
/// `@if index(...) != null { ... }, and `@if not index(...) { ... }` is
/// preferred to `@if index(...) == null { ... }`.
class UseFalseyNullRule extends Rule {
  String _equalityMessage(Expression otherSide) =>
      'Check for equality to null is unnecessarily explicit; '
      'prefer "not ${otherSide.span.text}", since null is "falsey", '
      'meaning it is equivalent to false in boolean expressions.';

  static final _inequalityMessage =
      '"!= null" is unnecessary; null is "falsey" in Sass, '
      'meaning it is equivalent to false in boolean expressions.';

  UseFalseyNullRule() : super('use_falsey_null_rule');

  @override
  List<Lint> visitBinaryOperationExpression(BinaryOperationExpression node) {
    var lint = <Lint>[];
    // This rule concerns itself with `null` as an expression on either side of
    // `==` or `!=`. Using `null` as an expression on either side of other
    // binary operations is also strange (`7 < null`, but a very different
    // issue).
    if (node.operator == BinaryOperator.equals) {
      if (node.left is NullExpression) {
        lint.add(Lint(
            rule: this,
            span: node.left.span,
            message: _equalityMessage(node.right)));
      }
      if (node.right is NullExpression) {
        lint.add(Lint(
            rule: this,
            span: node.right.span,
            message: _equalityMessage(node.left)));
      }
    } else if (node.operator == BinaryOperator.notEquals) {
      if (node.left is NullExpression) {
        lint.add(Lint(
            rule: this, span: node.left.span, message: _inequalityMessage));
      }
      if (node.right is NullExpression) {
        lint.add(Lint(
            rule: this, span: node.right.span, message: _inequalityMessage));
      }
    }

    return lint..addAll(super.visitBinaryOperationExpression(node));
  }
}
