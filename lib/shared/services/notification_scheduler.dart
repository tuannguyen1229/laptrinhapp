import 'dart:async';
import '../../features/tung_overdue_alerts/data/services/overdue_service.dart';
import '../../shared/models/borrow_card.dart';
import '../../shared/repositories/borrow_card_repository.dart';
import 'email_service.dart';

/// Service để schedule và quản lý việc gửi email thông báo tự động
/// Sử dụng Timer để check và gửi email định kỳ
class NotificationScheduler {
  final OverdueService _overdueService;
  final BorrowCardRepository _borrowRepository;
  final EmailService _emailService;
  Timer? _dailyTimer;
  Timer? _periodicTimer;

  NotificationScheduler({
    required OverdueService overdueService,
    required BorrowCardRepository borrowRepository,
    required EmailService emailService,
  })  : _overdueService = overdueService,
        _borrowRepository = borrowRepository,
        _emailService = emailService;

  /// Khởi tạo scheduler với email service mặc định
  static NotificationScheduler createDefault(
    OverdueService overdueService,
    BorrowCardRepository borrowRepository,
  ) {
    return NotificationScheduler(
      overdueService: overdueService,
      borrowRepository: borrowRepository,
      emailService: EmailService.defaultConfig(),
    );
  }

  /// Khởi tạo và bắt đầu scheduler
  static Future<void> initialize() async {
    print('NotificationScheduler: Initialized with auto email sending');
  }

  /// Bắt đầu schedule gửi email tự động
  /// - Check mỗi 1 giờ
  /// - Gửi email vào 8:00 AM hàng ngày
  Future<void> startAutoSchedule() async {
    print('NotificationScheduler: Starting auto schedule...');
    
    // Schedule check hàng giờ (mỗi 1 giờ)
    _periodicTimer = Timer.periodic(
      const Duration(hours: 1),
      (timer) async {
        final now = DateTime.now();
        print('NotificationScheduler: Periodic check at ${now.hour}:${now.minute}');
        
        // Chỉ gửi email vào 8:00 AM
        if (now.hour == 8 && now.minute < 60) {
          await checkAndSendNotifications();
        }
      },
    );

    // Schedule daily vào 8:00 AM
    _scheduleDailyAt8AM();
    
    // Gửi ngay lần đầu để test (comment dòng này nếu không muốn gửi ngay)
    print('NotificationScheduler: Sending initial notifications...');
    await checkAndSendNotifications();
  }

  /// Schedule task chạy hàng ngày lúc 8:00 AM
  void _scheduleDailyAt8AM() {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);
    
    // Nếu đã qua 8:00 AM hôm nay, schedule cho 8:00 AM ngày mai
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    final delay = scheduledTime.difference(now);
    print('NotificationScheduler: Next daily check in ${delay.inHours} hours ${delay.inMinutes % 60} minutes');
    
