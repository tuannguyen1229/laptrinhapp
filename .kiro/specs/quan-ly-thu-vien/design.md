# Tài liệu Thiết kế - Ứng dụng Quản lý Thư viện

## Tổng quan

Ứng dụng quản lý thư viện được xây dựng trên nền tảng Flutter với kiến trúc Clean Architecture, sử dụng PostgreSQL làm cơ sở dữ liệu chính. Ứng dụng được tổ chức theo mô hình phân chia công việc cho 3 thành viên với các module riêng biệt.

## Kiến trúc hệ thống

### Kiến trúc tổng thể
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Tuan      │  │    Tung     │  │    Duc      │         │
│  │  (Borrow)   │  │ (Overdue)   │  │  (Search)   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ BorrowBloc  │  │ OverdueBloc │  │ SearchBloc  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Repository  │  │   Models    │  │ Data Source │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    External Services                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ PostgreSQL  │  │   Camera    │  │ Notification│         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Cấu trúc thư mục dự án
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── tuan_borrow_management/          # Module 1: Quản lý mượn sách
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── tung_overdue_alerts/            # Module 2: Cảnh báo quá hạn
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── duc_search_functionality/       # Module 3: Tìm kiếm
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── borrow_return_status/           # Module 4: Danh sách thẻ đang mượn/đã trả
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── statistics_reports/             # Module 5: Thống kê báo cáo
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── iot_scanner_integration/        # Module 6: Tích hợp IoT và quét mã
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   ├── models/
│   ├── repositories/
│   ├── widgets/
│   └── services/
└── config/
    ├── database/
    ├── routes/
    └── themes/
