import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Base repository interface that all repositories should implement
abstract class BaseRepository<T, ID> {
  /// Create a new entity
  Future<Either<Failure, T>> create(T entity);
  
  /// Get entity by ID
  Future<Either<Failure, T?>> getById(ID id);
  
  /// Get all entities
  Future<Either<Failure, List<T>>> getAll();
  
  /// Update an existing entity
  Future<Either<Failure, T>> update(T entity);
  
  /// Delete entity by ID
  Future<Either<Failure, bool>> delete(ID id);
  
  /// Check if entity exists by ID
  Future<Either<Failure, bool>> exists(ID id);
}

/// Base repository with search capabilities
abstract class SearchableRepository<T, ID> extends BaseRepository<T, ID> {
  /// Search entities by query string
  Future<Either<Failure, List<T>>> search(String query);
  
  /// Search entities with pagination
  Future<Either<Failure, List<T>>> searchWithPagination(
    String query, {
    int page = 1,
    int limit = 20,
  });
  
  /// Get total count of entities matching query
  Future<Either<Failure, int>> getSearchCount(String query);
}

/// Base repository with pagination capabilities
abstract class PaginatedRepository<T, ID> extends BaseRepository<T, ID> {
  /// Get entities with pagination
  Future<Either<Failure, List<T>>> getAllWithPagination({
    int page = 1,
    int limit = 20,
  });
  
  /// Get total count of entities
  Future<Either<Failure, int>> getTotalCount();
}

/// Repository with filtering capabilities
abstract class FilterableRepository<T, ID, F> extends BaseRepository<T, ID> {
  /// Get entities with filters
  Future<Either<Failure, List<T>>> getWithFilters(F filters);
  
  /// Get entities with filters and pagination
  Future<Either<Failure, List<T>>> getWithFiltersAndPagination(
    F filters, {
    int page = 1,
    int limit = 20,
  });
  
  /// Get count of entities matching filters
  Future<Either<Failure, int>> getCountWithFilters(F filters);
}