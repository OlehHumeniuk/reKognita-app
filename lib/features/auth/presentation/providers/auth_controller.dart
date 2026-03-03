import 'package:flutter/foundation.dart';
import 'package:rekognita_app/features/auth/data/auth_api_client.dart';
import 'package:rekognita_app/features/auth/data/auth_session.dart';
import 'package:rekognita_app/features/auth/domain/entities/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? AuthApiClient();

  final AuthApiClient _apiClient;
  AuthUser? _currentUser;
  String? _accessToken;
  String? _error;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  void loginWithMock() {
    _currentUser = const AuthUser(
      id: '1',
      email: 'mock@rekognita.app',
      name: 'Андрій Ковач',
      role: 'Власник',
      companyId: 1,
    );
    _accessToken = 'mock-token';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final AuthSession session = await _apiClient.login(
        email: email,
        password: password,
      );
      _currentUser = session.user;
      _accessToken = session.accessToken;
      _error = null;
    } on AuthApiException catch (e) {
      _error = e.message;
      _currentUser = null;
      _accessToken = null;
    } catch (_) {
      _error = 'Не вдалося підключитись до сервера';
      _currentUser = null;
      _accessToken = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _accessToken = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
