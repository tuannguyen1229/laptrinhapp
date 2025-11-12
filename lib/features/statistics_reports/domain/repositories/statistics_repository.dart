import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../data/models/statistics_data.dart';

abstract class StatisticsRepository {
  /// Get user statistics for a date range
  Future<Either<Failure, List<UserStatistics>>> getUserStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get monthly statistics for a date range
  Future<Either<Failure, List<MonthlyStatistics>>> getMonthlyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get overall statistics summary
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get borrow cards in a specific date range
  Future<Either<Failure, List<BorrowCard>>> getBorrowCardsInDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get book popularity statistics
  Future<Either<Failure, Map<String, int>>> getBookPopularityStats({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  });

  /// Get borrower activity statistics
  Future<Either<Failure, Map<String, int>>> getBorrowerActivityStats({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  });
}