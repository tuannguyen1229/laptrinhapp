import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/services/email_service.dart';
import '../../../../shared/services/notification_scheduler.dart';
import './overdue_service.dart';

/// Service quản lý việc gửi email thông báo cho module Overdue
class EmailNotificationService {
  final EmailService _emailService;
  final NotificationScheduler _notificationScheduler;
  final OverdueService _overdueService;

  EmailNotificationService({
    required EmailService emailService,
    required NotificationScheduler notificationScheduler,
    required OverdueService overdueService,
  })  : _emailService = emailService,
        _notificationScheduler = notificationScheduler,
        _overdueService = overdueService;

  /// Gửi tất cả thông báo quá hạn
  Future<Either<Failure, NotificationStatistics>> sendOverdueNotifications() async {
    try {
      final result = await _overdueService.getOverdueCards();
      
      return await result.fold(
        (failure) async => Left(failure),
        (overdueCards) async {
          final stats = NotificationStatistics();
          
          for (final card in overdueCards) {
            if (card.borrowerEmail == null || card.borrowerEmail!.isEmpty) {
              stats.skipped++;
              continue;
            }

            final emailResult = await _emailService.sendOverdueNotification(card);
            
            if (emailResult.success) {
              stats.sent++;
              stats.successfulEmails.add(card.borrowerEmail!);
            } else {
              stats.failed++;
              stats.failedEmails.add(card.borrowerEmail!);
              stats.errors.add(emailResult.error ?? 'Unknown error');
            }
          }
          
          stats.completedAt = DateTime.now();
          return Right(stats);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to send overdue notifications: $e'));
    }
  }

  /// Gửi tất cả thông báo sắp đến hạn
  Future<Either<Failure, NotificationStatistics>> sendUpcomingDueNotifications() async {
    try {
      final upcomingCards = await _notificationScheduler.getUpcomingDueCards();
      final stats = NotificationStatistics();
      
      for (final card in upcomingCards) {
        if (card.borrowerEmail == null || card.borrowerEmail!.isEmpty) {
          stats.skipped++;
          continue;
        }

        final emailResult = await _emailService.sendUpcomingDueNotification(card);
        
        if (emailResult.success) {
          stats.sent++;
          stats.successfulEmails.add(card.borrowerEmail!);
        } else {
          stats.failed++;
          stats.failedEmails.add(card.borrowerEmail!);
          stats.errors.add(emailResult.error ?? 'Unknown error');
        }
      }
      
      stats.completedAt = DateTime.now();
      return Right(stats);
    } catch (e) {
      return Left(DatabaseFailure('Failed to send upcoming due notifications: $e'));
    }
  }

  /// Gửi email test đến một địa chỉ cụ thể
  Future<Either<Failure, String>> sendTestEmail(String toEmail) async {
    try {
      final result = await _emailService.sendEmail(
        to: toEmail,
        subject: '[Thư viện] Test Email Notification',
        body: '''
Xin chào,

Đây là email test để kiểm tra hệ thống thông báo tự động của thư viện.

Nếu bạn nhận được email này, nghĩa là hệ thống đang hoạt động bình thường.

Trân trọng,
Thư viện
''',
      );

      if (result.success) {
        return Right('Email test đã được gửi thành công đến $toEmail');
      } else {
        return Left(NetworkFailure(result.error ?? 'Failed to send test email'));
      }
    } catch (e) {
      return Left(NetworkFailure('Failed to send test email: $e'));
    }
  }

  /// Gửi email thông báo cho một borrow card cụ thể
  Future<Either<Failure, String>> sendNotificationForCard(
    BorrowCard card,
    NotificationType type,
  ) async {
    try {
      if (card.borrowerEmail == null || card.borrowerEmail!.isEmpty) {
        return Left(ValidationFailure('Không có địa chỉ email'));
      }

      EmailResult result;
      
      switch (type) {
        case NotificationType.upcomingDue:
          result = await _emailService.sendUpcomingDueNotification(card);
          break;
        case NotificationType.dueToday:
          result = await _emailService.sendDueTodayNotification(card);
          break;
        case NotificationType.overdue:
          result = await _emailService.sendOverdueNotification(card);
          break;
      }

      if (result.success) {
        return Right('Email đã được gửi thành công đến ${card.borrowerEmail}');
      } else {
        return Left(NetworkFailure(result.error ?? 'Failed to send email'));
      }
    } catch (e) {
      return Left(NetworkFailure('Failed to send notification: $e'));
    }
  }

  /// Lấy thống kê email đã gửi
  Future<Either<Failure, NotificationStatistics>> getNotificationStats() async {
    // TODO: Implement với database logging nếu cần
    // Hiện tại trả về stats rỗng
    return Right(NotificationStatistics());
  }

  /// Test kết nối SMTP
  Future<Either<Failure, bool>> testSmtpConnection() async {
    try {
      final isConnected = await _emailService.testConnection();
      if (isConnected) {
        return const Right(true);
      } else {
        return Left(NetworkFailure('Failed to connect to SMTP server'));
      }
    } catch (e) {
      return Left(NetworkFailure('SMTP connection error: $e'));
    }
  }

  /// Schedule gửi email tự động hàng ngày
  Future<Either<Failure, String>> scheduleAutomaticNotifications() async {
    try {
      await _notificationScheduler.startAutoSchedule();
      return const Right('Đã bật thông báo tự động hàng ngày lúc 8:00 AM');
    } catch (e) {
      return Left(DatabaseFailure('Failed to schedule notifications: $e'));
    }
  }

  /// Hủy schedule tự động
  Future<Either<Failure, String>> cancelAutomaticNotifications() async {
    try {
      await _notificationScheduler.cancelSchedule();
      return const Right('Đã tắt thông báo tự động');
    } catch (e) {
      return Left(DatabaseFailure('Failed to cancel schedule: $e'));
    }
  }

  /// Chạy thủ công việc gửi tất cả thông báo
  Future<Either<Failure, NotificationSummary>> runManualNotificationCheck() async {
    try {
      final summary = await _notificationScheduler.checkAndSendNotifications();
      return Right(summary);
    } catch (e) {
      return Left(DatabaseFailure('Failed to run manual check: $e'));
    }
  }
}

/// Loại thông báo
enum NotificationType {
  upcomingDue,  // Sắp đến hạn
  dueToday,     // Đến hạn hôm nay
  overdue,      // Quá hạn
}

/// Thống kê email notification
class NotificationStatistics {
  int sent = 0;
  int failed = 0;
  int skipped = 0;
  List<String> successfulEmails = [];
  List<String> failedEmails = [];
  List<String> errors = [];
  DateTime? completedAt;

  int get total => sent + failed + skipped;

  double get successRate {
    if (total == 0) return 0.0;
    return (sent / total) * 100;
  }

  @override
  String toString() {
    return '''
NotificationStatistics:
  Total: $total
  Sent: $sent
  Failed: $failed
  Skipped: $skipped
  Success Rate: ${successRate.toStringAsFixed(1)}%
  Completed At: $completedAt
''';
  }

  Map<String, dynamic> toJson() {
    return {
      'sent': sent,
      'failed': failed,
      'skipped': skipped,
      'total': total,
      'successRate': successRate,
      'successfulEmails': successfulEmails,
      'failedEmails': failedEmails,
      'errors': errors,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
