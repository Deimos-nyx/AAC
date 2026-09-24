import 'package:flutter_test/flutter_test.dart';

import 'package:voicepath/core/constants/grid_sizes.dart';
import 'package:voicepath/features/profiles/data/profile_repository.dart';
import 'package:voicepath/features/profiles/data/vocabulary_seeder.dart';
import 'package:voicepath/features/profiles/presentation/profile_provider.dart';
import 'package:voicepath/features/vocabulary/data/vocabulary_repository.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(sqfliteFfiTestSetUp);

  group('ProfileRepository', () {
    test('createProfile persists a profile that getAllProfiles then returns', () async {
      final db = await createTestDatabase();
      final repo = ProfileRepository(database: db);

      final created = await repo.createProfile(name: 'Amina', localeCode: 'en');
      expect(created.isOk, isTrue);
      expect(created.valueOrNull!.name, 'Amina');
      expect(created.valueOrNull!.gridSize, GridSizes.defaultSize);

      final all = await repo.getAllProfiles();
      expect(all.valueOrNull!.map((p) => p.name), contains('Amina'));
    });

    test('multiple profiles can coexist on one device (spec section 7)', () async {
      final db = await createTestDatabase();
      final repo = ProfileRepository(database: db);

      await repo.createProfile(name: 'Amina');
      await repo.createProfile(name: 'Rohan');
      await repo.createProfile(name: 'Priya');

      final all = await repo.getAllProfiles();
      expect(all.valueOrNull!.length, 3);
    });

    test('updateProfile persists a changed grid size (spec section 4)', () async {
      final db = await createTestDatabase();
      final repo = ProfileRepository(database: db);
      final profile = (await repo.createProfile(name: 'Amina')).valueOrNull!;

      final resized = profile.copyWith(gridSize: GridSizes.sixByFive);
      await repo.updateProfile(resized);

      final reloaded = await repo.getProfile(profile.id);
      expect(reloaded.valueOrNull!.gridSize, GridSizes.sixByFive);
    });

    test('deleteProfile removes it from getAllProfiles', () async {
      final db = await createTestDatabase();
      final repo = ProfileRepository(database: db);
      final profile = (await repo.createProfile(name: 'Amina')).valueOrNull!;

      await repo.deleteProfile(profile.id);

      final all = await repo.getAllProfiles();
      expect(all.valueOrNull!.any((p) => p.id == profile.id), isFalse);
    });

    test('remembers and restores the last active profile across app "restarts"', () async {
      final db = await createTestDatabase();
      final repo = ProfileRepository(database: db);
      final a = (await repo.createProfile(name: 'Amina')).valueOrNull!;
      await repo.createProfile(name: 'Rohan');
      await repo.setAppSetting('last_active_profile_id', a.id);

      // Simulate the app relaunching by creating a brand new repository
      // instance against the same underlying (in-memory) database.
      final freshRepo = ProfileRepository(database: db);
      final lastId = (await freshRepo.getAppSetting('last_active_profile_id')).valueOrNull;
      expect(lastId, a.id);
    });
  });

  group('ProfileProvider (profile switching)', () {
    test('selectProfile immediately swaps activeProfile (spec section 7)', () async {
      final db = await createTestDatabase();
      final provider = ProfileProvider(
        repository: ProfileRepository(database: db),
        seeder: VocabularySeeder(vocabularyRepository: VocabularyRepository(database: db)),
      );

      final amina = await provider.createProfile(name: 'Amina');
      final rohan = await provider.createProfile(name: 'Rohan');
      expect(provider.activeProfile?.id, rohan!.id, reason: 'creating a profile activates it');

      await provider.selectProfile(amina!.id);
      expect(provider.activeProfile?.id, amina.id);

      await provider.selectProfile(rohan.id);
      expect(provider.activeProfile?.id, rohan.id);
    });

    test('a new profile is seeded with real vocabulary, never left empty', () async {
      final db = await createTestDatabase();
      final vocabRepo = VocabularyRepository(database: db);
      final provider = ProfileProvider(
        repository: ProfileRepository(database: db),
        seeder: VocabularySeeder(vocabularyRepository: vocabRepo),
      );

      final profile = await provider.createProfile(name: 'Amina');
      final core = await vocabRepo.getCoreButtons(profile!.id);
      final categories = await vocabRepo.getCategories(profile.id);

      expect(core.valueOrNull, isNotEmpty);
      expect(categories.valueOrNull, isNotEmpty);
    });

    test('deleting the active profile falls back to another profile, or none', () async {
      final db = await createTestDatabase();
      final provider = ProfileProvider(
        repository: ProfileRepository(database: db),
        seeder: VocabularySeeder(vocabularyRepository: VocabularyRepository(database: db)),
      );

      final a = await provider.createProfile(name: 'Amina');
      await provider.createProfile(name: 'Rohan');
      await provider.selectProfile(a!.id);

      await provider.deleteProfile(a.id);
      expect(provider.activeProfile, isNotNull);
      expect(provider.activeProfile!.id, isNot(a.id));
    });
  });
}
