// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:io' as io;

import 'package:sass_linter/src/engine.dart';
import 'package:sass_linter/src/linter.dart';

Future<void> main(List<String> args) async {
  // Read from stdin; might be behind a flag in the future.
  if (args.isEmpty) {
    var source = await io.systemEncoding.decodeStream(io.stdin);
    _report(new Linter(source, allRules).run());
  } else {
    // Assume each arg is just a file path.
    // TODO(srawlins): Other things, sass dialect? directories, globs, options
    // file, exclude, color output, etc.
    var engine = new Engine(args);
    _report(engine.run());
  }
}

void _report(List<Lint> lints) {
  for (var lint in lints) {
    var url = lint.url ?? '[missing url]';
    print('${lint.message} at $url line ${lint.line + 1} '
        '(${lint.rule.name})');
  }
}
