/// Data models populated by the retrofit_craft scanner and consumed by the
/// generator.
library;

/// One enum (or class-with-static-consts) declaration discovered in the
/// project that serves as an entry or version registry.
class EnumRegistry {
  EnumRegistry({
    required this.name,
    required this.filePath,
    required this.values,
    this.hasPathField = false,
  });

  /// The declaration name, e.g. `Entry` or `Version`.
  final String name;

  /// Absolute path of the source file declaring it.
  final String filePath;

  /// Value/static-const names, in declaration order
  /// (e.g. `['identity', 'consumer']` for an `enum Entry`).
  final List<String> values;

  /// `true` when this registry's declaration carries a `final String path;`
  /// instance field. Used by the Version registry to opt into per-version
  /// URL path appending — see [api_generator.dart].
  ///
  /// When set, the generator emits
  /// `baseUrl: '${Entry.X.baseUrl}${Version.Y.path}'` instead of just
  /// `baseUrl: Entry.X.baseUrl`. Defaults to false so legacy Version enums
  /// (no `path` field) keep their pre-feature behaviour.
  final bool hasPathField;
}

/// Reference to a single enum/static-const value as written in source, e.g.
/// the `Entry.identity` in `@Api(entry: Entry.identity, ...)`.
class ApiRef {
  ApiRef({required this.prefix, required this.name});

  /// The prefix (enum/class name), e.g. `Entry`.
  final String prefix;

  /// The value/static-const name, e.g. `identity`.
  final String name;

  /// The full source expression: `Entry.identity`.
  String get expression => '$prefix.$name';

  @override
  String toString() => expression;
}

/// One `@Api(...)` + `@RestApi()` retrofit class to aggregate.
class ApiClassSpec {
  ApiClassSpec({
    required this.className,
    required this.filePath,
    required this.entry,
    required this.version,
  });

  /// The retrofit class name, e.g. `AuthApiV1`.
  final String className;

  /// Absolute path of the source file declaring the class.
  final String filePath;

  /// The `entry:` argument (e.g. `Entry.identity`), or `null` if the
  /// annotation omitted it (a default may still apply from config).
  final ApiRef? entry;

  /// The `version:` argument (e.g. `Version.v1`), or `null` if omitted.
  final ApiRef? version;
}

/// Naming helpers.
final RegExp _versionSuffix = RegExp(r'V\d+\w*$');

/// `AuthApiV1` -> `AuthApi`. The trailing `V\d+\w*` is stripped so a class
/// with a version suffix collapses to its base name.
String stripVersionSuffix(String className) =>
    className.replaceAll(_versionSuffix, '');

/// `AuthApi` -> `auth`. The first character is lowercased and a trailing
/// `Api` is dropped.
String groupFieldName(String className) {
  final base = stripVersionSuffix(className);
  if (base.isEmpty) return base;
  var name = base[0].toLowerCase() + base.substring(1);
  if (name.length > 3 && name.endsWith('Api')) {
    name = name.substring(0, name.length - 3);
  }
  return name;
}

/// `identity` -> `_IdentityEntry`.
String entryWrapperClassName(String entryName) {
  if (entryName.isEmpty) return '_Entry';
  final pascal = entryName[0].toUpperCase() + entryName.substring(1);
  return '_${pascal}Entry';
}

/// `(identity, auth)` -> `_IdentityAuthVersions`.
String versionsWrapperClassName(String entryName, String groupName) {
  if (entryName.isEmpty && groupName.isEmpty) return '_Versions';
  final pascalEntry = entryName.isEmpty
      ? ''
      : entryName[0].toUpperCase() + entryName.substring(1);
  final pascalGroup = groupName.isEmpty
      ? ''
      : groupName[0].toUpperCase() + groupName.substring(1);
  return '_$pascalEntry${pascalGroup}Versions';
}
