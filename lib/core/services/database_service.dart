import 'package:dartz/dartz.dart';
// import 'package:postgres/postgres.dart'; // Unused for now
// import 'package:sqflite/sqflite.dart'; // Unused for now
import '../../config/environment/app_config.dart';
import '../errors/failures.dart';
import '../../shared/database/database_helper.dart';

class DatabaseService {
  static DatabaseService? _instance;
  DatabaseHelper? _databaseHelper;

  DatabaseService._internal();

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  DatabaseHelper get databaseHelper {
    _databaseHelper ??= DatabaseHelper();
    return _databaseHelper!;
  }

  /// Initialize database connections with app config
  Future<Either<Failure, bool>> initializeDatabases() async {
    try {
      // Initialize local database
      final localResult = await databaseHelper.initializeLocalDatabase();
      if (localResult.isLeft()) {
        return localResult.fold((failure) => Left(failure), (_) => const Right(false));
      }

      // Initialize remote database with config
      final config = AppConfig.databaseConfig;
      final remoteResult = await databaseHelper.initializeRemoteDatabase(
        host: config['host'],
        port: config['port'],
        databaseName: config['database'],
        username: config['username'],
        password: config['password'],
      );

      return remoteResult.fold(
        (failure) {
          // If remote fails, continue with local only
          print('Warning: Remote database connection failed: ${failure.message}');
          return const Right(true); // Still return success for local-only mode
        },
        (_) => const Right(true),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to initialize databases: $e'));
    }
  }

  /// Test database connection
  Future<Either<Failure, Map<String, bool>>> testConnections() async {
    final results = <String, bool>{};

    // Test local connection
    try {
      final localResult = await databaseHelper.initializeLocalDatabase();
      results['local'] = localResult.isRight();
    } catch (e) {
      results['local'] = false;
    }

    // Test remote connection
    try {
      final config = AppConfig.databaseConfig;
      final remoteResult = await databaseHelper.initializeRemoteDatabase(
        host: config['host'],
        port: config['port'],
        databaseName: config['database'],
        username: config['username'],
        password: config['password'],
      );
      results['remote'] = remoteResult.isRight();
    } catch (e) {
      results['remote'] = false;
    }

    return Right(results);
  }

  /// Get current database configuration
  Map<String, dynamic> getCurrentConfig() {
    final config = AppConfig.databaseConfig;
    // Remove sensitive information for display
    return {
      'environment': AppConfig.environment.name,
      'host': config['host'],
      'port': config['port'],
      'database': config['database'],
      'username': config['username'],
      'ssl': config['ssl'],
      // Don't include password for security
    };
  }

  /// Close all connections
  Future<void> close() async {
    await _databaseHelper?.close();
  }
}