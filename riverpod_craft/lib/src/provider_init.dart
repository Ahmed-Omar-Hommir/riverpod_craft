import 'package:riverpod/riverpod.dart';

/// Signature of the global provider-init hook.
///
/// Runs **once per notifier instance**, awaited **before the notifier's first
/// fetch**. The place for cross-cutting logic — refetch-on-language-change,
/// offline-retry, etc. Branch on `notifier is DataNotifier` /
/// `notifier is PagedDataNotifier`, read `notifier`'s state, and act via `ref`.
typedef ProviderInitHook =
    Future<void> Function(Ref ref, Notifier notifier, Record arg);

/// Runtime registration surface for riverpod_craft.
class RiverpodCraft {
  RiverpodCraft._();

  /// A global hook every generated notifier runs once, before its first fetch.
  /// Register it once at startup:
  ///
  /// ```dart
  /// void main() {
  ///   RiverpodCraft.providerInit = providerInit;
  ///   runApp(const ProviderScope(child: App()));
  /// }
  /// ```
  ///
  /// A provider opts out with `@noInit`.
  static ProviderInitHook? providerInit;
}
