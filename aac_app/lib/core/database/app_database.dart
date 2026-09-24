import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'db_schema.dart';

/// Owns the single sqflite [Database] instance for the app.
///
/// Kept deliberately thin: repositories (ProfileRepository,
/// VocabularyRepository, ...) hold the actual query logic. This class only
/// knows how to open, migrate, and hand out the connection, so it can be
/// swapped for an in-memory database in tests.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  /// Test-only seam: wraps an already-open [Database] (typically opened via
  /// `sqflite_common_ffi` against an in-memory file) instead of touching
  /// `path_provider`, so repository/provider tests don't need a real device.
  /// See test/test_helpers.dart.
  @visibleForTesting
  factory AppDatabase.forTesting(Database db) {
    final wrapped = AppDatabase._();
    wrapped._db = db;
    return wrapped;
  }

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    final opened = await _open();
    _db = opened;
    return opened;
  }

  Future<Database> _open() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, AppConstants.databaseName);

    return openDatabase(
      dbPath,
      version: DbSchema.currentVersion,
      onConfigure: (db) async {
        // Required for ON DELETE CASCADE to actually cascade.
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await DbSchema.createAll(db.execute);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await DbSchema.migrate(db.execute, oldVersion, newVersion);
      },
    );
  }

  /// Used by tests and "delete all data" to get a completely fresh state.
  Future<void> resetForTesting() async {
    final db = await database;
    await db.close();
    _db = null;
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
