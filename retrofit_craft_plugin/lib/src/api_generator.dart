import 'package:path/path.dart' as p;

import 'api_models.dart';
import 'retrofit_craft_config.dart';

/// Result of [generateAppApi]: either a generated source string or a list of
/// validation diagnostics that aborted generation.
class GenerateResult {
  GenerateResult.source(this.source) : diagnostics = const [];
  GenerateResult.failed(this.diagnostics) : source = null;

  final String? source;
  final List<String> diagnostics;

  bool get success => source != null;
}

/// Build the `AppApi` aggregator source from collected scanner state.
GenerateResult generateAppApi({
  required RetrofitCraftConfig config,
  required Map<String, EnumRegistry> entries,
  required Map<String, EnumRegistry> versions,
  required List<ApiClassSpec> apiClasses,
  required String outputAbsPath,
}) {
  if (apiClasses.isEmpty) {
    return GenerateResult.failed(const [
      'No @Api-annotated classes found. Skipping AppApi generation.',
    ]);
  }

  final diagnostics = <String>[];

  // Resolve effective entry/version per class and group them.
  // groups[entryName][groupName] = list of resolved classes
  final groups = <String, Map<String, List<_ResolvedApi>>>{};
  // Tracks which enum prefix each entry name resolves to (must be unique).
  final entryPrefixForName = <String, String>{};

  for (final api in apiClasses) {
    var entryRef = api.entry ?? _parseDefault(config.defaultEntry);
    if (entryRef == null) {
      diagnostics.add(
        '${api.className}: @Api has no entry: and no default_entry is '
        'configured in craft_runner.yaml.',
      );
      continue;
    }

    // Dot-shorthand: empty prefix gets resolved against the (single)
    // discovered entry registry. With `entry_path` configured the scanner
    // scopes to exactly one enum, so this is unambiguous.
    if (entryRef.prefix.isEmpty) {
      final resolved = _resolveImplicitPrefix(
        entries,
        api.className,
        'entry',
      );
      if (resolved == null) {
        diagnostics.add(
          '${api.className}: @Api uses dot-shorthand `.${entryRef.name}` for '
          'entry but no Entry registry was discovered. Configure '
          '`entry_path` in craft_runner.yaml, or write the prefix '
          'explicitly (e.g. `Entry.${entryRef.name}`).',
        );
        continue;
      }
      if (resolved.isAmbiguous) {
        diagnostics.add(
          '${api.className}: @Api uses dot-shorthand `.${entryRef.name}` for '
          'entry but multiple Entry-like registries were discovered '
          '(${resolved.candidates.join(", ")}). Set `entry_path` in '
          'craft_runner.yaml to disambiguate.',
        );
        continue;
      }
      entryRef = ApiRef(prefix: resolved.name, name: entryRef.name);
    }

    // Validate the entry value exists in some discovered registry. If a
    // registry with that prefix was discovered, require the value to be in
    // it. If no registry matches the prefix, accept the reference but warn
    // about the missing declaration so the user can fix it.
    final entryReg = entries[entryRef.prefix];
    if (entryReg == null) {
      diagnostics.add(
        '${api.className}: @Api references "${entryRef.expression}", but '
        'no enum (or class with static const fields) named '
        '"${entryRef.prefix}" was found. Declare it at '
        '${config.entryPath ?? "any file under lib/"}.',
      );
      continue;
    }
    if (!entryReg.values.contains(entryRef.name)) {
      diagnostics.add(
        '${api.className}: @Api references "${entryRef.expression}", but '
        '"${entryRef.prefix}" does not declare a value "${entryRef.name}". '
        'Known values: ${entryReg.values.join(", ")}.',
      );
      continue;
    }
    final existing = entryPrefixForName[entryRef.name];
    if (existing != null && existing != entryRef.prefix) {
      diagnostics.add(
        '${api.className}: entry value "${entryRef.name}" was previously '
        'used with prefix "$existing" but is now referenced as '
        '"${entryRef.prefix}". Pick one.',
      );
      continue;
    }
    entryPrefixForName[entryRef.name] = entryRef.prefix;

    var versionRef = api.version ?? _parseDefault(config.defaultVersion);
    if (versionRef != null && versionRef.prefix.isEmpty) {
      final resolved = _resolveImplicitPrefix(
        versions,
        api.className,
        'version',
      );
      if (resolved == null) {
        diagnostics.add(
          '${api.className}: @Api uses dot-shorthand `.${versionRef.name}` '
          'for version but no Version registry was discovered. Configure '
          '`version_path` in craft_runner.yaml, or write the prefix '
          'explicitly (e.g. `Version.${versionRef.name}`).',
        );
        continue;
      }
      if (resolved.isAmbiguous) {
        diagnostics.add(
          '${api.className}: @Api uses dot-shorthand `.${versionRef.name}` '
          'for version but multiple Version-like registries were discovered '
          '(${resolved.candidates.join(", ")}). Set `version_path` in '
          'craft_runner.yaml to disambiguate.',
        );
        continue;
      }
      versionRef = ApiRef(prefix: resolved.name, name: versionRef.name);
    }
    if (versionRef != null) {
      final versionReg = versions[versionRef.prefix];
      if (versionReg == null) {
        diagnostics.add(
          '${api.className}: @Api references "${versionRef.expression}", '
          'but no enum named "${versionRef.prefix}" was found.',
        );
        continue;
      }
      if (!versionReg.values.contains(versionRef.name)) {
        diagnostics.add(
          '${api.className}: @Api references "${versionRef.expression}", '
          'but "${versionRef.prefix}" does not declare a value '
          '"${versionRef.name}". Known values: '
          '${versionReg.values.join(", ")}.',
        );
        continue;
      }
    }

    final groupName = groupFieldName(api.className);
    final byEntry = groups.putIfAbsent(entryRef.name, () => {});
    final byGroup = byEntry.putIfAbsent(groupName, () => []);
    byGroup.add(
      _ResolvedApi(
        spec: api,
        entryName: entryRef.name,
        entryPrefix: entryRef.prefix,
        group: groupName,
        version: versionRef,
      ),
    );
  }

  // Validate group consistency (versioning, duplicates).
  for (final entryName in groups.keys) {
    final byGroup = groups[entryName]!;
    for (final groupName in byGroup.keys) {
      final list = byGroup[groupName]!;
      final versioned = list.where((r) => r.version != null).toList();
      final unversioned = list.where((r) => r.version == null).toList();

      if (versioned.isNotEmpty && unversioned.isNotEmpty) {
        diagnostics.add(
          '$entryName.$groupName has classes both with and without a '
          'version. Either give every class a version, or leave it as the '
          'single class in the group: '
          '${list.map((r) => r.spec.className).join(', ')}.',
        );
        continue;
      }
      if (unversioned.length > 1) {
        diagnostics.add(
          '$entryName.$groupName has ${unversioned.length} unversioned '
          'classes. Each (entry, group) without a version layer must have '
          'exactly one class: '
          '${unversioned.map((r) => r.spec.className).join(', ')}.',
        );
        continue;
      }

      final seenVersions = <String>{};
      for (final r in versioned) {
        final v = r.version!.name;
        if (!seenVersions.add(v)) {
          diagnostics.add(
            '$entryName.$groupName has duplicate version "$v": '
            '${versioned.where((x) => x.version!.name == v).map((x) => x.spec.className).join(', ')}.',
          );
        }
      }
    }
  }

  if (diagnostics.isNotEmpty) {
    return GenerateResult.failed(diagnostics);
  }

  // Compute imports.
  // 1. Aliases for class-name collisions across retrofit source files.
  final classToFiles = <String, Set<String>>{};
  for (final api in apiClasses) {
    classToFiles.putIfAbsent(api.className, () => <String>{}).add(api.filePath);
  }
  final filesNeedingAlias = <String>{};
  for (final files in classToFiles.values) {
    if (files.length > 1) filesNeedingAlias.addAll(files);
  }
  final aliases = <String, String>{};
  {
    final sorted = filesNeedingAlias.toList()..sort();
    for (var i = 0; i < sorted.length; i++) {
      aliases[sorted[i]] = '_alias$i';
    }
  }

  // 2. Build the import list: Dio, every retrofit-class file, every entry
  // registry's declaring file (so `Entry.identity.baseUrl` resolves), plus
  // any Version registry whose `path` field is actually referenced in the
  // emitted code.
  final outputDir = p.dirname(outputAbsPath);
  final allSourceFiles = <String>{};
  for (final api in apiClasses) {
    allSourceFiles.add(api.filePath);
  }
  for (final entryName in groups.keys) {
    final prefix = entryPrefixForName[entryName]!;
    allSourceFiles.add(entries[prefix]!.filePath);
  }
  // Pull in Version registry files for every version whose registry exposes
  // a `path` field — the generated body references `<Prefix>.<name>.path`
  // and that prefix must be resolvable.
  for (final byGroup in groups.values) {
    for (final list in byGroup.values) {
      for (final r in list) {
        final v = r.version;
        if (v == null) continue;
        final reg = versions[v.prefix];
        if (reg != null && reg.hasPathField) {
          allSourceFiles.add(reg.filePath);
        }
      }
    }
  }

  final importLines = <String>['import \'package:dio/dio.dart\';'];
  final sortedFiles = allSourceFiles.toList()..sort();
  for (final file in sortedFiles) {
    final rel = p.relative(file, from: outputDir).replaceAll(r'\', '/');
    final alias = aliases[file];
    if (alias == null) {
      importLines.add("import '$rel';");
    } else {
      importLines.add("import '$rel' as $alias;");
    }
  }

  // Build the source body.
  final body = StringBuffer();

  // Root class.
  body
    ..writeln('class ${config.rootClassName} {')
    ..writeln('  ${config.rootClassName}({required this.dio});')
    ..writeln('  final Dio dio;')
    ..writeln();
  final sortedEntries = groups.keys.toList()..sort();
  for (final entryName in sortedEntries) {
    body.writeln(
      '  late final $entryName = ${entryWrapperClassName(entryName)}(dio);',
    );
  }
  body
    ..writeln('}')
    ..writeln();

  // Per-entry wrapper class.
  for (final entryName in sortedEntries) {
    final byGroup = groups[entryName]!;
    final wrapperClass = entryWrapperClassName(entryName);
    final entryPrefix = entryPrefixForName[entryName]!;
    final baseUrlExpr = '$entryPrefix.$entryName.baseUrl';

    body
      ..writeln('class $wrapperClass {')
      ..writeln('  $wrapperClass(this._dio);')
      ..writeln('  final Dio _dio;')
      ..writeln();
    final sortedGroups = byGroup.keys.toList()..sort();
    for (final groupName in sortedGroups) {
      final list = byGroup[groupName]!;
      final hasVersion = list.first.version != null;
      if (hasVersion) {
        body.writeln(
          '  late final $groupName = '
          '${versionsWrapperClassName(entryName, groupName)}(_dio);',
        );
      } else {
        final r = list.single;
        final ref = _classRef(r.spec, aliases);
        body.writeln(
          '  late final $groupName = $ref(_dio, baseUrl: $baseUrlExpr);',
        );
      }
    }
    body
      ..writeln('}')
      ..writeln();

    // Per-group versions wrapper class.
    for (final groupName in sortedGroups) {
      final list = byGroup[groupName]!;
      if (list.first.version == null) continue;
      final versionsClass = versionsWrapperClassName(entryName, groupName);
      body
        ..writeln('class $versionsClass {')
        ..writeln('  $versionsClass(this._dio);')
        ..writeln('  final Dio _dio;')
        ..writeln();
      final sortedList = [...list]
        ..sort((a, b) => a.version!.name.compareTo(b.version!.name));
      for (final r in sortedList) {
        final ref = _classRef(r.spec, aliases);
        final versionReg = versions[r.version!.prefix];
        final urlExpr = (versionReg != null && versionReg.hasPathField)
            ? "'\${$baseUrlExpr}\${${r.version!.expression}.path}'"
            : baseUrlExpr;
        body.writeln(
          '  late final ${r.version!.name} = '
          '$ref(_dio, baseUrl: $urlExpr);',
        );
      }
      body
        ..writeln('}')
        ..writeln();
    }
  }

  final source = '${importLines.join('\n')}\n\n${body.toString()}';
  return GenerateResult.source(source);
}

class _ResolvedApi {
  _ResolvedApi({
    required this.spec,
    required this.entryName,
    required this.entryPrefix,
    required this.group,
    required this.version,
  });

  final ApiClassSpec spec;
  final String entryName;
  final String entryPrefix;
  final String group;
  final ApiRef? version;
}

String _classRef(ApiClassSpec spec, Map<String, String> aliases) {
  final alias = aliases[spec.filePath];
  return alias == null ? spec.className : '$alias.${spec.className}';
}

/// Result of resolving a dot-shorthand `.name` to a concrete registry.
class _ResolvedPrefix {
  _ResolvedPrefix.unique(this.name) : candidates = [name];
  _ResolvedPrefix.ambiguous(this.candidates) : name = '';

  final String name;
  final List<String> candidates;

  bool get isAmbiguous => candidates.length > 1;
}

/// Returns the single registry name to use for a dot-shorthand reference.
///
/// Returns null when no registries were discovered (caller should error
/// with a "configure entry_path" message). Returns an `.ambiguous` result
/// when multiple candidates were discovered.
_ResolvedPrefix? _resolveImplicitPrefix(
  Map<String, EnumRegistry> registries,
  String contextClassName,
  String contextParam,
) {
  if (registries.isEmpty) return null;
  if (registries.length == 1) {
    return _ResolvedPrefix.unique(registries.keys.first);
  }
  return _ResolvedPrefix.ambiguous(registries.keys.toList());
}

/// Parse a yaml default value into an [ApiRef].
///
/// Accepts three equivalent shapes, all resolving to the same value:
///   - `consumer`         (bare; prefix resolved from the discovered registry)
///   - `.consumer`        (dot-shorthand; same)
///   - `Entry.consumer`   (explicit)
///
/// Returns `null` if the string is null/empty/malformed.
ApiRef? _parseDefault(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  // ".consumer" — dot-shorthand form; prefix resolved downstream.
  if (trimmed.startsWith('.')) {
    final name = trimmed.substring(1);
    return name.isEmpty ? null : ApiRef(prefix: '', name: name);
  }

  final dot = trimmed.indexOf('.');
  if (dot > 0 && dot < trimmed.length - 1) {
    // "Entry.consumer" — explicit prefix.
    return ApiRef(
      prefix: trimmed.substring(0, dot),
      name: trimmed.substring(dot + 1),
    );
  }
  if (dot < 0) {
    // "consumer" — bare name; prefix resolved downstream like dot-shorthand.
    return ApiRef(prefix: '', name: trimmed);
  }
  return null;
}
