import 'package:flutter/material.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';
import 'package:rekognita_app/features/dashboard/data/dashboard_api_client.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({DashboardApiClient? apiClient})
      : _apiClient = apiClient ?? DashboardApiClient();

  final DashboardApiClient _apiClient;

  bool _isLoading = false;
  String? _error;
  Company? _company;
  List<DashboardStat> _stats = [];
  List<ActivityItem> _activity = [];
  List<DistributionItem> _distribution = [];
  List<DocRecord> _docRecords = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Company? get company => _company;
  List<DashboardStat> get stats => _stats;
  List<ActivityItem> get activity => _activity;
  List<DistributionItem> get distribution => _distribution;
  List<DocRecord> get docRecords => _docRecords;

  Future<void> load(String accessToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.fetchOverview(accessToken);
      _company = Company.fromJson(data['company'] as Map<String, dynamic>);
      _stats = (data['stats'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (s) => DashboardStat(
              value: s['value'] as String,
              label: s['label'] as String,
              delta: s['delta'] as String?,
            ),
          )
          .toList();
      _activity = (data['activity'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (a) => ActivityItem(
              name: a['name'] as String,
              action: a['action'] as String,
              time: a['time'] as String,
              type: a['type'] as String,
            ),
          )
          .toList();
      _distribution = (data['distribution'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (d) => DistributionItem(
              name: d['name'] as String,
              percent: d['pct'] as int,
              color: _hexColor(d['color'] as String),
            ),
          )
          .toList();
      _docRecords = (data['docRecords'] as List)
          .cast<Map<String, dynamic>>()
          .map(DocRecord.fromJson)
          .toList();
    } on DashboardApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Не вдалося завантажити дашборд';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static Color _hexColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF2563EB);
    return Color(0xFF000000 | value);
  }
}
