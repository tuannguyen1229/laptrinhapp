import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../entities/search_query.dart';

abstract class SearchRepository {
  /// Tìm kiếm theo tên người mượn
  Future<Either<Failure, List<BorrowCard>>> searchByBorrowerName(String query);

  /// Tìm kiếm theo tên sách
  Future<Either<Failure, List<BorrowCard>>> searchByBookName(String query);

  /// Tìm kiếm nâng cao với nhiều tiêu chí
  Future<Either<Failure, List<BorrowCard>>> advancedSearch(SearchQuery query);

  /// Lấy suggestions cho tên người mượn
  Future<Either<Failure, List<String>>> getBorrowerSuggestions(String prefix);

  /// Lấy suggestions cho tên sách
  Future<Either<Failure, List<String>>> getBookSuggestions(String prefix);

  /// Lấy lịch sử tìm kiếm
  Future<Either<Failure, List<String>>> getSearchHistory();

  /// Lưu lịch sử tìm kiếm
  Future<Either<Failure, void>> saveSearchHistory(String query);

  /// Xóa lịch sử tìm kiếm
  Future<Either<Failure, void>> clearSearchHistory();
}
