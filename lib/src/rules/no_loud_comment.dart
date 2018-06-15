// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:charcode/charcode.dart';

// The sass package's API is not necessarily stable. It is being imported with
// the Sass team's explicit knowledge and approval. See
// https://github.com/sass/dart-sass/issues/236.
import 'package:sass/src/ast/sass.dart';

import '../lint.dart';
import '../rule.dart';

/// A lint rule that reports on the existence of "loud" (`/* */`) comments.
///
/// Comments should typically be "silent" (`//`), so that they are not shipped
/// to browsers, in the CSS output.
class NoLoudCommentRule extends Rule {
  NoLoudCommentRule() : super('no_loud_comment_rule');

  @override
  List<Lint> visitLoudComment(LoudComment node) {
    var textContents = node.text.contents;
    if (textContents.isNotEmpty &&
        textContents.first is String &&
        textContents.first.codeUnitAt(2) == $exclamation) {
      // Loud "preserved" comments are fine. See
      // https://sass-lang.com/documentation/file.SASS_REFERENCE.html#comments.
      return <Lint>[];
    }

    return [
      new Lint(
          rule: this,
          span: node.span,
          message: 'Comments should be written with the silent (`//`) syntax.')
    ];
  }
}
