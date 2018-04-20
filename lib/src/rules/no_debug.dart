// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';

import '../lint.dart';
import '../rule.dart';

/// A lint rule that reports on the existence of @debug at-rules.
///
/// These at-rules should not be found in Sass documents, for example checked
/// into source control.
class NoDebugRule extends Rule {
  NoDebugRule() : super('debug_directive_rule');

  @override
  List<Lint> visitDebugRule(DebugRule node) {
    return [
      new Lint(
          rule: this,
          span: node.span,
          message: '@debug directives should be removed.')
    ];
  }
}
