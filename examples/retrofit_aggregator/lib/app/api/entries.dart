/// API gateways. Use as `@Api(entry: Entry.identity, ...)`.
enum Entry {
  identity('https://identity.example.com/api/'),
  consumer('https://consumer.example.com/api/');

  const Entry(this.baseUrl);

  final String baseUrl;
}
