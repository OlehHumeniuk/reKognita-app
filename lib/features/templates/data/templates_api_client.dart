import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';
import 'package:rekognita_app/features/templates/domain/entities/parsing_template.dart';
import 'package:rekognita_app/features/templates/domain/entities/template_field.dart';

class TemplatesApiClient {
  TemplatesApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _base = '${BackendConfig.apiPrefix}/manager/templates';

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<ParsingTemplate>> fetchAll({required String token}) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.get(uri, headers: _headers(token));
    _assertOk(response, 200);
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final items = payload['items'] as List<dynamic>;
    return items.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ParsingTemplate> create({
    required String token,
    required String docType,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'docType': docType}),
    );
    _assertOk(response, 201);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ParsingTemplate> saveFields({
    required String token,
    required int id,
    required List<TemplateField> fields,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id/fields');
    final response = await _httpClient.put(
      uri,
      headers: _headers(token),
      body: jsonEncode({'fields': fields.map(_fieldToJson).toList()}),
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

  // ---------------------------------------------------------------------------

  void _assertOk(http.Response response, int expected) {
    if (response.statusCode != expected) {
      String detail = 'Request failed (${response.statusCode})';
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        detail = map['detail']?.toString() ?? detail;
      } catch (_) {}
      throw TemplatesApiException(detail);
    }
  }

  ParsingTemplate _fromJson(Map<String, dynamic> json) {
    final fieldsList = (json['fields'] as List<dynamic>)
        .map((f) => _fieldFromJson(f as Map<String, dynamic>))
        .toList();
    return ParsingTemplate(
      id: json['id'] as int,
      docType: json['docType'] as String,
      fields: fieldsList,
    );
  }

  TemplateField _fieldFromJson(Map<String, dynamic> json) {
    return TemplateField(
      name: json['name'] as String,
      type: _fieldTypeFromString(json['type'] as String),
      tableColumns: (json['tableColumns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      signatureLabel: json['signatureLabel'] as String?,
    );
  }

  Map<String, dynamic> _fieldToJson(TemplateField f) => {
        'name': f.name,
        'type': f.type.name,
        'tableColumns': f.tableColumns,
        'signatureLabel': f.signatureLabel,
      };

  FieldType _fieldTypeFromString(String value) {
    return FieldType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FieldType.text,
    );
  }
}

class TemplatesApiException implements Exception {
  TemplatesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
