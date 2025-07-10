class ApiConfig {
  // Base URLs for different environments
  static const String _devBaseUrl = 'https://dev-oms.getorio.com/api/';
  static const String _stagingBaseUrl = 'https://staging-oms.getorio.com/api/';
  static const String _productionBaseUrl = 'https://oms.getorio.com/api/';
  
  // Current environment
  static const Environment _currentEnvironment = Environment.production;
  
  // API endpoints
  static const String loginEndpoint = 'login';
  static const String helpVideosEndpoint = 'helps/list';
  static const String helpVideoDetailEndpoint = 'helps/detail';
  static const String notificationsEndpoint = 'notification/index';
  static const String notificationDetailEndpoint = 'notification/get_notification';
  static const String notificationCreateEndpoint = 'notification/create';
  static const String notificationEditEndpoint = 'notification/edit';
  static const String notificationDeleteEndpoint = 'notification/delete';
  static const String loadSheetEndpoint = 'loadsheet/show';
  static const String loadSheetDeleteEndpoint = 'loadsheet/delete';
  static const String loadSheetSingleEndpoint = 'loadsheet/single';
  static const String courierAccountsEndpoint = 'courier/getcourieraccounts';
  static const String profileEndpoint = 'profile';
  static const String dashboardEndpoint = 'dashboard-reporting';
  
  // Timeout configurations
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
  
  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Get base URL based on current environment
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return _devBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.production:
        return _productionBaseUrl;
    }
  }
  
  // Get full endpoint URL
  static String getEndpointUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Check if we're in development mode
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  
  // Check if we're in production mode
  static bool get isProduction => _currentEnvironment == Environment.production;
  
  // Get API headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Orio-OMS-App/1.0',
  };
  
  // Get headers with authentication
  static Map<String, String> getAuthHeaders(String apiKey) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    return headers;
  }
}

enum Environment {
  development,
  staging,
  production,
} 