import 'package:injectable/injectable.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/models/book.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../shared/database/database_helper.dart';

@injectable
class DashboardService {
  final BorrowCardRepository _borrowCardRepository;
  final DatabaseHelper _databaseHelper;

  DashboardService(this._borrowCardRepository, this._databaseHelper);

  /// Get dashboard statistics
  /// If user is provided and is a regular user, filter by borrower name
  Future<DashboardStats> getDashboardStats({User? user}) async {
    try {
      // Get all borrow cards
      final result = await _borrowCardRepository.getAll();
      var allCards = result.fold(
        (failure) => <BorrowCard>[],
        (cards) => cards,
      );

      // Filter by user if regular user
      if (user != null && user.role == UserRole.user) {
        allCards = allCards.where((card) => 
          card.borrowerName.toLowerCase() == user.fullName.toLowerCase()
        ).toList();
      }

      final now = DateTime.now();
      
      // Calculate overdue borrows (status = overdue OR (status = borrowed AND past due date))
      final overdueBorrows = allCards.where((card) {
        // Already marked as overdue
        if (card.status == BorrowStatus.overdue) return true;
        
        // Borrowed but past due date
        if (card.status == BorrowStatus.borrowed) {
          return card.expectedReturnDate.isBefore(now);
        }
        
        return false;
      }).length;

      // Calculate active borrows (borrowed status and not overdue)
      final activeBorrows = allCards.where((card) {
        if (card.status != BorrowStatus.borrowed) return false;
        return !card.expectedReturnDate.isBefore(now);
      }).length;

      // Calculate upcoming due (within 3 days, not overdue)
      final upcomingDueBorrows = allCards.where((card) {
        if (card.status != BorrowStatus.borrowed) return false;
        
        final daysUntilDue = card.expectedReturnDate.difference(now).inDays;
        
        // Not overdue and within 3 days
        return daysUntilDue >= 0 && daysUntilDue <= 3;
      }).length;

      // Calculate returned borrows
      final returnedBorrows = allCards.where((card) {
        return card.status == BorrowStatus.returned;
      }).length;

      // Calculate total books not in library (borrowed + overdue)
      final totalBooksNotInLibrary = activeBorrows + overdueBorrows;

      // Get 4 random books from database
      List<PopularBook> topPopularBooks = [];
      try {
        final booksResult = await _databaseHelper.executeRemoteQuery(
          'SELECT title, available_copies FROM books ORDER BY RANDOM() LIMIT 4',
        );
        
        await booksResult.fold(
          (failure) {
            print('Error getting books from database: ${failure.message}');
            // Fallback to using borrow cards data
            final uniqueBookNames = allCards
                .map((card) => card.bookName)
                .toSet()
                .toList();
            
            uniqueBookNames.shuffle();
            
            topPopularBooks = uniqueBookNames.take(4).map((bookName) {
              final count = allCards.where((card) => card.bookName == bookName).length;
              return PopularBook(
                bookName: bookName,
                borrowCount: count,
                availableCopies: 0,
              );
            }).toList();
          },
          (books) {
            topPopularBooks = books.map((book) {
              final title = book['title'] as String;
              final availableCopies = book['available_copies'] as int;
              
              // Count how many times this book was borrowed
              final count = allCards.where((card) => card.bookName == title).length;
              
              return PopularBook(
                bookName: title,
                borrowCount: count,
                availableCopies: availableCopies,
              );
            }).toList();
          },
        );
      } catch (e) {
        print('Error getting random books from database: $e');
        // Fallback to using borrow cards data
        final uniqueBookNames = allCards
            .map((card) => card.bookName)
            .toSet()
            .toList();
        
        uniqueBookNames.shuffle();
        
        topPopularBooks = uniqueBookNames.take(4).map((bookName) {
          final count = allCards.where((card) => card.bookName == bookName).length;
          return PopularBook(
            bookName: bookName,
            borrowCount: count,
            availableCopies: 0,
          );
        }).toList();
      }

      return DashboardStats(
        activeBorrows: activeBorrows,
        overdueBorrows: overdueBorrows,
        upcomingDueBorrows: upcomingDueBorrows,
        returnedBorrows: returnedBorrows,
        totalBooks: totalBooksNotInLibrary,
        popularBooks: topPopularBooks,
      );
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return const DashboardStats(
        activeBorrows: 0,
        overdueBorrows: 0,
        upcomingDueBorrows: 0,
        returnedBorrows: 0,
        totalBooks: 0,
        popularBooks: [],
      );
    }
  }

  /// Get recent activities (last 10)
  /// If user is provided and is a regular user, filter by borrower name
  Future<List<RecentActivity>> getRecentActivities({User? user}) async {
    try {
      final result = await _borrowCardRepository.getAll();
      var allCards = result.fold(
        (failure) => <BorrowCard>[],
        (cards) => cards,
      );

      // Filter by user if regular user
      if (user != null && user.role == UserRole.user) {
        allCards = allCards.where((card) => 
          card.borrowerName.toLowerCase() == user.fullName.toLowerCase()
        ).toList();
      }

      // Sort by borrow date (most recent first)
      final sortedCards = List<BorrowCard>.from(allCards)
        ..sort((a, b) => b.borrowDate.compareTo(a.borrowDate));

      // Take last 10 and convert to RecentActivity
      final recentCards = sortedCards.take(10).toList();

      final now = DateTime.now();
      
      return recentCards.map((card) {
        String action;
        DateTime actionDate;
        
        if (card.status == BorrowStatus.returned) {
          action = 'returned';
          actionDate = card.actualReturnDate ?? card.borrowDate;
        } else if (card.status == BorrowStatus.overdue || 
                   (card.status == BorrowStatus.borrowed && card.expectedReturnDate.isBefore(now))) {
          action = 'overdue';
          actionDate = card.expectedReturnDate;
        } else {
          action = 'borrowed';
          actionDate = card.borrowDate;
        }

        return RecentActivity(
          bookTitle: card.bookName,
          borrowerName: card.borrowerName,
          action: action,
          date: actionDate,
        );
      }).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }
}
