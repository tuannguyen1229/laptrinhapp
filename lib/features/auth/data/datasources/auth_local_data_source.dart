import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../shared/database/database_helper.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user, bool rememberMe);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<bool> hasValidSession();
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper _databaseHelper;

  AuthLocalDataSourceImpl(this._databaseHelper);

  Future<Database> get _database async {
    return await _databaseHelper.database;
  }

  @override
  Future<void> cacheUser(UserModel user, bool rememberMe) async {
    final db = await _database;

    try {
      // Create session table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_session (
          id INTEGER PRIMARY KEY,
          user_id INTEGER NOT NULL,
          username TEXT NOT NULL,
          email TEXT NOT NULL,
          full_name TEXT,
          role TEXT NOT NULL,
          is_active INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          last_login TEXT,
          remember_me INTEGER NOT NULL,
          session_expires_at TEXT NOT NULL
        )
      ''');

      // Clear old session
      await db.delete('user_session');

      // Calculate session expiry
      final expiresAt = rememberMe
          ? DateTime.now().add(const Duration(days: 7))
          : DateTime.now().add(const Duration(hours: 24));

      // Insert new session
      await db.insert(
        'user_session',
        {
          'user_id': user.id,
          'username': user.username,
          'email': user.email,
          'full_name': user.fullName,
          'role': user.role.name,
          'is_active': user.isActive ? 1 : 0,
          'created_at': user.createdAt.toIso8601String(),
          'last_login': user.lastLogin?.toIso8601String(),
          'remember_me': rememberMe ? 1 : 0,
          'session_expires_at': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ User session cached: ${user.username}');
    } catch (e) {
      print('❌ Cache user error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final db = await _database;

    try {
      // Check if table exists
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'user_session'],
      );

      if (tables.isEmpty) return null;

      final result = await db.query('user_session', limit: 1);

      if (result.isEmpty) return null;

      final session = result.first;

      // Check if session expired
      final expiresAt = DateTime.parse(session['session_expires_at'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        await clearCache();
        return null;
      }

      return UserModel.fromJson({
        'id': session['user_id'],
        'username': session['username'],
        'email': session['email'],
        'full_name': session['full_name'],
        'role': session['role'],
        'is_active': (session['is_active'] as int) == 1,
        'created_at': session['created_at'],
        'last_login': session['last_login'],
      });
    } catch (e) {
      print('❌ Get cached user error: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final db = await _database;

    try {
      await db.delete('user_session');
      print('✅ User session cleared');
    } catch (e) {
      print('❌ Clear cache error: $e');
    }
  }

  @override
  Future<bool> hasValidSession() async {
    final user = await getCachedUser();
    return user != null;
  }
}
