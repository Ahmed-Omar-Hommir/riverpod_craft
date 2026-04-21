import 'package:flutter/foundation.dart';

/// Marks a function or class as a Riverpod provider for code generation.
@protected
class ProviderAnnotation {
  /// Creates a [ProviderAnnotation].
  const ProviderAnnotation();
}

/// Marks a provider to be kept alive (not auto-disposed).
@protected
class KeepAliveAnnotation {
  /// Creates a [KeepAliveAnnotation].
  const KeepAliveAnnotation();
}

/// Marks a provider as a family provider that accepts arguments.
@protected
class FamilyAnnotation {
  /// Creates a [FamilyAnnotation].
  const FamilyAnnotation();
}

/// Annotation to mark a provider as a family provider.
const family = FamilyAnnotation();

/// Annotation to trigger code generation for a provider.
const provider = ProviderAnnotation();

/// Annotation to keep a provider alive (prevent auto-dispose).
const keepAlive = KeepAliveAnnotation();

/// Marks a function or class as a command provider for code generation.
@protected
class CommandAnnotation {
  /// Creates a [CommandAnnotation].
  const CommandAnnotation();
}

/// Annotation to generate a command provider with the default strategy.
const command = CommandAnnotation();

/// Annotation to generate a command provider with a droppable strategy.
const droppable = CommandAnnotation();

/// Annotation to generate a command provider with a restartable strategy.
const restartable = CommandAnnotation();

/// Annotation to generate a command provider with a concurrent strategy.
const concurrent = CommandAnnotation();

/// Annotation to generate a command provider with a sequential strategy.
const sequential = CommandAnnotation();

/// Marks a provider as settable, generating a `setState()` method.
@protected
class SettableAnnotation {
  /// Creates a [SettableAnnotation].
  const SettableAnnotation();
}

/// Annotation to generate a `setState()` method on the provider facade.
const settable = SettableAnnotation();
