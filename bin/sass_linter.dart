// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:sass_linter/src/engine.dart';
import 'package:sass_linter/src/exceptions.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/rule.dart';

void main(List<String> args) {
  var argParser = new ArgParser()
    ..addMultiOption('rules', help: 'List of rules to check')
    ..addFlag('stdin', help: 'Read Sass source from stdin.', negatable: false)
    ..addOption('stdin-file-url',
        help: 'Use this file url when reporting lint from stdin.')
    ..addFlag('help', abbr: 'h', help: 'Print help text.', negatable: false);
  var argResults = argParser.parse(args);

  try {
    if (argResults['help'] == true) _usage('Report lint found in Sass');

    var rules =
        argResults.wasParsed('rules') ? _parseRules(argResults['rules']) : null;

    if (argResults['stdin'] == true) {
      var engine = new Engine(['-'],
          rules: rules, stdinFileUrl: argResults['stdin-file-url'] as String);
      _report(engine.run());
    } else {
      if (argResults.rest.isEmpty) _usage('Report lint found in Sass');

      var engine = new Engine(argResults.rest,
          rules: rules, stdinFileUrl: argResults['stdin-file-url'] as String);
      _report(engine.run());
    }
  } on UsageException catch (error) {
    print('${error.message}\n\n'
        'Usage: sass_linter [input.scss input/ ...]\n'
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

/// Parse [rules] for linter [Rule]s.
///
/// Translates user-written String names for rules into instances of [Rule]s,
/// allowing for String-based APIs (e.g. command line). Rule names that both
/// include and exclude the "_rule" suffix can be parsed.
Iterable<Rule> _parseRules(List<String> rules) => rules.map((ruleName) {
      var sanitizedName =
          ruleName.endsWith('_rule') ? ruleName : '${ruleName}_rule';
      try {
        return allRules.firstWhere((r) => r.name == sanitizedName);
      } on StateError {
        throw new UsageException('Invalid rule: $ruleName');
      }
    });
