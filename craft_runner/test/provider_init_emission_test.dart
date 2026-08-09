import 'package:craft_runner/provider_info.dart';
import 'package:test/test.dart';

ProviderInfo _make({
  required bool noInit,
  ProviderType type = ProviderType.future,
}) => ProviderInfo(
  name: 'Foo',
  dataType: 'int',
  isKeepAlive: false,
  type: type,
  params: const [],
  commands: const [],
  isFunctional: true,
  functionName: 'foo',
  requiresRef: true,
  isNoInit: noInit,
);

void main() {
  test('@noInit emits an init() override (future)', () {
    expect(
      _make(noInit: true).build(),
      contains('Future<void> init() async {}'),
    );
  });

  test('normal provider emits no init() override (future)', () {
    expect(_make(noInit: false).build(), isNot(contains('init()')));
  });

  test('@noInit emits an init() override (paged)', () {
    expect(
      _make(noInit: true, type: ProviderType.paged).build(),
      contains('Future<void> init() async {}'),
    );
  });
}
