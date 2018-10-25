// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// An exception indicating that invalid arguments were passed.
class UsageException implements Exception {
  final String message;

  UsageException(this.message);
}
