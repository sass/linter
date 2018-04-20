import 'package:source_span/source_span.dart';

/// A violation of a lint rule; a piece of lint.
class Lint {
  /// The name of the rule which this violation represents.
  final String ruleName;

  /// A helpful description of this violation.
  final String message;

  /// The location of the violation in the source.
  final FileSpan span;

  Lint({this.ruleName, this.message, this.span});

  /// The URL of the source of this violation.
  Uri get url => span.file.url;

  /// The 1-based line number of this violation in the source.
  int get line => span.start.line + 1;

  /// The 1-based column number of this violation in the source.
  int get column => span.start.column + 1;
}