```

## Thành phần và Giao diện

### 1. Module Quản lý Mượn sách (Tuấn)
**Đường dẫn:** `lib/features/tuan_borrow_management/`

#### Presentation Layer
- `BorrowFormScreen`: Màn hình nhập thông tin mượn sách
- `BorrowListScreen`: Danh sách thẻ mượn
- `BorrowDetailScreen`: Chi tiết thẻ mượn
- `BorrowFormWidget`: Widget form nhập liệu
- `DatePickerWidget`: Widget chọn ngày
- `QRScannerWidget`: Widget quét mã QR/Barcode

#### Business Logic
- `BorrowBloc`: Quản lý state cho việc mượn sách
- `BorrowEvent`: Các sự kiện (CreateBorrow, UpdateBorrow, DeleteBorrow)
- `BorrowState`: Các trạng thái (Loading, Success, Error)

#### Data Layer
- `BorrowRepository`: Interface repository
- `BorrowRepositoryImpl`: Implement repository
- `BorrowLocalDataSource`: Nguồn dữ liệu local
- `BorrowRemoteDataSource`: Nguồn dữ liệu remote

### 2. Module Cảnh báo Quá hạn (Tùng)
**Đường dẫn:** `lib/features/tung_overdue_alerts/`

#### Presentation Layer
- `OverdueListScreen`: Danh sách sách quá hạn
- `OverdueDashboardWidget`: Widget dashboard cảnh báo
- `OverdueNotificationWidget`: Widget thông báo
- `OverdueCardWidget`: Widget hiển thị thẻ quá hạn
- `NotificationSettingsScreen`: 🆕 Màn hình cài đặt email notification

#### Business Logic
- `OverdueBloc`: Quản lý state cảnh báo quá hạn
- `OverdueEvent`: Các sự kiện (CheckOverdue, SendNotification)
- `OverdueState`: Các trạng thái cảnh báo
- `OverdueService`: Service kiểm tra quá hạn tự động
- `EmailNotificationService`: 🆕 Service gửi email thông báo
- `NotificationScheduler`: 🆕 Service schedule gửi email tự động

#### Data Layer
- `OverdueRepository`: Interface repository
- `OverdueRepositoryImpl`: Implement repository
- `NotificationService`: Service gửi thông báo
- `EmailService`: 🆕 Core service gửi email qua SMTP

### 3. Module Tìm kiếm (Đức)
**Đường dẫn:** `lib/features/duc_search_functionality/`

#### Presentation Layer
- `SearchScreen`: Màn hình tìm kiếm chính
- `SearchResultScreen`: Màn hình kết quả tìm kiếm
- `SearchBarWidget`: Widget thanh tìm kiếm
- `FilterWidget`: Widget bộ lọc
- `SearchResultListWidget`: Widget danh sách kết quả

#### Business Logic
- `SearchBloc`: Quản lý state tìm kiếm
- `SearchEvent`: Các sự kiện (SearchByName, SearchByBook, ApplyFilter)
- `SearchState`: Các trạng thái tìm kiếm
- `SearchService`: Service xử lý logic tìm kiếm

#### Data Layer
- `SearchRepository`: Interface repository
- `SearchRepositoryImpl`: Implement repository
- `SearchLocalDataSource`: Cache kết quả tìm kiếm

### 4. Module Danh sách Thẻ Mượn/Trả (Shared)
**Đường dẫn:** `lib/features/borrow_return_status/`

#### Presentation Layer
- `BorrowStatusScreen`: Màn hình chính với 2 tab
- `ActiveBorrowsTab`: Tab danh sách đang mượn
- `ReturnedBorrowsTab`: Tab danh sách đã trả
- `BorrowStatusCard`: Widget hiển thị thông tin thẻ
- `StatusFilterWidget`: Widget lọc theo trạng thái
- `PaginationWidget`: Widget phân trang

#### Business Logic
- `BorrowStatusBloc`: Quản lý state danh sách thẻ
- `BorrowStatusEvent`: Các sự kiện (LoadActiveBorrows, LoadReturnedBorrows, UpdateStatus)
- `BorrowStatusState`: Các trạng thái danh sách
- `StatusUpdateService`: Service cập nhật trạng thái thẻ

#### Data Layer
- `BorrowStatusRepository`: Interface repository
- `BorrowStatusRepositoryImpl`: Implement repository
- Tích hợp với `BorrowRepository` từ module Tuấn

### 5. Module Thống kê và Báo cáo (Shared)
**Đường dẫn:** `lib/features/statistics_reports/`

#### Presentation Layer
- `StatisticsScreen`: Màn hình thống kê chính
- `UserStatisticsTab`: Tab thống kê theo người dùng
- `MonthlyStatisticsTab`: Tab thống kê theo tháng
- `StatisticsChartWidget`: Widget biểu đồ
- `StatisticsTableWidget`: Widget bảng số liệu
- `DateRangePickerWidget`: Widget chọn khoảng thời gian
- `ExportReportWidget`: Widget xuất báo cáo

#### Business Logic
- `StatisticsBloc`: Quản lý state thống kê
- `StatisticsEvent`: Các sự kiện (LoadUserStats, LoadMonthlyStats, ExportReport)
- `StatisticsState`: Các trạng thái thống kê
- `ReportGeneratorService`: Service tạo báo cáo
- `ChartDataService`: Service xử lý dữ liệu biểu đồ

#### Data Layer
- `StatisticsRepository`: Interface repository
- `StatisticsRepositoryImpl`: Implement repository
- `ReportExportService`: Service xuất báo cáo PDF/Excel
- Tích hợp với tất cả repositories khác để lấy dữ liệu

### 6. Module Tích hợp IoT và Quét mã (Shared)
**Đường dẫn:** `lib/features/iot_scanner_integration/`

#### Presentation Layer
- `QRScannerScreen`: Màn hình quét mã chính
- `CameraPreviewWidget`: Widget hiển thị camera
- `ScanResultWidget`: Widget hiển thị kết quả quét
- `ManualInputFallbackWidget`: Widget nhập thủ công khi quét lỗi
- `ScanHistoryWidget`: Widget lịch sử quét

#### Business Logic
- `ScannerBloc`: Quản lý state quét mã
- `ScannerEvent`: Các sự kiện (StartScan, ProcessScanResult, SwitchToManual)
- `ScannerState`: Các trạng thái quét mã
- `QRCodeProcessorService`: Service xử lý mã QR
- `BarcodeProcessorService`: Service xử lý barcode
- `CameraPermissionService`: Service quản lý quyền camera

#### Data Layer
- `ScannerRepository`: Interface repository
- `ScannerRepositoryImpl`: Implement repository
- `ScanHistoryLocalDataSource`: Lưu trữ lịch sử quét
- Tích hợp với `BookRepository` và `ReaderRepository` để lấy thông tin

## Mô hình Dữ liệu

### Cơ sở dữ liệu PostgreSQL

#### Bảng borrow_cards (Thẻ mượn)
```sql
CREATE TABLE borrow_cards (
    id SERIAL PRIMARY KEY,
    borrower_name VARCHAR(255) NOT NULL,
    borrower_class VARCHAR(100),
    borrower_student_id VARCHAR(50),
    borrower_phone VARCHAR(20),
    borrower_email VARCHAR(255), -- 🆕 Email để gửi thông báo
    book_name VARCHAR(500) NOT NULL,
    book_code VARCHAR(100),
    borrow_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    actual_return_date DATE,
    status VARCHAR(50) DEFAULT 'borrowed', -- borrowed, returned, overdue
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Bảng books (Sách)
```sql
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    book_code VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    author VARCHAR(255),
    category VARCHAR(100),
    isbn VARCHAR(50),
    total_copies INTEGER DEFAULT 1,
    available_copies INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Bảng readers (Độc giả)
```sql
CREATE TABLE readers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    student_id VARCHAR(50) UNIQUE,
    class VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Models trong Flutter

#### BorrowCard Model
```dart
class BorrowCard {
  final int? id;
  final String borrowerName;
  final String? borrowerClass;
  final String? borrowerStudentId;
  final String? borrowerPhone;
  final String? borrowerEmail; // 🆕 Email để gửi thông báo
  final String bookName;
  final String? bookCode;
  final DateTime borrowDate;
  final DateTime expectedReturnDate;
  final DateTime? actualReturnDate;
  final BorrowStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

enum BorrowStatus { borrowed, returned, overdue }
```

#### Book Model
```dart
class Book {
  final int? id;
  final String bookCode;
  final String title;
  final String? author;
  final String? category;
  final String? isbn;
  final int totalCopies;
  final int availableCopies;
}
```

#### Reader Model
```dart
class Reader {
  final int? id;
  final String name;
  final String? studentId;
  final String? className;
  final String? phone;
  final String? email;
  final String? address;
}
```

## Xử lý Lỗi

### Hierarchy lỗi
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class CameraFailure extends Failure {
  const CameraFailure(String message) : super(message);
}
```

### Error Handling Strategy
- Sử dụng Either<Failure, Success> pattern
- Global error handler cho các lỗi không mong đợi
- User-friendly error messages
- Retry mechanism cho network errors
- Offline fallback cho database operations

## Chiến lược Kiểm thử

### Unit Tests
- Test cho tất cả business logic trong BLoCs
- Test cho repositories và data sources
- Test cho models và utilities
- Coverage target: 80%

### Widget Tests
- Test cho tất cả custom widgets
- Test cho user interactions
- Test cho form validations

### Integration Tests
- Test end-to-end workflows
- Test database operations
- Test camera functionality
- Test offline scenarios

### Test Organization
```
test/
├── unit/
│   ├── features/
│   │   ├── tuan_borrow_management/
│   │   ├── tung_overdue_alerts/
│   │   └── duc_search_functionality/
│   └── shared/
├── widget/
└── integration/
```

## Cấu hình và Dependencies

### Packages chính
```yaml
dependencies:
  flutter: ^3.16.0
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.4
  injectable: ^2.3.2
  postgres: ^2.6.2
  sqflite: ^2.3.0
  camera: ^0.10.5
  qr_code_scanner: ^1.0.1
  permission_handler: ^11.0.1
  flutter_local_notifications: ^16.1.0
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  mailer: ^6.0.1              # 🆕 Gửi email qua SMTP
  workmanager: ^0.5.2         # 🆕 Background tasks

dev_dependencies:
  flutter_test: ^3.16.0
  mockito: ^5.4.2
  bloc_test: ^9.1.4
  build_runner: ^2.4.7
  injectable_generator: ^2.4.1
```

### Database Configuration
```dart
class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 5432;
  static const String databaseName = 'library_management';
  static const String username = 'postgres';
  static const String password = 'password';
}
```

### Dependency Injection Setup
```dart
@InjectableInit()
void configureDependencies() => getIt.init();

