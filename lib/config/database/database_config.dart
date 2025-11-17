class DatabaseConfig {
  // PostgreSQL Configuration
  // Note: Thử các IP khác nếu 10.0.2.2 không work
  // 10.0.2.2 - Android emulator standard
  // 192.168.x.x - IP máy bạn trong mạng local
  // localhost - Chỉ work trên Windows desktop
  
  // 🌐 CLOUDFLARE TUNNEL / NGROK - Kết nối từ xa qua internet
  // Uncomment 2 dòng dưới và comment 2 dòng local khi dùng tunnel:
  // static const String postgresHost = 'random-name.trycloudflare.com'; // ⬅️ Cloudflare tunnel URL
  // static const int postgresPort = 7844; // ⬅️ Cloudflare tunnel port
  
  static const String postgresHost = '172.20.10.5'; // ⬅️ ĐỔI
  static const int postgresPort = 5432;
  static const String postgresDatabase = 'quan_ly_thu_vien_dev';
  static const String postgresUsername = 'postgres';
  static const String postgresPassword = '1234';
  
  // SQLite Configuration (for local storage)
  static const String sqliteDbName = 'library_management.db';
  static const int sqliteVersion = 1;
  
  // Connection timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration queryTimeout = Duration(seconds: 15);
  
  // Retry settings
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Development/Production flags
  static const bool isDevelopment = true; // Set to false in production
  static const bool enableLogging = true; // Set to false in production
  
  // Get PostgreSQL connection parameters
  static Map<String, dynamic> get postgresConfig => {
    'host': postgresHost,
    'port': postgresPort,
    'database': postgresDatabase,
    'username': postgresUsername,
    'password': postgresPassword,
  };
  
  // Get connection string for PostgreSQL
  static String get postgresConnectionString => 
      'postgresql://$postgresUsername:$postgresPassword@$postgresHost:$postgresPort/$postgresDatabase';
}