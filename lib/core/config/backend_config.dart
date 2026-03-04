import 'package:flutter/foundation.dart';

class BackendConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('RK_API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator loopback to host machine.
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static const String apiPrefix = '/api/v1';

  const BackendConfig._();
}
