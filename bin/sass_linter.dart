// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:sass_linter/src/engine.dart';
import 'package:sass_linter/src/lint.dart';

void main(List<String> args) {
  var argParser = new ArgParser()
    ..addFlag('stdin', help: 'Read Sass source from stdin.', negatable: false)
    ..addOption('stdin-file-url',
        help: 'Use this file url when reporting lint from stdin.')
    ..addFlag('help', abbr: 'h', help: 'Print help text.', negatable: false);
  var argResults = argParser.parse(args);

  try {
    if (argResults['help'] == true) _usage('Report lint found in Sass');

    if (argResults['stdin'] == true) {
      var engine = new Engine(['-'],
          stdinFileUrl: argResults['stdin-file-url'] as String);
      _report(engine.run());
    } else {
      if (argResults.rest.isEmpty) _usage('Report lint found in Sass');

      // Assume each arg is just a file path.
      // TODO(srawlins): Other things like directories.
      var engine = new Engine(argResults.rest,
          stdinFileUrl: argResults['stdin-file-url'] as String);
      _report(engine.run());
    }
  } on UsageException catch (error) {
    print('${error.message}\n\n'
        'Usage: sass_linter [input.scss ...]\n'
        '       sass_linter -\n\n'
        '${argParser.usage}');
    exitCode = 64;
  }
}

@alwaysThrows
// Throws a [UsageException] with the given [message].
void _usage(String message) => throw new UsageException(message);

void _report(Iterable<Lint> lints) {
  for (var lint in lints) {
    var url = lint.url ?? '[missing url]';
    print('${lint.message} at $url line ${lint.line + 1} '
        '(${lint.rule.name})');
  }
}

/// An exception indicating that invalid arguments were passed.
class UsageException implements Exception {
  final String message;

  UsageException(this.message);
}
