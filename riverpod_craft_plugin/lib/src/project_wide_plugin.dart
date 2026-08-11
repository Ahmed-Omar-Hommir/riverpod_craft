import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;

/// A craft_runner plugin that operates across the entire project rather than
/// one file at a time.
///
/// Use this when generated output aggregates information spread across many
/// source files — e.g. a single `AppApi` whose nested groups are populated
/// from `@Api`-annotated retrofit classes scattered across the codebase.
///
/// Lifecycle, once per full pass (startup, watch event, `generate`):
///   1. [reset]              — clear accumulated state.
///   2. [collectFromUnit]    — invoked for every Dart source file under each of
///                             this plugin's [sourceRoots] (excluding
///                             `*.craft.dart`, `*.g.dart`, `*.freezed.dart`).
///   3. [generate]           — return `{output_path: file_contents}`; an
///                             empty map means no output. craft_runner adds
///                             the GENERATED header and runs `dart_style`.
abstract class ProjectWideCraftPlugin {
  /// Stable identifier (e.g. `'retrofit_api'`).
  String get id;

  /// Project-relative directories whose Dart files are parsed and fed to
  /// [collectFromUnit]. Return `['lib']` for the common case, or e.g.
  /// `['test']` / `['lib', 'test']` for plugins whose sources live elsewhere.
  /// A parsed unit is delivered only to plugins that list its enclosing root,
  /// so a `lib`-only plugin never receives another plugin's `test/` files.
  List<String> get sourceRoots;

  /// Reset accumulated state at the start of a full pass.
  void reset();

  /// Contribute to internal state from one parsed source unit.
  void collectFromUnit(ParseStringResult unit, String filePath);

  /// Produce `{output_path: file_contents}`. Paths are project-relative or
  /// absolute; contents are the raw class bodies (no header, no `part of`).
  Map<String, String> generate();
}
