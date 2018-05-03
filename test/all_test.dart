// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'rule_test.dart' as rule_test;
import 'rules/no_debug_test.dart' as no_debug_test;

// This file is here for easy coverage gathering; one file to execute with
// `dart`.
void main() {
  rule_test.main();
  no_debug_test.main();
}
