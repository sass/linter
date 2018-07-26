# Sass Linter

The Sass Linter is the official linter of the Sass and SCSS languages.

# Using the Sass Linter

The Sass Linter does not yet have a runnable script. Stay tuned.

# Goals

There have been several stellar Sass linting tools, which help developers
adhere to style guides, avoid typos and pitfalls, etc. These improve developer
productivity by preventing bugs and reducing time in code review.

However, none of these linters is written in Dart, the language of the official
Sass implementation, and thus none use the primary Sass parser or AST which will
be supported in the future. The [scss-lint] project in particular, written in
Ruby, using the original parser, will fall behind as the Sass language moves
beyond the Ruby implementation.

The Sass Linter will be an officially supported client of the Dart Sass's AST,
and will stay up-to-date with language changes as they are implemented in the
official implementation, Dart Sass.

[scss-lint]: https://github.com/brigade/scss-lint

# TODO

Don't release this stuff till these TODOs are done or deprioritized:

* [x] DebugStatement
* [x] SilentComment
* [ ] MergeableSelector
* [ ] EmptyRule
* [ ] ImportPath
* [ ] Ignore via `ignore: `
* [ ] README
* [x] COTNRIBUTING.md
* [ ] Lint rules README
* [-] Tests
* [-] Tests of message, line, column
* [ ] Fixes
* [x] Command line
  * [x] Flag: --stdin
  * [x] Flag: --stdin-file-path
  * [ ] Flag: --color
  * [x] Flag: --help
  * [ ] FLag: --options-file
* [ ] Options file
  * [ ] Ignore lint rules
  * [ ] Ignore globs
* [ ] Travis
* [ ] Coverage
* [ ] Performance
