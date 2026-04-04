class Quote {
  const Quote({
    required this.id,
    required this.text,
    required this.author,
  });

  final String id;
  final String text;
  final String author;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Quote && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
