import 'package:flutter/foundation.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';

class CompanyContextController extends ChangeNotifier {
  CompanyContextController({required List<Company> seedCompanies})
    : _companies = List<Company>.unmodifiable(seedCompanies),
      _currentCompany = seedCompanies.first;

  final List<Company> _companies;
  Company _currentCompany;

  List<Company> get companies => _companies;
  Company get currentCompany => _currentCompany;

  void switchTo(Company company) {
    if (_currentCompany.id == company.id) {
      return;
    }
    _currentCompany = company;
    notifyListeners();
  }
}
