import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password, bool rememberMe);
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> checkUsernameAvailable(String username);
  Future<Either<Failure, bool>> checkEmailAvailable(String email);
  Future<Either<Failure, Map<String, String>>> requestPasswordReset(String username);
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
  Future<Either<Failure, bool>> verifyResetToken(String token);
}
