import 'package:sqflite/sqflite.dart';
import '../../../../shared/database/database_helper.dart';
import '../../../../config/injection/injection.dart';

class SearchHistoryService {
  static const _maxHistory = 10;
  static const _tableName = 'search_history';
  
  DatabaseHelper get _databaseHelper => getIt<DatabaseHelper>();

  /// Khởi tạo bảng search_history nếu chưa có
  Future<void> _initTable() async {
    final dbResult = await _databaseHelper.initializeLocalDatabase();
    final db = dbResult.fold(
      (failure) => throw Exception('Failed to initialize database: ${failure.message}'),
      (database) => database,
    );
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  /// Lưu search query vào history (SQLite)
  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      await _initTable();
      final dbResult = await _databaseHelper.initializeLocalDatabase();
      final db = dbResult.fold(
        (failure) => throw Exception('Failed to get database: ${failure.message}'),
        (database) => database,
      );
      
      // Xóa query cũ nếu có (để tránh duplicate)
      await db.delete(
        _tableName,
        where: 'query = ?',
        whereArgs: [query.trim()],
      );

      // Thêm query mới
      await db.insert(
        _tableName,
        {
          'query': query.trim(),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Giữ chỉ 10 records gần nhất
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
      ) ?? 0;

      if (count > _maxHistory) {
        await db.rawDelete('''
          DELETE FROM $_tableName 
          WHERE id NOT IN (
            SELECT id FROM $_tableName 
            ORDER BY created_at DESC 
            LIMIT $_maxHistory
          )
        ''');
      }
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  /// Lấy search history
  Future<List<String>> getHistory() async {
    try {
      await _initTable();
      final dbResult = await _databaseHelper.initializeLocalDatabase();
      final db = dbResult.fold(
        (failure) => throw Exception('Failed to get database: ${failure.message}'),
        (database) => database,
      );
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'created_at DESC',
        limit: _maxHistory,
      );

      return maps.map((map) => map['query'] as String).toList();
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Xóa toàn bộ history
  Future<void> clearHistory() async {
    try {
      await _initTable();
      final dbResult = await _databaseHelper.initializeLocalDatabase();
      final db = dbResult.fold(
        (failure) => throw Exception('Failed to get database: ${failure.message}'),
        (database) => database,
      );
      await db.delete(_tableName);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Xóa một item khỏi history
  Future<void> removeFromHistory(String query) async {
    try {
      await _initTable();
      final dbResult = await _databaseHelper.initializeLocalDatabase();
      final db = dbResult.fold(
        (failure) => throw Exception('Failed to get database: ${failure.message}'),
        (database) => database,
      );
      await db.delete(
        _tableName,
        where: 'query = ?',
        whereArgs: [query],
      );
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }
}
