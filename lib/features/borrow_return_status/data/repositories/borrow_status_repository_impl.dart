import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../../domain/repositories/borrow_status_repository.dart';
import '../services/pagination_service.dart';

class BorrowStatusRepositoryImpl implements BorrowStatusRepository {
  final BorrowCardRepository _borrowRepository;

  BorrowStatusRepositoryImpl({
    required BorrowCardRepository borrowRepository,
  }) : _borrowRepository = borrowRepository;

  @override
  Future<Either<Failure, List<BorrowCard>>> getActiveBorrows({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    try {
      final result = await _borrowRepository.getAll();
      
      return result.fold(
        (failure) => Left(failure),
        (allCards) {
          // Filter active borrows (borrowed + overdue)
          var filtered = allCards.where((card) {
            return card.status == BorrowStatus.borrowed || 
                   card.status == BorrowStatus.overdue ||
                   (card.status != BorrowStatus.returned && card.isOverdue);
          }).toList();

          // Apply search filter
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            filtered = filtered.where((card) {
              return card.borrowerName.toLowerCase().contains(query) ||
                     card.bookName.toLowerCase().contains(query) ||
                     (card.borrowerClass?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          // Sort by borrow date (newest first)
          filtered.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));

          // Apply pagination
          final offset = PaginationService.getOffset(page, limit);
          final endIndex = (offset + limit).clamp(0, filtered.length);
          final paginatedResults = filtered.sublist(
            offset.clamp(0, filtered.length),
            endIndex,
          );

          return Right(paginatedResults);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active borrows: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getReturnedBorrows({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    try {
      final result = await _borrowRepository.getAll();
      
      return result.fold(
        (failure) => Left(failure),
        (allCards) {
          // Filter returned borrows
          var filtered = allCards.where((card) {
            return card.status == BorrowStatus.returned;
          }).toList();

          // Apply search filter
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            filtered = filtered.where((card) {
              return card.borrowerName.toLowerCase().contains(query) ||
                     card.bookName.toLowerCase().contains(query) ||
                     (card.borrowerClass?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          // Sort by return date (newest first)
          filtered.sort((a, b) {
            final aDate = a.actualReturnDate ?? a.expectedReturnDate;
            final bDate = b.actualReturnDate ?? b.expectedReturnDate;
            return bDate.compareTo(aDate);
          });

          // Apply pagination
          final offset = PaginationService.getOffset(page, limit);
          final endIndex = (offset + limit).clamp(0, filtered.length);
          final paginatedResults = filtered.sublist(
            offset.clamp(0, filtered.length),
            endIndex,
          );

          return Right(paginatedResults);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get returned borrows: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getOverdueBorrows({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    try {
      final result = await _borrowRepository.getAll();
      
      return result.fold(
        (failure) => Left(failure),
        (allCards) {
          // Filter overdue borrows
          var filtered = allCards.where((card) {
            return card.status != BorrowStatus.returned && card.isOverdue;
          }).toList();

          // Apply search filter
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            filtered = filtered.where((card) {
              return card.borrowerName.toLowerCase().contains(query) ||
                     card.bookName.toLowerCase().contains(query) ||
                     (card.borrowerClass?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          // Sort by days overdue (most overdue first)
          filtered.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));

          // Apply pagination
          final offset = PaginationService.getOffset(page, limit);
          final endIndex = (offset + limit).clamp(0, filtered.length);
          final paginatedResults = filtered.sublist(
            offset.clamp(0, filtered.length),
            endIndex,
          );

          return Right(paginatedResults);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get overdue borrows: $e'));
    }
  }

  @override
  Future<Either<Failure, BorrowCard>> markAsReturned(
    int borrowCardId,
    DateTime returnDate,
  ) async {
    try {
      // Use the existing markAsReturned method from BorrowCardRepository
      return await _borrowRepository.markAsReturned(borrowCardId);
    } catch (e) {
      return Left(DatabaseFailure('Failed to mark as returned: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<BorrowStatus, int>>> getStatusCounts() async {
    try {
      final result = await _borrowRepository.getAll();
      
      return result.fold(
        (failure) => Left(failure),
        (allCards) {
          final counts = <BorrowStatus, int>{
            BorrowStatus.borrowed: 0,
            BorrowStatus.returned: 0,
            BorrowStatus.overdue: 0,
          };

          for (final card in allCards) {
            if (card.status == BorrowStatus.returned) {
              counts[BorrowStatus.returned] = counts[BorrowStatus.returned]! + 1;
            } else if (card.isOverdue) {
              counts[BorrowStatus.overdue] = counts[BorrowStatus.overdue]! + 1;
            } else {
              counts[BorrowStatus.borrowed] = counts[BorrowStatus.borrowed]! + 1;
            }
          }

          return Right(counts);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get status counts: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshData() async {
    // Delegate to BorrowCardRepository's refresh mechanism
    // This could trigger a sync from remote database
    try {
      // For now, just return success
      // In a real implementation, this might trigger a sync operation
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to refresh data: $e'));
    }
  }
}