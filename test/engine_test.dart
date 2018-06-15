// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sass_linter/src/engine.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  test('runs the linter against a single file', () async {
    await d.file('a.scss', '''
      @debug("debug message one here");
      @debug("debug message two here");
    ''').create();

    var path = p.join(d.sandbox, 'a.scss');

    var engine = new Engine([path]);
    var lints = engine.run();

    expect(lints, hasLength(2));
    expect(lints[0].url.path, equals(path));
    expect(lints[1].url.path, equals(path));
    // The engine returns 0-indexed line numbers.
    expect(lints[0].line, equals(0));
    expect(lints[1].line, equals(1));
  });

  test('runs the linter against multiple files', () async {
    await d.file('a.scss', '''
      @debug("message one here");
    ''').create();
    await d.file('b.scss', '''
      @debug("message two here");
    ''').create();

    var pathA = p.join(d.sandbox, 'a.scss');
    var pathB = p.join(d.sandbox, 'b.scss');
    var engine = new Engine([pathA, pathB]);
    var lints = engine.run();

    expect(lints, hasLength(2));
    expect(lints[0].url.path, equals(pathA));
    expect(lints[1].url.path, equals(pathB));
    // The engine returns 0-indexed line numbers.
    expect(lints[0].line, equals(0));
    expect(lints[1].line, equals(0));
  });
}
