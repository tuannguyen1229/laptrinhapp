import 'package:dartz/dartz.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:sqflite/sqflite.dart';
import '../../core/errors/failures.dart';
import '../../config/database/database_config.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _localDatabase;
  static pg.Connection? _remoteConnection;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Get remote PostgreSQL connection
  Future<pg.Connection> get connection async {
    // Always ensure connection is active
    await _ensureRemoteConnection();
    
    if (_remoteConnection == null) {
      throw Exception('Failed to connect to remote database');
    }
    return _remoteConnection!;
  }

  /// Get local SQLite database
  Future<Database> get database async {
    if (_localDatabase == null) {
      final result = await initializeLocalDatabase();
      result.fold(
        (failure) => throw Exception(failure.message),
        (db) => _localDatabase = db,
      );
    }
    return _localDatabase!;
  }

  /// Initialize local SQLite database
  Future<Either<Failure, Database>> initializeLocalDatabase() async {
    try {
      if (_localDatabase != null) return Right(_localDatabase!);

      final databasePath = await getDatabasesPath();
      final path = '$databasePath/library_management.db';

      _localDatabase = await openDatabase(
        path,
        version: 1,
        onCreate: _createLocalTables,
        onUpgrade: _upgradeLocalDatabase,
      );

      return Right(_localDatabase!);
    } catch (e) {
      return Left(DatabaseFailure('Failed to initialize local database: $e'));
    }
  }

  /// Initialize PostgreSQL connection
  Future<Either<Failure, String>> initializeRemoteDatabase({
    String? host,
    int? port,
    String? databaseName,
    String? username,
    String? password,
  }) async {
    try {
      if (_remoteConnection != null) {
        print('✅ PostgreSQL: Already connected');
        return const Right('Already connected to remote database');
      }

      final actualHost = host ?? DatabaseConfig.postgresHost;
      final actualPort = port ?? DatabaseConfig.postgresPort;
      final actualDb = databaseName ?? DatabaseConfig.postgresDatabase;
      final actualUser = username ?? DatabaseConfig.postgresUsername;
      
      print('🔄 PostgreSQL: Attempting connection...');
      print('   Host: $actualHost');
      print('   Port: $actualPort');
      print('   Database: $actualDb');
      print('   Username: $actualUser');

      _remoteConnection = await pg.Connection.open(
        pg.Endpoint(
          host: actualHost,
          port: actualPort,
          database: actualDb,
          username: actualUser,
          password: password ?? DatabaseConfig.postgresPassword,
        ),
        settings: const pg.ConnectionSettings(
          sslMode: pg.SslMode.disable,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout after 10 seconds');
        },
      );

      print('✅ PostgreSQL: Connected successfully!');
      return const Right('Connected to remote database successfully');
    } catch (e) {
      print('❌ PostgreSQL Error: $e');
      print('   Error type: ${e.runtimeType}');
      return Left(NetworkFailure('Failed to connect to remote database: $e'));
    }
  }

  /// Execute query on local database
  Future<Either<Failure, List<Map<String, dynamic>>>> executeLocalQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await initializeLocalDatabase();
      return db.fold(
        (failure) => Left(failure),
        (database) async {
          final result = await database.rawQuery(sql, arguments);
          return Right(result);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Local query execution failed: $e'));
    }
  }

  /// Execute insert on local database
  Future<Either<Failure, int>> executeLocalInsert(
    String table,
    Map<String, dynamic> values,
  ) async {
    try {
      final db = await initializeLocalDatabase();
      return db.fold(
        (failure) => Left(failure),
        (database) async {
          final id = await database.insert(table, values);
          return Right(id);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Local insert failed: $e'));
    }
  }

  /// Execute update on local database
  Future<Either<Failure, int>> executeLocalUpdate(
    String table,
    Map<String, dynamic> values,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    try {
      final db = await initializeLocalDatabase();
      return db.fold(
        (failure) => Left(failure),
        (database) async {
          final count = await database.update(
            table,
            values,
            where: whereClause,
            whereArgs: whereArgs,
          );
          return Right(count);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Local update failed: $e'));
    }
  }

  /// Execute delete on local database
  Future<Either<Failure, int>> executeLocalDelete(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    try {
      final db = await initializeLocalDatabase();
      return db.fold(
        (failure) => Left(failure),
        (database) async {
          final count = await database.delete(
            table,
            where: whereClause,
            whereArgs: whereArgs,
          );
          return Right(count);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Local delete failed: $e'));
    }
  }

  /// Execute query on remote database
  Future<Either<Failure, List<Map<String, dynamic>>>> executeRemoteQuery(
    String sql, [
    Map<String, dynamic>? parameters,
  ]) async {
    try {
      // Always check and reconnect if needed
      await _ensureRemoteConnection();

      final result = await _remoteConnection!.execute(sql, parameters: parameters);
      
      final List<Map<String, dynamic>> rows = [];
      for (final row in result) {
        final Map<String, dynamic> rowMap = {};
        final schema = result.schema;
        for (var i = 0; i < row.length; i++) {
          final columnName = schema.columns[i].columnName ?? 'column_$i';
          var value = row[i];
          
          // Convert DateTime to ISO8601 String for compatibility with json_serializable
          if (value is DateTime) {
            value = value.toIso8601String();
          }
          
          rowMap[columnName] = value;
        }
        rows.add(rowMap);
      }
      
      return Right(rows);
    } catch (e) {
      return Left(NetworkFailure('Remote query execution failed: $e'));
    }
  }

  /// Execute insert on remote database
  Future<Either<Failure, int>> executeRemoteInsert(
    String table,
    Map<String, dynamic> values,
  ) async {
    try {
      // Always check and reconnect if needed
      await _ensureRemoteConnection();

      // Build INSERT query with proper value escaping
      final columns = values.keys.join(', ');
      final valuesList = values.values.map((v) {
        if (v == null) return 'NULL';
        if (v is String) return "'${v.replaceAll("'", "''")}'"; // Escape single quotes
        if (v is DateTime) return "'${v.toIso8601String()}'";
        return v.toString();
      }).join(', ');
      
      final sql = 'INSERT INTO $table ($columns) VALUES ($valuesList) RETURNING id';
      print('🔄 INSERT SQL: $sql');

      final result = await _remoteConnection!.execute(sql);
      final id = result.first[0] as int;
      print('✅ Inserted with ID: $id');
      
      return Right(id);
    } catch (e) {
      print('❌ Remote insert failed: $e');
      return Left(NetworkFailure('Remote insert failed: $e'));
    }
  }

  /// Ensure remote connection is active, reconnect if needed
  Future<void> _ensureRemoteConnection() async {
    try {
      // Check if connection exists
      if (_remoteConnection == null) {
        print('🔄 PostgreSQL: No connection, connecting...');
        final initResult = await initializeRemoteDatabase();
        if (initResult.isLeft()) {
          throw Exception('Failed to connect to database');
        }
        return;
      }

      // Test connection with a simple query
      try {
        await _remoteConnection!.execute('SELECT 1');
        // Connection is working
        return;
      } catch (e) {
        // Connection is broken, need to reconnect
        print('🔄 PostgreSQL: Connection test failed, reconnecting...');
        print('   Error: $e');
        _remoteConnection = null;
        
        final initResult = await initializeRemoteDatabase();
        if (initResult.isLeft()) {
          throw Exception('Failed to reconnect to database');
        }
      }
    } catch (e) {
      print('❌ Failed to ensure connection: $e');
      _remoteConnection = null;
      throw e;
    }
  }

  /// Execute update on remote database
  Future<Either<Failure, int>> executeRemoteUpdate(
    String table,
    Map<String, dynamic> values,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    try {
      // Always check and reconnect if needed
      await _ensureRemoteConnection();

      // Build SET clause with proper value escaping
      final setClause = values.entries.map((entry) {
        final value = entry.value;
        String valueStr;
        if (value == null) {
          valueStr = 'NULL';
        } else if (value is String) {
          valueStr = "'${value.replaceAll("'", "''")}'";
        } else if (value is DateTime) {
          valueStr = "'${value.toIso8601String()}'";
        } else {
          valueStr = value.toString();
        }
        return '${entry.key} = $valueStr';
      }).join(', ');
      
      // Replace placeholders in WHERE clause with actual values
      var finalWhereClause = whereClause;
      for (var i = 0; i < whereArgs.length; i++) {
        final arg = whereArgs[i];
        String argStr;
        if (arg is String) {
          argStr = "'${arg.replaceAll("'", "''")}'";
        } else {
          argStr = arg.toString();
        }
        finalWhereClause = finalWhereClause.replaceFirst('?', argStr);
      }
      
      final sql = 'UPDATE $table SET $setClause WHERE $finalWhereClause';
      print('🔄 UPDATE SQL: $sql');

      final result = await _remoteConnection!.execute(sql);
      print('✅ Updated ${result.affectedRows} rows');
      
      return Right(result.affectedRows);
    } catch (e) {
      print('❌ Remote update failed: $e');
      return Left(NetworkFailure('Remote update failed: $e'));
    }
  }

  /// Execute delete on remote database
  Future<Either<Failure, int>> executeRemoteDelete(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    try {
      // Always check and reconnect if needed
      await _ensureRemoteConnection();

      // Replace placeholders in WHERE clause with actual values
      var finalWhereClause = whereClause;
      for (var i = 0; i < whereArgs.length; i++) {
        final arg = whereArgs[i];
        String argStr;
        if (arg is String) {
          argStr = "'${arg.replaceAll("'", "''")}'";
        } else {
          argStr = arg.toString();
        }
        finalWhereClause = finalWhereClause.replaceFirst('?', argStr);
      }
      
      final sql = 'DELETE FROM $table WHERE $finalWhereClause';
      print('🔄 DELETE SQL: $sql');

      final result = await _remoteConnection!.execute(sql);
      print('✅ Deleted ${result.affectedRows} rows');
      
      return Right(result.affectedRows);
    } catch (e) {
      print('❌ Remote delete failed: $e');
      return Left(NetworkFailure('Remote delete failed: $e'));
    }
  }

  /// Execute transaction on local database
  Future<Either<Failure, T>> executeLocalTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    try {
      final db = await initializeLocalDatabase();
      return db.fold(
        (failure) => Left(failure),
        (database) async {
          final result = await database.transaction(action);
          return Right(result);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Local transaction failed: $e'));
    }
  }

  /// Sync data from remote to local
  Future<Either<Failure, bool>> syncFromRemote() async {
    try {

      // Sync borrow cards
      final borrowCardsResult = await executeRemoteQuery(
        'SELECT * FROM borrow_cards ORDER BY updated_at DESC',
      );

      await borrowCardsResult.fold(
        (failure) => Left(failure),
        (borrowCards) async {
          final db = await initializeLocalDatabase();
          await db.fold(
            (failure) => Left(failure),
            (database) async {
              await database.delete('borrow_cards');
              for (final card in borrowCards) {
                await database.insert('borrow_cards', card);
              }
              return const Right(true);
            },
          );
        },
      );

      // Sync books
      final booksResult = await executeRemoteQuery(
        'SELECT * FROM books ORDER BY created_at DESC',
      );

      await booksResult.fold(
        (failure) => Left(failure),
        (books) async {
          final db = await initializeLocalDatabase();
          await db.fold(
            (failure) => Left(failure),
            (database) async {
              await database.delete('books');
              for (final book in books) {
                await database.insert('books', book);
              }
              return const Right(true);
            },
          );
        },
      );

      // Sync readers
      final readersResult = await executeRemoteQuery(
        'SELECT * FROM readers ORDER BY created_at DESC',
      );

      await readersResult.fold(
        (failure) => Left(failure),
        (readers) async {
          final db = await initializeLocalDatabase();
          await db.fold(
            (failure) => Left(failure),
            (database) async {
              await database.delete('readers');
              for (final reader in readers) {
                await database.insert('readers', reader);
              }
              return const Right(true);
            },
          );
        },
      );

      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Sync from remote failed: $e'));
    }
  }

  /// Close database connections
  Future<void> close() async {
    await _localDatabase?.close();
    await _remoteConnection?.close();
    _localDatabase = null;
    _remoteConnection = null;
  }

  /// Create local SQLite tables
  Future<void> _createLocalTables(Database db, int version) async {
    // Create borrow_cards table
    await db.execute('''
      CREATE TABLE borrow_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        borrower_name TEXT NOT NULL,
        borrower_class TEXT,
        borrower_student_id TEXT,
        borrower_phone TEXT,
        book_name TEXT NOT NULL,
        book_code TEXT,
        borrow_date TEXT NOT NULL,
        expected_return_date TEXT NOT NULL,
        actual_return_date TEXT,
        status TEXT DEFAULT 'borrowed',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create books table
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_code TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        author TEXT,
        category TEXT,
        isbn TEXT,
        total_copies INTEGER DEFAULT 1,
        available_copies INTEGER DEFAULT 1,
        created_at TEXT
      )
    ''');

    // Create readers table
    await db.execute('''
      CREATE TABLE readers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        student_id TEXT UNIQUE,
        class TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        created_at TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_borrow_cards_status ON borrow_cards(status)');
    await db.execute('CREATE INDEX idx_borrow_cards_borrower_name ON borrow_cards(borrower_name)');
    await db.execute('CREATE INDEX idx_borrow_cards_book_name ON borrow_cards(book_name)');
    await db.execute('CREATE INDEX idx_books_book_code ON books(book_code)');
    await db.execute('CREATE INDEX idx_books_title ON books(title)');
    await db.execute('CREATE INDEX idx_readers_student_id ON readers(student_id)');
    await db.execute('CREATE INDEX idx_readers_name ON readers(name)');
  }

  /// Upgrade local database
  Future<void> _upgradeLocalDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    // This will be called when the database version is increased
  }

  /// Create remote PostgreSQL tables
  // Future<void> _createRemoteTables(pg.Connection connection) async {  // Temporarily disabled
    /*
    // Create borrow_cards table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS borrow_cards (
        id SERIAL PRIMARY KEY,
        borrower_name VARCHAR(255) NOT NULL,
        borrower_class VARCHAR(100),
        borrower_student_id VARCHAR(50),
        borrower_phone VARCHAR(20),
        book_name VARCHAR(500) NOT NULL,
        book_code VARCHAR(100),
        borrow_date DATE NOT NULL,
        expected_return_date DATE NOT NULL,
        actual_return_date DATE,
        status VARCHAR(50) DEFAULT 'borrowed',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create books table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS books (
        id SERIAL PRIMARY KEY,
        book_code VARCHAR(100) UNIQUE NOT NULL,
        title VARCHAR(500) NOT NULL,
        author VARCHAR(255),
        category VARCHAR(100),
        isbn VARCHAR(50),
        total_copies INTEGER DEFAULT 1,
        available_copies INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create readers table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS readers (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        student_id VARCHAR(50) UNIQUE,
        class VARCHAR(100),
        phone VARCHAR(20),
        email VARCHAR(255),
        address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for better performance
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_borrow_cards_status ON borrow_cards(status)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_borrow_cards_borrower_name ON borrow_cards(borrower_name)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_borrow_cards_book_name ON borrow_cards(book_name)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_books_book_code ON books(book_code)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_books_title ON books(title)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_readers_student_id ON readers(student_id)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_readers_name ON readers(name)');
    */
  // }
}