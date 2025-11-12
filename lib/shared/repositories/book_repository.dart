import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/book.dart';
import 'base_repository.dart';

class BookFilters {
  final String? category;
  final String? author;
  final bool? isAvailable;
  final String? isbn;

  const BookFilters({
    this.category,
    this.author,
    this.isAvailable,
    this.isbn,
  });
}

abstract class BookRepository 
    extends FilterableRepository<Book, int, BookFilters>
    implements SearchableRepository<Book, int>, 
               PaginatedRepository<Book, int> {
  
  /// Get book by book code
  Future<Either<Failure, Book?>> getByBookCode(String bookCode);
  
  /// Get books by category
  Future<Either<Failure, List<Book>>> getByCategory(String category);
  
  /// Get books by author
  Future<Either<Failure, List<Book>>> getByAuthor(String author);
  
  /// Get available books
  Future<Either<Failure, List<Book>>> getAvailableBooks();
  
  /// Get book by ISBN
  Future<Either<Failure, Book?>> getByIsbn(String isbn);
  
  /// Update book availability
  Future<Either<Failure, Book>> updateAvailability(int id, int availableCopies);
  
  /// Decrease available copies (when borrowed)
  Future<Either<Failure, Book>> decreaseAvailableCopies(int id);
  
  /// Increase available copies (when returned)
  Future<Either<Failure, Book>> increaseAvailableCopies(int id);
  
  /// Get all categories
  Future<Either<Failure, List<String>>> getAllCategories();
  
  /// Get all authors
  Future<Either<Failure, List<String>>> getAllAuthors();
  
  /// Check if book code exists
  Future<Either<Failure, bool>> bookCodeExists(String bookCode);
  
  /// Get books with low availability (less than threshold)
  Future<Either<Failure, List<Book>>> getLowAvailabilityBooks(int threshold);
}