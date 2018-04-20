// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:meta/meta.dart';
import 'package:sass/src/ast/sass.dart';

import 'lint.dart';
import 'rule.dart';

/// The Linter finds lint in a Sass document by examining it with different lint rules.
class Linter {
  /// The root [Stylesheet] node of a Sass document.
  final Stylesheet tree;

  /// The rules which will examine the [tree].
  final List<Rule> rules;

  /// The [url] of the source document.
  final Uri url;

  /// Set up a Linter to examine [source] with [rules].
  ///
  /// Specify the [url] of [source] for reporting purposes.
  Linter(String source, {@required Iterable<Rule> rules, @required url})
      : this.tree = new Stylesheet.parseScss(source, url: url),
        this.rules = new List.unmodifiable(rules),
        this.url = (url is Uri)
            ? url
            : (url is String)
                ? new Uri.file(url)
                : throw new ArgumentError('url must be a Uri or a String');

  /// Runs the [rules] over [tree], returning any found lint.
  List<Lint> run() => rules.expand((rule) => tree.accept(rule)).toList();
}
