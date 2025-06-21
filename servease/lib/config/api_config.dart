class ApiConfig {
  // Get base URL from environment or use default
  static const String _defaultBaseUrl = 'https://servease-production.up.railway.app';

  // You can set this through environment variables or change it here
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  // API endpoints
  static const String apiPath = '/api';
  static const String adminPath = '/api/admin';

  // Auth endpoints
  static const String loginEndpoint = '$apiPath/auth/login';
  static const String registerEndpoint = '$apiPath/auth/register';

  // Full URLs
  static String get fullApiUrl => '$baseUrl$apiPath';
  static String get fullAdminUrl => '$baseUrl$adminPath';

  // Helper method to get full endpoint URL
  static String getEndpoint(String endpoint) {
    return '$baseUrl$apiPath$endpoint';
  }

  // Helper method to get admin endpoint URL
  static String getAdminEndpoint(String endpoint) {
    return '$baseUrl$adminPath$endpoint';
  }

  // Method to update base URL at runtime (useful for development)
  static String _runtimeBaseUrl = _defaultBaseUrl;

  static void setBaseUrl(String newBaseUrl) {
    _runtimeBaseUrl = newBaseUrl;
  }

  static String get currentBaseUrl => _runtimeBaseUrl;
  static String get currentApiUrl => '$_runtimeBaseUrl$apiPath';
  static String get currentAdminUrl => '$_runtimeBaseUrl$adminPath';

  // Helper methods with runtime URL
  static String getCurrentEndpoint(String endpoint) {
    return '$_runtimeBaseUrl$apiPath$endpoint';
  }

  static String getCurrentAdminEndpoint(String endpoint) {
    return '$_runtimeBaseUrl$adminPath$endpoint';
  }
}
