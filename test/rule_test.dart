// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass/src/ast/sass.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:sass_linter/src/rule.dart';
import 'package:test/test.dart';

/// A rule which tries to emulate the shape of a typical lint rule.
///
/// Testing with this rule can verify that lint found by a rule which only
/// overrides a tiny set of `visit` methods is reported all the way up the tree.
class _DummyRule extends Rule {
  _DummyRule() : super('dummy_rule');

  @override
  visitBooleanExpression(BooleanExpression node) {
    return [new Lint(rule: this, span: node.span, message: 'Found a boolean.')];
  }

  @override
  visitNumberExpression(NumberExpression node) {
    return [new Lint(rule: this, span: node.span, message: 'Found a number.')];
  }
}

final url = 'a.scss';
final rule = new _DummyRule();

void main() {
  test('reports lint when boolean is found in an @at-root query', () {
    var lints = getLints(r'''
        .parent {
          @at-root .child-#{1} {
            a: red;
          }
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 28);
  });

  test('reports lint when boolean is found in an @at-root body', () {
    var lints = getLints(r'''
        .parent {
          @at-root .child {
            $a: true;
          }
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 2);
    expect(lint.column, 16);
  });

  test('reports lint when number is found in a binary operation', () {
    var lints = getLints(r'$a: 1 + 2;');

    expect(lints, hasLength(2));

    expect(lints[0].line, 0);
    expect(lints[0].column, 4);
    expect(lints[1].line, 0);
    expect(lints[1].column, 8);
  });

  test('reports lint when boolean is found in a @debug at-rule', () {
    var lints = getLints(r'@debug true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 7);
  });

  test('reports lint when boolean is found in a declaration name', () {
    var lints = getLints(r'''
        p {
          foo-#{true}: red;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 16);
  });

  test('reports lint when boolean is found in a declaration value', () {
    var lints = getLints(r'''
        p {
          foo: true;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 15);
  });

  test('reports lint when boolean is found in an @each list', () {
    var lints = getLints(r'''
        @each $animal in true, false {
          $a: red;
        }
    ''');

    expect(lints, hasLength(2));

    expect(lints[0].line, 0);
    expect(lints[0].column, 25);
    expect(lints[1].line, 0);
    expect(lints[1].column, 31);
  });

  test('reports lint when boolean is found in an @each loop body', () {
    var lints = getLints(r'''
        @each $animal in puma, sea-slug, egret, salamander {
          $a: true;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint when boolean is found in an @error at-rule', () {
    var lints = getLints(r'@error true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 7);
  });

  test('reports lint when number is found in an @extend selector', () {
    var lints = getLints(r'''
        .error-1 {
          color: red;
        }

        .seriousError {
          @extend .error-#{1};
          font-weight: bold;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 5);
    expect(lint.column, 27);
  });

  test('reports lint when boolean is found in a @for condition', () {
    var lints = getLints(r'''
        @for $i from 1 through 3 {
          $a: red;
        }
    ''');

    expect(lints, hasLength(2));

    expect(lints[0].line, 0);
    expect(lints[0].column, 21);
    expect(lints[1].line, 0);
    expect(lints[1].column, 31);
  });

  test('reports lint when boolean is found in a @for body', () {
    var lints = getLints(r'''
        @for $i from 1 through 3 {
          $a: true;
        }
    ''');

    expect(lints, hasLength(3));

    var lint = lints.last;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint when boolean is found in a @function body', () {
    var lints = getLints(r'''
        @function grid-width($n) {
          $a: true;
          @return $a;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint when boolean is found in a @if clause expression', () {
    var lints = getLints(r'''
        p {
          @if true {
            $a: red;
          }
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint when boolean is found in a @if else clause body', () {
    var lints = getLints(r'''
        $type: monster;
        p {
          @if $type == ocean {
            $a: red;
          } @else {
            $a: true;
          }
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 5);
    expect(lint.column, 16);
  });

  test('reports lint when boolean is found in a @if clause body', () {
    var lints = getLints(r'''
        $type: monster;
        p {
          @if $type == ocean {
            $a: true;
          }
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 3);
    expect(lint.column, 16);
  });

  test('reports lint when boolean is found in a map literal', () {
    var lints = getLints(r'''
        $map: (
	    key1: false,
	    true: value2,
        );
    ''');

    expect(lints, hasLength(2));

    var boolInValue = lints[0];
    expect(boolInValue.line, 1);
    expect(boolInValue.column, 11);

    var boolInKey = lints[1];
    expect(boolInKey.line, 2);
    expect(boolInKey.column, 5);
  });

  test('reports lint when boolean is found in a style selector', () {
    var lints = getLints(r'''
        p-#{1} {
          a: red;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 0);
    expect(lint.column, 12);
  });

  test('reports lint when boolean is found in a style rule', () {
    var lints = getLints(r'''
        p {
          $a: true;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint when boolean is found in a variable declaration', () {
    var lints = getLints(r'$a: true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 4);
  });

  test('reports lint when boolean is found in an @warn at-rule', () {
    var lints = getLints(r'@warn true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.rule, rule);
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 6);
  });
}

List<Lint> getLints(String source) =>
    new Linter(source, [rule], url: url).run();
