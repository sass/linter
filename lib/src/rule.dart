// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/visitor/interface/expression.dart';
import 'package:sass/src/visitor/interface/statement.dart';

import 'lint.dart';

/// A parent class for all lint rules, which visits all nodes in a [Stylesheet].
///
/// The implementations of each visitor will eventually guarantee a traversal
/// of an entire [Stylesheet]. Extenders need only visit individual nodes that
/// they might act on.
abstract class Rule
    implements StatementVisitor<List<Lint>>, ExpressionVisitor<List<Lint>> {
  /// The name of the lint rule.
  ///
  /// The [name] acts as an identifier, and may be used in output. It should be
  /// underscore_case, unique, and brief.
  final String name;

  Rule(this.name);

  @override
  List<Lint> visitAtRootRule(AtRootRule node) {
    var lint = <Lint>[];
    if (node.query != null) lint.addAll(_visitInterpolation(node.query));
    for (var child in node.children) {
      lint.addAll(child.accept(this));
    }
    return lint;
  }

  @override
  List<Lint> visitAtRule(AtRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitBinaryOperationExpression(BinaryOperationExpression node) {
    return node.left.accept(this) + node.right.accept(this);
  }

  @override
  List<Lint> visitBooleanExpression(BooleanExpression node) {
    return <Lint>[];
  }

  @override
  List<Lint> visitColorExpression(ColorExpression node) {
    return <Lint>[];
  }

  @override
  List<Lint> visitContentRule(ContentRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitDebugRule(DebugRule node) {
    return node.expression.accept(this);
  }

  @override
  List<Lint> visitDeclaration(Declaration node) {
    // TODO(srawlins): Visit and test children.
    return _visitInterpolation(node.name) + node.value.accept(this);
  }

  @override
  List<Lint> visitEachRule(EachRule node) {
    var lint = node.list.accept(this);
    for (var child in node.children) {
      lint.addAll(child.accept(this));
    }
    return lint;
  }

  @override
  List<Lint> visitErrorRule(ErrorRule node) {
    return node.expression.accept(this);
  }

  @override
  List<Lint> visitExtendRule(ExtendRule node) {
    return _visitInterpolation(node.selector);
  }

  @override
  List<Lint> visitForRule(ForRule node) {
    var lint = node.from.accept(this) + node.to.accept(this);
    for (var child in node.children) {
      lint.addAll(child.accept(this));
    }
    return lint;
  }

  @override
  List<Lint> visitFunctionExpression(FunctionExpression node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitFunctionRule(FunctionRule node) {
    // TODO(srawlins): visit and test `arguments`.
    var lint = <Lint>[];
    for (var child in node.children) {
      lint.addAll(child.accept(this));
    }
    return lint;
  }

  @override
  List<Lint> visitIfExpression(IfExpression node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitIfRule(IfRule node) {
    var lint = <Lint>[];
    for (var clause in node.clauses) {
      lint.addAll(clause.expression.accept(this));
      for (var child in clause.children) {
        lint.addAll(child.accept(this));
      }
    }
    if (node.lastClause != null) {
      for (var child in node.lastClause.children) {
        lint.addAll(child.accept(this));
      }
    }
    return lint;
  }

  @override
  List<Lint> visitImportRule(ImportRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitIncludeRule(IncludeRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitListExpression(ListExpression node) {
    var lint = <Lint>[];
    for (var value in node.contents) {
      lint.addAll(value.accept(this));
    }
    return lint;
  }

  @override
  List<Lint> visitLoudComment(LoudComment node) {
    return _visitInterpolation(node.text);
  }

  @override
  List<Lint> visitMapExpression(MapExpression node) {
    var lint = <Lint>[];
    for (var pair in node.pairs) {
      lint.addAll(pair.item1.accept(this));
      lint.addAll(pair.item2.accept(this));
    }
    return lint;
  }

  @override
  List<Lint> visitMediaRule(MediaRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitMixinRule(MixinRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitNullExpression(NullExpression node) {
    return <Lint>[];
  }

  @override
  List<Lint> visitNumberExpression(NumberExpression node) {
    return <Lint>[];
  }

  @override
  List<Lint> visitParenthesizedExpression(ParenthesizedExpression node) {
    return node.expression.accept(this);
  }

  @override
  List<Lint> visitReturnRule(ReturnRule node) {
    return node.expression.accept(this);
  }

  @override
  List<Lint> visitSelectorExpression(SelectorExpression node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitSilentComment(SilentComment node) {
    return <Lint>[];
  }

  @override
  List<Lint> visitStringExpression(StringExpression node) {
    // TODO(srawlins): visit and test `text`.
    return <Lint>[];
  }

  @override
  List<Lint> visitStyleRule(StyleRule node) {
    var lint = _visitInterpolation(node.selector);
    for (var child in node.children) {
      lint.addAll(child.accept(this));
    }
    return lint;
  }

  @override
  List<Lint> visitStylesheet(Stylesheet node) {
    return node.children.expand((child) => child.accept(this)).toList();
  }

  @override
  List<Lint> visitSupportsRule(SupportsRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitUnaryOperationExpression(UnaryOperationExpression node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitValueExpression(ValueExpression node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitVariableDeclaration(VariableDeclaration node) {
    return node.expression.accept(this);
  }

  @override
  List<Lint> visitVariableExpression(VariableExpression node) {
    return <Lint>[];
  }

  @override
  List<Lint> visitWarnRule(WarnRule node) {
    return node.expression.accept(this);
  }

  @override
  List<Lint> visitWhileRule(WhileRule node) {
    throw new UnimplementedError();
  }

  List<Lint> _visitInterpolation(Interpolation node) {
    var lint = <Lint>[];
    for (var value in node.contents) {
      if (value is String) continue;
      lint.addAll((value as Expression).accept(this));
    }
    return lint;
  }
}
