import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:craft_runner/file_processor.dart';
import 'package:craft_runner/src/plugin_loader.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

/// Main entry point for the craft_runner CLI.
class CraftRunnerCli {
  /// Reentry guard env var. The auto-generated entry script re-invokes
  /// the same `dart run` chain, which would loop forever; the child sets
  /// this to bypass the parent's handoff on the second pass.
  static const _reentryEnvVar = 'CRAFT_RUNNER_REENTRY';

  /// Env var carrying the parent-computed SHA of the entry snapshot. The kernel
  /// snapshot is deterministic and embeds every plugin + framework library, so
  /// its hash is a complete "generator changed" signal. Computed in the parent
  /// (during the compile it already pays for) so the child's startup fingerprint
  /// stays cheap.
  static const _entryHashEnvVar = 'CRAFT_RUNNER_ENTRY_HASH';

  /// Fingerprint of the generator for this watch session, reused when the
  /// manifest is refreshed after in-watch passes.
  static String? _sessionFingerprint;

  /// Project subdirectories craft_runner scans and watches. Hand-written
  /// sources and every generated `.craft.dart` live under these. Scanning the
  /// project root instead recurses into `.dart_tool/`,
  /// `build/`, `ios/`, `.git/` and the like — on a real Flutter app that is
  /// ~300k filesystem entries and ~4s per walk (done twice at startup), versus
  /// a few hundred entries and ~15ms when scoped here.
  static const List<String> sourceRoots = ['lib', 'test'];

