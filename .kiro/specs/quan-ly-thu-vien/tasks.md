# Danh sách Công việc - Ứng dụng Quản lý Thư viện

- [x] 1. Thiết lập cấu trúc dự án và core services






  - Tạo cấu trúc thư mục Flutter theo Clean Architecture
  - Cấu hình dependencies và packages cần thiết
  - Thiết lập dependency injection với GetIt và Injectable
  - Tạo core services: DatabaseHelper, NotificationService, CameraService
  - Thiết lập kết nối PostgreSQL và SQLite local
  - _Requirements: 7.1, 7.3_

- [x] 2. Tạo shared models và repositories





  - Implement BorrowCard, Book, Reader models với JSON serialization
  - Tạo base repository interfaces và abstract classes
  - Implement shared database operations và error handling
  - Tạo AppEventBus cho communication giữa modules
  - _Requirements: 7.1, 7.2_

- [x] 3. Module Tuấn - Quản lý mượn sách (tuan_borrow_management) ✅ HOÀN THÀNH
  - ✅ Tạo BorrowRepository và BorrowRepositoryImpl
  - ✅ Implement BorrowBloc với đầy đủ events và states
  - ✅ Tạo BorrowFormScreen với form validation và date picker
  - ✅ Implement BorrowListScreen với search, filter, pagination
  - ✅ Tạo BorrowDetailScreen với UI gradient đẹp
  - ✅ Integrate placeholder cho Scanner module
  - ✅ Offline-first architecture (SQLite + PostgreSQL)
  - ✅ Real-time update sau khi edit/delete
  - ✅ Beautiful gradient UI design
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [x] 3.1 Implement BorrowRepository và data layer ✅
  - ✅ Tạo BorrowLocalDataSource (SQLite)
  - ✅ Tạo BorrowRemoteDataSource (PostgreSQL)
  - ✅ Implement CRUD operations cho borrow cards
  - ✅ Thêm validation logic với BorrowCardValidator
  - _Requirements: 1.1, 1.5_

- [x] 3.2 Tạo BorrowBloc và business logic ✅
  - ✅ Implement BorrowBloc với state management
  - ✅ Tạo đầy đủ events: Create, Update, Delete, Load, Search, Filter
  - ✅ Implement các states: Loading, Loaded, Error, Empty
  - ✅ Pagination và refresh functionality
  - ✅ Mark as returned và update status
  - ✅ Scanner input handling (placeholder)
  - _Requirements: 1.1, 1.6_

- [x] 3.3 Implement presentation layer ✅
  - ✅ Tạo BorrowFormScreen với form fields và validation
  - ✅ Implement DatePickerWidget cho chọn ngày mượn/trả
  - ✅ Tạo BorrowListScreen với search, filter chips, pagination
  - ✅ Implement BorrowDetailScreen với thông tin chi tiết
  - ✅ BorrowCardWidget với gradient design theo trạng thái
  - ✅ Pull-to-refresh và infinite scroll
  - ✅ Real-time UI update
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [ ]* 3.4 Viết unit tests cho Borrow module (⏸️ Hoãn lại - Sẽ viết sau khi hoàn thành tất cả modules)
  - Test BorrowBloc với các scenarios khác nhau
  - Test BorrowRepository operations
  - Test form validation logic
  - _Requirements: 1.1, 1.6_

- [x] 4. Module Tùng - Cảnh báo quá hạn (tung_overdue_alerts) ✅ HOÀN THÀNH
  - ✅ Tạo OverdueRepository và OverdueRepositoryImpl
  - ✅ Implement OverdueBloc với logic kiểm tra quá hạn tự động
  - ✅ Tạo OverdueListScreen với gradient UI đẹp
  - ✅ Implement OverdueDashboardWidget với thống kê màu sắc
  - ✅ OverdueService với logic tính toán quá hạn
  - ✅ Phân loại mức độ: Nhẹ, Trung bình, Nghiêm trọng
  - ✅ Beautiful gradient cards theo mức độ quá hạn
  - ⏸️ Background service (sẽ implement sau)
  - ⏸️ Push notifications (sẽ implement sau)
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [x] 4.1 Implement OverdueRepository và logic kiểm tra ✅
  - ✅ Tạo OverdueService để check ngày quá hạn
  - ✅ Implement logic tính toán số ngày quá hạn
  - ✅ Phân loại mức độ nghiêm trọng (low/medium/high)
  - ✅ Thống kê chi tiết theo mức độ
  - ⏸️ Background timer (hoãn lại - cần permission)
  - _Requirements: 2.1, 2.2_

