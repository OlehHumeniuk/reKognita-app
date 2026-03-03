class BackendConfig {
  static const String baseUrl = String.fromEnvironment(
    'RK_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String apiPrefix = '/api/v1';

  const BackendConfig._();
}
