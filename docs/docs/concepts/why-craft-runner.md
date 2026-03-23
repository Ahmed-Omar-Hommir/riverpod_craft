---
sidebar_position: 6
---

# Why craft_runner?

## Why not `build_runner`?

`build_runner` is the standard code generation tool in the Dart ecosystem. However, it is extremely slow — and the problem gets worse as the number of files grows.

One of Dart's stated goals for 2026 is to significantly improve both `build_runner` and the Analyzer. Some speed optimizations have already shipped, but the performance remains unsatisfactory for a smooth developer experience.

We built `craft_runner` specifically to solve this performance problem. Once `build_runner` reaches a satisfactory performance level, we intend to migrate back.

## How `craft_runner` is faster

The standard `build_runner` pipeline works like this:

```
Source File → Parse (AST) → Analyze → Generate Code
```

The **Analyze** step is the bottleneck. It performs deep type analysis, resolves imports across files, builds symbol graphs, and runs global type inference. This is the step that makes `build_runner` slow.

`craft_runner` skips the Analyze step entirely:

```
Source File → Parse (AST) → Generate Code
```

This works because Riverpod provider generation only needs what's **explicitly written in the file** — function signatures, class declarations, annotations, parameters, and return types as written. No cross-file resolution needed.

:::info
Deep analysis **is** necessary for packages like `freezed` (unions, exhaustiveness), `json_serializable` (field/type mapping), and `retrofit` (API client generation). But for Riverpod providers, it's not needed — so we skip it.
:::

## The Trade-off

Since `craft_runner` reads file structure only (no cross-file type resolution), you need to write types **explicitly** in your provider files. Avoid hiding async return types behind typedefs defined in other files.

```dart
// ❌ BAD — typedef defined in another file, generator can't resolve it
typedef MyResponse = Future<List<String>>;

@provider
MyResponse getData(Ref ref) async => [];
```

```dart
// ✅ GOOD — explicit return type, easy to detect
typedef MyResponse = List<String>;

@provider
Future<MyResponse> getData(Ref ref) async => [];
```

The rule is simple: **the `Future<>` or `Stream<>` wrapper must be visible in the return type**. Everything else works as expected.

The trade-off is small. The speedup is significant.

## Can I use both `craft_runner` and `build_runner`?

Yes. `craft_runner` only handles riverpod_craft code generation. If you use other code gen packages (`freezed`, `json_serializable`, `retrofit`, etc.), you still run `build_runner` for those.

Both runners work independently and don't interfere with each other:

| Runner | Generates | Files |
|--------|-----------|-------|
| `craft_runner` | riverpod_craft providers | `.craft.dart` |
| `build_runner` | freezed, json_serializable, etc. | `.g.dart`, `.freezed.dart` |

```bash
# Run both side by side
dart run craft_runner watch
dart run build_runner watch
```

## Future

`craft_runner` was built to solve the speed problem — it's not a permanent replacement for `build_runner`. We plan to migrate back once the Dart team achieves satisfactory `build_runner` performance.

Your provider code stays the same either way — only the runner changes.
