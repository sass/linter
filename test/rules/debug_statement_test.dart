import 'package:sass_linter/sass_linter.dart';
import 'package:test/test.dart';

void main() {
  var url = 'a.scss';

  List<Lint> getLints(String source) =>
      new Linter(source, rules: [new DebugDirectiveRule()], url: url).run();

  test('does not report lint when no @debug directive is found', () {
    var lints = getLints(r'$red: #f00;');

    expect(lints, isEmpty);
  });

  test('reports lint when @debug directive is found', () {
    var lints = getLints(r'@debug 10em + 12em;');

    expect(lints, hasLength(1));

    var lint = lints.single;
    expect(lint.ruleName, 'debug_directive_rule');
    expect(lint.message, contains('@debug directives should be removed.'));
    expect(lint.url, new Uri.file(url));
    expect(lint.line, 1);
    expect(lint.column, 1);
  });
}
