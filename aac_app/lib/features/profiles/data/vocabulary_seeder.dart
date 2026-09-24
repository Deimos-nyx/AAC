import '../../../core/constants/core_vocabulary.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/result.dart';
import '../../vocabulary/data/vocabulary_repository.dart';
import '../../vocabulary/domain/button_model.dart';
import '../../vocabulary/domain/category_model.dart';

/// Populates a freshly created profile with real starter vocabulary (see
/// core_vocabulary.dart) so a new user never lands on an empty board.
class VocabularySeeder {
  final VocabularyRepository _vocabRepo;

  VocabularySeeder({VocabularyRepository? vocabularyRepository})
      : _vocabRepo = vocabularyRepository ?? VocabularyRepository();

  Future<Result<void>> seedProfile({
    required String profileId,
    required String localeCode,
  }) async {
    try {
      final now = DateTime.now();
      final categoryIdByKey = <String, String>{};

      for (var i = 0; i < seedCategories.length; i++) {
        final seed = seedCategories[i];
        final id = IdGenerator.newId();
        categoryIdByKey[seed.key] = id;
        final category = CategoryModel(
          id: id,
          profileId: profileId,
          name: seed.nameFor(localeCode),
          iconKey: seed.iconEmoji,
          colorHex: seed.colorHex,
          sortOrder: i,
          isSystem: true,
        );
        final result = await _vocabRepo.createCategory(
          profileId: profileId,
          name: category.name,
          iconKey: category.iconKey,
          colorHex: category.colorHex,
        );
        if (result.isError) return const Result.error('somethingWentWrong');
        // createCategory generates its own id; keep our map pointed at the
        // real id so button seeding below references the row that exists.
        categoryIdByKey[seed.key] = result.valueOrNull!.id;
      }

      var sortOrder = 0;
      for (final seed in seedCoreButtons) {
        final button = ButtonModel(
          id: IdGenerator.newId(),
          profileId: profileId,
          label: seed.labelFor(localeCode),
          spokenPhrase: seed.labelFor(localeCode),
          iconKey: seed.emoji,
          isCore: true,
          sortOrder: sortOrder++,
          createdAt: now,
          updatedAt: now,
        );
        await _vocabRepo.createButton(button);
      }

      sortOrder = 0;
      for (final seed in seedFringeButtons) {
        final categoryId = categoryIdByKey[seed.categoryKey];
        final button = ButtonModel(
          id: IdGenerator.newId(),
          profileId: profileId,
          categoryId: categoryId,
          label: seed.labelFor(localeCode),
          spokenPhrase: seed.labelFor(localeCode),
          iconKey: seed.emoji,
          isCore: false,
          sortOrder: sortOrder++,
          createdAt: now,
          updatedAt: now,
        );
        await _vocabRepo.createButton(button);
      }

      return const Result.ok(null);
    } catch (_) {
      return const Result.error('somethingWentWrong');
    }
  }
}
