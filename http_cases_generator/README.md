# http_cases_generator

`http_cases_generator` is a project-wide `craft_runner` plugin that composes
user-written HTTP test cases into a discoverable, strongly typed catalog.
It organizes cases only: it does not create mocks or depend on an HTTP client,
OpenAPI, Patrol, Dio, or a mocking package.

## Setup

Add the annotations normally and the generator as a development dependency:

```yaml
dependencies:
  http_cases: ^0.1.0

dev_dependencies:
  http_cases_generator: ^0.1.0
  craft_runner: ^0.11.0
```

Create `craft_runner.yaml` in the application root:

```yaml
roots: [lib, test]
exclude: [.craft.dart, .g.dart, .freezed.dart]

builders:
  http_cases_generator:HttpCasesBuilder:
    scope: [test/http_cases]
    output: test/http_cases/http_cases.craft.dart
```

Then run:

```sh
dart run craft_runner build
```

## Declaring cases

```dart
import 'package:http_cases/http_cases.dart';

@ApiCase('cart')
class GetV1 {
  const GetV1();

  @DefaultCase()
  void success() {}

  void failed() {}
}
```

The generated standalone library is consumed as follows:

```dart
import 'http_cases/http_cases.craft.dart';

void configure() {
  apiCases.setUpDefaults();
  apiCases.cart.getV1.failed();
}
```

If at least one default method is asynchronous, `setUpDefaults()` returns
`Future<void>` and awaits only asynchronous defaults.

## Declaration rules

- Groups use lower snake case, such as `cart` or `device_management`.
- Each case is a public, non-abstract class with an unnamed, parameterless
  constructor. It may be implicit, `const`, factory, or an ordinary generative
  constructor.
- A case may have zero or one `@DefaultCase()` methods.
- A default is a public instance method with no required parameters.
- Optional parameters are allowed because the generated invocation omits them.
- Generator methods and `async void` defaults are rejected.
- An async default must use `async` syntax or declare `Future`/`FutureOr` so the
  syntax-only scanner can identify it.

Cases without defaults remain available in the catalog and are not invoked by
`setUpDefaults()`. Defaults are ordered by group, generated case accessor,
source path, and class name, so output and execution order are deterministic.

Const-only catalogs keep a `const apiCases` root. When any case has a non-const
constructor, the generated root and affected group cache that case in a
`late final` field:

```dart
final apiCases = ApiCases();

class CartCases {
  CartCases();

  late final DeleteItemV1 deleteItemV1 = DeleteItemV1();
}
```

Build diagnostics include the source line and column:

```text
test/http_cases/cart/get_v1.dart:12:8: GetV1.success must not require arguments.
```

## Architecture

Craft Runner parses all configured source files once and passes them to
`HttpCasesBuilder`, a multi-file builder. The builder scans `@ApiCase`
declarations, validates them, and writes one standalone `.craft.dart` library.
Because the output imports source libraries instead of being a `part`, it can
aggregate cases from unrelated libraries. Files that are themselves `part`s
are imported through their owning library. Import prefixes are generated when
class names collide across libraries or with generated class names.

Craft Runner is syntax-only. Annotation names and async return types are
recognized from their written syntax rather than resolved Dart elements.

The annotation and generator packages are intentionally separate. A combined
package would make applications depend on `analyzer`, `dart_style`, and
`craft_runner` merely to retain two annotations at runtime.

See [`example`](example/) for a complete project.
