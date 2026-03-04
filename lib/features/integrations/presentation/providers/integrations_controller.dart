import 'package:flutter/material.dart';
import 'package:rekognita_app/features/integrations/data/integration_api_client.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';

enum IntegrationsStatus { idle, loading, saving, error }

class IntegrationsController extends ChangeNotifier {
  IntegrationsController({
    required String accessToken,
    IntegrationApiClient? apiClient,
  })  : _token = accessToken,
        _apiClient = apiClient ?? IntegrationApiClient();

  final String _token;
  final IntegrationApiClient _apiClient;

  List<Integration> _integrations = [];
  IntegrationsStatus _status = IntegrationsStatus.idle;
  String? _error;

  List<Integration> get integrations => List.unmodifiable(_integrations);
  bool get isLoading => _status == IntegrationsStatus.loading;
  bool get isSaving => _status == IntegrationsStatus.saving;
  String? get error => _error;

  Future<void> load() async {
    _status = IntegrationsStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _integrations = await _apiClient.fetchAll(token: _token);
      _status = IntegrationsStatus.idle;
    } on IntegrationApiException catch (e) {
      _status = IntegrationsStatus.error;
      _error = e.message;
    } catch (_) {
      _status = IntegrationsStatus.error;
      _error = 'Не вдалося завантажити інтеграції';
    }
    notifyListeners();
  }

  Future<void> create({
    required String name,
    required IntegrationStatus status,
    required String icon,
    Color color = const Color(0xFF3B82F6),
    String? webhookUrl,
  }) async {
    _status = IntegrationsStatus.saving;
    _error = null;
    notifyListeners();

    try {
      final created = await _apiClient.create(
        token: _token,
        name: name,
        status: status,
        types: const [],
        icon: icon,
        color: color,
        webhookUrl: webhookUrl,
      );
      _integrations = [..._integrations, created];
      _status = IntegrationsStatus.idle;
    } on IntegrationApiException catch (e) {
      _status = IntegrationsStatus.error;
      _error = e.message;
    } catch (_) {
      _status = IntegrationsStatus.error;
      _error = 'Не вдалося створити інтеграцію';
    }
    notifyListeners();
  }

  Future<void> update(Integration updated) async {
    _status = IntegrationsStatus.saving;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiClient.update(
        token: _token,
        id: updated.id,
        name: updated.name,
        status: updated.status,
        types: updated.types,
        icon: updated.icon,
        color: updated.color,
        webhookUrl: updated.webhookUrl,
      );
      _integrations = [
        for (final intg in _integrations)
          if (intg.id == updated.id) result else intg,
      ];
      _status = IntegrationsStatus.idle;
    } on IntegrationApiException catch (e) {
      _status = IntegrationsStatus.error;
      _error = e.message;
    } catch (_) {
      _status = IntegrationsStatus.error;
      _error = 'Не вдалося оновити інтеграцію';
    }
    notifyListeners();
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete(token: _token, id: id);
      _integrations = _integrations.where((i) => i.id != id).toList();
      notifyListeners();
    } on IntegrationApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (_) {
      _error = 'Не вдалося видалити інтеграцію';
      notifyListeners();
    }
  }
}
