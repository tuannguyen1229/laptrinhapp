import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/database/database_helper.dart';
import '../../../../shared/models/borrow_card.dart';

abstract class BorrowLocalDataSource {
  Future<Either<Failure, BorrowCard>> createBorrowCard(BorrowCard borrowCard);
  Future<Either<Failure, BorrowCard?>> getBorrowCardById(int id);
  Future<Either<Failure, List<BorrowCard>>> getAllBorrowCards();
  Future<Either<Failure, BorrowCard>> updateBorrowCard(BorrowCard borrowCard);
  Future<Either<Failure, bool>> deleteBorrowCard(int id);
  Future<Either<Failure, List<BorrowCard>>> getBorrowCardsByStatus(BorrowStatus status);
  Future<Either<Failure, List<BorrowCard>>> searchBorrowCards(String query);
  Future<Either<Failure, List<BorrowCard>>> getBorrowCardsWithPagination({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, int>> getTotalBorrowCardsCount();
  Future<Either<Failure, List<BorrowCard>>> getOverdueBorrowCards();
}

class BorrowLocalDataSourceImpl implements BorrowLocalDataSource {
  final DatabaseHelper databaseHelper;

  BorrowLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<Either<Failure, BorrowCard>> createBorrowCard(BorrowCard borrowCard) async {
    try {
      final now = DateTime.now();
      final borrowCardData = borrowCard.copyWith(
        createdAt: now,
        updatedAt: now,
      ).toJson();
      
      // Remove id for insert
      borrowCardData.remove('id');
      
      final result = await databaseHelper.executeLocalInsert(
        'borrow_cards',
        borrowCardData,
      );

      return result.fold(
        (failure) => Left(failure),
        (id) async {
          final createdCard = borrowCard.copyWith(
            id: id,
            createdAt: now,
            updatedAt: now,
          );
          return Right(createdCard);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to create borrow card: $e'));
    }
  }

  @override
  Future<Either<Failure, BorrowCard?>> getBorrowCardById(int id) async {
    try {
      final result = await databaseHelper.executeLocalQuery(
        'SELECT * FROM borrow_cards WHERE id = ?',
        [id],
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          if (rows.isEmpty) {
            return const Right(null);
          }
          final borrowCard = BorrowCard.fromJson(rows.first);
          return Right(borrowCard);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow card by id: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getAllBorrowCards() async {
    try {
      final result = await databaseHelper.executeLocalQuery(
        'SELECT * FROM borrow_cards ORDER BY created_at DESC',
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final borrowCards = rows.map((row) => BorrowCard.fromJson(row)).toList();
          return Right(borrowCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all borrow cards: $e'));
    }
  }

  @override
  Future<Either<Failure, BorrowCard>> updateBorrowCard(BorrowCard borrowCard) async {
    try {
      if (borrowCard.id == null) {
        return const Left(ValidationFailure('Borrow card ID is required for update'));
      }

      final updatedCard = borrowCard.copyWith(updatedAt: DateTime.now());
      final borrowCardData = updatedCard.toJson();
      borrowCardData.remove('id'); // Remove id from update data

      final result = await databaseHelper.executeLocalUpdate(
        'borrow_cards',
        borrowCardData,
        'id = ?',
        [borrowCard.id!],
      );

      return result.fold(
        (failure) => Left(failure),
        (count) {
          if (count == 0) {
            return const Left(DatabaseFailure('No borrow card found to update'));
          }
          return Right(updatedCard);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to update borrow card: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBorrowCard(int id) async {
    try {
      final result = await databaseHelper.executeLocalDelete(
        'borrow_cards',
        'id = ?',
        [id],
      );

      return result.fold(
        (failure) => Left(failure),
        (count) => Right(count > 0),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete borrow card: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getBorrowCardsByStatus(BorrowStatus status) async {
    try {
      final result = await databaseHelper.executeLocalQuery(
        'SELECT * FROM borrow_cards WHERE status = ? ORDER BY created_at DESC',
        [status.name],
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final borrowCards = rows.map((row) => BorrowCard.fromJson(row)).toList();
          return Right(borrowCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards by status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> searchBorrowCards(String query) async {
    try {
      final result = await databaseHelper.executeLocalQuery(
        '''
        SELECT * FROM borrow_cards 
        WHERE borrower_name LIKE ? OR book_name LIKE ? 
        ORDER BY created_at DESC
        ''',
        ['%$query%', '%$query%'],
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final borrowCards = rows.map((row) => BorrowCard.fromJson(row)).toList();
          return Right(borrowCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to search borrow cards: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getBorrowCardsWithPagination({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final result = await databaseHelper.executeLocalQuery(
        'SELECT * FROM borrow_cards ORDER BY created_at DESC LIMIT ? OFFSET ?',
        [limit, offset],
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final borrowCards = rows.map((row) => BorrowCard.fromJson(row)).toList();
          return Right(borrowCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get borrow cards with pagination: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalBorrowCardsCount() async {
    try {
      final result = await databaseHelper.executeLocalQuery(
        'SELECT COUNT(*) as count FROM borrow_cards',
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final count = rows.first['count'] as int;
          return Right(count);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get total borrow cards count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BorrowCard>>> getOverdueBorrowCards() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final result = await databaseHelper.executeLocalQuery(
        '''
        SELECT * FROM borrow_cards 
        WHERE status != 'returned' AND expected_return_date < ? 
        ORDER BY expected_return_date ASC
        ''',
        [today],
      );

      return result.fold(
        (failure) => Left(failure),
        (rows) {
          final borrowCards = rows.map((row) => BorrowCard.fromJson(row)).toList();
          return Right(borrowCards);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get overdue borrow cards: $e'));
    }
  }
}