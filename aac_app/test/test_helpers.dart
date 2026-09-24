import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:voicepath/core/database/app_database.dart';
import 'package:voicepath/core/database/db_schema.dart';

/// Creates a fresh, fully-migrated [AppDatabase] backed by an in-memory
/// sqflite database (via `sqflite_common_ffi`), so repository/provider
/// tests exercise real SQL without touching a device or the filesystem.
///
/// Call [sqfliteFfiTestSetUp] once (e.g. in a `setUpAll`) before using this.
Future<AppDatabase> createTestDatabase() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: DbSchema.currentVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
      onCreate: (db, version) async => DbSchema.createAll(db.execute),
    ),
  );
  return AppDatabase.forTesting(db);
}

/// Points sqflite at the FFI (pure-Dart, no platform channel) backend. Must
/// run before any test that touches a database.
void sqfliteFfiTestSetUp() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
