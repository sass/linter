// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/rules/quote_map_keys.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:test/test.dart';

final url = 'a.scss';
final rule = new QuoteMapKeysRule();

void main() {
  test('reports lint when map literal key is unquoted', () {
    var lints = getLints('\$map: (\n'
        '    key1: value1,\n'
        '    "key2": value2,\n'
        ');');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, contains('String literal map keys should be quoted.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 1);
    expect(lint.column, 4);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
