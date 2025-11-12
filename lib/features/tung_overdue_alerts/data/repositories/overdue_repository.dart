import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../services/overdue_service.dart';

abstract class OverdueRepository {
  Future<Either<Failure, List<BorrowCard>>> getOverdueCards();
  Future<Either<Failure, OverdueStatistics>> getStatistics();
  Future<Either<Failure, int>> getOverdueCount();
}

class OverdueRepositoryImpl implements OverdueRepository {
  final OverdueService overdueService;

  OverdueRepositoryImpl({required this.overdueService});

  @override
  Future<Either<Failure, List<BorrowCard>>> getOverdueCards() async {
    try {
      return await overdueService.getOverdueCards();
    } catch (e) {
      return Left(DatabaseFailure('Lỗi khi lấy danh sách sách quá hạn: $e'));
    }
  }

  @override
  Future<Either<Failure, OverdueStatistics>> getStatistics() async {
    try {
      return await overdueService.getOverdueStatistics();
    } catch (e) {
      return Left(DatabaseFailure('Lỗi khi lấy thống kê quá hạn: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getOverdueCount() async {
    try {
      final result = await overdueService.getOverdueCards();
      return result.fold(
        (failure) => Left(failure),
        (cards) => Right(cards.length),
      );
    } catch (e) {
      return Left(DatabaseFailure('Lỗi khi đếm số sách quá hạn: $e'));
    }
  }
}
