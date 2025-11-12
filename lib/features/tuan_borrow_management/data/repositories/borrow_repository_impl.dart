import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/borrow_card.dart';
import '../../../../shared/repositories/borrow_card_repository.dart';
import '../datasources/borrow_local_data_source.dart';
import '../datasources/borrow_remote_data_source.dart';

class BorrowRepositoryImpl implements BorrowCardRepository {
  final BorrowLocalDataSource localDataSource;
  final BorrowRemoteDataSource remoteDataSource;

  BorrowRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, BorrowCard>> create(BorrowCard entity) async {
    try {
      // Only use PostgreSQL
      print('🔄 Repository: Creating borrow card in PostgreSQL...');
      return await remoteDataSource.createBorrowCard(entity);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create borrow card: $e'));
    }
  }

  @override
  Future<Either<Failure, BorrowCard?>> getById(int id) async {
    try {
      // Only use PostgreSQL
      return await remoteDataSource.getBorrowCardById(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow card by id: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getAll() async {
    try {
      // Only use PostgreSQL
      print('🔄 Repository: Loading all borrow cards from PostgreSQL...');
      final result = await remoteDataSource.getAllBorrowCards();
      
      return result.fold(
        (failure) {
          print('❌ PostgreSQL failed: ${failure.message}');
          return Left(failure);
        },
        (cards) {
          print('✅ Loaded ${cards.length} cards from PostgreSQL');
          return Right(cards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all borrow cards: $e'));
    }
  }

  @override
  Future<Either<Failure, BorrowCard>> update(BorrowCard entity) async {
    try {
      // Only use PostgreSQL
      print('🔄 Repository: Updating borrow card in PostgreSQL...');
      return await remoteDataSource.updateBorrowCard(entity);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update borrow card: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      // Only use PostgreSQL
      print('🔄 Repository: Deleting borrow card from PostgreSQL...');
      return await remoteDataSource.deleteBorrowCard(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete borrow card: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> exists(int id) async {
    try {
      final result = await getById(id);
      return result.fold(
        (failure) => Left(failure),
        (card) => Right(card != null),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to check if borrow card exists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getByStatus(BorrowStatus status) async {
    try {
      // Only use PostgreSQL
      return await remoteDataSource.getBorrowCardsByStatus(status);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards by status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getOverdueCards() async {
    try {
      // Only use PostgreSQL
      return await remoteDataSource.getOverdueBorrowCards();
    } catch (e) {
      return Left(DatabaseFailure('Failed to get overdue borrow cards: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getByBorrowerName(String name) async {
    try {
      return await search(name);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards by borrower name: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getByBookName(String bookName) async {
    try {
      return await search(bookName);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards by book name: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // For now, get all and filter locally
      // In a real implementation, this should be done at the database level
      final allCardsResult = await getAll();
      
      return allCardsResult.fold(
        (failure) => Left(failure),
        (cards) {
          final filteredCards = cards.where((card) {
            return card.borrowDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   card.borrowDate.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();
          return Right(filteredCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards by date range: $e'));
    }
  }

  @override
  Future<Either<Failure, BorrowCard>> markAsReturned(int id) async {
    try {
      final cardResult = await getById(id);
      
      return cardResult.fold(
        (failure) => Left(failure),
        (card) async {
          if (card == null) {
            return const Left(DatabaseFailure('Borrow card not found'));
          }
          
          final returnedCard = card.copyWith(
            status: BorrowStatus.returned,
            actualReturnDate: DateTime.now(),
          );
          
          return await update(returnedCard);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to mark borrow card as returned: $e'));
    }
  }

  @override
  Future<Either<Failure, BorrowCard>> updateStatus(int id, BorrowStatus status) async {
    try {
      final cardResult = await getById(id);
      
      return cardResult.fold(
        (failure) => Left(failure),
        (card) async {
          if (card == null) {
            return const Left(DatabaseFailure('Borrow card not found'));
          }
          
          final updatedCard = card.copyWith(status: status);
          return await update(updatedCard);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to update borrow card status: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final cardsResult = await getByDateRange(startDate, endDate);
      
      return cardsResult.fold(
        (failure) => Left(failure),
        (cards) {
          final statistics = {
            'total_borrows': cards.length,
            'active_borrows': cards.where((c) => c.status == BorrowStatus.borrowed).length,
            'returned_borrows': cards.where((c) => c.status == BorrowStatus.returned).length,
            'overdue_borrows': cards.where((c) => c.status == BorrowStatus.overdue || c.isOverdue).length,
            'unique_borrowers': cards.map((c) => c.borrowerName).toSet().length,
            'unique_books': cards.map((c) => c.bookName).toSet().length,
          };
          return Right(statistics);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getBorrowingHistory(String borrowerName) async {
    try {
      final allCardsResult = await getAll();
      
      return allCardsResult.fold(
        (failure) => Left(failure),
        (cards) {
          final history = cards
              .where((card) => card.borrowerName.toLowerCase().contains(borrowerName.toLowerCase()))
              .toList();
          return Right(history);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrowing history: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getActiveBorrowsCount() async {
    try {
      final activeCardsResult = await getByStatus(BorrowStatus.borrowed);
      
      return activeCardsResult.fold(
        (failure) => Left(failure),
        (cards) => Right(cards.length),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active borrows count: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getOverdueCount() async {
    try {
      final overdueCardsResult = await getOverdueCards();
      
      return overdueCardsResult.fold(
        (failure) => Left(failure),
        (cards) => Right(cards.length),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get overdue count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> search(String query) async {
    try {
      // Only use PostgreSQL
      return await remoteDataSource.searchBorrowCards(query);
    } catch (e) {
      return Left(DatabaseFailure('Failed to search borrow cards: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> searchWithPagination(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final searchResult = await search(query);
      
      return searchResult.fold(
        (failure) => Left(failure),
        (cards) {
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          
          if (startIndex >= cards.length) {
            return const Right([]);
          }
          
          final paginatedCards = cards.sublist(
            startIndex,
            endIndex > cards.length ? cards.length : endIndex,
          );
          
          return Right(paginatedCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to search borrow cards with pagination: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getSearchCount(String query) async {
    try {
      final searchResult = await search(query);
      
      return searchResult.fold(
        (failure) => Left(failure),
        (cards) => Right(cards.length),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get search count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getAllWithPagination({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Only use PostgreSQL
      print('🔄 Repository: Loading page $page from PostgreSQL...');
      return await remoteDataSource.getBorrowCardsWithPagination(
        page: page,
        limit: limit,
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards with pagination: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalCount() async {
    try {
      // Only use PostgreSQL
      return await remoteDataSource.getTotalBorrowCardsCount();
    } catch (e) {
      return Left(DatabaseFailure('Failed to get total count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getWithFilters(BorrowCardFilters filters) async {
    try {
      final allCardsResult = await getAll();
      
      return allCardsResult.fold(
        (failure) => Left(failure),
        (cards) {
          var filteredCards = cards;
          
          if (filters.status != null) {
            filteredCards = filteredCards.where((card) => card.status == filters.status).toList();
          }
          
          if (filters.borrowerName != null && filters.borrowerName!.isNotEmpty) {
            filteredCards = filteredCards
                .where((card) => card.borrowerName.toLowerCase().contains(filters.borrowerName!.toLowerCase()))
                .toList();
          }
          
          if (filters.bookName != null && filters.bookName!.isNotEmpty) {
            filteredCards = filteredCards
                .where((card) => card.bookName.toLowerCase().contains(filters.bookName!.toLowerCase()))
                .toList();
          }
          
          if (filters.startDate != null) {
            filteredCards = filteredCards
                .where((card) => card.borrowDate.isAfter(filters.startDate!.subtract(const Duration(days: 1))))
                .toList();
          }
          
          if (filters.endDate != null) {
            filteredCards = filteredCards
                .where((card) => card.borrowDate.isBefore(filters.endDate!.add(const Duration(days: 1))))
                .toList();
          }
          
          if (filters.isOverdue != null) {
            filteredCards = filteredCards.where((card) => card.isOverdue == filters.isOverdue).toList();
          }
          
          return Right(filteredCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards with filters: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getWithFiltersAndPagination(
    BorrowCardFilters filters, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final filteredResult = await getWithFilters(filters);
      
      return filteredResult.fold(
        (failure) => Left(failure),
        (cards) {
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          
          if (startIndex >= cards.length) {
            return const Right([]);
          }
          
          final paginatedCards = cards.sublist(
            startIndex,
            endIndex > cards.length ? cards.length : endIndex,
          );
          
          return Right(paginatedCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards with filters and pagination: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getCountWithFilters(BorrowCardFilters filters) async {
    try {
      final filteredResult = await getWithFilters(filters);
      
      return filteredResult.fold(
        (failure) => Left(failure),
        (cards) => Right(cards.length),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get count with filters: $e'));
    }
  }


}