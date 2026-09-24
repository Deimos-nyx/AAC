import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/result.dart';
import '../domain/button_model.dart';
import '../domain/category_model.dart';

/// Data-access layer for categories and buttons. The two are handled in one
/// repository because most operations (e.g. "delete category") need to
/// touch both in a single transaction.
class VocabularyRepository {
  final AppDatabase _db;

  VocabularyRepository({AppDatabase? database}) : _db = database ?? AppDatabase.instance;

  // ---------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------

  Future<Result<List<CategoryModel>>> getCategories(String profileId) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'categories',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'sort_order ASC',
      );
      return Result.ok(rows.map(CategoryModel.fromDbMap).toList());
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.getCategories', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<CategoryModel>> createCategory({
    required String profileId,
    required String name,
    String? iconKey,
    String? colorHex,
  }) async {
    try {
      final db = await _db.database;
      final existingCount = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM categories WHERE profile_id = ?',
              [profileId],
            ),
          ) ??
          0;
      final category = CategoryModel(
        id: IdGenerator.newId(),
        profileId: profileId,
        name: name.trim().isEmpty ? 'New category' : name.trim(),
        iconKey: iconKey,
        colorHex: colorHex,
        sortOrder: existingCount,
      );
      await db.insert('categories', category.toDbMap());
      return Result.ok(category);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.createCategory', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<void>> updateCategory(CategoryModel category) async {
    try {
      final db = await _db.database;
      await db.update('categories', category.toDbMap(), where: 'id = ?', whereArgs: [category.id]);
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.updateCategory', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  /// Deletes a category. Buttons in it are NOT deleted — their
  /// `category_id` is set to NULL (via ON DELETE SET NULL) so custom
  /// buttons a caregiver spent time creating are never silently destroyed
  /// just because their folder was removed.
  Future<Result<void>> deleteCategory(String id) async {
    try {
      final db = await _db.database;
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.deleteCategory', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<void>> reorderCategories(List<String> orderedIds) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        for (var i = 0; i < orderedIds.length; i++) {
          await txn.update(
            'categories',
            {'sort_order': i},
            where: 'id = ?',
            whereArgs: [orderedIds[i]],
          );
        }
      });
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.reorderCategories', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  // ---------------------------------------------------------------------
  // Buttons
  // ---------------------------------------------------------------------

  /// Core vocabulary buttons for a profile (shown on every board regardless
  /// of the selected category, per spec section 2).
  Future<Result<List<ButtonModel>>> getCoreButtons(String profileId) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'buttons',
        where: 'profile_id = ? AND is_core = 1',
        whereArgs: [profileId],
        orderBy: 'sort_order ASC',
      );
      return Result.ok(rows.map(ButtonModel.fromDbMap).toList());
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.getCoreButtons', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<List<ButtonModel>>> getButtonsForCategory(
    String profileId,
    String? categoryId,
  ) async {
    try {
      final db = await _db.database;
      final rows = categoryId == null
          ? await db.query(
              'buttons',
              where: 'profile_id = ? AND category_id IS NULL AND is_core = 0',
              whereArgs: [profileId],
              orderBy: 'sort_order ASC',
            )
          : await db.query(
              'buttons',
              where: 'profile_id = ? AND category_id = ?',
              whereArgs: [profileId, categoryId],
              orderBy: 'sort_order ASC',
            );
      return Result.ok(rows.map(ButtonModel.fromDbMap).toList());
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.getButtonsForCategory', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<List<ButtonModel>>> getAllButtons(String profileId) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'buttons',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'sort_order ASC',
      );
      return Result.ok(rows.map(ButtonModel.fromDbMap).toList());
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.getAllButtons', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  /// Simple case-insensitive prefix/contains search used by text-mode word
  /// prediction (see word_prediction_service.dart).
  Future<Result<List<ButtonModel>>> searchButtons(String profileId, String query) async {
    try {
      if (query.trim().isEmpty) return const Result.ok([]);
      final db = await _db.database;
      final rows = await db.query(
        'buttons',
        where: 'profile_id = ? AND label LIKE ?',
        whereArgs: [profileId, '${query.trim()}%'],
        orderBy: 'is_core DESC, label ASC',
        limit: 20,
      );
      return Result.ok(rows.map(ButtonModel.fromDbMap).toList());
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.searchButtons', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<ButtonModel>> createButton(ButtonModel button) async {
    try {
      final db = await _db.database;
      await db.insert('buttons', button.toDbMap());
      return Result.ok(button);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.createButton', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<void>> updateButton(ButtonModel button) async {
    try {
      final db = await _db.database;
      await db.update(
        'buttons',
        button.copyWith(updatedAt: DateTime.now()).toDbMap(),
        where: 'id = ?',
        whereArgs: [button.id],
      );
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.updateButton', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<void>> deleteButton(String id) async {
    try {
      final db = await _db.database;
      await db.delete('buttons', where: 'id = ?', whereArgs: [id]);
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.deleteButton', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  /// Moves a button to a new grid slot / sort position. Kept as its own
  /// method (rather than a generic updateButton call) because motor-
  /// planning consistency (spec section 3) means moves should be rare and
  /// deliberate — this is the single choke point where that happens.
  Future<Result<void>> moveButton({
    required String buttonId,
    int? newGridPosition,
    int? newSortOrder,
    String? newCategoryId,
    bool clearCategory = false,
  }) async {
    try {
      final db = await _db.database;
      final updates = <String, Object?>{'updated_at': DateTime.now().millisecondsSinceEpoch};
      if (newGridPosition != null) updates['grid_position'] = newGridPosition;
      if (newSortOrder != null) updates['sort_order'] = newSortOrder;
      if (clearCategory) {
        updates['category_id'] = null;
      } else if (newCategoryId != null) {
        updates['category_id'] = newCategoryId;
      }
      await db.update('buttons', updates, where: 'id = ?', whereArgs: [buttonId]);
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.moveButton', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }

  Future<Result<bool>> hasAnyVocabulary(String profileId) async {
    try {
      final db = await _db.database;
      final count = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM buttons WHERE profile_id = ?',
              [profileId],
            ),
          ) ??
          0;
      return Result.ok(count > 0);
    } catch (e, st) {
      AppLogger.error('VocabularyRepository.hasAnyVocabulary', e, st);
      return Result.error('somethingWentWrong', e);
    }
  }
}
