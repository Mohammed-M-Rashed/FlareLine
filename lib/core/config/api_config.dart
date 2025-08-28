class ApiConfig {
  // Environment configuration
  static const String devBaseUrl = 'http://127.0.0.1:8000/api';
  static const String stagingBaseUrl = 'https://staging-api.yourcompany.com/api';
  static const String productionBaseUrl = 'https://api.yourcompany.com/api';
  
  // Get base URL based on environment
  static String get baseUrl {
    // You can use environment variables or build flavors
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    
    switch (environment) {
      case 'production':
        return productionBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      default:
        return devBaseUrl;
    }
  }
  
  // API timeout configuration
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second
  
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  
  // Cache configuration
  static const int cacheExpirationMinutes = 5;
}
