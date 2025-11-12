import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/database/database_helper.dart';
import '../../domain/entities/book_category_stats.dart';

@injectable
class BookCategoryStatsService {
  final DatabaseHelper _databaseHelper;

  BookCategoryStatsService(this._databaseHelper);

  /// Lấy danh sách tất cả sách với số lượng còn lại
  Future<Either<Failure, List<BookCategoryStats>>> getCategoryStats() async {
    try {
      // Query to get all books with their availability
      final result = await _databaseHelper.executeRemoteQuery(
        '''
        SELECT 
          title as category,
          1 as total_books,
          available_copies as available_books,
          (total_copies - available_copies) as borrowed_books
        FROM books
        ORDER BY title ASC
        ''',
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final stats = rows.map((row) {
            return BookCategoryStats(
              category: row['category'] as String,
              totalBooks: row['total_books'] as int,
              availableBooks: row['available_books'] as int,
              borrowedBooks: row['borrowed_books'] as int,
            );
          }).toList();
          
          return Right(stats);
        },
      );
    } catch (e) {
      print('Error getting category stats: $e');
      return Left(DatabaseFailure('Không thể lấy thống kê theo thể loại: $e'));
    }
  }

  /// Lấy tổng số sách trong thư viện
  Future<Either<Failure, int>> getTotalBooksCount() async {
    try {
      final result = await _databaseHelper.executeRemoteQuery(
        'SELECT COUNT(*) as count FROM books',
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final count = rows.first['count'] as int;
          return Right(count);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Không thể đếm số sách: $e'));
    }
  }

  /// Lấy tổng số sách còn lại
  Future<Either<Failure, int>> getTotalAvailableBooks() async {
    try {
      final result = await _databaseHelper.executeRemoteQuery(
        'SELECT SUM(available_copies) as total FROM books',
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final total = rows.first['total'] as int? ?? 0;
          return Right(total);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Không thể đếm số sách còn lại: $e'));
    }
  }
}
