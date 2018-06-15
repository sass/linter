// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'lint.dart';
import 'linter.dart';
import 'rule.dart';
import 'rules/no_debug.dart';

// Literally all of the rules defined in this package. Whether the binary will
// check all of the rules, or a subset, or none, by default, may change how this
// list is used. That cannot happen until the binary supports a config file or
// a flag with a list of lint rules.
final allRules = <Rule>[
  new NoDebugRule(),
];

// The engine maintains a context for linting.
//
// This just includes simple things like a list of paths to be linted, etc.
class Engine {
  // The paths of Sass files to be linted.
  final List<String> paths;

  Engine(this.paths);

  // Run all of the defined linters against the Sass input(s).
  List<Lint> run() {
    // TODO(srawlins): This currently produces a list of lint sorted first by
    // path, then by lint rule, then, theoretically, by line number. They should
    // instead be sorted by path (sorted, even though [paths] may not be
    // sorted?), then by line number, then maybe by lint rule (maybe sorting by
    // lint rule at the end is not important, but I think at least stability is
    // important).
    return paths.expand((path) {
      var source = new File(path).readAsStringSync();
      return new Linter(source, allRules, url: path).run();
    }).toList();
  }
}
