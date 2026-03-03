import 'package:flutter/foundation.dart';
import 'package:rekognita_app/features/auth/data/auth_api_client.dart';
import 'package:rekognita_app/features/auth/data/auth_session.dart';
import 'package:rekognita_app/features/auth/data/social_identity.dart';
import 'package:rekognita_app/features/auth/data/social_sign_in_service.dart';
import 'package:rekognita_app/features/auth/domain/entities/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthApiClient? apiClient,
    SocialSignInService? socialSignInService,
  }) : _apiClient = apiClient ?? AuthApiClient(),
       _socialSignInService = socialSignInService ?? SocialSignInService();

  final AuthApiClient _apiClient;
  final SocialSignInService _socialSignInService;
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
    _setLoading();
    try {
      final AuthSession session = await _apiClient.login(
        email: email,
        password: password,
      );
      _setSession(session);
    } on AuthApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Не вдалося підключитись до сервера');
    } finally {
      _setIdle();
    }
  }

  Future<void> loginWithGoogle() async {
    _setLoading();
    try {
      final SocialIdentity identity = await _socialSignInService
          .signInWithGoogle();
      final AuthSession session = await _apiClient.loginWithSocial(
        provider: identity.provider,
        idToken: identity.idToken,
        email: identity.email,
        fullName: identity.fullName,
      );
      _setSession(session);
    } on SocialSignInException catch (e) {
      _setError(e.message);
    } on AuthApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Не вдалося виконати Google вхід');
    } finally {
      _setIdle();
    }
  }

  Future<void> loginWithApple() async {
    _setLoading();
    try {
      final SocialIdentity identity = await _socialSignInService
          .signInWithApple();
      final AuthSession session = await _apiClient.loginWithSocial(
        provider: identity.provider,
        idToken: identity.idToken,
        email: identity.email,
        fullName: identity.fullName,
      );
      _setSession(session);
    } on SocialSignInException catch (e) {
      _setError(e.message);
    } on AuthApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Не вдалося виконати Apple вхід');
    } finally {
      _setIdle();
    }
  }

  void _setLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _setSession(AuthSession session) {
    _currentUser = session.user;
    _accessToken = session.accessToken;
    _error = null;
  }

  void _setError(String message) {
    _error = message;
    _currentUser = null;
    _accessToken = null;
  }

  void _setIdle() {
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _accessToken = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
