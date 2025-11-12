import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/reader.dart';
import 'base_repository.dart';

class ReaderFilters {
  final String? className;
  final String? studentId;

  const ReaderFilters({
    this.className,
    this.studentId,
  });
}

abstract class ReaderRepository 
    extends FilterableRepository<Reader, int, ReaderFilters>
    implements SearchableRepository<Reader, int>, 
               PaginatedRepository<Reader, int> {
  
  /// Get reader by student ID
  Future<Either<Failure, Reader?>> getByStudentId(String studentId);
  
  /// Get readers by class name
  Future<Either<Failure, List<Reader>>> getByClassName(String className);
  
  /// Get reader by phone number
  Future<Either<Failure, Reader?>> getByPhone(String phone);
  
  /// Get reader by email
  Future<Either<Failure, Reader?>> getByEmail(String email);
  
  /// Check if student ID exists
  Future<Either<Failure, bool>> studentIdExists(String studentId);
  
  /// Check if phone exists
  Future<Either<Failure, bool>> phoneExists(String phone);
  
  /// Check if email exists
  Future<Either<Failure, bool>> emailExists(String email);
  
  /// Get all class names
  Future<Either<Failure, List<String>>> getAllClassNames();
  
  /// Get readers with active borrows
  Future<Either<Failure, List<Reader>>> getReadersWithActiveBorrows();
  
  /// Get reader statistics (total borrows, overdue count, etc.)
  Future<Either<Failure, Map<String, dynamic>>> getReaderStatistics(int readerId);
}