// Core Services - Shared across all modules
@module
abstract class CoreModule {
  @lazySingleton
  DatabaseHelper get databaseHelper => DatabaseHelper();
  
  @lazySingleton
  NotificationService get notificationService => NotificationService();
  
  @lazySingleton
  CameraService get cameraService => CameraService();
  
  @lazySingleton
  ReportExportService get reportExportService => ReportExportService();
}

// Module 1: Tuấn - Borrow Management
@module
abstract class TuanBorrowModule {
  @lazySingleton
  BorrowRepository get borrowRepository => BorrowRepositoryImpl(
    getIt<DatabaseHelper>(),
    getIt<NotificationService>()
  );
  
  @factory
  BorrowBloc get borrowBloc => BorrowBloc(getIt<BorrowRepository>());
}

// Module 2: Tùng - Overdue Alerts
@module
abstract class TungOverdueModule {
  @lazySingleton
  OverdueRepository get overdueRepository => OverdueRepositoryImpl(
    getIt<BorrowRepository>(),
    getIt<NotificationService>()
  );
  
  @factory
  OverdueBloc get overdueBloc => OverdueBloc(getIt<OverdueRepository>());
}

// Module 3: Đức - Search Functionality
@module
abstract class DucSearchModule {
  @lazySingleton
  SearchRepository get searchRepository => SearchRepositoryImpl(
    getIt<BorrowRepository>(),
    getIt<DatabaseHelper>()
  );
  
