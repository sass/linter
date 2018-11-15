// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:sass/src/ast/sass.dart';
import 'package:sass_linter/src/lint.dart';
import 'package:sass_linter/src/linter.dart';
import 'package:sass_linter/src/rule.dart';
import 'package:test/test.dart';

/// A configurable linter rule.
///
/// This rule only overrides a few leaf visit methods. This rule can be used in
/// tests to verify that [Rule]'s visit methods walk down the AST, and report
/// lint back up.
class _DummyRule extends Rule {
  final bool boolean;
  final bool number;
  final bool variable;

  _DummyRule({this.boolean = false, this.number = false, this.variable = false})
      : super('dummy_rule');

  @override
  visitBooleanExpression(BooleanExpression node) {
    return boolean
        ? [Lint(rule: this, span: node.span, message: 'Found a boolean.')]
        : <Lint>[];
  }

  @override
  visitNumberExpression(NumberExpression node) {
    return number
        ? [Lint(rule: this, span: node.span, message: 'Found a number.')]
        : <Lint>[];
  }

  @override
  visitVariableExpression(VariableExpression node) {
    return variable
        ? [Lint(rule: this, span: node.span, message: 'Found a variable.')]
        : <Lint>[];
  }
}

final url = 'a.scss';
final booleanRule = new _DummyRule(boolean: true);
final numberRule = new _DummyRule(number: true);
final variableRule = new _DummyRule(variable: true);

List<Lint> getBooleanLints(String source) =>
    new Linter(source, [booleanRule], url: url).run();

List<Lint> getNumberLints(String source) =>
    new Linter(source, [numberRule], url: url).run();

List<Lint> getVariableLints(String source) =>
    new Linter(source, [variableRule], url: url).run();

void main() {
  test('reports lint found within an @at-root query', () {
    var lints = getNumberLints(r'''
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

  test('reports lint found within an @at-root body', () {
    var lints = getBooleanLints(r'''
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

  test('reports lint found within a binary operation', () {
    var lints = getNumberLints(r'$a: 1 + 2;');

    expect(lints, hasLength(2));

    expect(lints[0].line, 0);
    expect(lints[0].column, 4);
    expect(lints[1].line, 0);
    expect(lints[1].column, 8);
  });

  test('reports lint found within a @debug at-rule', () {
    var lints = getBooleanLints(r'@debug true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 7);
  });

  test('reports lint found within a declaration name', () {
    var lints = getBooleanLints(r'''
        p {
          foo-#{true}: red;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 16);
  });

  test('reports lint found within a declaration value', () {
    var lints = getBooleanLints(r'''
        p {
          foo: true;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 15);
  });

  test('reports lint found within an @each list', () {
    var lints = getBooleanLints(r'''
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

  test('reports lint found within an @each loop body', () {
    var lints = getBooleanLints(r'''
        @each $animal in puma, sea-slug, egret, salamander {
          $a: true;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint found within an @error at-rule', () {
    var lints = getBooleanLints(r'@error true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 7);
  });

  test('reports lint found within an @extend selector', () {
    var lints = getNumberLints(r'''
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

  test('reports lint found within a @for condition', () {
    var lints = getNumberLints(r'''
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

  test('reports lint found within a @for body', () {
    var lints = getBooleanLints(r'''
        @for $i from 1 through 3 {
          $a: true;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.last;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint found within a @function body', () {
    var lints = getBooleanLints(r'''
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

  test('reports lint found within a function invocation name', () {
    var lints = getNumberLints(r'''
        p {
          // Imagine CSS provides a function, "attr2".
          color: attr#{2}("data-color");
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 2);
    expect(lint.column, 23);
  });

  test('reports lint found within a function invocation positional arg', () {
    var lints = getNumberLints(r'''
        $my-red: darken(red, 10%);
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 0);
    expect(lint.column, 29);
  });

  test('reports lint found within a function invocation keyword arg', () {
    var lints = getNumberLints(r'''
        $my-red: darken(red, $amount: 10%);
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 0);
    expect(lint.column, 38);
  });

  test('reports lint found within a function invocation varargs', () {
    var lints = getVariableLints(r'''
        $args: red 10%;
        $my-red: darken($args...);
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 24);
  });

  test('reports lint found within a function invocation keyword varargs', () {
    var lints = getVariableLints(r'''
        $attrs: (hue: 0, saturation: 0);
        $my-red: adjust-color(red, (1, 2, 3)..., $attrs...);
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 49);
  });

  test('reports lint found within an @if clause expression', () {
    var lints = getBooleanLints(r'''
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

  test('reports lint found within an @if else clause body', () {
    var lints = getBooleanLints(r'''
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

  test('reports lint found within an @if clause body', () {
    var lints = getBooleanLints(r'''
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

  test('reports lint found within a map literal', () {
    var lints = getBooleanLints(r'''
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

  test('reports lint found within a parenthesized expression', () {
    var lints = getBooleanLints(r'''
    @if foo or
        (bar and false) or
        (true) {
      p: {color: red; }
    }
    ''');

    expect(lints, hasLength(2));

    var boolInBinary = lints[0];
    expect(boolInBinary.line, 1);
    expect(boolInBinary.column, 17);

    var boolInParens = lints[1];
    expect(boolInParens.line, 2);
    expect(boolInParens.column, 9);
  });

  test('reports lint found within a style selector', () {
    var lints = getNumberLints(r'''
        p-#{1} {
          a: red;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 0);
    expect(lint.column, 12);
  });

  test('reports lint found within a style rule', () {
    var lints = getBooleanLints(r'''
        p {
          $a: true;
        }
    ''');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.line, 1);
    expect(lint.column, 14);
  });

  test('reports lint found within a variable declaration', () {
    var lints = getBooleanLints(r'$a: true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 4);
  });

  test('reports lint found within an @warn at-rule', () {
    var lints = getBooleanLints(r'@warn true;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.message, equals('Found a boolean.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 0);
    expect(lint.column, 6);
  });
}
