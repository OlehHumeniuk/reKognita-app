import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/document_types/domain/entities/document_type.dart';

class DocumentTypeApiClient {
  DocumentTypeApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _base = '${BackendConfig.apiPrefix}/manager/document-types';

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<DocumentType>> fetchAll({required String token}) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.get(uri, headers: _headers(token));
    _assertOk(response, 200);
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final items = payload['items'] as List<dynamic>;
    return items
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DocumentType> create({
    required String token,
    required String name,
    String icon = '📄',
    String integration = '—',
    String color = '#3b82f6',
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'icon': icon,
        'integration': integration,
        'color': color,
      }),
    );
    _assertOk(response, 201);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DocumentType> updateName({
    required String token,
    required int id,
    required String name,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id');
    final response = await _httpClient.put(
      uri,
      headers: _headers(token),
      body: jsonEncode({'name': name}),
    );
    _assertOk(response, 200);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int id}) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id');
    final response =
        await _httpClient.delete(uri, headers: _headers(token));
    _assertOk(response, 204);
  }

  void _assertOk(http.Response response, int expected) {
    if (response.statusCode != expected) {
      String detail = 'Request failed (${response.statusCode})';
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        detail = map['detail']?.toString() ?? detail;
      } catch (_) {}
      throw DocumentTypeApiException(detail);
    }
  }

  DocumentType _fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      integration: json['integration'] as String,
      fields: json['fields'] as int,
      workers: json['workers'] as int,
      color: _colorFromHex(json['color'] as String),
    );
  }

  Color _colorFromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    final value = int.tryParse(clean, radix: 16);
    if (value == null) return AppColors.brand;
    return Color(0xFF000000 | value);
  }
}

class DocumentTypeApiException implements Exception {
  DocumentTypeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
