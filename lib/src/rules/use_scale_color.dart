// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';

import '../lint.dart';
import '../rule.dart';

/// A lint rule that reports on the use of older, non-scaling color adjustment
/// functions.
///
/// These functions each add/subtract a number to/from some color property or
/// other, rather than scaling the property. This is especially confusing when
/// a user passes a _percentage_ as an argument, such as `darken($color, 30%)`.
///
/// The `scale-color()` function should be used instead.
class UseScaleColorRule extends Rule {
  /// The set of non-scaling functions to be avoided.
  static final _oldFunctions = Set<String>.of([
    'saturate',
    'desaturate',
    'darken',
    'lighten',
    'opacify',
    'fade-in',
    'transparentize',
    'fade-out'
  ]);

  UseScaleColorRule() : super('use_scale_color_rule');

  @override
  List<Lint> visitFunctionExpression(FunctionExpression node) {
    if (node.name.contents.length > 1) return <Lint>[];
    var name = node.name.contents.single;
    if (_oldFunctions.contains(name)) {
      var documentationUrl =
          'https://sass-lang.com/documentation/functions/color#$name';
      return [
        new Lint(
            rule: this,
            span: node.span,
            message:
                '"$name" is a non-scaling function; use scale-color instead. '
                'See $documentationUrl for more information.')
      ];
    } else {
      return <Lint>[];
    }
  }
}
