import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';
import 'package:rekognita_app/features/billing/domain/entities/plan_item.dart';

class BillingApiClient {
  BillingApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<List<PlanItem>> fetchPlans() async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/manager/billing/plans',
    );
    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw BillingApiException('Не вдалося завантажити плани');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['plans'] as List)
        .cast<Map<String, dynamic>>()
        .map(PlanItem.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> fetchSubscription(String accessToken) async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/manager/billing/subscription',
    );
    final response = await _httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw BillingApiException('Failed to load subscription');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createInvoice(
    String plan,
    String accessToken,
  ) async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/manager/billing/create-invoice',
    );
    final response = await _httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'plan': plan}),
    );
    if (response.statusCode != 200) {
      String message = 'Failed to create invoice';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['detail']?.toString() ?? message;
      } catch (_) {}
      throw BillingApiException(message);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class BillingApiException implements Exception {
  BillingApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
