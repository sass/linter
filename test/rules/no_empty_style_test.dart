// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/rules/no_empty_style.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:test/test.dart';

final url = 'a.scss';
final rule = new NoEmptyStyleRule();

void main() {
  test('does not report lint when style rule has style declaration', () {
    var lints = getLints(r'p { color: red; }');

    expect(lints, isEmpty);
  });

  test('does not report lint when style rule has nested style rule', () {
    var lints = getLints('div.foo {\n'
        '  div.bar {\n'
        '    color: red;\n'
        '  }\n'
        '}');

    expect(lints, isEmpty);
  });

  test('reports lint when style rule has no style declaration', () {
    var lints = getLints('p {\n'
        '  \$red: #f00;\n'
        '  @debug("Hello.");\n'
        '}');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, contains('Style rule is empty.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 0);
  });

  test('reports nested empty rules', () {
    var lints = getLints('div.foo {\n'
        '  div.bar {\n'
        '  }\n'
        '  div.baz {\n'
        '  }\n'
        '}');

    expect(lints, hasLength(2));

    var lintOnBar = lints[0];
    expect(lintOnBar.rule, rule);
    expect(lintOnBar.message, contains('Style rule is empty.'));
    expect(lintOnBar.url, new Uri.file(url));
    expect(lintOnBar.line, 1);
    expect(lintOnBar.column, 2);

    var lintOnBaz = lints[1];
    expect(lintOnBaz.rule, rule);
    expect(lintOnBaz.message, contains('Style rule is empty.'));
    expect(lintOnBaz.url, new Uri.file(url));
    expect(lintOnBaz.line, 3);
    expect(lintOnBaz.column, 2);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
