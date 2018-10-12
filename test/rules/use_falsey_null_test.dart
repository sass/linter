// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/rules/use_falsey_null.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:test/test.dart';

final url = 'a.scss';
final rule = new UseFalseyNullRule();

void main() {
  test('does not report lint when nothing is checked for null', () {
    var lints = getLints(r'@if 1 != 7 { @debug("True."); }');

    expect(lints, isEmpty);
  });

  test('reports lint when expression is checked for equality to `null`', () {
    var lints = getLints(r'@if 1 == null { @debug("True."); }');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message,
        contains('Check for equality to null is unnecessarily explicit'));
    expect(lint.message, contains('prefer "not 1"'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 9);
  });

  test('reports lint when expression is checked for inequality to `null`', () {
    var lints = getLints(r'@if null != 7 { @debug("True."); }');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, contains('"!= null" is unnecessary'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 4);
  });

  test('reports lint on inner binary expressions', () {
    var lints = getLints(r'@if 1 == 2 or 3 == null { @debug("True."); }');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message,
        contains('Check for equality to null is unnecessarily explicit'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 19);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
