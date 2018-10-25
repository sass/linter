// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';
import 'package:test/test.dart';

void main() {
  test('prints usage when no args are passed', () async {
    var linter = await runLinter([]);
    expect(linter.stdout, emits('Report lint found in Sass'));
    await linter.shouldExit(64);
  });

  test('prints usage when "--help" is passed', () async {
    var linter = await runLinter(['--help']);
    expect(linter.stdout, emits('Report lint found in Sass'));
    await linter.shouldExit(64);
  });

  test('lints a file', () async {
    await d.file('a.scss', r'$red: #ff0000;').create();
    var linter = await runLinter(['a.scss']);
    expect(linter.stdout, emitsDone);
    await linter.shouldExit(0);
  });

  test('reports lint found in a file', () async {
    await d.file('a.scss', '@debug("here");').create();
    var linter = await runLinter(['a.scss']);
    expect(
        linter.stdout,
        emits('@debug directives should be removed. '
            'at a.scss line 1 (no_debug_rule)'));
    await linter.shouldExit(0);
  });

  test('lints source from stdin', () async {
    var linter = await runLinter(['-']);
    linter.stdin.writeln(r'$red: #ff0000;');
    linter.stdin.close();
    expect(linter.stdout, emitsDone);
    await linter.shouldExit(0);
  });

  test('reports lint found in stdin using "-"', () async {
    var linter = await runLinter(['-']);
    linter.stdin.writeln('@debug("here");');
    linter.stdin.close();
    expect(
        linter.stdout,
        emits('@debug directives should be removed. '
            'at [missing url] line 1 (no_debug_rule)'));
    await linter.shouldExit(0);
  });

  test('reports lint found in stdin using "--stdin"', () async {
    var linter = await runLinter(['--stdin']);
    linter.stdin.writeln('@debug("here");');
    linter.stdin.close();
    expect(
        linter.stdout,
        emits('@debug directives should be removed. '
            'at [missing url] line 1 (no_debug_rule)'));
    await linter.shouldExit(0);
  });

  test('reports lint with a path using "--stdin-file-url"', () async {
    var linter = await runLinter(['--stdin-file-url=/a/b/c.scss', '-']);
    linter.stdin.writeln('@debug("here");');
    linter.stdin.close();
    expect(
        linter.stdout,
        emits('@debug directives should be removed. '
            'at /a/b/c.scss line 1 (no_debug_rule)'));
    await linter.shouldExit(0);
  });

  test('reports lint for a single specified lint rule', () async {
    await d.file('a.scss', '@debug("here");').create();
    var linter = await runLinter(['--rules', 'no_debug_rule', 'a.scss']);
    expect(
        linter.stdout,
        emits('@debug directives should be removed. '
            'at a.scss line 1 (no_debug_rule)'));
    await linter.shouldExit(0);
  });

  test('does not report lint for an unspecified lint rule', () async {
    await d.file('a.scss', '@debug("here");').create();
    var linter = await runLinter(['--rules', 'no_empty_style_rule', 'a.scss']);
    expect(linter.stdout, emitsDone);
    await linter.shouldExit(0);
  });

  test('reports lint for multiple specified lint rules', () async {
    await d.file('a.scss', 'p {}\n@debug("here");').create();
    var linter = await runLinter(
        ['--rules', 'no_debug_rule,no_empty_style_rule', 'a.scss']);
    expect(
        linter.stdout,
        emitsInOrder([
          '@debug directives should be removed. '
              'at a.scss line 2 (no_debug_rule)',
          'Style rule is empty. at a.scss line 1 (no_empty_style_rule)',
        ]));
    await linter.shouldExit(0);
  });

  test('allows users to drop "_rule" suffix in `--rules` arg', () async {
    await d.file('a.scss', 'p {}\n@debug("here");').create();
    var linter =
        await runLinter(['--rules', 'no_debug,no_empty_style', 'a.scss']);
    expect(
        linter.stdout,
        emitsInOrder([
          '@debug directives should be removed. '
              'at a.scss line 2 (no_debug_rule)',
          'Style rule is empty. at a.scss line 1 (no_empty_style_rule)',
        ]));
    await linter.shouldExit(0);
  });

  test('prints an error when an unkwown rule is passed', () async {
    await d.file('a.scss', '@debug("here");').create();
    var linter = await runLinter(['--rules', 'not_a_rule', 'a.scss']);
    expect(linter.stdout, emits('Invalid rule: not_a_rule'));
    await linter.shouldExit(64);
  });
}

Future<TestProcess> runLinter(Iterable<String> arguments) => TestProcess.start(
    Platform.executable,
    ['--checked', p.absolute('bin/sass_linter.dart')]..addAll(arguments),
    workingDirectory: d.sandbox,
    description: 'sass_linter');
