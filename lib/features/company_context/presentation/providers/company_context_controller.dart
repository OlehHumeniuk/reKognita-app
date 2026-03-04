import 'package:flutter/foundation.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/company_context/data/company_api_client.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';

class CompanyContextController extends ChangeNotifier {
  CompanyContextController({CompanyApiClient? apiClient})
      : _apiClient = apiClient ?? CompanyApiClient(),
        _companies = List<Company>.unmodifiable(seedCompanies),
        _currentCompany = seedCompanies.first;

  final CompanyApiClient _apiClient;
  List<Company> _companies;
  Company _currentCompany;

  List<Company> get companies => _companies;
  Company get currentCompany => _currentCompany;

  Future<void> loadCompanies(String accessToken) async {
    try {
      final fetched = await _apiClient.fetchCompanies(accessToken);
      if (fetched.isEmpty) return;
      _companies = List<Company>.unmodifiable(fetched);
      final stillPresent = fetched.any((c) => c.id == _currentCompany.id);
      _currentCompany = stillPresent
          ? fetched.firstWhere((c) => c.id == _currentCompany.id)
          : fetched.first;
      notifyListeners();
    } catch (_) {
      // Keep seed data on failure — app still works offline
    }
  }

  void setCurrentCompany(Company company) {
    if (_currentCompany.id == company.id) return;
    _currentCompany = company;
    notifyListeners();
  }

  void switchTo(Company company) => setCurrentCompany(company);
}
