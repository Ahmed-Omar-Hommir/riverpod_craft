import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:craft_runner/craft_runner.dart';
import 'package:dart_style/dart_style.dart';

import 'plugin_runner.dart';
import 'plugins/command_plugin.dart';
import 'plugins/provider_plugin.dart';
import 'riverpod_craft_options.dart';

const _header =
    '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
    '// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member\n';

class RiverpodCraftBuilder extends CraftBuilderSingleFile {
  RiverpodCraftBuilder({this.options = RiverpodCraftOptions.empty});

  /// Built by craft_runner from the builder's `craft_runner.yaml` block.
  factory RiverpodCraftBuilder.fromConfig(Map<String, Object?> config) =>
      RiverpodCraftBuilder.withMappers(
        errorMapper: config['error_mapper'] as String?,
        pagedMapper: config['paged_provider_mapper'] as String?,
      );

  /// Reads the mapper sources now; they are snapshotted for the session, so a
  /// mapper edit needs a restart.
  factory RiverpodCraftBuilder.withMappers({
    String? errorMapper,
    String? pagedMapper,
  }) {
    String? read(String? path) {
      if (path == null) return null;
      final file = File(path);
      if (file.existsSync()) return file.readAsStringSync();
      stderr.writeln('riverpod_craft: mapper not found: $path');
      return null;
    }

    return RiverpodCraftBuilder(
      options: RiverpodCraftOptions.resolve(
        errorMapperPath: errorMapper,
        errorMapperContent: read(errorMapper),
        pagedMapperPath: pagedMapper,
        pagedMapperContent: read(pagedMapper),
      ),
    );
  }

  final RiverpodCraftOptions options;

  final PluginRunner _runner = PluginRunner([ProviderPlugin(), CommandPlugin()]);

  @override
  List<String> get scope => ['lib'];

  @override
  void build(String path, ParseStringResult result) {
    if (!path.endsWith('_provider.dart')) return;
    if (!result.content.contains('@provider') &&
        !result.content.contains('@command')) {
      return;
    }

    final generated = _runner.run(result, options: options);
    if (generated == null || generated.isEmpty) return;

    final name = path.substring(path.lastIndexOf('/') + 1);
    final partName = name.replaceFirst('.dart', '.craft.dart');
    if (!_declaresPart(result.unit, partName)) {
      throw StateError("$path is missing `part '$partName';`");
    }

    writeIfChanged(
      path.replaceFirst('.dart', '.craft.dart'),
      _format(
        '$_header'
        "part of '$name';\n"
        '${_pagedPreamble(generated)}${_errorPreamble(generated)}\n'
        '$generated',
      ),
    );
  }

  bool _declaresPart(CompilationUnit unit, String partName) => unit.directives
      .whereType<PartDirective>()
      .any((d) => d.uri.stringValue == partName);

  String _pagedPreamble(String generated) {
    if (!generated.contains('PagedDataNotifier')) return '';
    if (options.hasPagedMapper) {
      return '\ntypedef Paged<T> = '
          'Future<${options.pagedMapperInputType!}<T>>;\n\n'
          '${options.pagedMapperSource ?? ''}\n';
    }
    final pageKeyType =
        RegExp(r'final (\S+) firstPageKey').firstMatch(generated)?.group(1) ??
        'int';
    return '\ntypedef Paged<T> = Future<PaginatedResponse<T, $pageKeyType>>;\n';
  }

  String _errorPreamble(String generated) {
    if (!generated.contains('${RiverpodCraftOptions.errorMapperInlineName}(')) {
      return '';
    }
    return '\n${options.errorMapperSource ?? ''}\n';
  }

  String _format(String content) {
    try {
      return DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      ).format(content);
    } catch (_) {
      return content;
    }
  }
}