  @factory
  SearchBloc get searchBloc => SearchBloc(getIt<SearchRepository>());
}

// Module 4: Borrow/Return Status (Shared)
@module
abstract class BorrowStatusModule {
  @lazySingleton
  BorrowStatusRepository get borrowStatusRepository => BorrowStatusRepositoryImpl(
    getIt<BorrowRepository>()
  );
  
  @factory
  BorrowStatusBloc get borrowStatusBloc => BorrowStatusBloc(
    getIt<BorrowStatusRepository>()
  );
}

// Module 5: Statistics & Reports (Shared)
@module
abstract class StatisticsModule {
  @lazySingleton
  StatisticsRepository get statisticsRepository => StatisticsRepositoryImpl(
    getIt<BorrowRepository>(),
    getIt<DatabaseHelper>()
  );
  
  @factory
  StatisticsBloc get statisticsBloc => StatisticsBloc(
    getIt<StatisticsRepository>(),
    getIt<ReportExportService>()
  );
}

// Module 6: IoT Scanner Integration (Shared)
@module
abstract class ScannerModule {
  @lazySingleton
  ScannerRepository get scannerRepository => ScannerRepositoryImpl(
    getIt<CameraService>(),
    getIt<DatabaseHelper>()
  );
  
  @factory
  ScannerBloc get scannerBloc => ScannerBloc(getIt<ScannerRepository>());
}
```

## Liên kết giữa các Module

### Data Flow và Integration
```dart
// Shared Event Bus cho communication giữa modules
@lazySingleton
class AppEventBus {
  final StreamController<AppEvent> _eventController = StreamController.broadcast();
  
  Stream<AppEvent> get events => _eventController.stream;
  
  void emit(AppEvent event) => _eventController.add(event);
}

// Events để modules giao tiếp với nhau
abstract class AppEvent {}

class BorrowCreatedEvent extends AppEvent {
  final BorrowCard borrowCard;
  BorrowCreatedEvent(this.borrowCard);
}

class BorrowReturnedEvent extends AppEvent {
  final int borrowId;
  BorrowReturnedEvent(this.borrowId);
}

class OverdueDetectedEvent extends AppEvent {
  final List<BorrowCard> overdueCards;
  OverdueDetectedEvent(this.overdueCards);
}
```

### Module Integration Strategy
1. **Tuấn's Borrow Module** → Emit events khi tạo/cập nhật thẻ mượn
2. **Tùng's Overdue Module** → Listen events từ Borrow Module để check quá hạn
3. **Đức's Search Module** → Access data từ Borrow Repository
4. **Status Module** → Aggregate data từ Borrow Module
5. **Statistics Module** → Aggregate data từ tất cả modules
6. **Scanner Module** → Provide data cho Borrow Module

### Navigation và Routing
```dart
// Centralized routing để modules có thể navigate qua lại
class AppRouter {
  static const String borrowForm = '/borrow-form';
  static const String overdueList = '/overdue-list';
  static const String search = '/search';
  static const String borrowStatus = '/borrow-status';
  static const String statistics = '/statistics';
  static const String scanner = '/scanner';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case borrowForm:
        return MaterialPageRoute(
          builder: (_) => BorrowFormScreen(),
        );
      case overdueList:
        return MaterialPageRoute(
          builder: (_) => OverdueListScreen(),
        );
      // ... other routes
    }
  }
}
```

## Bảo mật và Hiệu suất

### Security Measures
- Input validation và sanitization
- SQL injection prevention
- Secure storage cho sensitive data
- Permission handling cho camera và storage

### Performance Optimizations
- Database indexing cho search operations
- Lazy loading cho large lists
- Image caching cho QR codes
- Background processing cho overdue checks
- Pagination cho large datasets

### Offline Support
- Local SQLite database sync
- Cached search results
- Offline form submissions
- Background sync when online

## Monitoring và Logging

### Logging Strategy
```dart
class AppLogger {
  static void logInfo(String message, [String? tag]);
  static void logError(String message, [dynamic error, StackTrace? stackTrace]);
  static void logDebug(String message, [String? tag]);
}
```

### Analytics Events
- User actions tracking
- Error tracking
- Performance metrics
- Feature usage statistics