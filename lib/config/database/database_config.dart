class DatabaseConfig {
  // PostgreSQL Configuration
  // Note: Thử các IP khác nếu 10.0.2.2 không work
  // 10.0.2.2 - Android emulator standard
  // 192.168.x.x - IP máy bạn trong mạng local
  // localhost - Chỉ work trên Windows desktop
  
  // 🌐 CONFIG MODE - Đổi giá trị này để chuyển đổi:
  // 'local' - Kết nối local (chỉ bạn dùng được)
  // 'remote' - Kết nối qua internet (mọi người dùng chung)
  static const String connectionMode = 'remote'; // ⬅️ ĐỔI 'local' hoặc 'remote'
  
  // Tự động chọn host
  static String get postgresHost {
    if (connectionMode == 'remote') {
      // REMOTE: Mọi người kết nối qua Cloudflare Tunnel
      return 'db.nhutuan.io.vn';
    } else {
      // LOCAL: Chỉ máy bạn kết nối được
      // Emulator: 10.0.2.2
      // Windows Desktop: localhost
      // Android Device: 192.168.x.x (IP máy tính trong LAN)
      return '10.0.2.2'; // ⬅️ Đổi theo device của bạn
    }
  }
  
  static const int postgresPort = 5432;
  static const String postgresDatabase = 'quan_ly_thu_vien_dev';
  static const String postgresUsername = 'postgres';
  static const String postgresPassword = ''; // ⬅️ Không dùng password
  
  // SQLite Configuration (for local storage)
  static const String sqliteDbName = 'library_management.db';
  static const int sqliteVersion = 1;
  
  // Connection timeout settings
  static const Duration connectionTimeout = Duration(seconds: 60); // Tăng lên cho emulator
  static const Duration queryTimeout = Duration(seconds: 30);
  
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