- [x] 4.2 Tạo OverdueBloc và state management ✅
  - ✅ Implement OverdueBloc với state management
  - ✅ Tạo events: LoadOverdueCards, LoadStatistics, Refresh
  - ✅ Implement states: Loading, Loaded, Error, Empty
  - ✅ CheckOverdueAutomatically event (placeholder)
  - ⏸️ NotificationService integration (hoãn lại)
  - _Requirements: 2.3, 2.5, 2.6_

- [x] 4.3 Implement presentation layer cho overdue alerts ✅
  - ✅ Tạo OverdueListScreen với danh sách sách quá hạn
  - ✅ Implement OverdueDashboardWidget với thống kê đẹp
  - ✅ OverdueCardWidget với gradient theo mức độ
  - ✅ Màu sắc cảnh báo: Orange (nhẹ), Deep Orange (TB), Red (nặng)
  - ✅ Icons và UI cảnh báo rõ ràng
  - ✅ Empty state khi không có quá hạn
  - ✅ Pull-to-refresh functionality
  - _Requirements: 2.3, 2.4, 2.6_

- [ ]* 4.4 Viết unit tests cho Overdue module (⏸️ Hoãn lại)
  - Test OverdueService logic
  - Test OverdueBloc scenarios
  - Test notification functionality
  - _Requirements: 2.1, 2.3_

- [x] 4.5 Module Tùng - Email Notification (tung_overdue_alerts) ✅ HOÀN THÀNH
  - ✅ Thêm cột borrower_email vào database (database/setup_postgres.sql)
  - ✅ Cập nhật BorrowCard model với email field (lib/shared/models/borrow_card.dart)
  - ✅ Implement EmailService với SMTP integration (lib/shared/services/email_service.dart)
  - ✅ Implement NotificationScheduler với Timer-based tasks (lib/shared/services/notification_scheduler.dart)
  - ✅ Implement EmailNotificationService (lib/features/tung_overdue_alerts/data/services/email_notification_service.dart)
  - ✅ Tạo NotificationSettingsScreen (lib/features/tung_overdue_alerts/presentation/screens/notification_settings_screen.dart)
  - ✅ Email templates: upcoming_due, due_today, overdue (trong EmailService)
  - ✅ Email logging và error handling (NotificationSummary, EmailResult)
  - ✅ Test với Gmail SMTP server (hardcoded credentials)
  - ✅ Tài liệu chi tiết (AUTO_EMAIL_NOTIFICATION.md)
  - ✅ Auto schedule 8:00 AM hàng ngày
  - ✅ Check mỗi 1 giờ
  - ✅ Gửi email theo mốc: 2-3 ngày trước, đến hạn, quá hạn 1/3/7 ngày
  - _Requirements: 2.1 (Email Notification)_

- [x] 5. Module Đức - Tìm kiếm (duc_search_functionality) ✅ HOÀN THÀNH
  - ✅ Tạo SearchRepository và SearchRepositoryImpl
  - ✅ Implement SearchBloc với live search functionality
  - ✅ Tạo SearchScreen với search bar và filters
  - ✅ Implement SearchResultCardWidget với kết quả
  - ✅ Tạo advanced search với multiple criteria
  - ✅ Implement search history và caching
  - ✅ Debounce 300ms cho live search
  - ✅ Highlight matched text trong results
  - ✅ Beautiful gradient UI design
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [x] 5.1 Implement SearchRepository và search logic ✅
  - ✅ Tạo SearchService với full-text search
  - ✅ Implement search algorithms cho tên sách và người mượn
  - ✅ Tạo search caching mechanism (5 phút expiry)
  - ✅ Implement search history service (SharedPreferences)
  - ✅ Sort by relevance (exact match first)
  - _Requirements: 3.1, 3.2, 3.6_

