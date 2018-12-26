// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/configuration.dart';
import 'package:sass_linter/src/exceptions.dart';
import 'package:sass_linter/src/rules/no_debug.dart';
import 'package:sass_linter/src/rules/no_loud_comment.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('empty configuration', () {
    var configuration = Configuration.empty;

    test('has null (unspecified) value for rules', () {
      expect(configuration.rules, isNull);
    });

    test('has empty (no specified) value for rules', () {
      expect(configuration.paths, isEmpty);
    });
  });

  test('configuration can be parsed from empty file', () async {
    await d.file('a.yaml', '').create();
    var configuration = Configuration.parse('${d.sandbox}/a.yaml');
    expect(configuration.rules, isNull);
    expect(configuration.paths, isEmpty);
  });

  test('configuration can be parsed from file with single rule', () async {
    var configSource = r'''
rules:
  - no_debug_rule
''';
    await d.file('a.yaml', configSource).create();
    var configuration = Configuration.parse('${d.sandbox}/a.yaml');
    expect(configuration.rules, contains(TypeMatcher<NoDebugRule>()));
    expect(configuration.paths, isEmpty);
  });

  test('configuration can be parsed from file with single path', () async {
    var configSource = r'''
paths:
  - foo/bar.scss
''';
    await d.file('a.yaml', configSource).create();
    var configuration = Configuration.parse('${d.sandbox}/a.yaml');
    expect(configuration.rules, isNull);
    expect(configuration.paths, contains('foo/bar.scss'));
  });

  test('configuration can be parsed from file with rules and paths', () async {
    var configSource = r'''
rules:
  - no_debug_rule
  - no_loud_comment_rule
paths:
  - foo/bar.scss
  - foo/baz.scss
''';
    await d.file('a.yaml', configSource).create();
    var configuration = Configuration.parse('${d.sandbox}/a.yaml');
    expect(configuration.rules, hasLength(2));
    expect(configuration.rules, contains(TypeMatcher<NoDebugRule>()));
    expect(configuration.rules, contains(TypeMatcher<NoLoudCommentRule>()));
    expect(configuration.paths, hasLength(2));
    expect(configuration.paths, contains('foo/bar.scss'));
    expect(configuration.paths, contains('foo/baz.scss'));
  });

  test(
      'configuration can be parsed from file with specified but "null" rules '
      'and paths', () async {
    var configSource = r'''
rules:
paths:
''';
    await d.file('a.yaml', configSource).create();
    var configuration = Configuration.parse('${d.sandbox}/a.yaml');
    expect(configuration.rules, isNull);
    expect(configuration.paths, isEmpty);
  });

  test('throws when a configuration file cannot be parsed as YAML', () async {
    await _assertError(r'''
1.2: 2.3
a::b
''');
  });

  test('throws when a configuration file cannot be parsed as a map', () async {
    await _assertError(r'''
- no_debug_rule
- no_loud_comment_rule
''');
  });

  test('throws when a configuration file cannot be parsed', () async {
    await _assertError(r'''
rules:
  - unknown_rule
''');
  });

  test('throws when the value of "rules" is not a list', () async {
    await _assertError(r'''
rules: 7
''');
  });

  test('throws when the value of "paths" is not a list', () async {
    await _assertError(r'''
paths: 7
''');
  });

  test('throws when the values of the "rules" list are not strings', () async {
    await _assertError(r'''
rules:
- no_debug_rule: foo
  bar: false
''');
  });

  test('throws when the values of the "paths" list are not strings', () async {
    await _assertError(r'''
paths:
- foo.scss: true
  bar: false
''');
  });
}

Future<void> _assertError(String configSource) async {
  await d.file('a.yaml', configSource).create();
  expect(() => Configuration.parse('${d.sandbox}/a.yaml'),
      throwsA(TypeMatcher<ConfigParseException>()));
}