    _dailyTimer = Timer(delay, () async {
      await checkAndSendNotifications();
      // Reschedule cho ngày hôm sau
      _scheduleDailyAt8AM();
    });
  }

  /// Dừng scheduler
  Future<void> stopSchedule() async {
    _dailyTimer?.cancel();
    _periodicTimer?.cancel();
    _dailyTimer = null;
    _periodicTimer = null;
    print('NotificationScheduler: Schedule stopped');
  }

  /// Hủy schedule (alias cho stopSchedule)
  Future<void> cancelSchedule() async {
    await stopSchedule();
  }

  /// Kiểm tra và gửi tất cả thông báo
  Future<NotificationSummary> checkAndSendNotifications() async {
    final summary = NotificationSummary();
    print('\n📧 ========== BẮT ĐẦU GỬI EMAIL THÔNG BÁO ==========');
    print('⏰ Thời gian: ${DateTime.now()}');

    try {
      // 1. Gửi thông báo sắp đến hạn (0-3 ngày)
      print('\n📬 Checking sách sắp đến hạn (0-3 ngày)...');
      final upcomingCards = await getUpcomingDueCards();
      print('   Tìm thấy: ${upcomingCards.length} sách');
      
      for (final card in upcomingCards) {
        if (card.borrowerEmail != null && card.borrowerEmail!.isNotEmpty) {
          print('   📤 Gửi email đến: ${card.borrowerEmail} (${card.borrowerName})');
          final result = await _emailService.sendUpcomingDueNotification(card);
          if (result.success) {
            summary.upcomingDueSent++;
            print('   ✅ Gửi thành công!');
          } else {
            summary.failed++;
            summary.errors.add('Failed to send to ${card.borrowerEmail}: ${result.error}');
            print('   ❌ Gửi thất bại: ${result.error}');
          }
          // Delay 200ms giữa các email
          await Future.delayed(const Duration(milliseconds: 200));
        } else {
          summary.skipped++;
          print('   ⏭️  Bỏ qua: ${card.borrowerName} (không có email)');
        }
      }

      // 2. Gửi thông báo đến hạn hôm nay
      print('\n📬 Checking sách đến hạn hôm nay...');
      final dueTodayCards = await getDueTodayCards();
      print('   Tìm thấy: ${dueTodayCards.length} sách');
      
      for (final card in dueTodayCards) {
        if (card.borrowerEmail != null && card.borrowerEmail!.isNotEmpty) {
          print('   📤 Gửi email đến: ${card.borrowerEmail} (${card.borrowerName})');
          final result = await _emailService.sendDueTodayNotification(card);
          if (result.success) {
            summary.dueTodaySent++;
            print('   ✅ Gửi thành công!');
          } else {
            summary.failed++;
            summary.errors.add('Failed to send to ${card.borrowerEmail}: ${result.error}');
            print('   ❌ Gửi thất bại: ${result.error}');
          }
          await Future.delayed(const Duration(milliseconds: 200));
        } else {
          summary.skipped++;
          print('   ⏭️  Bỏ qua: ${card.borrowerName} (không có email)');
        }
      }

      // 3. Gửi thông báo quá hạn (mỗi ngày)
      print('\n📬 Checking sách quá hạn (< 0 ngày)...');
      final overdueCards = await getOverdueCardsForNotification();
      print('   Tìm thấy: ${overdueCards.length} sách');
      
      for (final card in overdueCards) {
        if (card.borrowerEmail != null && card.borrowerEmail!.isNotEmpty) {
          print('   📤 Gửi email đến: ${card.borrowerEmail} (${card.borrowerName}) - Quá hạn ${card.daysOverdue} ngày');
          final result = await _emailService.sendOverdueNotification(card);
          if (result.success) {
            summary.overdueSent++;
            print('   ✅ Gửi thành công!');
          } else {
            summary.failed++;
            summary.errors.add('Failed to send to ${card.borrowerEmail}: ${result.error}');
            print('   ❌ Gửi thất bại: ${result.error}');
          }
          await Future.delayed(const Duration(milliseconds: 200));
        } else {
          summary.skipped++;
          print('   ⏭️  Bỏ qua: ${card.borrowerName} (không có email)');
        }
      }

      summary.success = true;
      summary.completedAt = DateTime.now();
      
      print('\n📊 ========== KẾT QUẢ GỬI EMAIL ==========');
      print('✅ Thành công: ${summary.totalSent} email');
      print('   - Sắp đến hạn: ${summary.upcomingDueSent}');
      print('   - Đến hạn hôm nay: ${summary.dueTodaySent}');
      print('   - Quá hạn: ${summary.overdueSent}');
      print('❌ Thất bại: ${summary.failed}');
      print('⏭️  Bỏ qua: ${summary.skipped}');
      print('==========================================\n');
      
    } catch (e) {
      summary.success = false;
      summary.errors.add('Error during notification check: $e');
      print('❌ LỖI: $e');
    }

    return summary;
  }

  /// Lấy danh sách sách sắp đến hạn (còn 0-3 ngày)
  /// Chỉ gửi khi còn ≤ 3 ngày (0, 1, 2, 3 ngày)
  /// KHÔNG gửi cho sách quá hạn (< 0 ngày)
  Future<List<BorrowCard>> getUpcomingDueCards() async {
    final result = await _borrowRepository.getAll();
    
    return result.fold(
      (failure) => [],
      (cards) {
        final now = DateTime.now();
        return cards.where((card) {
          if (card.status == BorrowStatus.returned) return false;
          
          final daysUntilDue = card.expectedReturnDate.difference(now).inDays;
          // Chỉ gửi khi còn 0-3 ngày (chưa quá hạn)
          return daysUntilDue >= 0 && daysUntilDue <= 3;
        }).toList();
      },
    );
  }

  /// Lấy danh sách sách đến hạn hôm nay
  Future<List<BorrowCard>> getDueTodayCards() async {
    final result = await _borrowRepository.getAll();
    
    return result.fold(
      (failure) => [],
      (cards) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        return cards.where((card) {
          if (card.status == BorrowStatus.returned) return false;
          
          final dueDate = DateTime(
            card.expectedReturnDate.year,
            card.expectedReturnDate.month,
            card.expectedReturnDate.day,
          );
          
          return dueDate.isAtSameMomentAs(today);
        }).toList();
      },
    );
  }

  /// Lấy danh sách sách quá hạn cần gửi thông báo
  /// Gửi tiếp tục mỗi ngày cho sách quá hạn (< 0 ngày)
  Future<List<BorrowCard>> getOverdueCardsForNotification() async {
    final result = await _overdueService.getOverdueCards();
    
    return result.fold(
      (failure) => [],
      (cards) {
        // Trả về TẤT CẢ sách quá hạn (gửi mỗi ngày)
        return cards.toList();
      },
    );
  }

  /// Tính toán thời gian delay ban đầu để chạy vào 8:00 AM
  // ignore: unused_element
  Duration _calculateInitialDelay() {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);
    
    // Nếu đã qua 8:00 AM hôm nay, schedule cho 8:00 AM ngày mai
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    return scheduledTime.difference(now);
  }
}

/// Callback dispatcher cho WorkManager (Disabled)
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       // TODO: Initialize dependencies và gọi checkAndSendNotifications
//       // Cần setup dependency injection trong background task
//       print('Background task executed: $task');
//       return Future.value(true);
//     } catch (e) {
//       print('Error in background task: $e');
//       return Future.value(false);
//     }
//   });
// }

/// Tóm tắt kết quả gửi thông báo
class NotificationSummary {
  bool success = false;
  int upcomingDueSent = 0;
  int dueTodaySent = 0;
  int overdueSent = 0;
  int failed = 0;
  int skipped = 0;
  List<String> errors = [];
  DateTime? completedAt;

  int get totalSent => upcomingDueSent + dueTodaySent + overdueSent;

  @override
  String toString() {
    return '''
NotificationSummary:
  Success: $success
  Total Sent: $totalSent
  - Upcoming Due: $upcomingDueSent
  - Due Today: $dueTodaySent
  - Overdue: $overdueSent
  Failed: $failed
  Skipped: $skipped
  Errors: ${errors.length}
  Completed At: $completedAt
''';
  }
}
