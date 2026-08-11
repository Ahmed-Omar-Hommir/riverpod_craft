import 'dart:async';
import 'dart:io';

import 'package:craft_runner/file_processor.dart';
import 'package:craft_runner/src/plugin_loader.dart';
import 'package:path/path.dart' as path;

/// Main entry point for the Riverpod Craft CLI tool
class RiverpodCraftCLI {
  /// Reentry guard env var. The auto-generated entry script re-invokes
  /// the same `dart run` chain, which would loop forever; the child sets
  /// this to bypass the parent's handoff on the second pass.
  static const _reentryEnvVar = 'CRAFT_RUNNER_REENTRY';

  /// Project subdirectories craft_runner scans and watches. Hand-written
  /// `_provider.dart` sources and every generated `.craft.dart` live under
  /// these. Scanning the project root instead recurses into `.dart_tool/`,
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
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.dart')) yield entity;
      }
    }
  }

  static Future<void> main(List<String> args) async {
    // Load config from riverpod_craft.yaml if present
    _loadConfig();

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

  /// Loads config from riverpod_craft.yaml (plugins + mapper).
  static void _loadConfig() {
    if (!PluginLoader.hasConfig()) return;

    // Load paged mapper config and parse mapper file
    CraftConfig.pagedMapperPath = PluginLoader.loadPagedMapperPath();
    CraftConfig.parseMapperFile();

    // Load global error mapper config and parse mapper file
    CraftConfig.errorMapperPath = PluginLoader.loadErrorMapperPath();
    CraftConfig.parseErrorMapperFile();
  }

  /// If `riverpod_craft.yaml`'s `plugins:` list is non-empty, generate
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
      '🔌 loaded ${specs.length} plugin(s) from riverpod_craft.yaml '
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
    final proc = await Process.start(
      'dart',
      compiled ? [snapshot.path, ...args] : ['run', entryFile.path, ...args],
      mode: ProcessStartMode.inheritStdio,
      environment: {_reentryEnvVar: 'true'},
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
  /// is instantiated under an `Object` type so the per-file / project-wide
  /// `is` checks promote cleanly regardless of which interface(s) the
  /// plugin actually implements.
  static String _buildEntryScript(List<PluginSpec> specs) {
    final buf = StringBuffer();
    buf.writeln('// GENERATED by craft_runner. DO NOT EDIT.');
    buf.writeln('// Source: riverpod_craft.yaml `plugins:` entries.');
    buf.writeln("import 'package:craft_runner/craft_runner.dart';");
    buf.writeln(
      "import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';",
    );
    for (var i = 0; i < specs.length; i++) {
      buf.writeln("import '${specs[i].importUri}' as _p$i;");
    }
    buf.writeln();
    buf.writeln('Future<void> main(List<String> args) async {');
    buf.writeln('  final perFile = <RiverpodCraftPlugin>[];');
    buf.writeln('  final projectWide = <ProjectWideCraftPlugin>[];');
    for (var i = 0; i < specs.length; i++) {
      final cls = specs[i].className;
      buf.writeln('  final Object p$i = _p$i.$cls();');
      buf.writeln('  if (p$i is RiverpodCraftPlugin) perFile.add(p$i);');
      buf.writeln(
        '  if (p$i is ProjectWideCraftPlugin) projectWide.add(p$i);',
      );
    }
    buf.writeln('  await runWithPlugins(');
    buf.writeln('    perFile,');
    buf.writeln('    args,');
    buf.writeln('    projectWidePlugins: projectWide,');
    buf.writeln('  );');
    buf.writeln('}');
    return buf.toString();
  }

  /// Starts watch mode to monitor file changes
  static Future<void> _startWatchMode() async {
    print('🚀 riverpod_craft · watch mode');

    final currentDir = Directory.current;

    final sw = Stopwatch()..start();
    await _cleanupExistingFiles(currentDir);
    await _processExistingFiles(currentDir);
    await _runProjectWidePass(currentDir);

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
    });
  }

  /// Runs the project-wide pass once and awaits it (used at startup and
  /// after single-file `generate`, where we want output before returning).
  static Future<void> _runProjectWidePass(Directory dir) async {
    if (!FileProcessor.projectWideProcessor.hasPlugins) return;
    await FileProcessor.projectWideProcessor.runFullPass(dir.path);
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
          print('Usage: riverpod_craft generate <file_path>');
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

    print('🔄 generating ${path.relative(file.path, from: Directory.current.path)}');

    final contents = await file.readAsString();
    await FileProcessor.processProviderFile(contents, file, log: true);
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
      final result = await Process.run('dart', [
        'pub',
        'global',
        'activate',
        tool,
      ], runInShell: true);

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
      print('   ⚠️  Extension directory not found: extention/provider-converter/');
      print('   💡 Building extension from source...');
      await _buildVSCodeExtension();
      return;
    }

    File? latestVsix;
    String latestVersion = '';

    await for (final entity in extensionDir.list()) {
      if (entity is File && entity.path.endsWith('.vsix')) {
        final fileName = path.basename(entity.path);
        final versionMatch = RegExp(r'(\d+\.\d+\.\d+)\.vsix').firstMatch(fileName);
        if (versionMatch != null) {
          final version = versionMatch.group(1)!;
          if (latestVersion.isEmpty || _compareVersions(version, latestVersion) > 0) {
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

    final result = await Process.run('code', [
      '--install-extension',
      latestVsix.absolute.path,
      '--force',
    ], runInShell: true);

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

    if (normalized.endsWith('_provider.dart')) {
      final file = File(eventPath);
      if (await file.exists()) {
        await FileProcessor.processFileIfChanged(file, log: true);
      }
    }

    // Project-wide plugins observe every source file. Debounce so a burst of
    // saves produces at most one regeneration.
    _scheduleProjectWidePass(Directory.current);
  }

  static void _showHelp() {
    print('''
🚀 Riverpod Craft - Code Generation Tool

Usage:
  riverpod_craft [command] [options]

Commands:
  watch                 Start watching for file changes (default)
  generate              Generate a single provider file
  clean                 Remove all generated .craft.dart files
  init                  Initialize project (install dependencies & VS Code extension)
  help                  Show this help message

Examples:
  dart run craft_runner                             # Start watch mode
  dart run craft_runner watch                       # Start watch mode
  dart run craft_runner init                        # Initialize project dependencies
  dart run craft_runner generate lib/features/auth/auth_provider.dart
  dart run craft_runner clean                       # Clean all generated files

Custom Plugins:
  1. Add craft_runner as a dev dependency
  2. Create your plugin extending ProviderPlugin or CommandPlugin
  3. Create tool/craft.dart:

     import 'package:craft_runner/craft_runner.dart';
     import '../lib/plugins/my_plugin.dart';

     void main(List<String> args) {
       runWithPlugins([MyPlugin()], args);
     }

  4. Run: dart run tool/craft.dart watch
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

  static Future<void> _processExistingFiles(Directory directory) async {
    final sw = Stopwatch()..start();
    final List<File> files = [];
    await for (final entity in _sourceDartFiles(directory)) {
      if (entity.path.endsWith('_provider.dart')) {
        files.add(entity);
      }
    }

    if (files.isNotEmpty) {
      // Batch startup pass: stay quiet per-file and print one summary below.
      await Future.wait(
        files.map((file) => FileProcessor.processFileIfChanged(file)),
      );
      print(
        '🔄 processed ${files.length} provider file(s) · '
        '${sw.elapsedMilliseconds}ms',
      );
    }
  }
}
