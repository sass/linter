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

/// A lint rule that reports on unquoted map keys in a map literal.
///
/// Some tokens (like `green`) parse as colors rather than strings. It is safer
/// to always quote map keys.
class QuoteMapKeysRule extends Rule {
  QuoteMapKeysRule() : super('quote_map_keys_rule');

  @override
  List<Lint> visitMapExpression(MapExpression node) {
    var lint = <Lint>[];

    for (var key in node.pairs.map((p) => p.item1)) {
      if (key is StringExpression && !key.hasQuotes) {
        lint.add(Lint(
            rule: this,
            span: key.span,
            message: 'String literal map keys should be quoted.'));
      }
    }

    return lint..addAll(super.visitMapExpression(node));
  }
}
