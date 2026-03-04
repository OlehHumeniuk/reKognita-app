import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';

class DashboardApiClient {
  DashboardApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, dynamic>> fetchOverview(String accessToken, {String period = 'today'}) async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/manager/dashboard-overview?period=$period',
    );
    final response = await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode != 200) {
      throw DashboardApiException('Failed to load dashboard (${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class DashboardApiException implements Exception {
  DashboardApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
