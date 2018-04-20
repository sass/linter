import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/visitor/interface/statement.dart';

import 'lint.dart';

/// A parent class for all lint rules, which visits all nodes in a [Stylesheet].
///
/// The implementations of each visitor will eventually guarantee a traversal
/// of an entire [Stylesheet]. Extenders need only visit individual nodes that
/// they might act on.
abstract class Rule implements StatementVisitor<void> {
  /// The name of the lint rule.
  final String name;

  /// The list of lints found while visiting a [Stylesheet].
  final List<Lint> lints = <Lint>[];

  Rule(this.name);

  @override
  void visitAtRootRule(AtRootRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitAtRule(AtRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitContentRule(ContentRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitDeclaration(Declaration node) {
    throw new UnimplementedError();
  }

  @override
  void visitEachRule(EachRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitErrorRule(ErrorRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitExtendRule(ExtendRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitForRule(ForRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitFunctionRule(FunctionRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitIfRule(IfRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitImportRule(ImportRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitIncludeRule(IncludeRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitLoudComment(LoudComment node) {
    throw new UnimplementedError();
  }

  @override
  void visitMediaRule(MediaRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitMixinRule(MixinRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitReturnRule(ReturnRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitSilentComment(SilentComment node) {
    throw new UnimplementedError();
  }

  @override
  void visitStyleRule(StyleRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitStylesheet(Stylesheet node) {
    for (var child in node.children) child.accept(this);
  }

  @override
  void visitSupportsRule(SupportsRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    // TODO(srawlins): visit expressions.
  }

  @override
  void visitWarnRule(WarnRule node) {
    throw new UnimplementedError();
  }

  @override
  void visitWhileRule(WhileRule node) {
    throw new UnimplementedError();
  }

  /// Report a single lint at [node].
  void reportLint(SassNode node, String message) {
    lints.add(new Lint(ruleName: name, message: message, span: node.span));
  }
}