- [x] 5.2 Tạo SearchBloc và live search ✅
  - ✅ Implement SearchBloc với debounced search (300ms)
  - ✅ Tạo events: SearchByBorrowerNameEvent, SearchByBookNameEvent, ApplyAdvancedSearchEvent
  - ✅ Implement live search với real-time results
  - ✅ Implement states: Initial, Loading, Loaded, Empty, Error
  - ✅ Cache integration trong BLoC
  - ✅ Search history integration
  - _Requirements: 3.4, 3.7_

- [x] 5.3 Implement presentation layer cho search ✅
  - ✅ Tạo SearchScreen với search bar và tab navigation
  - ✅ Implement AdvancedSearchDialog cho advanced search
  - ✅ Tạo SearchResultCardWidget với highlight matched text
  - ✅ Implement SearchHistoryWidget với chips
  - ✅ Implement SearchBarWidget
  - ✅ Empty state, Loading state, Error state
  - ✅ Navigation to detail screen
  - ✅ Beautiful gradient UI (Cyan-Blue)
  - _Requirements: 3.1, 3.3, 3.4, 3.7_

- [ ]* 5.4 Viết unit tests cho Search module (⏸️ Hoãn lại)
  - Test search algorithms và performance
  - Test SearchBloc với various queries
  - Test filter functionality
  - Test cache expiry
  - _Requirements: 3.1, 3.2_

- [x] 6. Module Danh sách thẻ mượn/trả (borrow_return_status) ✅ HOÀN THÀNH
  - ✅ Tạo BorrowStatusRepository sử dụng BorrowRepository
  - ✅ Implement BorrowStatusBloc với tab management
  - ✅ Tạo BorrowStatusScreen với 2 tabs: Đang mượn/Đã trả
  - ✅ Implement pagination cho large datasets
  - ✅ Tạo status update functionality
  - ✅ Integrate với tất cả modules khác để sync data
  - ✅ Beautiful gradient UI design với status colors
  - ✅ Search functionality across tabs
  - ✅ Mark as returned với confirmation dialog
  - ✅ Status summary widget với counts
  - ✅ Real-time UI updates
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

- [x] 6.1 Implement BorrowStatusRepository ✅
  - ✅ Tạo BorrowStatusRepositoryImpl aggregate data từ BorrowRepository
  - ✅ Implement filtering logic theo status (active/returned/overdue)
  - ✅ Tạo PaginationService với offset calculation
  - ✅ Search functionality với multiple fields
  - ✅ Status counts calculation
  - _Requirements: 4.1, 4.4_

- [x] 6.2 Tạo BorrowStatusBloc và tab management ✅
  - ✅ Implement BorrowStatusBloc với comprehensive state management
  - ✅ Tạo events: LoadBorrowStatusEvent, SwitchTabEvent, SearchBorrowsEvent
  - ✅ Implement MarkAsReturnedEvent với optimistic updates
  - ✅ Pagination events: LoadNextPageEvent, LoadPreviousPageEvent, GoToPageEvent
  - ✅ RefreshDataEvent và LoadStatusCountsEvent
  - ✅ Error handling và loading states
  - _Requirements: 4.1, 4.2, 4.6_

- [x] 6.3 Implement presentation layer cho status management ✅
  - ✅ Tạo BorrowStatusScreen với TabController và search
  - ✅ Implement StatusSummaryWidget với interactive status cards
  - ✅ Tạo BorrowStatusCardWidget với gradient theo status
  - ✅ Implement PaginationWidget với page numbers
  - ✅ Mark as returned button với confirmation
  - ✅ Empty states, loading states, error states
  - ✅ Pull-to-refresh functionality
  - ✅ Navigation to detail screen
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ]* 6.4 Viết unit tests cho BorrowStatus module
  - Test status filtering logic
  - Test pagination functionality
  - Test tab switching behavior
  - _Requirements: 4.1, 4.2_

- [x] 7. Module Thống kê và báo cáo (statistics_reports)




  - Tạo StatisticsRepository aggregate data từ tất cả modules
  - Implement StatisticsBloc với chart data processing
  - Tạo StatisticsScreen với tabs cho user stats và monthly stats
  - Implement chart widgets sử dụng fl_chart package
  - Tạo report export functionality (PDF/Excel)
  - Implement date range filtering
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [x] 7.1 Implement StatisticsRepository và data aggregation


  - Tạo repository collect data từ tất cả sources
  - Implement statistical calculations
  - Tạo ChartDataService để format data cho charts
  - _Requirements: 5.1, 5.2, 5.3_

