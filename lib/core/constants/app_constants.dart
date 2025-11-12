class AppConstants {
  // Database constants
  static const String localDatabaseName = 'library_management.db';
  static const int localDatabaseVersion = 1;
  
  // PostgreSQL constants
  static const String postgresHost = 'localhost';
  static const int postgresPort = 5432;
  static const String postgresDatabaseName = 'quan_ly_thu_vien_dev';
  static const String postgresUsername = 'postgres';
  static const String postgresPassword = 'password';
  
  // Notification constants
  static const String notificationChannelId = 'library_notifications';
  static const String notificationChannelName = 'Library Management';
  static const String notificationChannelDescription = 'Notifications for library management';
  
  // Camera constants
  static const double qrScanAreaSize = 250.0;
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Overdue check interval (in hours)
  static const int overdueCheckInterval = 24;
}