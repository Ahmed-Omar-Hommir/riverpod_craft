import 'package:dio/dio.dart';

import 'app/app_api.craft.dart';

/// Compile-time proof that the generated aggregator's
/// `api.{entry}.{group}.v{n}.{method}()` access path resolves and
/// type-checks. Used by the E2E test's `dart analyze` step.
// ignore: unused_element
Future<void> _check(Dio dio) async {
  final api = AppApi(dio: dio);

  await api.identity.auth.v1.login(phone: '0918475643', password: 'pw');
  await api.identity.auth.v3.login(
    phone: '0918475643',
    password: 'pw',
    otp: '000000',
  );
  await api.identity.health.check();
  await api.consumer.order.v2.checkout(<String, dynamic>{});
}
