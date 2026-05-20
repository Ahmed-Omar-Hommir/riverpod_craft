/// API versions. Use as `@Api(entry: ..., version: Version.v1)`.
///
/// Each value carries a URL path segment that retrofit_craft concatenates
/// onto the entry's `baseUrl` — so a class annotated with
/// `@Api(entry: Entry.identity, version: Version.v1)` gets
/// `baseUrl: '${Entry.identity.baseUrl}${Version.v1.path}'` in the
/// generated wrapper. Method paths therefore drop their version prefix
/// (`@POST('login')` rather than `@POST('/v1/login')`).
///
/// Include the trailing slash so `baseUrl + path + methodPath` joins cleanly
/// without manual normalisation.
enum Version {
  v1('v1/'),
  v2('v2/'),
  v3('v3/');

  const Version(this.path);

  final String path;
}
