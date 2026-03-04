import 'package:flutter/foundation.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/team/data/employee_api_client.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';

enum TeamStatus { idle, loading, saving, error }

class TeamController extends ChangeNotifier {
  TeamController({
    required String accessToken,
    EmployeeApiClient? apiClient,
  })  : _token = accessToken,
        _apiClient = apiClient ?? EmployeeApiClient();

  final String _token;
  final EmployeeApiClient _apiClient;

  List<Employee> _employees = [];
  Employee? _selected;
  String _query = '';
  TeamStatus _status = TeamStatus.idle;
  String? _error;
  final Map<int, List<DocRecord>> _employeeDocs = {};
  bool _isLoadingDocs = false;

  List<Employee> get filteredEmployees {
    final input = _query.toLowerCase().trim();
    if (input.isEmpty) return _employees;
    return _employees
        .where((e) => e.name.toLowerCase().contains(input))
        .toList(growable: false);
  }

  Employee? get selected => _selected;
  String get query => _query;
  bool get isLoading => _status == TeamStatus.loading;
  bool get isSaving => _status == TeamStatus.saving;
  bool get isLoadingDocs => _isLoadingDocs;
  String? get error => _error;

  List<DocRecord> docsFor(int employeeId) =>
      _employeeDocs[employeeId] ?? const [];

  Future<void> load() async {
    _status = TeamStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _employees = await _apiClient.fetchAll(token: _token);
      _status = TeamStatus.idle;
    } on EmployeeApiException catch (e) {
      _status = TeamStatus.error;
      _error = e.message;
    } catch (_) {
      _status = TeamStatus.error;
      _error = 'Не вдалося завантажити співробітників';
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void select(Employee employee) {
    if (_selected?.id == employee.id) {
      _selected = null;
      notifyListeners();
      return;
    }
    _selected = employee;
    notifyListeners();
    loadEmployeeDocs(employee.id);
  }

  Future<void> loadEmployeeDocs(int employeeId) async {
    _isLoadingDocs = true;
    notifyListeners();
    try {
      final docs = await _apiClient.fetchDocRecords(
          token: _token, employeeId: employeeId);
      _employeeDocs[employeeId] = docs;
    } catch (_) {
      _employeeDocs.putIfAbsent(employeeId, () => const []);
    }
    _isLoadingDocs = false;
    notifyListeners();
  }

  Future<void> createEmployee({
    required String name,
    required String role,
    required String dept,
  }) async {
    try {
      final created = await _apiClient.create(
        token: _token,
        name: name,
        role: role,
        dept: dept,
      );
      _employees = [..._employees, created];
      _selected = created;
      notifyListeners();
    } on EmployeeApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (_) {
      _error = 'Не вдалося створити співробітника';
      notifyListeners();
    }
  }

  Future<void> updateEmployee({
    required int id,
    required String name,
    required String role,
    required String dept,
  }) async {
    _status = TeamStatus.saving;
    notifyListeners();

    try {
      final updated = await _apiClient.update(
        token: _token,
        id: id,
        name: name,
        role: role,
        dept: dept,
      );
      _employees = [for (final e in _employees) if (e.id == id) updated else e];
      if (_selected?.id == id) _selected = updated;
      _status = TeamStatus.idle;
    } on EmployeeApiException catch (e) {
      _status = TeamStatus.error;
      _error = e.message;
    } catch (_) {
      _status = TeamStatus.error;
      _error = 'Не вдалося оновити співробітника';
    }
    notifyListeners();
  }

  Future<void> toggleStatus(int id) async {
    _status = TeamStatus.saving;
    notifyListeners();

    try {
      final updated = await _apiClient.toggleStatus(token: _token, id: id);
      _employees = [for (final e in _employees) if (e.id == id) updated else e];
      if (_selected?.id == id) _selected = updated;
      _status = TeamStatus.idle;
    } on EmployeeApiException catch (e) {
      _status = TeamStatus.error;
      _error = e.message;
    } catch (_) {
      _status = TeamStatus.error;
      _error = 'Не вдалося змінити статус';
    }
    notifyListeners();
  }

  Future<void> addDoc(int id, String docType) async {
    _status = TeamStatus.saving;
    notifyListeners();

    try {
      final updated = await _apiClient.addDoc(token: _token, id: id, docType: docType);
      _employees = [for (final e in _employees) if (e.id == id) updated else e];
      if (_selected?.id == id) _selected = updated;
      _status = TeamStatus.idle;
    } on EmployeeApiException catch (e) {
      _status = TeamStatus.error;
      _error = e.message;
    } catch (_) {
      _status = TeamStatus.error;
      _error = 'Не вдалося додати тип документа';
    }
    notifyListeners();
  }

  Future<void> removeDoc(int id, String docType) async {
    _status = TeamStatus.saving;
    notifyListeners();

    try {
      final updated = await _apiClient.removeDoc(token: _token, id: id, docType: docType);
      _employees = [for (final e in _employees) if (e.id == id) updated else e];
      if (_selected?.id == id) _selected = updated;
      _status = TeamStatus.idle;
    } on EmployeeApiException catch (e) {
      _status = TeamStatus.error;
      _error = e.message;
    } catch (_) {
      _status = TeamStatus.error;
      _error = 'Не вдалося видалити тип документа';
    }
    notifyListeners();
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await _apiClient.delete(token: _token, id: id);
      _employees = _employees.where((e) => e.id != id).toList();
      if (_selected?.id == id) _selected = null;
      notifyListeners();
    } on EmployeeApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (_) {
      _error = 'Не вдалося видалити співробітника';
      notifyListeners();
    }
  }
}
