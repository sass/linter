// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

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
    var lints = engine.run().toList();

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
    var lints = engine.run().toList();

    expect(lints, hasLength(2));
    expect(lints[0].url.path, equals(pathA));
    expect(lints[1].url.path, equals(pathB));
    // The engine returns 0-indexed line numbers.
    expect(lints[0].line, equals(0));
    expect(lints[1].line, equals(0));
  });

  test('runs the linter against a single directory', () async {
    await d.dir('parent', [
      d.file('a.scss', '''
        @debug("debug message one here");
        @debug("debug message two here");
      '''),
      d.dir('child', [
        d.file('b.scss', '''
          @debug("debug message three here");
        '''),
      ]),
    ]).create();

    var parentPath = p.join(d.sandbox, 'parent');
    var pathA = p.join(parentPath, 'a.scss');
    var pathB = p.join(parentPath, 'child', 'b.scss');

    var engine = new Engine([parentPath]);
    var lints = engine.run().toList();

    expect(lints, hasLength(3));
    expect(lints[0].url.path, equals(pathA));
    expect(lints[1].url.path, equals(pathA));
    expect(lints[2].url.path, equals(pathB));
  });

  test('skips non-Sass files', () async {
    await d.dir('parent', [
      d.file('a.txt', '''
        // This file is not Sass. But what if it really looked like Sass?
        @debug("debug message one here");
      '''),
    ]).create();

    var path = p.join(d.sandbox, 'parent');
    var engine = new Engine([path]);
    expect(engine.run(), isEmpty);
  });
}
