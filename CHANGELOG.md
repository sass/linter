## 0.0.1

* Both files and directories can be passed to the script. Directories will be
  searched recursively for files with the `.scss` extension.
* New rules: `no_debug_rule`, `no_empty_style_rule`, `no_loud_comment_rule`,
  `non_numeric_dimension_rule`, `quote_map_keys_rule`, `use_falsey_null_rule`,
  `use_scale_color`, each with tests
* Script supports arguments: `--stdin` (and alias `-`), `--rules`, and
  `--stdin-file-url`
