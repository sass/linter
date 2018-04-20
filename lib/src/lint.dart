// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import 'rule.dart';

/// A violation of a lint rule; a piece of lint.
class Lint {
  /// The rule which generated this violation.
  final Rule rule;

  /// A helpful description of this violation.
  final String message;

  /// The location of the violation in the source.
  final FileSpan span;

  Lint({@required this.rule, @required this.message, @required this.span});

  /// The URL of the source of this violation.
  Uri get url => span.sourceUrl;

  /// The 1-based line number of this violation in the source.
  int get line => span.start.line;

  /// The 1-based column number of this violation in the source.
  int get column => span.start.column;
}
