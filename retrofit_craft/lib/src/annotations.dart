/// Marks a retrofit-annotated class for inclusion in the generated `AppApi`.
///
/// `Api` is **generic over your project's `Entry` and `Version` enums**, so
/// the call site gets full type safety and Dart 3.6+ dot-shorthand for
/// enum values:
///
/// ```dart
/// @Api(entry: .identity, version: .v1)
/// @RestApi()
/// abstract class AuthApi {
///   factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;
///   @POST('/login')
///   Future<void> login(...);
/// }
/// ```
///
/// To make `.identity` / `.v1` resolve, the annotation's `E` / `V` must be
/// fixed to concrete enum types. The recommended pattern is to declare one
/// project-level `Api` annotation that subclasses [Api] with your enums
/// baked in:
///
/// ```dart
/// // lib/app/api/api.dart
/// import 'package:retrofit_craft/retrofit_craft.dart' as rc;
/// import 'entries.dart';
/// import 'versions.dart';
///
/// class Api extends rc.Api<Entry, Version> {
///   const Api({super.entry, super.version});
/// }
/// ```
///
/// Then everywhere:
///
/// ```dart
/// import 'package:my_app/app/api/api.dart';
///
/// @Api(entry: .identity, version: .v1)
/// @RestApi()
/// abstract class AuthApi { ... }
/// ```
///
/// `E` is conventionally an enhanced enum exposing a `String baseUrl` field
/// (the generator emits `<Entry>.<name>.baseUrl` into each retrofit ctor
/// call). `V` can be any enum — only the value names matter (they become
/// the `v1`, `v2`, ... fields on the generated versions wrapper).
class Api<E extends Object, V extends Object> {
  const Api({this.entry, this.version});

  /// One of `E`'s enum values (or any const expression of the form
  /// `<Prefix>.<name>`). When omitted, falls back to `default_entry` from
  /// `riverpod_craft.yaml`.
  final E? entry;

  /// One of `V`'s enum values. When omitted, no version layer is emitted
  /// (the retrofit class is exposed directly on the entry wrapper).
  final V? version;
}
