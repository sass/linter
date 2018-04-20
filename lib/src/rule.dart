// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/visitor/interface/statement.dart';

import 'lint.dart';

/// A parent class for all lint rules, which visits all nodes in a [Stylesheet].
///
/// The implementations of each visitor will eventually guarantee a traversal
/// of an entire [Stylesheet]. Extenders need only visit individual nodes that
/// they might act on.
abstract class Rule implements StatementVisitor<List<Lint>> {
  /// The name of the lint rule.
  ///
  /// The [name] acts as an identifier, and may be used in output. It should be
  /// underscore_case, unique, and brief.
  final String name;

  Rule(this.name);

  @override
  List<Lint> visitAtRootRule(AtRootRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitAtRule(AtRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitContentRule(ContentRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitDeclaration(Declaration node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitEachRule(EachRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitErrorRule(ErrorRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitExtendRule(ExtendRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitForRule(ForRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitFunctionRule(FunctionRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitIfRule(IfRule node) {
    throw new UnimplementedError();
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
  List<Lint> visitLoudComment(LoudComment node) {
    throw new UnimplementedError();
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
  List<Lint> visitReturnRule(ReturnRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitSilentComment(SilentComment node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitStyleRule(StyleRule node) {
    throw new UnimplementedError();
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
  List<Lint> visitVariableDeclaration(VariableDeclaration node) {
    // TODO(srawlins): visit expressions.
    return <Lint>[];
  }

  @override
  List<Lint> visitWarnRule(WarnRule node) {
    throw new UnimplementedError();
  }

  @override
  List<Lint> visitWhileRule(WhileRule node) {
    throw new UnimplementedError();
  }
}
