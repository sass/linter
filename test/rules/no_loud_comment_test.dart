// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass_linter/src/rules/no_loud_comment.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:test/test.dart';

final url = 'a.scss';
final rule = new NoLoudCommentRule();

void main() {
  test('does not report lint when no loud comment is found', () {
    var lints = getLints(r'// silent comment');

    expect(lints, isEmpty);
  });

  test('reports lint when loud comment is found', () {
    var lints = getLints(r'/* loud comment */');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message,
        contains('Comments should be written with the silent (`//`) syntax.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 0);
  });

  test('does not report lint when loud, **preserved** comment is found', () {
    var lints = getLints(r'/*! Copyright notice */');

    expect(lints, isEmpty);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
