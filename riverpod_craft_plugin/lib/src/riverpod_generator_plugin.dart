import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:craft_runner/craft_runner.dart';
import 'package:path/path.dart' as p;

import 'craft_config.dart';
import 'plugin_runner.dart';
import 'plugins/command_plugin.dart';
import 'plugins/provider_plugin.dart';

/// The header emitted at the top of every generated provider part. It is
/// returned as part of the file body so the project-wide processor keeps it
/// verbatim (the processor skips its own header when this one is present).
const _providerHeader =
    '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
    '// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member\n';

/// craft_runner project-wide plugin that generates riverpod providers and
/// commands. For every `*_provider.dart` under `lib/` it produces a
/// `*.craft.dart` part carrying the notifier/facade/command code, mirroring the
/// former built-in per-file generation.
class RiverpodGeneratorPlugin implements ProjectWideCraftPlugin {
  RiverpodGeneratorPlugin({Directory? rootDir}) : _rootDir = rootDir;

  final Directory? _rootDir;

  final PluginRunner _runner = PluginRunner([ProviderPlugin(), CommandPlugin()]);
  final List<_ProviderUnit> _collected = [];

  @override
  String get id => 'riverpod';

  @override
  List<String> get sourceRoots => const ['lib'];

  @override
  void reset() {
    _collected.clear();
    CraftConfig.load(_rootDir);
  }

  @override
  void collectFromUnit(ParseStringResult unit, String filePath) {
    if (!filePath.endsWith('_provider.dart')) return;
    _collected.add(_ProviderUnit(filePath, unit));
  }

  @override
  Map<String, String> generate() {
    final outputs = <String, String>{};
    for (final unit in _collected) {
      final file = File(unit.filePath);
      final produced = _process(file, unit.result);
      if (produced != null) outputs[produced.path] = produced.content;
    }
    return outputs;
  }

  _GeneratedPart? _process(File file, ParseStringResult parsedResult) {
    final String contents;
    try {
      contents = file.readAsStringSync();
    } on FileSystemException {
      return null;
    }

    final fileName = file.uri.pathSegments.last;
    final partName = fileName.replaceAll('.dart', '.craft.dart');
    final generatedFilePath = p.join(file.parent.path, partName);
    final parsedUnit = parsedResult.unit;

    final generatedContent = _runner.run(parsedResult);

    if (generatedContent == null || generatedContent.isEmpty) {
      _cleanupPartAndGenerated(file, parsedUnit, partName);
      return null;
    }

    final hasPaged = generatedContent.contains('PagedDataNotifier');
    final pagedPreamble = hasPaged ? _buildPagedPreamble(generatedContent) : '';

    final usesErrorMapper = generatedContent.contains(
      '${CraftConfig.errorMapperInlineName}(',
    );
    final errorMapperPreamble = usesErrorMapper
        ? _buildErrorMapperPreamble()
        : '';

    _ensurePartDirective(file, contents, parsedUnit, partName);

    final fullContent =
        '$_providerHeader'
        "part of '$fileName';\n"
        '$pagedPreamble$errorMapperPreamble\n'
        '$generatedContent';

    return _GeneratedPart(generatedFilePath, fullContent);
  }

  String _buildPagedPreamble(String generatedContent) {
    if (CraftConfig.hasPagedMapper && CraftConfig.pagedMapperInputType != null) {
      final inputType = CraftConfig.pagedMapperInputType!;
      final mapperFn = CraftConfig.pagedMapperFunctionSource ?? '';
      return '''

typedef Paged<T> = Future<$inputType<T>>;

$mapperFn
''';
    }
    final pageKeyType =
        RegExp(r'final (\S+) firstPageKey').firstMatch(generatedContent)?.group(1) ??
        'int';
    return '\ntypedef Paged<T> = Future<PaginatedResponse<T, $pageKeyType>>;\n';
  }

  String _buildErrorMapperPreamble() {
    final mapperFn = CraftConfig.errorMapperFunctionSource;
    if (!CraftConfig.hasErrorMapper || mapperFn == null) return '';
    return '\n$mapperFn\n';
  }

  void _ensurePartDirective(
    File file,
    String contents,
    CompilationUnit unit,
    String partName,
  ) {
    final hasPartDirective = unit.directives.whereType<PartDirective>().any(
      (d) => d.uri.stringValue == partName,
    );
    if (hasPartDirective) {
      final lines = contents.split('\n');
      final partIndex = lines.indexWhere(
        (line) => line.trim() == "part '$partName';",
      );
      if (partIndex > 0 && lines[partIndex - 1].trim().isNotEmpty) {
        lines.insert(partIndex, '');
        file.writeAsStringSync(lines.join('\n'));
      }
      return;
    }

    int insertOffset = 0;
    if (unit.directives.isNotEmpty) {
      insertOffset = unit.directives.last.end;
    }

    final insertText = "\n\npart '$partName';\n";
    final newContents =
        contents.substring(0, insertOffset) +
        insertText +
        contents.substring(insertOffset);
    file.writeAsStringSync(newContents);
  }

  void _cleanupPartAndGenerated(
    File file,
    CompilationUnit unit,
    String partName,
  ) {
    final generatedFile = File(p.join(file.parent.path, partName));
    if (generatedFile.existsSync()) {
      generatedFile.deleteSync();
    }

    final hasPartDirective = unit.directives.whereType<PartDirective>().any(
      (d) => d.uri.stringValue == partName,
    );
    if (!hasPartDirective) return;

    final lines = file.readAsLinesSync();
    final filtered = lines.where(
      (line) => !line.trim().startsWith("part '") || !line.contains(partName),
    );
    file.writeAsStringSync(filtered.join('\n'));
  }
}

class _ProviderUnit {
  _ProviderUnit(this.filePath, this.result);

  final String filePath;
  final ParseStringResult result;
}

class _GeneratedPart {
  _GeneratedPart(this.path, this.content);

  final String path;
  final String content;
}
