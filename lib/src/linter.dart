// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';

import 'lint.dart';
import 'rule.dart';

/// The Linter finds lint in a Sass document by examining it with different lint rules.
class Linter {
  /// The root [Stylesheet] node of a Sass document.
  final Stylesheet tree;

  /// The rules which will examine the [tree].
  final List<Rule> rules;

  /// Set up a Linter to examine [source] with [rules].
  ///
  /// Specify the [url] of [source] for reporting purposes.
  Linter(String source, Iterable<Rule> rules, {url})
      : this.tree = new Stylesheet.parseScss(source, url: url),
        this.rules = new List.unmodifiable(rules);

  /// Runs the [rules] over [tree], returning any found lint.
  List<Lint> run() => rules.expand((rule) => tree.accept(rule)).toList();
}
