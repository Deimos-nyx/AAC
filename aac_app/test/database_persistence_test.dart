import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:voicepath/core/database/app_database.dart';
import 'package:voicepath/core/database/db_schema.dart';
import 'package:voicepath/features/profiles/data/profile_repository.dart';

import 'test_helpers.dart';

Future<Database> _openAt(String path) {
  return databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: DbSchema.currentVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
      onCreate: (db, version) async => DbSchema.createAll(db.execute),
    ),
  );
}

void main() {
  setUpAll(sqfliteFfiTestSetUp);

  test('data written before closing the database is still there after reopening it', () async {
    // Unlike the other test files (which use `:memory:` for speed/isolation),
    // this test writes to a real temp file and closes the connection fully,
    // to prove persistence actually survives a process restart — not just
    // that a shared in-memory handle happens to still be alive.
    final tempDir = await Directory.systemTemp.createTemp('voicepath_db_test');
    final dbPath = p.join(tempDir.path, 'test.db');
    addTearDown(() => tempDir.delete(recursive: true));

    final firstConnection = await _openAt(dbPath);
    final firstRepo = ProfileRepository(database: AppDatabase.forTesting(firstConnection));
    final created = await firstRepo.createProfile(name: 'Persisted Profile');
    expect(created.isOk, isTrue);
    await firstConnection.close();

    final secondConnection = await _openAt(dbPath);
    final secondRepo = ProfileRepository(database: AppDatabase.forTesting(secondConnection));
    final reloaded = await secondRepo.getAllProfiles();

    expect(reloaded.valueOrNull!.map((p) => p.name), contains('Persisted Profile'));
    await secondConnection.close();
  });

  test('a fresh database is created with every table the app relies on', () async {
    final db = await createTestDatabase();
    final connection = await db.database;
    final tables = await connection.query(
      'sqlite_master',
      where: "type = 'table'",
      columns: ['name'],
    );
    final names = tables.map((row) => row['name'] as String).toSet();

    expect(names, containsAll(['profiles', 'categories', 'buttons', 'app_settings']));
  });
}
