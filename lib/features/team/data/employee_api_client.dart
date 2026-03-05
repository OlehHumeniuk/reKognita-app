import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rekognita_app/core/config/backend_config.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';

class EmployeeApiClient {
  EmployeeApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _base = '${BackendConfig.apiPrefix}/manager/employees';

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Employee>> fetchAll({required String token}) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.get(uri, headers: _headers(token));
    _assertOk(response, 200);
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final items = payload['items'] as List<dynamic>;
    return items.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Employee> create({
    required String token,
    required String name,
    required String role,
    required String dept,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base');
    final response = await _httpClient.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'name': name, 'role': role, 'dept': dept}),
    );
    _assertOk(response, 201);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Employee> update({
    required String token,
    required int id,
    required String name,
    required String role,
    required String dept,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id');
    final response = await _httpClient.put(
      uri,
      headers: _headers(token),
      body: jsonEncode({'name': name, 'role': role, 'dept': dept}),
    );
    _assertOk(response, 200);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Employee> toggleStatus({
    required String token,
    required int id,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id/toggle-status');
    final response = await _httpClient.patch(uri, headers: _headers(token));
    _assertOk(response, 200);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Employee> addDoc({
    required String token,
    required int id,
    required String docType,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id/docs');
    final response = await _httpClient.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'docType': docType}),
    );
    _assertOk(response, 200);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Employee> removeDoc({
    required String token,
    required int id,
    required String docType,
  }) async {
    final encodedDoc = Uri.encodeComponent(docType);
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id/docs/$encodedDoc');
    final response = await _httpClient.delete(uri, headers: _headers(token));
    _assertOk(response, 200);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String token, required int id}) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id');
    final response = await _httpClient.delete(uri, headers: _headers(token));
    _assertOk(response, 204);
  }

  Future<List<DocRecord>> fetchDocRecords({
    required String token,
    required int employeeId,
  }) async {
    final uri =
        Uri.parse('${BackendConfig.baseUrl}$_base/$employeeId/doc-records');
    final response = await _httpClient.get(uri, headers: _headers(token));
    _assertOk(response, 200);
    final items = jsonDecode(response.body) as List<dynamic>;
    return items
        .map((e) => DocRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------

  void _assertOk(http.Response response, int expected) {
    if (response.statusCode != expected) {
      String detail = 'Request failed (${response.statusCode})';
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        detail = map['detail']?.toString() ?? detail;
      } catch (_) {}
      throw EmployeeApiException(detail);
    }
  }

  Future<Employee> toggleBlock({
    required String token,
    required int id,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$_base/$id/toggle-block');
    final response = await _httpClient.patch(uri, headers: _headers(token));
    _assertOk(response, 200);
    return _fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Employee _fromJson(Map<String, dynamic> json) {
    final lastSeenStr = json['lastSeenAt'] as String?;
    return Employee(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      dept: json['dept'] as String,
      isActive: json['isActive'] as bool,
      isBlocked: json['isBlocked'] as bool? ?? false,
      lastSeenAt: lastSeenStr != null ? DateTime.parse(lastSeenStr) : null,
      docs: (json['docs'] as List<dynamic>).map((e) => e as String).toList(),
      inviteCode: json['inviteCode'] as String?,
    );
  }
}

class EmployeeApiException implements Exception {
  EmployeeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
