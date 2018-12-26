// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:sass_linter/src/engine.dart';
import 'package:sass_linter/src/exceptions.dart';
import 'package:sass_linter/src/rule.dart';

/// A collection of configuration options.
class Configuration {
  /// An empty configuration with only default values.
  static final empty = Configuration._(null, <String>[]);

  /// Rules to use when linting.
  final List<Rule> rules;

  /// Paths which the linter will examine.
  final List<String> paths;

  /// Load a [YamlNode] from [source] and ensure that it is a [YamlMap].
  static YamlMap _loadYamlMap(String source, String path) {
    try {
      var document = loadYamlNode(source, sourceUrl: p.toUri(path));

      if (document is! Map) {
        throw ConfigParseException(
            'The configuration file must be a Yaml map.', document.span);
      }

      return document as YamlMap;
    } on YamlException catch (error) {
      throw ConfigParseException(error.toString(), error.span);
    }
  }

  /// Asserts that [field] is a list and runs [forElement] for each element it
  /// contains.
  ///
  /// Returns a list of values returned by [forElement].
  static List<T> _getList<T>(
      YamlMap document, String field, T forElement(YamlNode elementNode)) {
    var node = document.nodes[field];
    if (node.value == null) return [];
    _validate(node, '"$field" in the configuration file must be a List.',
        (value) => value is List);
    return (node as YamlList).nodes.map(forElement).toList();
  }

  /// Throws an exception with [message] if [test] returns `false` when passed
  /// [node]'s value.
  static void _validate(YamlNode node, String message, bool test(value)) {
    if (test(node.value)) return;
    throw ConfigParseException(message, node.span);
  }

  /// Parse a [Configuration] from a YAML file at [path].
  factory Configuration.parse(String path) {
    var source = File(path).readAsStringSync();
    if (source.isEmpty) return Configuration.empty;

    var document = Configuration._loadYamlMap(source, path);
    if (document.value == null) return Configuration.empty;

    List<Rule> rules;

    // Use `null` for a missing or `null` value, and let the engine populate a
    // default list.
    if (document.containsKey('rules') && document['rules'] != null) {
      var ruleNameNodes = _getList(document, 'rules', (ruleNode) {
        _validate(
            ruleNode, 'Rules must be strings.', (value) => value is String);
        return ruleNode;
      });
      rules = [];
      for (var ruleNameNode in ruleNameNodes) {
        try {
          rules.add(parseRule(ruleNameNode.value));
        } on UnknownRuleException {
          throw ConfigParseException('Unknown rule', ruleNameNode.span);
        }
      }
    }

    List<String> paths = [];

    if (document.containsKey('paths')) {
      paths = _getList(document, 'paths', (pathNode) {
        _validate(
            pathNode, 'Paths must be strings.', (value) => value is String);
        return pathNode.value;
      });
    }
    return Configuration._(rules, paths);
  }

  Configuration._(this.rules, this.paths);
}
