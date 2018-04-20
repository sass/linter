// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/rules/no_debug.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:test/test.dart';

final url = 'a.scss';
final rule = new NoDebugRule();

void main() {
  test('does not report lint when no @debug directive is found', () {
    var lints = getLints(r'$red: #f00;');

    expect(lints, isEmpty);
  });

  test('reports lint when @debug directive is found', () {
    var lints = getLints(r'@debug 10em + 12em;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, contains('@debug directives should be removed.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 0);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
