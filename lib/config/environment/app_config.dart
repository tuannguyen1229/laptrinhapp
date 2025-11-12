enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  // Database configurations for different environments
  static Map<String, dynamic> get databaseConfig {
    switch (_environment) {
      case Environment.development:
        return {
          'host': '10.0.2.2', // 10.0.2.2 cho Android emulator, localhost cho Windows desktop
          'port': 5432,
          'database': 'quan_ly_thu_vien_dev',
          'username': 'postgres',
          'password': '1234',
          'ssl': false,
        };
      
      case Environment.staging:
        return {
          'host': 'staging-db.example.com',
          'port': 5432,
          'database': 'quan_ly_thu_vien_staging',
          'username': 'staging_user',
          'password': 'staging_password',
          'ssl': true,
        };
      
      case Environment.production:
        return {
          'host': 'prod-db.example.com',
          'port': 5432,
          'database': 'quan_ly_thu_vien_prod',
          'username': 'prod_user',
          'password': 'prod_password',
          'ssl': true,
        };
    }
  }
  
  // App configurations
  static String get appName {
    switch (_environment) {
      case Environment.development:
        return 'Quản lý thư viện (Dev)';
      case Environment.staging:
        return 'Quản lý thư viện (Staging)';
      case Environment.production:
        return 'Quản lý thư viện';
    }
  }
  
  static bool get isDebugMode => _environment == Environment.development;
  static bool get enableLogging => _environment != Environment.production;
  
  // API configurations (for future use)
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.example.com/api';
      case Environment.production:
        return 'https://api.example.com/api';
    }
  }
}