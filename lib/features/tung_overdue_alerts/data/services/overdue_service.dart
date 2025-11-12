import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../../../../shared/services/email_service.dart';

/// Service để kiểm tra và xử lý sách quá hạn
class OverdueService {
  final BorrowCardRepository borrowRepository;

  OverdueService({required this.borrowRepository});

  /// Lấy danh sách tất cả sách quá hạn
  Future<Either<Failure, List<BorrowCard>>> getOverdueCards() async {
    return await borrowRepository.getOverdueCards();
  }

  /// Kiểm tra một thẻ mượn có quá hạn không
  bool isOverdue(BorrowCard card) {
    if (card.status == BorrowStatus.returned) {
      return false;
    }
    return card.isOverdue;
  }

  /// Tính số ngày quá hạn
  int calculateOverdueDays(BorrowCard card) {
    if (!isOverdue(card)) {
      return 0;
    }
    return card.daysOverdue;
  }

  /// Lấy thống kê sách quá hạn
  Future<Either<Failure, OverdueStatistics>> getOverdueStatistics() async {
    final result = await getOverdueCards();
    
    return result.fold(
      (failure) => Left(failure),
      (overdueCards) {
        final stats = OverdueStatistics(
          totalOverdue: overdueCards.length,
          criticalOverdue: overdueCards.where((card) => card.daysOverdue > 7).length,
          moderateOverdue: overdueCards.where((card) => card.daysOverdue > 3 && card.daysOverdue <= 7).length,
          recentOverdue: overdueCards.where((card) => card.daysOverdue <= 3).length,
          overdueCards: overdueCards,
        );
        return Right(stats);
      },
    );
  }

  /// Lấy mức độ nghiêm trọng của quá hạn
  OverdueSeverity getOverdueSeverity(int daysOverdue) {
    if (daysOverdue <= 3) {
      return OverdueSeverity.low;
    } else if (daysOverdue <= 7) {
      return OverdueSeverity.medium;
    } else {
      return OverdueSeverity.high;
    }
  }

  /// Gửi email reset mật khẩu
  Future<void> sendPasswordResetEmail(String email, String userName, String resetCode) async {
    try {
      final emailService = EmailService.defaultConfig();
      final result = await emailService.sendPasswordResetEmail(
        to: email,
        userName: userName,
        resetCode: resetCode,
      );
      
      if (result.success) {
        print('✅ Password reset email sent successfully to: $email');
      } else {
        print('❌ Failed to send password reset email: ${result.message}');
        throw Exception(result.error ?? 'Failed to send email');
      }
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      rethrow;
    }
  }
}

/// Thống kê sách quá hạn
class OverdueStatistics {
  final int totalOverdue;
  final int criticalOverdue; // > 7 ngày
  final int moderateOverdue; // 3-7 ngày
  final int recentOverdue;   // <= 3 ngày
  final List<BorrowCard> overdueCards;

  OverdueStatistics({
    required this.totalOverdue,
    required this.criticalOverdue,
    required this.moderateOverdue,
    required this.recentOverdue,
    required this.overdueCards,
  });
}

/// Mức độ nghiêm trọng của quá hạn
enum OverdueSeverity {
  low,    // <= 3 ngày
  medium, // 3-7 ngày
  high,   // > 7 ngày
}
