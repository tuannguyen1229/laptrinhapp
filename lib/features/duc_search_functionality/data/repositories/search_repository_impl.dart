import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/repositories/search_repository.dart';
import '../services/search_service.dart';
import '../services/search_history_service.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchService _searchService;
  final SearchHistoryService _historyService;

  SearchRepositoryImpl({
    required SearchService searchService,
    required SearchHistoryService historyService,
  })  : _searchService = searchService,
        _historyService = historyService;

  @override
  Future<Either<Failure, List<BorrowCard>>> searchByBorrowerName(
    String query,
  ) async {
    try {
      return await _searchService.searchByBorrowerName(query);
    } catch (e) {
      return Left(DatabaseFailure('Failed to search by borrower name: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> searchByBookName(
    String query,
  ) async {
    try {
      return await _searchService.searchByBookName(query);
    } catch (e) {
      return Left(DatabaseFailure('Failed to search by book name: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> advancedSearch(
    SearchQuery query,
  ) async {
    try {
      return await _searchService.advancedSearch(query);
    } catch (e) {
      return Left(DatabaseFailure('Failed to perform advanced search: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBorrowerSuggestions(
    String prefix,
  ) async {
    try {
      return await _searchService.getBorrowerNameSuggestions(prefix);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrower suggestions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBookSuggestions(
    String prefix,
  ) async {
    try {
      return await _searchService.getBookNameSuggestions(prefix);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get book suggestions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchHistory() async {
    try {
      final history = await _historyService.getHistory();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure('Failed to get search history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchHistory(String query) async {
    try {
      await _historyService.saveSearch(query);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save search history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearSearchHistory() async {
    try {
      await _historyService.clearHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear search history: $e'));
    }
  }
}
