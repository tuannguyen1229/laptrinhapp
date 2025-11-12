import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/book.dart';
import '../../../../shared/database/database_helper.dart';

/// Service để tìm kiếm sách từ database
class BookSearchService {
  final DatabaseHelper _databaseHelper;

  BookSearchService(this._databaseHelper);

  /// Chuyển đổi tiếng Việt có dấu sang không dấu
  String _removeVietnameseTones(String str) {
    str = str.toLowerCase();
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp(r'[đ]'), 'd');
    return str;
  }

  /// Tìm kiếm sách theo tên (hỗ trợ không dấu)
  Future<Either<Failure, List<Book>>> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    try {
      print('🔍 Searching books with query: "$query"');
      
      // Get all books from database (for better Vietnamese search support)
      final result = await _databaseHelper.executeRemoteQuery(
        'SELECT * FROM books ORDER BY title ASC',
      );

      return result.fold(
        (failure) {
          print('❌ Search failed: ${failure.message}');
          return Left(failure);
        },
        (rows) {
          print('✅ Found ${rows.length} books from database');
          final books = rows.map((row) => Book.fromJson(row)).toList();
          
          // Additional filtering for Vietnamese without tones
          final queryNoTone = _removeVietnameseTones(query.toLowerCase().trim());
          print('🔤 Query without tones: "$queryNoTone"');
          
          final filtered = books.where((book) {
            final titleNoTone = _removeVietnameseTones(book.title.toLowerCase());
            final authorNoTone = _removeVietnameseTones(book.author?.toLowerCase() ?? '');
            
            return titleNoTone.contains(queryNoTone) || 
                   authorNoTone.contains(queryNoTone);
          }).toList();
          
          // Sort by relevance
          filtered.sort((a, b) {
            final aTitleNoTone = _removeVietnameseTones(a.title.toLowerCase());
            final bTitleNoTone = _removeVietnameseTones(b.title.toLowerCase());
            
            // Exact match first
            if (aTitleNoTone == queryNoTone) return -1;
            if (bTitleNoTone == queryNoTone) return 1;
            
            // Starts with query
            if (aTitleNoTone.startsWith(queryNoTone) && !bTitleNoTone.startsWith(queryNoTone)) {
              return -1;
            }
            if (bTitleNoTone.startsWith(queryNoTone) && !aTitleNoTone.startsWith(queryNoTone)) {
              return 1;
            }
            
            return aTitleNoTone.compareTo(bTitleNoTone);
          });
          
          print('📚 After filtering: ${filtered.length} books');
          if (filtered.isNotEmpty) {
            print('   First result: ${filtered.first.title}');
          }
          
          return Right(filtered);
        },
      );
    } catch (e) {
      print('Error searching books: $e');
      return Left(DatabaseFailure('Không thể tìm kiếm sách: $e'));
    }
  }

  /// Lấy thông tin chi tiết sách theo book_code
  Future<Either<Failure, Book?>> getBookByCode(String bookCode) async {
    try {
      final result = await _databaseHelper.executeRemoteQuery(
        "SELECT * FROM books WHERE book_code = '$bookCode' LIMIT 1",
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          if (rows.isEmpty) {
            return const Right(null);
          }
          return Right(Book.fromJson(rows.first));
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Không thể lấy thông tin sách: $e'));
    }
  }

  /// Lấy tất cả sách
  Future<Either<Failure, List<Book>>> getAllBooks() async {
    try {
      final result = await _databaseHelper.executeRemoteQuery(
        'SELECT * FROM books ORDER BY title ASC',
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final books = rows.map((row) => Book.fromJson(row)).toList();
          return Right(books);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Không thể lấy danh sách sách: $e'));
    }
  }
}