  /// Streams every `.dart` file under the project's [sourceRoots], skipping
  /// any root that is absent. Replaces the old whole-project recursive walks.
  static Stream<File> _sourceDartFiles(Directory root) async* {
    for (final sub in sourceRoots) {
      final dir = Directory(path.join(root.path, sub));
      if (!dir.existsSync()) continue;
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.dart')) yield entity;
      }
    }
  }

  static Future<void> main(List<String> args) async {
    // If yaml declares community plugins, hand off to a generated entry
    // script that imports + instantiates them. Skipped when re-entered
    // (the child sets [_reentryEnvVar]) or when the caller already wired
    // plugins in-process via `runWithPlugins(...)`.
    if (Platform.environment[_reentryEnvVar] != 'true' &&
        !FileProcessor.hasRegisteredPlugins) {
      final handed = await _maybeHandoffToYamlPlugins(args);
      if (handed) return;
    }

    if (args.isEmpty) {
      await _startWatchMode();
    } else {
      await _processCommandLineArgs(args);
    }
  }

  /// If `craft_runner.yaml`'s `plugins:` list is non-empty, generate
  /// `.dart_tool/craft_runner/entry.dart` (imports each declared plugin,
  /// instantiates it, dispatches via `runWithPlugins`) and spawn
  /// `dart run` on it. Returns `true` when handoff happened.
  static Future<bool> _maybeHandoffToYamlPlugins(List<String> args) async {
    final specs = PluginLoader.loadPluginSpecs();
    if (specs.isEmpty) return false;

    final rootDir = Directory.current.path;
    final entryDir = Directory(
      path.join(rootDir, '.dart_tool', 'craft_runner'),
    );
    await entryDir.create(recursive: true);
    final entryFile = File(path.join(entryDir.path, 'entry.dart'));

    final script = _buildEntryScript(specs);
    if (!entryFile.existsSync() || entryFile.readAsStringSync() != script) {
      entryFile.writeAsStringSync(script);
    }

    print(
      '🔌 loaded ${specs.length} plugin(s) from craft_runner.yaml '
      '→ handing off to entry.dart',
    );

    final exitCode = await _runEntry(entryFile, args, rootDir);
    if (exitCode != 0) exit(exitCode);
    return true;
  }

  /// Runs the generated entry script by compiling it to a kernel snapshot and
  /// executing that directly.
  ///
  /// A raw `dart run <file>` re-runs dependency resolution + native-asset build
  /// hooks and JIT-compiles the whole plugin graph (including the large
  /// `analyzer` package) on every launch. Running a precompiled snapshot skips
  /// all of that — no build-hook step, and the plugin graph is compiled once.
  /// Recompiled every launch (the compile itself does not run build hooks) so a
  /// plugin-source edit is never served stale. Falls back to `dart run` if the
  /// snapshot can't be produced.
  static Future<int> _runEntry(
    File entryFile,
    List<String> args,
    String rootDir,
  ) async {
    final snapshot = File(path.setExtension(entryFile.path, '.dill'));
    final compiled = await _compileEntry(entryFile, snapshot, rootDir);
    final env = {_reentryEnvVar: 'true'};
    if (compiled) {
      final digest = sha256.convert(await snapshot.readAsBytes());
      env[_entryHashEnvVar] = digest.toString();
    }
    final proc = await Process.start(
      'dart',
      compiled ? [snapshot.path, ...args] : ['run', entryFile.path, ...args],
      mode: ProcessStartMode.inheritStdio,
      environment: env,
      workingDirectory: rootDir,
    );
    return proc.exitCode;
  }

  static Future<bool> _compileEntry(
    File entryFile,
    File snapshot,
    String rootDir,
  ) async {
    try {
      final result = await Process.run(
        'dart',
        ['compile', 'kernel', entryFile.path, '-o', snapshot.path],
        workingDirectory: rootDir,
      );
      if (result.exitCode == 0 && snapshot.existsSync()) return true;
      stderr.writeln(
        'craft_runner: entry snapshot compile failed; using `dart run`.\n'
        '${(result.stdout as String).trim()}\n'
        '${(result.stderr as String).trim()}',
      );
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Build the source of `.dart_tool/craft_runner/entry.dart`. Each plugin
  /// is instantiated and collected as a [ProjectWideCraftPlugin], then handed
  /// to `runWithPlugins`.
  static String _buildEntryScript(List<PluginSpec> specs) {
    final buf = StringBuffer();
    buf.writeln('// GENERATED by craft_runner. DO NOT EDIT.');
    buf.writeln('// Source: craft_runner.yaml `plugins:` entries.');
    buf.writeln("import 'package:craft_runner/craft_runner.dart';");
    for (var i = 0; i < specs.length; i++) {
      buf.writeln("import '${specs[i].importUri}' as _p$i;");
    }
    buf.writeln();
    buf.writeln('Future<void> main(List<String> args) async {');
    buf.writeln('  final projectWide = <ProjectWideCraftPlugin>[];');
    for (var i = 0; i < specs.length; i++) {
      final cls = specs[i].className;
      buf.writeln('  final Object p$i = _p$i.$cls();');
      buf.writeln(
        '  if (p$i is ProjectWideCraftPlugin) projectWide.add(p$i);',
      );
    }
    buf.writeln('  await runWithPlugins(projectWide, args);');
    buf.writeln('}');
    return buf.toString();
  }

  /// Starts watch mode to monitor file changes
  static Future<void> _startWatchMode() async {
    print('🚀 craft_runner · watch mode');

    final currentDir = Directory.current;

    final sw = Stopwatch()..start();

    // Skip the whole build when nothing that affects output has changed since
    // the last run: same generator (plugins/framework/config) and same source
    // file set + mtimes, and every recorded output still on disk. This turns a
    // no-change restart from a full cold rebuild into a stat-only pass.
    final fingerprint = await _generatorFingerprint(currentDir);
    _sessionFingerprint = fingerprint;
    final sources = await _scanSourceMtimes(currentDir);
    final manifest = _loadManifest(currentDir);
    final upToDate = manifest != null &&
        manifest['fingerprint'] == fingerprint &&
        _sourcesUnchanged(manifest['sources'], sources) &&
        _outputsPresent(manifest['outputs']);

    if (upToDate) {
      print('⚡ up to date · ${sources.length} sources unchanged');
    } else {
      await _cleanupExistingFiles(currentDir);
      await _runProjectWidePass(currentDir);
      await _saveManifest(currentDir, fingerprint, sources);
    }

    // Watch only the source roots. A recursive watch on the project root also
    // delivers (then filters) every `.dart_tool/` and `build/` churn event.
    final watched = <String>[];
    for (final sub in sourceRoots) {
      final dir = Directory(path.join(currentDir.path, sub));
      if (!dir.existsSync()) continue;
      dir.watch(recursive: true).listen((event) async {
        await _handleFileEvent(event.path);
      });
      watched.add('$sub/');
    }

    print(
      '✅ ready in ${sw.elapsedMilliseconds}ms · watching ${watched.join(', ')}',
    );
  }

  /// Debounce timer for project-wide passes triggered by watch events.
  static Timer? _projectWideDebounce;

  /// Last logged trigger path + time, used to collapse the burst of duplicate
  /// file-system events macOS delivers for a single save into one `✎` line.
  static String? _lastTriggerPath;
  static DateTime _lastTriggerAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Schedules a project-wide regeneration if any project-wide plugin is
  /// registered, debounced 250ms so a save-storm produces at most one pass.
  static void _scheduleProjectWidePass(Directory dir) {
    if (!FileProcessor.projectWideProcessor.hasPlugins) return;
    _projectWideDebounce?.cancel();
    _projectWideDebounce = Timer(const Duration(milliseconds: 250), () async {
      await FileProcessor.projectWideProcessor.runFullPass(dir.path);
      await _refreshManifest(dir);
    });
  }

  /// Runs the project-wide pass once and awaits it (used at startup and
  /// after single-file `generate`, where we want output before returning).
  static Future<void> _runProjectWidePass(Directory dir) async {
    if (!FileProcessor.projectWideProcessor.hasPlugins) return;
    await FileProcessor.projectWideProcessor.runFullPass(dir.path);
  }

  // ---- Startup-skip manifest ----------------------------------------------

  static File _manifestFile(Directory dir) =>
      File(path.join(dir.path, '.dart_tool', 'craft_runner', 'manifest.json'));

  static Map<String, dynamic>? _loadManifest(Directory dir) {
    final file = _manifestFile(dir);
    if (!file.existsSync()) return null;
    try {
      final data = jsonDecode(file.readAsStringSync());
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveManifest(
    Directory dir,
    String fingerprint,
    Map<String, int> sources,
  ) async {
    final outputs = <String>[];
    await for (final file in _sourceDartFiles(dir)) {
      if (file.path.endsWith('.craft.dart')) {
        outputs.add(path.normalize(file.path));
      }
    }
    final file = _manifestFile(dir);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'fingerprint': fingerprint,
        'sources': sources,
        'outputs': outputs,
      }),
    );
  }

  /// Rewrites the manifest after an in-watch pass so the next restart reflects
  /// the current source state (and can skip when nothing changed).
  static Future<void> _refreshManifest(Directory dir) async {
    final fingerprint = _sessionFingerprint;
    if (fingerprint == null) return;
    await _saveManifest(dir, fingerprint, await _scanSourceMtimes(dir));
  }

  /// `{normalizedPath: mtimeMs}` for every non-generated source `.dart` under
  /// the source roots.
  static Future<Map<String, int>> _scanSourceMtimes(Directory dir) async {
    final result = <String, int>{};
    await for (final file in _sourceDartFiles(dir)) {
      final p = file.path;
      if (p.endsWith('.craft.dart') ||
          p.endsWith('.g.dart') ||
          p.endsWith('.freezed.dart')) {
        continue;
      }
      result[path.normalize(p)] =
          (await file.lastModified()).millisecondsSinceEpoch;
    }
    return result;
  }

  /// A hash that changes whenever the generator would produce different output:
  /// the entry snapshot (all plugin + framework code, hashed by the parent),
  /// craft_runner.yaml, and the inlined mapper files. Falls back to a
  /// never-matching value when the snapshot hash is unavailable (the `dart run`
  /// fallback path) so a rebuild happens rather than risking stale output.
  static Future<String> _generatorFingerprint(Directory dir) async {
    final entryHash = Platform.environment[_entryHashEnvVar];
    if (entryHash == null) {
      return 'no-snapshot:${DateTime.now().microsecondsSinceEpoch}';
    }
    // Generator code (incl. any plugin's own config handling) is captured by the
    // entry-snapshot hash; plugin config files that live under lib/ (e.g. a
    // a plugin's mapper) are caught by the generic source-mtime scan.
    return 'entry:$entryHash|'
        'yaml:${await _hashFile(File(path.join(dir.path, 'craft_runner.yaml')))}';
  }

  static Future<String> _hashFile(File file) async {
    if (!file.existsSync()) return '';
    return sha256.convert(await file.readAsBytes()).toString();
  }

  static bool _sourcesUnchanged(Object? recorded, Map<String, int> current) {
    if (recorded is! Map) return false;
    if (recorded.length != current.length) return false;
    for (final entry in current.entries) {
      if (recorded[entry.key] != entry.value) return false;
    }
    return true;
  }

  static bool _outputsPresent(Object? outputs) {
    if (outputs is! List) return false;
    for (final p in outputs) {
      if (p is! String || !File(p).existsSync()) return false;
    }
    return true;
  }

  /// Processes command line arguments
  static Future<void> _processCommandLineArgs(List<String> args) async {
    final command = args[0].toLowerCase();

    switch (command) {
      case 'watch':
        await _startWatchMode();
        break;
      case 'generate':
        if (args.length < 2) {
          print('❌ Error: Please specify a file path');
          print('Usage: craft_runner generate <file_path>');
          return;
        }
        final filePath = args[1];
        await _generateSingleFile(filePath);
        break;
      case 'clean':
        await _cleanAllGeneratedFiles();
        break;
      case 'init':
        await _runInit();
        break;
      case 'help':
        _showHelp();
        break;
      default:
        print('❌ Unknown command: $command');
        _showHelp();
    }
  }

  /// Generates a single file
  static Future<void> _generateSingleFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      print('❌ Error: File not found: $filePath');
      return;
    }

    print(
        '🔄 generating ${path.relative(file.path, from: Directory.current.path)}');

    await _runProjectWidePass(Directory.current);
  }

  /// Cleans all generated files
  static Future<void> _cleanAllGeneratedFiles() async {
    final currentDir = Directory.current;

    final List<File> generatedFiles = [];
    await for (final entity in _sourceDartFiles(currentDir)) {
      if (entity.path.endsWith('.craft.dart')) {
        generatedFiles.add(entity);
      }
    }

    for (final file in generatedFiles) {
      await file.delete();
      print('🗑️  Deleted: ${path.basename(file.path)}');
    }

    print('✅ Cleaned ${generatedFiles.length} generated files');
  }

  /// Runs the init command to set up the project
  static Future<void> _runInit() async {
    print('🚀 Initializing project...');
    print('=' * 50);

    await _installFlutterDependencies();
    await _installVSCodeExtension();

    print('');
    print('=' * 50);
    print('✅ Project initialized successfully!');
  }

  static Future<void> _installFlutterDependencies() async {
    print('');
    print('📦 Installing global tools...');

    final tools = ['flutter_gen'];

    for (final tool in tools) {
      print('   Activating $tool...');
      final result = await Process.run(
          'dart',
          [
            'pub',
            'global',
            'activate',
            tool,
          ],
          runInShell: true);

      if (result.exitCode == 0) {
        print('   ✅ $tool activated');
      } else {
        print('   ⚠️  Failed to activate $tool: ${result.stderr}');
      }
    }
  }

  static Future<void> _installVSCodeExtension() async {
    print('');
    print('🔌 Installing VS Code extension...');

    final extensionDir = Directory('extention/provider-converter');
    if (!await extensionDir.exists()) {
      print(
          '   ⚠️  Extension directory not found: extention/provider-converter/');
      print('   💡 Building extension from source...');
      await _buildVSCodeExtension();
      return;
    }

    File? latestVsix;
    String latestVersion = '';

    await for (final entity in extensionDir.list()) {
      if (entity is File && entity.path.endsWith('.vsix')) {
        final fileName = path.basename(entity.path);
        final versionMatch =
            RegExp(r'(\d+\.\d+\.\d+)\.vsix').firstMatch(fileName);
        if (versionMatch != null) {
          final version = versionMatch.group(1)!;
          if (latestVersion.isEmpty ||
              _compareVersions(version, latestVersion) > 0) {
            latestVersion = version;
            latestVsix = entity;
          }
        }
      }
    }

    if (latestVsix == null) {
      print('   ⚠️  No .vsix file found in extention/provider-converter/');
      print('   💡 Building extension from source...');
      await _buildVSCodeExtension();
      return;
    }

    print('   Found extension: ${path.basename(latestVsix.path)}');

    final result = await Process.run(
        'code',
        [
          '--install-extension',
          latestVsix.absolute.path,
          '--force',
        ],
        runInShell: true);

    if (result.exitCode == 0) {
      print('   ✅ VS Code extension installed');
    } else {
      print('   ⚠️  Failed to install extension: ${result.stderr}');
      print('   💡 Try manually: code --install-extension ${latestVsix.path}');
    }
  }

  static Future<void> _buildVSCodeExtension() async {
    final extensionDir = Directory('extention/provider-converter');
    if (!await extensionDir.exists()) {
      print('   ❌ Extension source not found');
      return;
    }

    print('   Running npm install...');
    var result = await Process.run('npm', ['install'],
        workingDirectory: extensionDir.path, runInShell: true);

    if (result.exitCode != 0) {
      print('   ❌ npm install failed: ${result.stderr}');
      return;
    }

    print('   Running vsce package...');
    result = await Process.run('npx', ['vsce', 'package'],
        workingDirectory: extensionDir.path, runInShell: true);

    if (result.exitCode != 0) {
      print('   ❌ vsce package failed: ${result.stderr}');
      return;
    }

    print('   ✅ Extension built successfully');
    await _installVSCodeExtension();
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1.compareTo(p2);
    }
    return 0;
  }

  static Future<void> _handleFileEvent(String eventPath) async {
    final normalized = path.normalize(eventPath);

    // Skip non-Dart files and generator outputs.
    if (!normalized.endsWith('.dart') ||
        normalized.endsWith('.craft.dart') ||
        normalized.endsWith('.g.dart') ||
        normalized.endsWith('.freezed.dart')) {
      return;
    }

    // Show the trigger so the cause of the pass below is visible at a glance
    // (and any unexpected churn is easy to spot) — collapsing the duplicate
    // events macOS fires for a single save into one line.
    final now = DateTime.now();
    final isDuplicate = normalized == _lastTriggerPath &&
        now.difference(_lastTriggerAt).inMilliseconds < 300;
    _lastTriggerPath = normalized;
    _lastTriggerAt = now;
    if (!isDuplicate) {
      print('✎ ${path.relative(eventPath, from: Directory.current.path)}');
    }

    // Plugins observe every source file. Debounce so a burst of saves produces
    // at most one regeneration.
    _scheduleProjectWidePass(Directory.current);
  }

  static void _showHelp() {
    print('''
🚀 craft_runner - Code Generation Tool

Usage:
  craft_runner [command] [options]

Commands:
  watch                 Start watching for file changes (default)
  generate              Run a single pass (regenerates outputs)
  clean                 Remove all generated .craft.dart files
  init                  Initialize project (install dependencies & VS Code extension)
  help                  Show this help message

Examples:
  dart run craft_runner                             # Start watch mode
  dart run craft_runner watch                       # Start watch mode
  dart run craft_runner init                        # Initialize project dependencies
  dart run craft_runner generate lib/features/auth/auth_provider.dart
  dart run craft_runner clean                       # Clean all generated files

Plugins:
  Declare them in craft_runner.yaml under `plugins:` as `<package>:<ClassName>`.
  Each plugin implements `ProjectWideCraftPlugin` and must be a (dev_)dependency.
  Or wire them in-process via a `tool/craft.dart` that calls
  `runWithPlugins([MyPlugin()], args)` from `package:craft_runner/craft_runner.dart`.
''');
  }

  static Future<void> _cleanupExistingFiles(Directory directory) async {
    final sw = Stopwatch()..start();
    final List<File> generatedFiles = [];
    await for (final entity in _sourceDartFiles(directory)) {
      if (entity.path.endsWith('.craft.dart')) {
        generatedFiles.add(entity);
      }
    }

    if (generatedFiles.isEmpty) return;
    for (final file in generatedFiles) {
      await file.delete();
    }
    print(
      '🧹 cleaned ${generatedFiles.length} stale output(s) · '
      '${sw.elapsedMilliseconds}ms',
    );
  }

}
