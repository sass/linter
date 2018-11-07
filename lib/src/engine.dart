// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'lint.dart';
import 'linter.dart';
import 'rule.dart';
import 'rules/no_debug.dart';
import 'rules/no_empty_style.dart';
import 'rules/no_loud_comment.dart';
import 'rules/non_numeric_dimension.dart';
import 'rules/quote_map_keys.dart';
import 'rules/use_falsey_null.dart';

/// Literally all of the rules defined in this package. Whether the binary will
/// check all of the rules, or a subset, or none, by default, may change how
/// this list is used. That cannot happen until the binary supports a config
/// file or a flag with a list of lint rules.
final allRules = <Rule>[
  new NoDebugRule(),
  new NoEmptyStyleRule(),
  new NoLoudCommentRule(),
  new NonNumericDimensionRule(),
  new QuoteMapKeysRule(),
  new UseFalseyNullRule(),
];

/// The engine maintains a context for linting.
///
/// This just includes simple things like a list of paths to be linted, etc.
class Engine {
  /// The paths of Sass files to be linted.
  ///
  /// This list may also include "-", the special path that represents `stdin`.
  final List<String> paths;

  /// [Rule]s which will be run by this engine.
  final List<Rule> rules;

  /// The file URL to use when reporting lints from stdin.
  final String stdinFileUrl;

  /// Create a new [Engine] to process files in [paths] with [rules].
  ///
  /// If no [rules] are passed in, the Engine will process with all available
  /// rules.
  ///
  /// For any path equal to "-", stdin will be processed. Pass in
  /// [stdinFileUrl] in order to report a specific path for lint found in
  /// stdin.
  Engine(this.paths, {Iterable<Rule> rules, this.stdinFileUrl})
      : this.rules = new List.unmodifiable(rules ?? allRules);

  /// Run all of the defined rules against the Sass input(s).
  Iterable<Lint> run() {
    // TODO(srawlins): This currently produces a list of lint sorted first by
    // path, then by lint rule, then, theoretically, by line number. They should
    // instead be sorted by path (sorted, even though [paths] may not be
    // sorted?), then by line number, then maybe by lint rule (maybe sorting by
    // lint rule at the end is not important, but I think at least stability is
    // important).
    return paths.map((path) {
      if (path == '-') {
        var source = new StringBuffer();
        while (true) {
          var line = stdin.readLineSync();
          if (line == null) break;
          source.writeln(line);
        }
        return new Linter(source.toString(), rules, url: stdinFileUrl).run();
      } else {
        var source = new File(path).readAsStringSync();
        return new Linter(source, rules, url: path).run();
      }
    }).expand((lint) => lint);
  }
}
