// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:sass_linter/src/configuration.dart';
import 'package:sass_linter/src/engine.dart';
import 'package:sass_linter/src/exceptions.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/rule.dart';
import 'package:source_span/source_span.dart';

void main(List<String> args) {
  var argParser = new ArgParser()
    ..addOption('config',
        help: 'Path to a config YAML file; all options parsed at the '
            'command-line will override options in the config file.')
    ..addMultiOption('rules', help: 'List of rules to check')
    ..addFlag('stdin', help: 'Read Sass source from stdin.', negatable: false)
    ..addOption('stdin-file-url',
        help: 'Use this file url when reporting lint from stdin.')
    ..addFlag('help', abbr: 'h', help: 'Print help text.', negatable: false);
  var argResults = argParser.parse(args);

  try {
    Configuration config;
    try {
      if (argResults['help'] == true) _usage('Report lint found in Sass');

      // Generate a [Configuration], either by reading a configuration file, or
      // by generating an empty one.
      config = argResults.wasParsed('config')
          ? Configuration.parse(argResults['config'] as String)
          : Configuration.empty;
    } on SourceSpanException catch (error) {
      print(error.toString(color: _supportsAnsiEscapes));
      io.exit(255);
    }

    List<Rule> rules;
    try {
      rules = argResults.wasParsed('rules')
          ? parseRules(argResults['rules'] as List<String>).toList()
          : config.rules;
    } on UnknownRuleException catch (error) {
      throw UsageException('Unknown rule: ${error.ruleName}');
    }

    if (argResults['stdin'] == true) {
      var engine = new Engine(['-'],
          rules: rules, stdinFileUrl: argResults['stdin-file-url'] as String);
      _report(engine.run());
    } else {
      var paths = argResults.rest;
      if (paths.isEmpty) paths = config.paths;

      if (paths.isEmpty) _usage('Report lint found in Sass');

      var engine = new Engine(paths,
          rules: rules, stdinFileUrl: argResults['stdin-file-url'] as String);
      _report(engine.run());
    }
  } on UsageException catch (error) {
    print('${error.message}\n\n'
        'Usage: sass_linter [input.scss input/ ...]\n'
        '       sass_linter -\n\n'
        '${argParser.usage}');
    io.exitCode = 64;
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

/// Returns whether the current platform supports ANSI escape codes.
bool get _supportsAnsiEscapes =>
    io.stdout.hasTerminal &&
    // We don't trust [io.stdout.supportsAnsiEscapes] except on Windows because
    // it relies on the TERM environment variable which has many false
    // negatives.
    (!io.Platform.isWindows || io.stdout.supportsAnsiEscapes);
