import 'package:flutter/foundation.dart';

@protected
class ProviderAnnotation {
  const ProviderAnnotation();
}

@protected
class KeepAliveAnnotation {
  const KeepAliveAnnotation();
}

@protected
class FamilyAnnotation {
  const FamilyAnnotation();
}

const family = FamilyAnnotation();

const provider = ProviderAnnotation();
const keepAlive = KeepAliveAnnotation();

@protected
class CommandAnnotation {
  const CommandAnnotation();
}

const command = CommandAnnotation();

const droppable = CommandAnnotation();
const restartable = CommandAnnotation();
const concurrent = CommandAnnotation();
const sequential = CommandAnnotation();

@protected
class SettableAnnotation {
  const SettableAnnotation();
}

const settable = SettableAnnotation();
