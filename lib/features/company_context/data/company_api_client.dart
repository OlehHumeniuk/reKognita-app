import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';

class CompanyApiClient {
  CompanyApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<List<Company>> fetchCompanies(String accessToken) async {
    final uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.apiPrefix}/manager/companies',
    );
    final response = await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load companies (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List;
    return items
        .cast<Map<String, dynamic>>()
        .map(Company.fromJson)
        .toList();
  }
}
