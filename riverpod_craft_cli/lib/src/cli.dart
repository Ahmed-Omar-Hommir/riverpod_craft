import 'dart:io';

import 'package:riverpod_craft_cli/file_processor.dart';
import 'package:riverpod_craft_cli/src/plugin_loader.dart';
import 'package:path/path.dart' as path;

/// Main entry point for the Riverpod Craft CLI tool
class RiverpodCraftCLI {
  static Future<void> main(List<String> args) async {
    // Load community plugins from riverpod_craft.yaml if present
    _loadPlugins();

    if (args.isEmpty) {
      await _startWatchMode();
    } else {
      await _processCommandLineArgs(args);
    }
  }

  /// Loads community plugins from riverpod_craft.yaml config.
  static void _loadPlugins() {
    if (!PluginLoader.hasConfig()) return;

    final pluginPaths = PluginLoader.loadPluginPaths();
    if (pluginPaths.isEmpty) return;

    print('Found ${pluginPaths.length} community plugin(s) in riverpod_craft.yaml');
    for (final pluginPath in pluginPaths) {
      print('   $pluginPath');
    }
    print('   Use runWithPlugins() to load custom plugins. See: riverpod_craft help');
    print('');
  }

  /// Starts watch mode to monitor file changes
  static Future<void> _startWatchMode() async {
    print('🚀 Riverpod Craft - Starting Watch Mode');
    print('=' * 50);

    final currentDir = Directory.current;

    await _cleanupExistingFiles(currentDir);
    await _processExistingFiles(currentDir);
    print('👀 Starting file watcher...');
    final watcher = currentDir.watch(recursive: true);

    watcher.listen((event) async {
      await _handleFileEvent(event.path);
    });
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

    print('🔄 Generating: ${path.basename(file.path)}');

    final contents = await file.readAsString();
    await FileProcessor.processProviderFile(contents, file);
  }

  /// Cleans all generated files
  static Future<void> _cleanAllGeneratedFiles() async {
    final currentDir = Directory.current;

    final List<File> generatedFiles = [];
    await for (final entity in currentDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && entity.path.endsWith('.pg.dart')) {
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

    if (normalized.endsWith('_provider.dart')) {
      final file = File(eventPath);
      if (await file.exists()) {
        await FileProcessor.processFileIfChanged(file);
      }
    }
  }

  static void _showHelp() {
    print('''
🚀 Riverpod Craft - Code Generation Tool

Usage:
  riverpod_craft [command] [options]

Commands:
  watch                 Start watching for file changes (default)
  generate              Generate a single provider file
  clean                 Remove all generated .pg.dart files
  init                  Initialize project (install dependencies & VS Code extension)
  help                  Show this help message

Examples:
  riverpod_craft                                    # Start watch mode
  riverpod_craft watch                              # Start watch mode
  riverpod_craft init                               # Initialize project dependencies
  riverpod_craft generate lib/features/auth/auth_provider.dart
  riverpod_craft clean                              # Clean all generated files

Custom Plugins:
  1. Add riverpod_craft_cli as a dev dependency
  2. Create your plugin extending ProviderPlugin or CommandPlugin
  3. Create tool/craft.dart:

     import 'package:riverpod_craft_cli/riverpod_craft_cli.dart';
     import '../lib/plugins/my_plugin.dart';

     void main(List<String> args) {
       runWithPlugins([MyPlugin()], args);
     }

  4. Run: dart run tool/craft.dart watch
''');
  }

  static Future<void> _cleanupExistingFiles(Directory directory) async {
    final List<File> generatedFiles = [];
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.pg.dart')) {
        generatedFiles.add(entity);
      }
    }

    if (generatedFiles.isNotEmpty) {
      print('🧹 Cleaning up ${generatedFiles.length} existing generated files...');
      for (final file in generatedFiles) {
        await file.delete();
      }
    }
  }

  static Future<void> _processExistingFiles(Directory directory) async {
    final List<File> files = [];
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('_provider.dart')) {
        files.add(entity);
      }
    }

    if (files.isNotEmpty) {
      print('🔄 Processing ${files.length} existing files...');
      await Future.wait(
        files.map((file) => FileProcessor.processFileIfChanged(file)),
      );
    }
  }
}
