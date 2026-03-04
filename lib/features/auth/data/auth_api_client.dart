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

    return _parseAuthResponse(response, defaultMessage: 'Login failed');
  }

  Future<AuthSession> loginWithSocial({
    required String provider,
    required String idToken,
    String? email,
    String? fullName,
  }) async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/auth/social/$provider',
    );

    final body = <String, dynamic>{'id_token': idToken};
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }
    if (fullName != null && fullName.isNotEmpty) {
      body['full_name'] = fullName;
    }

    final response = await _httpClient.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _parseAuthResponse(response, defaultMessage: 'Social login failed');
  }

  Future<String> switchCompany(int companyId, String currentToken) async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/auth/switch-company',
    );
    final response = await _httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentToken',
      },
      body: jsonEncode({'company_id': companyId}),
    );
    if (response.statusCode != 200) {
      throw AuthApiException('Failed to switch company');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['access_token'] as String;
  }

  AuthSession _parseAuthResponse(
    http.Response response, {
    required String defaultMessage,
  }) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = defaultMessage;
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
