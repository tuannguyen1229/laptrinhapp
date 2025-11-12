import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/borrow_card.dart';
import 'base_repository.dart';

class BorrowCardFilters {
  final BorrowStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? borrowerName;
  final String? bookName;
  final bool? isOverdue;

  const BorrowCardFilters({
    this.status,
    this.startDate,
    this.endDate,
    this.borrowerName,
    this.bookName,
    this.isOverdue,
  });
}

abstract class BorrowCardRepository 
    extends FilterableRepository<BorrowCard, int, BorrowCardFilters>
    implements SearchableRepository<BorrowCard, int>, 
               PaginatedRepository<BorrowCard, int> {
  
  /// Get borrow cards by status
  Future<Either<Failure, List<BorrowCard>>> getByStatus(BorrowStatus status);
  
  /// Get overdue borrow cards
  Future<Either<Failure, List<BorrowCard>>> getOverdueCards();
  
  /// Get borrow cards by borrower name
  Future<Either<Failure, List<BorrowCard>>> getByBorrowerName(String name);
  
  /// Get borrow cards by book name
  Future<Either<Failure, List<BorrowCard>>> getByBookName(String bookName);
  
  /// Get borrow cards by date range
  Future<Either<Failure, List<BorrowCard>>> getByDateRange(
    DateTime startDate, 
    DateTime endDate
  );
  
  /// Mark borrow card as returned
  Future<Either<Failure, BorrowCard>> markAsReturned(int id);
  
  /// Update borrow card status
  Future<Either<Failure, BorrowCard>> updateStatus(int id, BorrowStatus status);
  
  /// Get statistics for a date range
  Future<Either<Failure, Map<String, dynamic>>> getStatistics(
    DateTime startDate, 
    DateTime endDate
  );
  
  /// Get borrowing history for a specific borrower
  Future<Either<Failure, List<BorrowCard>>> getBorrowingHistory(String borrowerName);
  
  /// Get active borrows count
  Future<Either<Failure, int>> getActiveBorrowsCount();
  
  /// Get overdue count
  Future<Either<Failure, int>> getOverdueCount();
}