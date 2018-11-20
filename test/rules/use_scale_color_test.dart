// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/rules/use_scale_color.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:test/test.dart';

final url = 'a.scss';
final rule = new UseScaleColorRule();

void main() {
  test('does not report lint when an acceptable function is used', () {
    var lints = getLints(r'p { color: grayscale(red); }');

    expect(lints, isEmpty);
  });

  test('reports lint when an older color function is used', () {
    var lints = getLints('p { color: darken(red, 50%); }');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(
        lint.message,
        contains(
            '"darken" is a non-scaling function; use scale-color instead.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 11);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
