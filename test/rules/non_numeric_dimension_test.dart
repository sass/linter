// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/rules/non_numeric_dimension.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:test/test.dart';

final url = 'a.scss';
final rule = new NonNumericDimensionRule();

void main() {
  test('does not report lint when no dimension-interpolating is found', () {
    var lints = getLints(r'$pad: 2; $doublePad: $pad * 1px;');

    expect(lints, isEmpty);
  });

  test('does not report lint when no understood units are used', () {
    var lints = getLints(r'$pad: 2; $doublePad: #{$pad}pxx;');

    expect(lints, isEmpty);
  });

  test('does not report lint when a unit is followed by an interpolation', () {
    var lints = getLints(r'$pad: 2; $doublePad: #{$pad}px#{$pad};');

    expect(lints, isEmpty);
  });

  test('does not report lint when a unit is preceded by another string', () {
    var lints = getLints(r'$pad: 2; $doublePad: px#{$pad}px;');

    expect(lints, isEmpty);
  });

  test('reports lint when variable used in interpolation', () {
    var lints = getLints(r'$pad: 2; $padPx: #{$pad}px;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message,
        contains('Apply a unit to a numerical value via arithmetic'));
    expect(lint.message, contains(r'e.g. `$pad * 1px`.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 17);
  });

  test('reports lint when expression used in interpolation', () {
    var lints = getLints(r'$pad: 2; $padAndMore: #{$pad + 5}px;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, contains(r'`($pad + 5) * 1px`.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 22);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
