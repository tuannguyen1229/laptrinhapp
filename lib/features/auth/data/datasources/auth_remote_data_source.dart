import 'package:injectable/injectable.dart';
import 'package:postgres/postgres.dart';
import '../../../../shared/database/database_helper.dart';
import '../models/user_model.dart';
import '../services/password_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> updateLastLogin(int userId);
  Future<bool> checkUsernameExists(String username);
  Future<bool> checkEmailExists(String email);
  Future<UserModel?> getUserByEmail(String email);
  Future<UserModel?> getUserByUsername(String username);
  Future<String> createPasswordResetToken(int userId);
  Future<bool> verifyResetToken(String token);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> recordLoginHistory(int userId, bool success);
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DatabaseHelper _databaseHelper;
  final PasswordService _passwordService;

  AuthRemoteDataSourceImpl(this._databaseHelper, this._passwordService);

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      // Ensure connection is active before querying
      final connection = await _databaseHelper.connection;

      // Get user by username
      final result = await connection.execute(
        Sql.named('''
          SELECT id, username, email, password_hash, full_name, role, is_active, created_at, last_login
          FROM users
          WHERE username = @username AND is_active = true
        '''),
        parameters: {'username': username},
      );

      if (result.isEmpty) {
        throw Exception('Tên đăng nhập hoặc mật khẩu không đúng');
      }

      final row = result.first;
      final passwordHash = row[3] as String;

      // Verify password
      // Support multiple password formats
      bool isPasswordValid = false;
      if (passwordHash.contains(':')) {
        // Format: salt:hash (PasswordService)
        isPasswordValid = _passwordService.verifyPassword(password, passwordHash);
      } else if (passwordHash.length == 64) {
        // Format: SHA-256 hash (legacy, 64 hex characters)
        final testHash = _passwordService.hashPasswordLegacy(password);
        isPasswordValid = passwordHash == testHash;
      } else {
        // Plain text password (development only)
        isPasswordValid = password == passwordHash;
      }

      if (!isPasswordValid) {
        await recordLoginHistory(row[0] as int, false);
        throw Exception('Tên đăng nhập hoặc mật khẩu không đúng');
      }

      // Record successful login
      await recordLoginHistory(row[0] as int, true);
      await updateLastLogin(row[0] as int);

      return UserModel.fromJson({
        'id': row[0],
        'username': row[1],
        'email': row[2],
        'full_name': row[4],
        'role': row[5],
        'is_active': row[6],
        'created_at': (row[7] as DateTime).toIso8601String(),
        'last_login': row[8] != null ? (row[8] as DateTime).toIso8601String() : null,
      });
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final connection = await _databaseHelper.connection;

    try {
      // Check if username exists
      if (await checkUsernameExists(username)) {
        throw Exception('Tên đăng nhập đã tồn tại');
      }

      // Check if email exists
      if (await checkEmailExists(email)) {
        throw Exception('Email đã được sử dụng');
      }

      // Hash password
      final passwordHash = _passwordService.hashPassword(password);

      // Insert new user
      final result = await connection.execute(
        Sql.named('''
          INSERT INTO users (username, email, password_hash, full_name, role, is_active)
          VALUES (@username, @email, @password_hash, @full_name, 'user', true)
          RETURNING id, username, email, full_name, role, is_active, created_at, last_login
        '''),
        parameters: {
          'username': username,
          'email': email,
          'password_hash': passwordHash,
          'full_name': fullName,
        },
      );

      if (result.isEmpty) {
        throw Exception('Không thể tạo tài khoản');
      }

      final row = result.first;
      return UserModel.fromJson({
        'id': row[0],
        'username': row[1],
        'email': row[2],
        'full_name': row[3],
        'role': row[4],
        'is_active': row[5],
        'created_at': (row[6] as DateTime).toIso8601String(),
        'last_login': row[7] != null ? (row[7] as DateTime).toIso8601String() : null,
      });
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateLastLogin(int userId) async {
    final connection = await _databaseHelper.connection;

    try {
      await connection.execute(
        Sql.named('''
          UPDATE users
          SET last_login = CURRENT_TIMESTAMP
          WHERE id = @user_id
        '''),
        parameters: {'user_id': userId},
      );
    } catch (e) {
      print('❌ Update last login error: $e');
    }
  }

  @override
  Future<bool> checkUsernameExists(String username) async {
    final connection = await _databaseHelper.connection;

    try {
      final result = await connection.execute(
        Sql.named('SELECT COUNT(*) FROM users WHERE username = @username'),
        parameters: {'username': username},
      );

      return (result.first[0] as int) > 0;
    } catch (e) {
      print('❌ Check username error: $e');
      return false;
    }
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    final connection = await _databaseHelper.connection;

    try {
      final result = await connection.execute(
        Sql.named('SELECT COUNT(*) FROM users WHERE email = @email'),
        parameters: {'email': email},
      );

      return (result.first[0] as int) > 0;
    } catch (e) {
      print('❌ Check email error: $e');
      return false;
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final connection = await _databaseHelper.connection;

    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT id, username, email, password_hash, full_name, role, is_active, created_at, last_login
          FROM users
          WHERE email = @email AND is_active = true
        '''),
        parameters: {'email': email},
      );

      if (result.isEmpty) return null;

      final row = result.first;
      return UserModel.fromJson({
        'id': row[0],
        'username': row[1],
        'email': row[2],
        'full_name': row[4],
        'role': row[5],
        'is_active': row[6],
        'created_at': (row[7] as DateTime).toIso8601String(),
        'last_login': row[8] != null ? (row[8] as DateTime).toIso8601String() : null,
      });
    } catch (e) {
      print('❌ Get user by email error: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> getUserByUsername(String username) async {
    final connection = await _databaseHelper.connection;

    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT id, username, email, password_hash, full_name, role, is_active, created_at, last_login
          FROM users
          WHERE username = @username AND is_active = true
        '''),
        parameters: {'username': username},
      );

      if (result.isEmpty) return null;

      final row = result.first;
      return UserModel.fromJson({
        'id': row[0],
        'username': row[1],
        'email': row[2],
        'full_name': row[4],
        'role': row[5],
        'is_active': row[6],
        'created_at': (row[7] as DateTime).toIso8601String(),
        'last_login': row[8] != null ? (row[8] as DateTime).toIso8601String() : null,
      });
    } catch (e) {
      print('❌ Get user by username error: $e');
      return null;
    }
  }

  @override
  Future<String> createPasswordResetToken(int userId) async {
    final connection = await _databaseHelper.connection;

    try {
      // Generate 6-digit code
      final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      final expiresAt = DateTime.now().add(const Duration(minutes: 15));

      await connection.execute(
        Sql.named('''
          INSERT INTO password_reset_tokens (user_id, token, expires_at, used)
          VALUES (@user_id, @token, @expires_at, false)
        '''),
        parameters: {
          'user_id': userId,
          'token': code,
          'expires_at': expiresAt,
        },
      );

      return code;
    } catch (e) {
      print('❌ Create reset token error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> verifyResetToken(String token) async {
    final connection = await _databaseHelper.connection;

    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT COUNT(*) FROM password_reset_tokens
          WHERE token = @token 
            AND used = false 
            AND expires_at > CURRENT_TIMESTAMP
        '''),
        parameters: {'token': token},
      );

      return (result.first[0] as int) > 0;
    } catch (e) {
      print('❌ Verify reset token error: $e');
      return false;
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    final connection = await _databaseHelper.connection;

    try {
      print('🔍 Verifying token: $token');
      
      // Get user_id from token
      final tokenResult = await connection.execute(
        Sql.named('''
          SELECT user_id FROM password_reset_tokens
          WHERE token = @token 
            AND used = false 
            AND expires_at > CURRENT_TIMESTAMP
        '''),
        parameters: {'token': token},
      );

      if (tokenResult.isEmpty) {
        print('❌ Token not found or expired');
        throw Exception('Mã xác thực không hợp lệ hoặc đã hết hạn');
      }

      final userId = tokenResult.first[0] as int;
      print('✅ Token valid for user ID: $userId');

      // Hash new password
      final passwordHash = _passwordService.hashPassword(newPassword);
      print('🔐 Password hashed');

      // Update password
      await connection.execute(
        Sql.named('''
          UPDATE users
          SET password_hash = @password_hash
          WHERE id = @user_id
        '''),
        parameters: {
          'password_hash': passwordHash,
          'user_id': userId,
        },
      );
      print('✅ Password updated in database');

      // Mark token as used
      await connection.execute(
        Sql.named('''
          UPDATE password_reset_tokens
          SET used = true
          WHERE token = @token
        '''),
        parameters: {'token': token},
      );
      print('✅ Token marked as used');
      print('🎉 Password reset completed successfully!');
    } catch (e) {
      print('❌ Reset password error: $e');
      rethrow;
    }
  }

  @override
  Future<void> recordLoginHistory(int userId, bool success) async {
    final connection = await _databaseHelper.connection;

    try {
      await connection.execute(
        Sql.named('''
          INSERT INTO login_history (user_id, login_time, success, device_info)
          VALUES (@user_id, CURRENT_TIMESTAMP, @success, 'Flutter App')
        '''),
        parameters: {
          'user_id': userId,
          'success': success,
        },
      );
    } catch (e) {
      print('❌ Record login history error: $e');
    }
  }
}
