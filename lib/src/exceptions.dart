// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:source_span/source_span.dart';

/// An exception indicating that invalid values were found in a config YAML
/// file.
class ConfigParseException extends SourceSpanFormatException {
  ConfigParseException(String message, SourceSpan span) : super(message, span);
}

class UnknownRuleException implements Exception {
  final String ruleName;

  UnknownRuleException(this.ruleName);
}

/// An exception indicating that invalid arguments were passed.
class UsageException implements Exception {
  final String message;

  UsageException(this.message);
}
