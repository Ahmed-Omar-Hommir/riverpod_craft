import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;
import 'package:path/path.dart' as p;
import 'package:craft_runner/craft_runner.dart';

import 'api_generator.dart';
import 'api_scanner.dart';
import 'retrofit_craft_config.dart';

/// craft_runner project-wide plugin: scans every Dart file in `lib/` for
/// `@Api`-annotated retrofit classes plus enum (or class-with-static-const)
/// declarations of `Entry` and `Version`, then emits one aggregator file
/// (`lib/app/app_api.craft.dart` by default).
///
/// Register in `tool/craft.dart`:
///
/// ```dart
/// import 'package:craft_runner/craft_runner.dart';
/// import 'package:retrofit_craft_plugin/retrofit_craft_plugin.dart';
///
/// void main(List<String> args) {
///   runWithPlugins(const [], args,
///       projectWidePlugins: [RetrofitApiPlugin()]);
/// }
/// ```
class RetrofitApiPlugin implements ProjectWideCraftPlugin {
  RetrofitApiPlugin({RetrofitCraftConfig? config, Directory? rootDir})
      : _explicitConfig = config,
        // ignore: prefer_initializing_formals
        _rootDir = rootDir;

  final RetrofitCraftConfig? _explicitConfig;
  final Directory? _rootDir;

  final ApiScanner _scanner = ApiScanner();
  RetrofitCraftConfig? _loadedConfig;

  @override
  String get id => 'retrofit_api';

  @override
  List<String> get sourceRoots => const ['lib'];

  @override
  void reset() {
    _scanner.reset();
    _loadedConfig = _explicitConfig;
    // Reset scoping; will be (re-)applied on the first collectFromUnit.
    _scanner.entryFilePath = null;
    _scanner.versionFilePath = null;
  }

  @override
  void collectFromUnit(ParseStringResult unit, String filePath) {
    final config = _config();
    final rootDir = _rootDir ?? Directory.current;

    _scanner.entryFilePath = _resolveScope(config.entryPath, rootDir);
    _scanner.versionFilePath = _resolveScope(config.versionPath, rootDir);

    _scanner.collectFromUnit(unit, filePath);
  }

  @override
  Map<String, String> generate() {
    final config = _config();
    final rootDir = _rootDir ?? Directory.current;
    final outputAbsPath = p.normalize(
      p.isAbsolute(config.output)
          ? config.output
          : p.join(rootDir.path, config.output),
    );

    final result = generateAppApi(
      config: config,
      entries: _scanner.entries,
      versions: _scanner.versions,
      apiClasses: _scanner.apiClasses,
      outputAbsPath: outputAbsPath,
    );

    if (!result.success) {
      for (final d in result.diagnostics) {
        print('retrofit_craft: $d');
      }
      final stale = File(outputAbsPath);
      if (stale.existsSync()) stale.deleteSync();
      return const {};
    }

    return {outputAbsPath: result.source!};
  }

  RetrofitCraftConfig _config() {
    return _loadedConfig ??=
        _explicitConfig ?? RetrofitCraftConfig.load(_rootDir);
  }

  String? _resolveScope(String? path, Directory rootDir) {
    if (path == null) return null;
    return p.normalize(
      p.isAbsolute(path) ? path : p.join(rootDir.path, path),
    );
  }
}
