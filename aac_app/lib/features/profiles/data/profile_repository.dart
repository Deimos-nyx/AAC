import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/result.dart';
import '../domain/profile_model.dart';

/// Data-access layer for [ProfileModel]. Screens/providers never touch
/// sqflite directly — everything goes through here so the query logic (and
/// error handling) lives in exactly one place.
class ProfileRepository {
  final AppDatabase _db;

  ProfileRepository({AppDatabase? database}) : _db = database ?? AppDatabase.instance;

  Future<Result<List<ProfileModel>>> getAllProfiles() async {
    try {
      final db = await _db.database;
      final rows = await db.query('profiles', orderBy: 'sort_order ASC, created_at ASC');
      return Result.ok(rows.map(ProfileModel.fromDbMap).toList());
    } catch (e, st) {
      AppLogger.error('ProfileRepository.getAllProfiles', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<ProfileModel?>> getProfile(String id) async {
    try {
      final db = await _db.database;
      final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id], limit: 1);
      if (rows.isEmpty) return const Result.ok(null);
      return Result.ok(ProfileModel.fromDbMap(rows.first));
    } catch (e, st) {
      AppLogger.error('ProfileRepository.getProfile', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<ProfileModel>> createProfile({
    required String name,
    String localeCode = 'en',
  }) async {
    try {
      final now = DateTime.now();
      final db = await _db.database;
      final existingCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM profiles'),
          ) ??
          0;
      final profile = ProfileModel(
        id: IdGenerator.newId(),
        name: name.trim().isEmpty ? 'New profile' : name.trim(),
        localeCode: localeCode,
        createdAt: now,
        updatedAt: now,
        sortOrder: existingCount,
      );
      await db.insert('profiles', profile.toDbMap());
      return Result.ok(profile);
    } catch (e, st) {
      AppLogger.error('ProfileRepository.createProfile', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<void>> updateProfile(ProfileModel profile) async {
    try {
      final db = await _db.database;
      final updated = profile.copyWith(updatedAt: DateTime.now());
      await db.update(
        'profiles',
        updated.toDbMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('ProfileRepository.updateProfile', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  /// Deletes the profile. Categories and buttons cascade via the foreign
  /// key ON DELETE CASCADE defined in db_schema.dart — there is deliberately
  /// no manual cleanup loop here to avoid the two getting out of sync.
  Future<Result<void>> deleteProfile(String id) async {
    try {
      final db = await _db.database;
      await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('ProfileRepository.deleteProfile', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<void>> deleteAllData() async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        await txn.delete('buttons');
        await txn.delete('categories');
        await txn.delete('profiles');
        await txn.delete('app_settings');
      });
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('ProfileRepository.deleteAllData', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<String?>> getAppSetting(String key) async {
    try {
      final db = await _db.database;
      final rows = await db.query('app_settings', where: 'key = ?', whereArgs: [key], limit: 1);
      if (rows.isEmpty) return const Result.ok(null);
      return Result.ok(rows.first['value'] as String);
    } catch (e, st) {
      AppLogger.error('ProfileRepository.getAppSetting', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<void>> setAppSetting(String key, String value) async {
    try {
      final db = await _db.database;
      await db.insert(
        'app_settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('ProfileRepository.setAppSetting', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }
}
