import 'package:flutter/foundation.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/document_types/data/document_type_api_client.dart';
import 'package:rekognita_app/features/document_types/domain/entities/document_type.dart';

enum DocumentTypesStatus { idle, loading, error }

class DocumentTypesController extends ChangeNotifier {
  DocumentTypesController({
    required String accessToken,
    DocumentTypeApiClient? apiClient,
  })  : _token = accessToken,
        _apiClient = apiClient ?? DocumentTypeApiClient();

  final String _token;
  final DocumentTypeApiClient _apiClient;

  List<DocumentType> _types = List.of(seedDocumentTypes);
  int? _activeDocumentTypeId;
  DocumentTypesStatus _status = DocumentTypesStatus.idle;
  String? _error;

  List<DocumentType> get types => List.unmodifiable(_types);
  int? get activeDocumentTypeId => _activeDocumentTypeId;
  bool get isLoading => _status == DocumentTypesStatus.loading;
  String? get error => _error;

  Future<void> load() async {
    _status = DocumentTypesStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _types = await _apiClient.fetchAll(token: _token);
      _status = DocumentTypesStatus.idle;
    } on DocumentTypeApiException catch (e) {
      _status = DocumentTypesStatus.error;
      _error = e.message;
    } catch (_) {
      _status = DocumentTypesStatus.error;
      _error = 'Не вдалося завантажити типи документів';
    }
    notifyListeners();
  }

  void toggleSelection(int id) {
    _activeDocumentTypeId = _activeDocumentTypeId == id ? null : id;
    notifyListeners();
  }

  Future<void> createType(String name) async {
    try {
      final created = await _apiClient.create(token: _token, name: name);
      _types = [..._types, created];
      notifyListeners();
    } on DocumentTypeApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (_) {
      _error = 'Не вдалося створити тип документа';
      notifyListeners();
    }
  }

  Future<void> editName(int id, String name) async {
    try {
      final updated = await _apiClient.updateName(
        token: _token,
        id: id,
        name: name,
      );
      _types = [
        for (final t in _types)
          if (t.id == id) updated else t,
      ];
      notifyListeners();
    } on DocumentTypeApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (_) {
      _error = 'Не вдалося оновити тип документа';
      notifyListeners();
    }
  }

}
