import 'package:flutter/foundation.dart';
import 'package:rekognita_app/features/templates/data/templates_api_client.dart';
import 'package:rekognita_app/features/templates/domain/entities/parsing_template.dart';
import 'package:rekognita_app/features/templates/domain/entities/template_field.dart';

enum TemplatesStatus { idle, loading, saving, error }

class TemplatesController extends ChangeNotifier {
  TemplatesController({
    required String accessToken,
    TemplatesApiClient? apiClient,
  })  : _token = accessToken,
        _apiClient = apiClient ?? TemplatesApiClient();

  final String _token;
  final TemplatesApiClient _apiClient;

  List<ParsingTemplate> _templates = [];
  int? _activeIndex;
  TemplatesStatus _status = TemplatesStatus.idle;
  String? _error;

  List<ParsingTemplate> get templates => List.unmodifiable(_templates);
  int? get activeIndex => _activeIndex;
  bool get isLoading => _status == TemplatesStatus.loading;
  bool get isSaving => _status == TemplatesStatus.saving;
  String? get error => _error;

  Future<void> load() async {
    _status = TemplatesStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _templates = await _apiClient.fetchAll(token: _token);
      _status = TemplatesStatus.idle;
    } on TemplatesApiException catch (e) {
      _status = TemplatesStatus.error;
      _error = e.message;
    } catch (_) {
      _status = TemplatesStatus.error;
      _error = 'Не вдалося завантажити шаблони';
    }
    notifyListeners();
  }

  void select(int index) {
    _activeIndex = _activeIndex == index ? null : index;
    notifyListeners();
  }

  Future<void> createTemplate(String docType) async {
    try {
      final created = await _apiClient.create(token: _token, docType: docType);
      _templates = [..._templates, created];
      _activeIndex = _templates.length - 1;
      notifyListeners();
    } on TemplatesApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (_) {
      _error = 'Не вдалося створити шаблон';
      notifyListeners();
    }
  }

  Future<void> saveAll({
    required int id,
    required String docType,
    required List<TemplateField> fields,
    String? integration,
  }) async {
    _status = TemplatesStatus.saving;
    _error = null;
    notifyListeners();

    try {
      final updated = await _apiClient.saveFields(
        token: _token,
        id: id,
        docType: docType,
        fields: fields,
        integration: integration,
      );
      _templates = [
        for (final t in _templates)
          if (t.id == id) updated else t,
      ];
      _status = TemplatesStatus.idle;
    } on TemplatesApiException catch (e) {
      _status = TemplatesStatus.error;
      _error = e.message;
    } catch (_) {
      _status = TemplatesStatus.error;
      _error = 'Не вдалося зберегти шаблон';
    }
    notifyListeners();
  }
}
