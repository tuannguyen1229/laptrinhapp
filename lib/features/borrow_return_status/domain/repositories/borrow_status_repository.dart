import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';

abstract class BorrowStatusRepository {
  /// Lấy danh sách thẻ đang mượn với pagination
  Future<Either<Failure, List<BorrowCard>>> getActiveBorrows({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  /// Lấy danh sách thẻ đã trả với pagination
  Future<Either<Failure, List<BorrowCard>>> getReturnedBorrows({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  /// Lấy danh sách thẻ quá hạn
  Future<Either<Failure, List<BorrowCard>>> getOverdueBorrows({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  /// Cập nhật trạng thái thẻ mượn (đánh dấu đã trả)
  Future<Either<Failure, BorrowCard>> markAsReturned(
    int borrowCardId,
    DateTime returnDate,
  );

  /// Lấy tổng số thẻ theo trạng thái
  Future<Either<Failure, Map<BorrowStatus, int>>> getStatusCounts();

  /// Refresh data từ remote
  Future<Either<Failure, void>> refreshData();
}