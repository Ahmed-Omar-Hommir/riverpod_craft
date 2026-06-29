import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

import 'src/plugin_loader.dart';
import 'src/plugin_runner.dart';
import 'src/plugins/provider_plugin.dart';
import 'src/plugins/command_plugin.dart';
import 'src/project_wide_processor.dart';

/// The default set of built-in plugins.
final List<RiverpodCraftPlugin> builtInPlugins = [
  ProviderPlugin(),
  CommandPlugin(),
];

/// Handles file processing operations
class FileProcessor {
  static final Map<String, String> _fileContentCache = {};
  static final Map<String, DateTime> _fileModificationCache = {};

  /// The plugin runner used for code generation.
  static PluginRunner _pluginRunner = PluginRunner(builtInPlugins);

  /// The processor for project-wide plugins (e.g. retrofit_craft's
  /// `AppApi` aggregator). Empty until [registerProjectWidePlugins] is called.
  static ProjectWideProcessor _projectWideProcessor =
      ProjectWideProcessor(const []);

  /// True once any plugin has been registered in-process via
  /// [registerPlugins] / [registerProjectWidePlugins]. The CLI consults
  /// this to skip the yaml-driven handoff when the caller already wired
  /// plugins through `runWithPlugins(...)` from a custom entry script.
  static bool _pluginsRegistered = false;
  static bool get hasRegisteredPlugins => _pluginsRegistered;

  /// Register additional plugins (e.g., community plugins from config).
  ///
  /// If an extra plugin has the same [RiverpodCraftPlugin.id] as a built-in,
  /// it **replaces** the built-in plugin instead of running alongside it.
  /// This lets developers extend a built-in plugin and swap it in.
  static void registerPlugins(List<RiverpodCraftPlugin> extraPlugins) {
    final extraIds = extraPlugins.map((p) => p.id).toSet();
    final kept = builtInPlugins.where((p) => !extraIds.contains(p.id)).toList();
    _pluginRunner = PluginRunner([...kept, ...extraPlugins]);
    if (extraPlugins.isNotEmpty) _pluginsRegistered = true;
  }

  /// Register project-wide plugins ([ProjectWideCraftPlugin]).
  ///
  /// Unlike per-file plugins, these collect across every Dart source file
  /// under `lib/` and emit standalone (non-part) generated files.
  static void registerProjectWidePlugins(
    List<ProjectWideCraftPlugin> plugins,
  ) {
    _projectWideProcessor = ProjectWideProcessor(plugins);
    if (plugins.isNotEmpty) _pluginsRegistered = true;
  }

  /// The active project-wide processor.
  static ProjectWideProcessor get projectWideProcessor =>
      _projectWideProcessor;

  /// Processes file only if it has changed.
  ///
  /// Pass `log: true` (watch events, single-file `generate`) to emit a one-line
  /// `🔧 <output> · <ms>` when a `.craft.dart` is actually written. The startup
  /// batch leaves it `false` and prints a single summary line instead.
  static Future<void> processFileIfChanged(
    File file, {
    bool log = false,
  }) async {
    final filePath = file.path;
    final lastModified = await file.lastModified();

    if (_fileModificationCache[filePath] == lastModified) {
      return; // File hasn't changed
    }

    _fileModificationCache[filePath] = lastModified;

    final contents = await file.readAsString();

    await processProviderFile(contents, file, log: log);
  }