- [x] 7.2 Tạo StatisticsBloc và report generation


  - Implement StatisticsBloc với complex data processing
  - Tạo ReportGeneratorService cho PDF/Excel export
  - Implement date range filtering logic
  - _Requirements: 5.4, 5.5, 5.6_



- [ ] 7.3 Implement presentation layer cho statistics
  - Tạo StatisticsScreen với multiple tabs
  - Implement chart widgets với fl_chart
  - Tạo StatisticsTableWidget cho tabular data
  - Implement DateRangePickerWidget
  - Tạo ExportReportWidget
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.6_

- [ ]* 7.4 Viết unit tests cho Statistics module
  - Test statistical calculations
  - Test report generation
  - Test chart data formatting
  - _Requirements: 5.1, 5.3_

- [ ] 8. Module IoT và quét mã (iot_scanner_integration)
  - Tạo ScannerRepository với camera integration
  - Implement ScannerBloc với QR/Barcode processing
  - Tạo QRScannerScreen với camera preview
  - Implement QR code và barcode detection
  - Tạo fallback manual input khi scan fails
  - Integrate với Book và Reader repositories
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [ ] 8.1 Implement ScannerRepository và camera services
  - Tạo CameraService với permission handling
  - Implement QRCodeProcessorService và BarcodeProcessorService
  - Tạo ScanHistoryLocalDataSource
  - _Requirements: 6.1, 6.2, 6.5_

- [ ] 8.2 Tạo ScannerBloc và processing logic
  - Implement ScannerBloc với camera state management
  - Tạo events: StartScanEvent, ProcessScanResultEvent
  - Implement error handling cho scan failures
  - _Requirements: 6.2, 6.4, 6.6_

- [ ] 8.3 Implement presentation layer cho scanner
  - Tạo QRScannerScreen với camera preview
  - Implement CameraPreviewWidget
  - Tạo ScanResultWidget và ManualInputFallbackWidget
  - Implement permission request UI
  - _Requirements: 6.1, 6.3, 6.4, 6.6_

- [ ]* 8.4 Viết unit tests cho Scanner module
  - Test QR/Barcode processing logic
  - Test camera permission handling
  - Test fallback functionality
  - _Requirements: 6.2, 6.4_

- [ ] 9. Integration và navigation setup
  - Implement AppRouter với tất cả routes
  - Tạo main navigation drawer/bottom navigation
  - Setup deep linking giữa các modules
  - Implement AppEventBus integration
  - Test cross-module communication
  - _Requirements: Tất cả modules_

- [ ] 9.1 Setup navigation và routing
  - Implement AppRouter với named routes
  - Tạo MainNavigationWidget
  - Setup navigation context và route guards
  - _Requirements: Tất cả modules_

- [ ] 9.2 Implement cross-module integration
  - Setup AppEventBus listeners trong tất cả modules
  - Implement data sharing giữa modules
  - Test module communication flows
  - _Requirements: Tất cả modules_

- [ ]* 9.3 Viết integration tests
  - Test end-to-end workflows
  - Test cross-module data flow
  - Test navigation flows
  - _Requirements: Tất cả modules_

- [ ] 10. UI/UX polish và final testing
  - Implement consistent theming across all modules
  - Add loading states và error handling UI
  - Implement responsive design cho different screen sizes
  - Add accessibility features
  - Performance optimization và memory management
  - Final integration testing và bug fixes
  - _Requirements: Tất cả modules_

- [ ] 10.1 Implement theming và UI consistency
  - Tạo AppTheme với consistent colors và typography
  - Implement dark/light theme support
  - Apply theming across tất cả modules
  - _Requirements: Tất cả modules_

- [ ] 10.2 Add loading states và error handling
  - Implement LoadingWidget và ErrorWidget
  - Add proper error messages và retry mechanisms
  - Implement offline support indicators
  - _Requirements: 7.3, 7.4, 7.5_

- [ ] 10.3 Performance optimization
  - Implement lazy loading cho large lists
  - Add image caching và memory management
  - Optimize database queries và indexing
  - _Requirements: Tất cả modules_

- [ ]* 10.4 Final testing và quality assurance
  - Comprehensive testing across tất cả modules
  - Performance testing và memory leak detection
  - User acceptance testing simulation
  - _Requirements: Tất cả modules_