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
  ///
  /// Typically a Uri or a String.
  final dynamic url;

  factory Linter(String source, {List<Rule> rules, url}) {
    var tree = new Stylesheet.parseScss(source, url: url);
    return new Linter._(tree, rules: rules, url: url);
  }

  Linter._(this.tree, {this.rules, this.url});

  /// Runs the [rules] over [tree], returning any found lint.
  List<Lint> run() {
    var lints = <Lint>[];
    for (var rule in rules) {
      tree.accept(rule);
      lints.addAll(rule.lints);
    }
    return lints;
  }
}
