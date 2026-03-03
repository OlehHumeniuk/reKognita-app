import 'package:flutter/foundation.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';

class TeamController extends ChangeNotifier {
  TeamController({required List<Employee> seedEmployees})
    : _allEmployees = List<Employee>.unmodifiable(seedEmployees);

  final List<Employee> _allEmployees;
  String _query = '';
  Employee? _selected;

  String get query => _query;
  Employee? get selected => _selected;

  List<Employee> get filteredEmployees {
    final input = _query.toLowerCase().trim();
    if (input.isEmpty) {
      return _allEmployees;
    }
    return _allEmployees
        .where((e) => e.name.toLowerCase().contains(input))
        .toList(growable: false);
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void select(Employee employee) {
    _selected = employee;
    notifyListeners();
  }
}
