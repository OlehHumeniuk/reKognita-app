import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';

class IntegrationApiClient {
  IntegrationApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _base = '${BackendConfig.apiPrefix}/manager/integrations';

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Integration>> fetchAll({required String token}) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.get(uri, headers: _headers(token));
    _assertOk(response, 200);
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final items = payload['items'] as List<dynamic>;
    return items
        .map((e) => Integration.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Integration> create({
    required String token,
    required String name,
    required IntegrationStatus status,
    required List<String> types,
    required String icon,
    required Color color,
    String? webhookUrl,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'status': status.name,
        'types': types,
        'icon': icon,
        'color': '#${color.toARGB32().toRadixString(16).substring(2)}',
        'webhookUrl': webhookUrl,
      }),
    );
    _assertOk(response, 201);
    return Integration.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Integration> update({
    required String token,
    required int id,
    required String name,
    required IntegrationStatus status,
    required List<String> types,
    required String icon,
    required Color color,
    String? webhookUrl,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id');
    final response = await _httpClient.put(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'status': status.name,
        'types': types,
        'icon': icon,
        'color': '#${color.toARGB32().toRadixString(16).substring(2)}',
        'webhookUrl': webhookUrl,
      }),
    );
    _assertOk(response, 200);
    return Integration.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int id}) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id');
    final response = await _httpClient.delete(uri, headers: _headers(token));
    _assertOk(response, 204);
  }

  void _assertOk(http.Response response, int expected) {
    if (response.statusCode != expected) {
      String detail = 'Request failed (${response.statusCode})';
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        detail = map['detail']?.toString() ?? detail;
      } catch (_) {}
      throw IntegrationApiException(detail);
    }
  }
}

class IntegrationApiException implements Exception {
  IntegrationApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
