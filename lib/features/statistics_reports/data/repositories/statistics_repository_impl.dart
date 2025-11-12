import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../models/statistics_data.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final BorrowCardRepository borrowCardRepository;

  StatisticsRepositoryImpl({
    required this.borrowCardRepository,
  });

  @override
  Future<Either<Failure, List<UserStatistics>>> getUserStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get all borrow cards in date range
      final borrowCardsResult = startDate != null && endDate != null
          ? await borrowCardRepository.getByDateRange(startDate, endDate)
          : await borrowCardRepository.getAll();

      return borrowCardsResult.fold(
        (failure) => Left(failure),
        (borrowCards) {
          final userStatsMap = <String, UserStatistics>{};

          // Group by borrower name and calculate statistics
          for (final card in borrowCards) {
            final borrowerName = card.borrowerName;
            
            if (!userStatsMap.containsKey(borrowerName)) {
              userStatsMap[borrowerName] = UserStatistics(
                borrowerName: borrowerName,
                totalBorrows: 0,
                activeBorrows: 0,
                returnedBorrows: 0,
                overdueBorrows: 0,
                borrowedBooks: [],
              );
            }

            final currentStats = userStatsMap[borrowerName]!;
            final isOverdue = card.isOverdue;
            
            userStatsMap[borrowerName] = UserStatistics(
              borrowerName: borrowerName,
              totalBorrows: currentStats.totalBorrows + 1,
              activeBorrows: currentStats.activeBorrows + 
                  (card.status == BorrowStatus.borrowed && !isOverdue ? 1 : 0),
              returnedBorrows: currentStats.returnedBorrows + 
                  (card.status == BorrowStatus.returned ? 1 : 0),
              overdueBorrows: currentStats.overdueBorrows + 
                  (isOverdue ? 1 : 0),
              lastBorrowDate: _getLatestDate(currentStats.lastBorrowDate, card.borrowDate),
              borrowedBooks: [...currentStats.borrowedBooks, card.bookName].toSet().toList(),
            );
          }

          // Sort by total borrows descending
          final userStatsList = userStatsMap.values.toList()
            ..sort((a, b) => b.totalBorrows.compareTo(a.totalBorrows));

          return Right(userStatsList);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MonthlyStatistics>>> getMonthlyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get all borrow cards in date range
      final borrowCardsResult = startDate != null && endDate != null
          ? await borrowCardRepository.getByDateRange(startDate, endDate)
          : await borrowCardRepository.getAll();

      return borrowCardsResult.fold(
        (failure) => Left(failure),
        (borrowCards) {
          final monthlyStatsMap = <String, MonthlyStatistics>{};

          // Group by year-month and calculate statistics
          for (final card in borrowCards) {
            final monthKey = '${card.borrowDate.year}-${card.borrowDate.month}';
            
            if (!monthlyStatsMap.containsKey(monthKey)) {
              monthlyStatsMap[monthKey] = MonthlyStatistics(
                year: card.borrowDate.year,
                month: card.borrowDate.month,
                totalBorrows: 0,
                totalReturns: 0,
                newBorrows: 0,
                overdueCount: 0,
                popularBooks: [],
                activeBorrowers: [],
              );
            }

            final currentStats = monthlyStatsMap[monthKey]!;
            final isOverdue = card.isOverdue;
            
            monthlyStatsMap[monthKey] = MonthlyStatistics(
              year: currentStats.year,
              month: currentStats.month,
              totalBorrows: currentStats.totalBorrows + 1,
              totalReturns: currentStats.totalReturns + 
                  (card.status == BorrowStatus.returned ? 1 : 0),
              newBorrows: currentStats.newBorrows + 
                  (card.status == BorrowStatus.borrowed ? 1 : 0),
              overdueCount: currentStats.overdueCount + 
                  (isOverdue ? 1 : 0),
              popularBooks: _updatePopularBooks(currentStats.popularBooks, card.bookName),
              activeBorrowers: _updateActiveBorrowers(currentStats.activeBorrowers, card.borrowerName),
            );
          }

          // Sort by year-month
          final monthlyStatsList = monthlyStatsMap.values.toList()
            ..sort((a, b) {
              final aDate = DateTime(a.year, a.month);
              final bDate = DateTime(b.year, b.month);
              return aDate.compareTo(bDate);
            });

          return Right(monthlyStatsList);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get monthly statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get all borrow cards in date range
      final borrowCardsResult = startDate != null && endDate != null
          ? await borrowCardRepository.getByDateRange(startDate, endDate)
          : await borrowCardRepository.getAll();

      return borrowCardsResult.fold(
        (failure) => Left(failure),
        (borrowCards) {
          if (borrowCards.isEmpty) {
            return Right(StatisticsSummary(
              totalBorrows: 0,
              activeBorrows: 0,
              returnedBorrows: 0,
              overdueBorrows: 0,
              uniqueBorrowers: 0,
              uniqueBooks: 0,
              averageBorrowDuration: 0.0,
              mostPopularBook: 'Không có dữ liệu',
              mostActiveBorrower: 'Không có dữ liệu',
              dateRange: DateTime.now(),
            ));
          }

          final totalBorrows = borrowCards.length;
          final activeBorrows = borrowCards.where((c) => c.status == BorrowStatus.borrowed && !c.isOverdue).length;
          final returnedBorrows = borrowCards.where((c) => c.status == BorrowStatus.returned).length;
          final overdueBorrows = borrowCards.where((c) => c.isOverdue).length;
          
          final uniqueBorrowers = borrowCards.map((c) => c.borrowerName).toSet().length;
          final uniqueBooks = borrowCards.map((c) => c.bookName).toSet().length;
          
          // Calculate average borrow duration for returned books
          final returnedCards = borrowCards.where((c) => c.actualReturnDate != null).toList();
          final averageBorrowDuration = returnedCards.isNotEmpty
              ? returnedCards
                  .map((c) => c.actualReturnDate!.difference(c.borrowDate).inDays)
                  .reduce((a, b) => a + b) / returnedCards.length
              : 0.0;

          // Find most popular book
          final bookCounts = <String, int>{};
          for (final card in borrowCards) {
            bookCounts[card.bookName] = (bookCounts[card.bookName] ?? 0) + 1;
          }
          final mostPopularBook = bookCounts.isNotEmpty
              ? bookCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
              : 'Không có dữ liệu';

          // Find most active borrower
          final borrowerCounts = <String, int>{};
          for (final card in borrowCards) {
            borrowerCounts[card.borrowerName] = (borrowerCounts[card.borrowerName] ?? 0) + 1;
          }
          final mostActiveBorrower = borrowerCounts.isNotEmpty
              ? borrowerCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
              : 'Không có dữ liệu';

          return Right(StatisticsSummary(
            totalBorrows: totalBorrows,
            activeBorrows: activeBorrows,
            returnedBorrows: returnedBorrows,
            overdueBorrows: overdueBorrows,
            uniqueBorrowers: uniqueBorrowers,
            uniqueBooks: uniqueBooks,
            averageBorrowDuration: averageBorrowDuration,
            mostPopularBook: mostPopularBook,
            mostActiveBorrower: mostActiveBorrower,
            dateRange: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get statistics summary: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getBorrowCardsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await borrowCardRepository.getByDateRange(startDate, endDate);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards in date range: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getBookPopularityStats({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    try {
      final borrowCardsResult = startDate != null && endDate != null
          ? await borrowCardRepository.getByDateRange(startDate, endDate)
          : await borrowCardRepository.getAll();

      return borrowCardsResult.fold(
        (failure) => Left(failure),
        (borrowCards) {
          final bookCounts = <String, int>{};
          
          for (final card in borrowCards) {
            bookCounts[card.bookName] = (bookCounts[card.bookName] ?? 0) + 1;
          }

          // Sort by count and take top books
          final sortedBooks = bookCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          final topBooks = Map<String, int>.fromEntries(
            sortedBooks.take(limit),
          );

          return Right(topBooks);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get book popularity stats: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getBorrowerActivityStats({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    try {
      final borrowCardsResult = startDate != null && endDate != null
          ? await borrowCardRepository.getByDateRange(startDate, endDate)
          : await borrowCardRepository.getAll();

      return borrowCardsResult.fold(
        (failure) => Left(failure),
        (borrowCards) {
          final borrowerCounts = <String, int>{};
          
          for (final card in borrowCards) {
            borrowerCounts[card.borrowerName] = (borrowerCounts[card.borrowerName] ?? 0) + 1;
          }

          // Sort by count and take top borrowers
          final sortedBorrowers = borrowerCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          final topBorrowers = Map<String, int>.fromEntries(
            sortedBorrowers.take(limit),
          );

          return Right(topBorrowers);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrower activity stats: $e'));
    }
  }

  // Helper methods
  DateTime? _getLatestDate(DateTime? current, DateTime newDate) {
    if (current == null) return newDate;
    return newDate.isAfter(current) ? newDate : current;
  }

  List<String> _updatePopularBooks(List<String> currentBooks, String newBook) {
    final books = List<String>.from(currentBooks);
    if (!books.contains(newBook)) {
      books.add(newBook);
    }
    return books;
  }

  List<String> _updateActiveBorrowers(List<String> currentBorrowers, String newBorrower) {
    final borrowers = List<String>.from(currentBorrowers);
    if (!borrowers.contains(newBorrower)) {
      borrowers.add(newBorrower);
    }
    return borrowers;
  }
}