import 'dart:async';

import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

import '../data_provider/async_state/async_state.dart';
import 'currency_controller.dart';

part 'action_strategy.dart';
part 'command_notifier.dart';

class KeepAliveManager {
  KeepAliveManager({required List<Ref> refs}) : _refs = refs;

  final List<Ref> _refs;

  List<KeepAliveLink?>? _keepAliveLinks;

  void keepAlive() {
    if (_keepAliveLinks != null) return;

    _keepAliveLinks = _refs.map((ref) => ref.keepAlive()).toList();
  }

  void close() {
    if (_keepAliveLinks != null) {
      for (final link in _keepAliveLinks!) {
        (link as dynamic)?.close();
      }
      _keepAliveLinks = null;
    }
  }
}
