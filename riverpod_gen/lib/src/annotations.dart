class ProviderAnnotation {
  const ProviderAnnotation();
}

class ProviderValueAnnotation {
  const ProviderValueAnnotation();
}

class KeepAliveAnnotation {
  const KeepAliveAnnotation();
}

class FamilyAnnotation {
  const FamilyAnnotation();
}

const family = FamilyAnnotation();

const provider = ProviderAnnotation();
const providerValue = ProviderAnnotation();
const keepAlive = KeepAliveAnnotation();

class CommandAnnotation {
  const CommandAnnotation();
}

const command = CommandAnnotation();

const droppable = CommandAnnotation();
const restartable = CommandAnnotation();
const concurrent = CommandAnnotation();
const sequential = CommandAnnotation();
