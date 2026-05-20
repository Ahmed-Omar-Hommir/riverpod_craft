import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;
import 'package:analyzer/dart/ast/ast.dart';

import 'api_models.dart';

/// Stateful collector over many parsed units.
///
/// Call [collectFromUnit] once per source file, then read [entries],
/// [versions], and [apiClasses] for generation.
class ApiScanner {
  /// Enum (or class-with-static-consts) registries that look like an Entry
  /// declaration. Keyed by registry name (e.g. `Entry`).
  final Map<String, EnumRegistry> entries = <String, EnumRegistry>{};

  /// Same, for Version-like registries.
  final Map<String, EnumRegistry> versions = <String, EnumRegistry>{};

  /// `@Api`-annotated retrofit classes.
  final List<ApiClassSpec> apiClasses = <ApiClassSpec>[];

  /// When set (by the plugin from yaml config), only files matching this
  /// path are scanned for Entry registries. `null` means "scan every file".
  String? entryFilePath;
  String? versionFilePath;

  void reset() {
    entries.clear();
    versions.clear();
    apiClasses.clear();
  }

  void collectFromUnit(ParseStringResult unit, String filePath) {
    final scanEntries = entryFilePath == null || entryFilePath == filePath;
    final scanVersions =
        versionFilePath == null || versionFilePath == filePath;

    for (final decl in unit.unit.declarations) {
      // 1. Enum declarations -> potential Entry/Version registries.
      if (decl is EnumDeclaration) {
        final name = decl.name.lexeme;
        final values = [
          for (final c in decl.constants) c.name.lexeme,
        ];
        final hasPathField = _hasStringPathField(decl.members);
        final registry = EnumRegistry(
          name: name,
          filePath: filePath,
          values: values,
          hasPathField: hasPathField,
        );
        // Heuristic: any enum is a candidate. The generator validates which
        // are actually referenced. Restrict to entry_path / version_path
        // when configured so unrelated project enums don't pollute the set.
        if (scanEntries) entries[name] = registry;
        if (scanVersions) versions[name] = registry;
        continue;
      }

      // 2. Class declarations -> potential @Api retrofit classes, OR a
      // class-with-static-const-fields registry (rare; the recommended
      // shape is an enum).
      if (decl is! ClassDeclaration) continue;

      // Static-const registry detection (e.g. `class Entry { static const
      // identity = Entry(...); ... }`). Collect any top-level class that
      // has static const fields.
      if (scanEntries || scanVersions) {
        final staticConsts = _staticConstFieldNames(decl);
        if (staticConsts.isNotEmpty) {
          final hasPathField = _hasStringPathField(decl.members);
          final registry = EnumRegistry(
            name: decl.name.lexeme,
            filePath: filePath,
            values: staticConsts,
            hasPathField: hasPathField,
          );
          if (scanEntries) entries[decl.name.lexeme] = registry;
          if (scanVersions) versions[decl.name.lexeme] = registry;
        }
      }

      // @Api annotation.
      final apiAnno = _firstAnnotation(decl.metadata, 'Api');
      if (apiAnno == null) continue;
      final spec = _extractApiClass(decl, apiAnno, filePath);
      if (spec != null) apiClasses.add(spec);
    }
  }

  /// Returns true if [members] contains a non-static `final String path;`
  /// instance field. The Version enum uses this convention to opt into URL
  /// path appending (e.g. `enum Version { v1('v1/'); ...; final String path; }`).
  bool _hasStringPathField(NodeList<ClassMember> members) {
    for (final member in members) {
      if (member is! FieldDeclaration) continue;
      if (member.isStatic) continue;
      final type = member.fields.type?.toSource();
      if (type != 'String') continue;
      for (final v in member.fields.variables) {
        if (v.name.lexeme == 'path') return true;
      }
    }
    return false;
  }

  List<String> _staticConstFieldNames(ClassDeclaration decl) {
    final out = <String>[];
    for (final member in decl.members) {
      if (member is! FieldDeclaration) continue;
      if (!member.isStatic) continue;
      final keyword = member.fields.keyword?.lexeme;
      // Only `static const`. `static final` is excluded — the values
      // wouldn't be usable in const annotations downstream.
      if (keyword != 'const') continue;
      for (final v in member.fields.variables) {
        out.add(v.name.lexeme);
      }
    }
    return out;
  }

  ApiClassSpec? _extractApiClass(
    ClassDeclaration decl,
    Annotation apiAnno,
    String filePath,
  ) {
    ApiRef? entryRef;
    ApiRef? versionRef;

    final args = apiAnno.arguments?.arguments;
    if (args != null) {
      for (final arg in args) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        final ref = _propertyAccess(arg.expression);
        if (ref == null) {
          print(
            'retrofit_craft: @Api(...) $name argument should be a property '
            'access like `Entry.identity` or a dot-shorthand `.identity` '
            '(got "${arg.expression.toSource()}") in '
            '${decl.name.lexeme} ($filePath).',
          );
          continue;
        }
        if (name == 'entry') entryRef = ref;
        if (name == 'version') versionRef = ref;
      }
    }

    return ApiClassSpec(
      className: decl.name.lexeme,
      filePath: filePath,
      entry: entryRef,
      version: versionRef,
    );
  }

  static final RegExp _identifierRe = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  /// Pull `(Prefix, name)` out of one of:
  /// - `Entry.identity`              — `PrefixedIdentifier`
  /// - `Entry.identity`              — `PropertyAccess` (in some contexts)
  /// - `.identity`                   — Dart 3.6+ dot-shorthand
  ///
  /// For dot-shorthand, [ApiRef.prefix] is left empty; the generator fills
  /// it in from the discovered entry/version registry (typically the enum
  /// declared at `entry_path` / `version_path`).
  ApiRef? _propertyAccess(Expression expr) {
    if (expr is PrefixedIdentifier) {
      return ApiRef(prefix: expr.prefix.name, name: expr.identifier.name);
    }
    if (expr is PropertyAccess) {
      final target = expr.target;
      if (target is SimpleIdentifier) {
        return ApiRef(prefix: target.name, name: expr.propertyName.name);
      }
    }
    // Dot-shorthand fallback: source like `.identity`. We don't depend on
    // a specific analyzer AST node here so the same code works across the
    // analyzer versions that pre/post-date dot-shorthand support.
    final src = expr.toSource();
    if (src.startsWith('.') && src.length > 1) {
      final name = src.substring(1);
      if (_identifierRe.hasMatch(name)) {
        return ApiRef(prefix: '', name: name);
      }
    }
    return null;
  }

  Annotation? _firstAnnotation(NodeList<Annotation> metadata, String name) {
    for (final a in metadata) {
      if (a.name.name == name) return a;
    }
    return null;
  }
}