  static Future<void> processProviderFile(
    String contents,
    File file, {
    bool log = false,
  }) async {
    final sw = Stopwatch()..start();
    try {
      var effectiveContents = contents;
      if (_fileContentCache[file.path] == effectiveContents) {
        return; // Content hasn't changed
      }

      final fileName = file.uri.pathSegments.last;
      final partName = fileName.replaceAll('.dart', '.craft.dart');
      final generatedFilePath =
          '${file.parent.path.endsWith('/') ? file.parent.path : '${file.parent.path}/'}$partName';
      final generatedFile = File(generatedFilePath);

      // Fast path: if file clearly has no plugin annotations, avoid analyzer parse.
      // The check is driven by the union of all registered plugin annotation names.
      final stripped = effectiveContents
          // Remove block comments
          .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
          // Remove line comments
          .replaceAll(RegExp(r'//.*'), '');

      final allAnnotations = _pluginRunner.allAnnotations;
      final maybeAnnotated = allAnnotations.any(
        (name) => stripped.contains('@$name'),
      );

      if (!maybeAnnotated) {
        final hasPartLine =
            effectiveContents.contains("part '$partName';") ||
            effectiveContents.contains('part "$partName";');
        final generatedExists = await generatedFile.exists();

        if (hasPartLine || generatedExists) {
          await _cleanupPartLineSimple(file, partName);
          if (generatedExists) {
            await generatedFile.delete();
          }
          _fileContentCache[file.path] = await file.readAsString();
        } else {
          _fileContentCache[file.path] = effectiveContents;
        }
        return;
      }

      final parsedResult = parseString(content: effectiveContents);
      final parsedUnit = parsedResult.unit;

      // Run the plugin pipeline
      final generatedContent = _pluginRunner.run(parsedResult);

      if (generatedContent == null || generatedContent.isEmpty) {
        await _cleanupPartAndGenerated(file, parsedUnit);
        _fileContentCache[file.path] = await file.readAsString();
        return;
      }

      // Check if file has paged providers
      final hasPaged = generatedContent.contains('PagedDataNotifier');
      final pagedPreamble = hasPaged ? _buildPagedPreamble() : '';

      // Inline the global error mapper function when a generated notifier
      // routes its errors through it.
      final usesErrorMapper = generatedContent.contains(
        '${CraftConfig.errorMapperInlineName}(',
      );
      final errorMapperPreamble = usesErrorMapper
          ? _buildErrorMapperPreamble()
          : '';

      effectiveContents = await _ensurePartDirective(
        file,
        effectiveContents,
        parsedUnit,
      );

      _fileContentCache[file.path] = effectiveContents;

      final fullContent = "// GENERATED CODE - DO NOT MODIFY BY HAND\n// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member\npart of '$fileName';\n$pagedPreamble$errorMapperPreamble\n$generatedContent";

      final formatter = DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      );

      final formatted = formatter.format(fullContent);
      // Only write when the generated part actually changed; a no-op rewrite
      // would needlessly re-trigger the IDE analyzer (and any file watcher).
      final genFile = File(generatedFilePath);
      if (!await genFile.exists() || await genFile.readAsString() != formatted) {
        await genFile.writeAsString(formatted);
        if (log) {
          print(
            '   🔧 ${p.relative(generatedFilePath, from: Directory.current.path)}'
            ' · ${sw.elapsedMilliseconds}ms',
          );
        }
      }
    } on FileSystemException catch (e) {
      print('FileSystemException: ${e.message}, path = ${e.path}');
    } catch (e) {
      print('Error processing file "${file.path}": $e');
    }
  }

  /// Builds the Paged<T> typedef (and mapper function) for .craft.dart files.
  ///
  /// With mapper: typedef + inlined pagedMapper function.
  /// Without mapper: typedef defaults to PaginatedResponse<T>.
  static String _buildPagedPreamble() {
    if (CraftConfig.hasPagedMapper && CraftConfig.pagedMapperInputType != null) {
      final inputType = CraftConfig.pagedMapperInputType!;
      final mapperFn = CraftConfig.pagedMapperFunctionSource ?? '';
      return '''

typedef Paged<T> = Future<$inputType<T>>;

$mapperFn
''';
    }
    return '\ntypedef Paged<T> = Future<PaginatedResponse<T>>;\n';
  }

  /// Inlines the global `errorMapper` function (from `error_mapper` in
  /// `riverpod_craft.yaml`) into a `.craft.dart` file so generated notifiers
  /// can route caught errors through it. Returns an empty string when no
  /// mapper is configured.
  static String _buildErrorMapperPreamble() {
    final mapperFn = CraftConfig.errorMapperFunctionSource;
    if (!CraftConfig.hasErrorMapper || mapperFn == null) return '';
    return '\n$mapperFn\n';
  }


  static Future<String> _ensurePartDirective(
    File file,
    String contents,
    CompilationUnit unit,
  ) async {
    final fileName = p.basename(file.path);
    final partName = fileName.replaceAll('.dart', '.craft.dart');

    final hasPartDirective = unit.directives.whereType<PartDirective>().any(
      (p) => p.uri.stringValue == partName,
    );
    if (hasPartDirective) {
      // Ensure a blank line before the part directive for formatting consistency
      final lines = contents.split('\n');
      final partIndex = lines.indexWhere(
        (line) => line.trim() == "part '$partName';",
      );
      if (partIndex > 0 && lines[partIndex - 1].trim().isNotEmpty) {
        lines.insert(partIndex, '');
        final updated = lines.join('\n');
        await file.writeAsString(updated);
        return updated;
      }
      return contents;
    }

    // Find insertion point: after last library/import/export/part directive
    int insertOffset = 0;
    if (unit.directives.isNotEmpty) {
      insertOffset = unit.directives.last.end;
    }

    final insertText = "\n\npart '$partName';\n";
    final newContents =
        contents.substring(0, insertOffset) +
        insertText +
        contents.substring(insertOffset);

    await file.writeAsString(newContents);
    return newContents;
  }

  static Future<void> _cleanupPartAndGenerated(
    File file,
    CompilationUnit unit,
  ) async {
    final fileName = p.basename(file.path);
    final partName = fileName.replaceAll('.dart', '.craft.dart');
    final generatedFile = File(p.join(file.parent.path, partName));

    // Delete generated file if it exists
    if (await generatedFile.exists()) {
      await generatedFile.delete();
    }

    // If part directive is present, remove it and rewrite source
    final hasPartDirective = unit.directives.whereType<PartDirective>().any(
      (p) => p.uri.stringValue == partName,
    );
    if (!hasPartDirective) return;

    final lines = await file.readAsLines();
    final filtered = lines.where(
      (line) => !line.trim().startsWith("part '") || !line.contains(partName),
    );
    await file.writeAsString(filtered.join('\n'));
  }

  static Future<void> _cleanupPartLineSimple(File file, String partName) async {
    final lines = await file.readAsLines();
    final filtered = lines.where(
      (line) => !line.trim().startsWith('part ') || (!line.contains(partName)),
    );
    await file.writeAsString(filtered.join('\n'));
  }
}
