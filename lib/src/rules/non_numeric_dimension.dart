// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';

import '../lint.dart';
import '../rule.dart';

// Units which may be seen "appended" to a number.
const List<String> _units = const [
  // Font-relative lengths:
  // https://www.w3.org/TR/css-values-4/#font-relative-lengths
  'em', 'ex', 'cap', 'ch', 'ic', 'rem', 'lh', 'rlh',

  // Viewport-relative lengths:
  // https://www.w3.org/TR/css-values-4/#viewport-relative-lengths
  'vw', 'vh', 'vi', 'vb', 'vmin', 'vmax',

  // Absolute lengths:
  // https://www.w3.org/TR/css-values-4/#absolute-lengths
  'cm', 'mm', 'Q', 'in', 'pc', 'pt', 'px',

  // Angle units:
  // https://www.w3.org/TR/css-values-4/#angles
  'deg', 'grad', 'rad', 'turn',

  // Duration units:
  // https://www.w3.org/TR/css-values-4/#time
  's', 'ms',

  // Frequency units:
  // https://www.w3.org/TR/css-values-4/#frequency
  'Hz', 'kHz',

  // Resolution units:
  // https://www.w3.org/TR/css-values-4/#resolution
  'dpi', 'dpcm', 'dppx', 'x',

  // Flexible lengths:
  // https://www.w3.org/TR/css-grid-1/#fr-unit
  'fr',

  // Percentage:
  // https://www.w3.org/TR/css-values-4/#percentages
  '%'
];

/// A lint rule that reports on non-numeric dimensions which are created by
/// interpolating a value with a unit.
///
/// Interpolating a value with a unit (e.g. `#{$value}px`) results in a
/// _string_ value, not as numeric value. This value then cannot be used in
/// numerical operations.  It is better to use arithmetic to apply a unit to a
/// number (e.g. `$value * 1px`).
class NonNumericDimensionRule extends Rule {
  NonNumericDimensionRule() : super('non_numeric_dimension_rule');

  @override
  List<Lint> visitStringExpression(StringExpression node) {
    var lint = <Lint>[];

    if (node.hasQuotes) {
      // A quoted string is much more likely a deliberate non-numeric
      // dimension. Leave it alone.
      return lint;
    }

    if (node.text.contents.length != 2) {
      // More than two items are also much more likely a deliberate non-numeric
      // dimension. Leave it alone.
      return lint;
    }

    var firstItem = node.text.contents[0];
    if (firstItem is String) {
      return lint;
    }

    var secondItem = node.text.contents[1];
    if (secondItem is String && _units.contains(secondItem)) {
      var suggestionNeedsParens = firstItem is BinaryOperationExpression &&
          firstItem.operator.precedence < BinaryOperator.times.precedence;
      var replacementSuggestion = suggestionNeedsParens
          ? '($firstItem) * 1$secondItem'
          : '$firstItem * 1$secondItem';
      lint.add(new Lint(
          rule: this,
          span: node.span,
          message: 'Apply a unit to a numerical value via arithmetic, '
              'rather than interpolation; e.g. `$replacementSuggestion`. See '
              'https://sass-lang.com/documentation/values/numbers#units for '
              'more information.'));
    }

    return lint;
  }
}
