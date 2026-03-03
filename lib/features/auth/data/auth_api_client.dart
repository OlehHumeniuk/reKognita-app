import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';
import 'package:rekognita_app/features/auth/data/auth_session.dart';

class AuthApiClient {
  AuthApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/auth/login',
    );

    final response = await _httpClient.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      String message = 'Login failed';
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        message = map['detail']?.toString() ?? message;
      } catch (_) {}
      throw AuthApiException(message);
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthSession.fromJson(payload);
  }
}

class AuthApiException implements Exception {
  AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
