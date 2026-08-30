/// Annotations for declaring a generated catalog of HTTP test cases.
library;

/// Assigns an HTTP case class to [group].
class ApiCase {
  const ApiCase(this.group);

  final String group;
}

/// Marks the method used to establish the baseline state for an HTTP case.
class DefaultCase {
  const DefaultCase();
}
