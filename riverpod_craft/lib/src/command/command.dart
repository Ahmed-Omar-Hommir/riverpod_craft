import 'dart:async';

import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

import '../data_provider/async_state/async_state.dart';
import '../error_mapper.dart';
import 'currency_controller.dart';

part 'action_strategy.dart';
part 'command_notifier.dart';

/// Manages keep-alive links for a list of [Ref]s to prevent provider disposal.
class KeepAliveManager {
  /// Creates a [KeepAliveManager] for the given [refs].
  KeepAliveManager({required this._refs});

  final List<Ref> _refs;

  List<KeepAliveLink?>? _keepAliveLinks;

  /// Activates keep-alive links for all managed refs.
  void keepAlive() {
    if (_keepAliveLinks != null) return;

    _keepAliveLinks = _refs.map((ref) => ref.keepAlive()).toList();
  }

  /// Closes all active keep-alive links, allowing providers to be disposed.
  void close() {
    if (_keepAliveLinks != null) {
      for (final link in _keepAliveLinks!) {
        (link as dynamic)?.close();
      }
      _keepAliveLinks = null;
    }
  }
}
