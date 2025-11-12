import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../services/password_service.dart';
import '../../../../features/tung_overdue_alerts/data/services/overdue_service.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final PasswordService passwordService;
  final OverdueService overdueService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.passwordService,
    required this.overdueService,
  });

  @override
  Future<Either<Failure, User>> login(
    String username,
    String password,
    bool rememberMe,
  ) async {
    try {
      final user = await remoteDataSource.login(username, password);
      await localDataSource.cacheUser(user, rememberMe);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Validate username (no special characters)
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        return const Left(ValidationFailure(
          'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới',
        ));
      }

      // Validate password strength
      final passwordError = passwordService.getPasswordStrengthMessage(password);
      if (passwordError.isNotEmpty) {
        return Left(ValidationFailure(passwordError));
      }

      final user = await remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      // Auto login after register
      await localDataSource.cacheUser(user, false);

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsernameAvailable(String username) async {
    try {
      final exists = await remoteDataSource.checkUsernameExists(username);
      return Right(!exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailAvailable(String email) async {
    try {
      final exists = await remoteDataSource.checkEmailExists(email);
      return Right(!exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> requestPasswordReset(String username) async {
    try {
      // Get user by username
      final user = await remoteDataSource.getUserByUsername(username);
      if (user == null) {
        return const Left(ServerFailure('Tên đăng nhập không tồn tại trong hệ thống'));
      }

      // Create reset token
      final token = await remoteDataSource.createPasswordResetToken(user.id);

      // Send email with token
      try {
        await overdueService.sendPasswordResetEmail(user.email, user.fullName, token);
        print('✅ Password reset email sent to: ${user.email}');
      } catch (e) {
        print('⚠️ Failed to send email: $e');
        // Continue anyway - user can still use the token
      }

      return Right({
        'token': token,
        'email': user.email,
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    try {
      // Validate password strength
      final passwordError = passwordService.getPasswordStrengthMessage(newPassword);
      if (passwordError.isNotEmpty) {
        return Left(ValidationFailure(passwordError));
      }

      await remoteDataSource.resetPassword(token, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyResetToken(String token) async {
    try {
      final isValid = await remoteDataSource.verifyResetToken(token);
      return Right(isValid);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
