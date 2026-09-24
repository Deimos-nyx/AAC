import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:voicepath/core/services/backup_service.dart';
import 'package:voicepath/features/profiles/data/profile_repository.dart';
import 'package:voicepath/features/profiles/data/vocabulary_seeder.dart';
import 'package:voicepath/features/vocabulary/data/vocabulary_repository.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(sqfliteFfiTestSetUp);

  test('exporting then importing a profile recreates its vocabulary as a new profile', () async {
    final db = await createTestDatabase();
    final profileRepo = ProfileRepository(database: db);
    final vocabRepo = VocabularyRepository(database: db);
    final seeder = VocabularySeeder(vocabularyRepository: vocabRepo);

    final original =
        (await profileRepo.createProfile(name: 'Amina', localeCode: 'en')).valueOrNull!;
    await seeder.seedProfile(profileId: original.id, localeCode: 'en');

    // A real temp directory stands in for the app's documents directory —
    // see BackupService's documentsPathProvider seam — so this test needs
    // no platform-channel mocking to exercise real file I/O.
    final tempDir = await Directory.systemTemp.createTemp('voicepath_backup_test');
    addTearDown(() => tempDir.delete(recursive: true));

    final backupService = BackupService(
      profileRepository: profileRepo,
      vocabularyRepository: vocabRepo,
      documentsPathProvider: () async => tempDir.path,
    );

    final exportResult = await backupService.exportProfile(original.id);
    expect(exportResult.isOk, isTrue);
    final backupFile = File(exportResult.valueOrNull!);
    expect(await backupFile.exists(), isTrue);
    expect(backupFile.path.endsWith(BackupService.fileExtension), isTrue);

    final importResult = await backupService.importBackup(backupFile.path);
    expect(importResult.isOk, isTrue);
    final restoredId = importResult.valueOrNull!;
    expect(
      restoredId,
      isNot(original.id),
      reason: 'import always creates a new profile, never overwrites an existing one',
    );

    final restoredCore = (await vocabRepo.getCoreButtons(restoredId)).valueOrNull!;
    final originalCore = (await vocabRepo.getCoreButtons(original.id)).valueOrNull!;
    expect(restoredCore.length, originalCore.length);
    expect(
      restoredCore.map((b) => b.label).toSet(),
      originalCore.map((b) => b.label).toSet(),
    );

    final restoredCategories = (await vocabRepo.getCategories(restoredId)).valueOrNull!;
    final originalCategories = (await vocabRepo.getCategories(original.id)).valueOrNull!;
    expect(restoredCategories.length, originalCategories.length);
    expect(
      restoredCategories.map((c) => c.name).toSet(),
      originalCategories.map((c) => c.name).toSet(),
    );

    // The source profile must be completely untouched by the import.
    final stillThere = await profileRepo.getProfile(original.id);
    expect(stillThere.valueOrNull, isNotNull);
    final stillThereCore = (await vocabRepo.getCoreButtons(original.id)).valueOrNull!;
    expect(stillThereCore.length, originalCore.length);
  });

  test('appearance and speech settings travel with the backup', () async {
    final db = await createTestDatabase();
    final profileRepo = ProfileRepository(database: db);
    final vocabRepo = VocabularyRepository(database: db);

    final original = (await profileRepo.createProfile(name: 'Rohan')).valueOrNull!;
    await profileRepo.updateProfile(original.copyWith(
      highContrast: true,
      fontScale: 1.5,
      ttsRate: 0.3,
    ));

    final tempDir = await Directory.systemTemp.createTemp('voicepath_backup_test_2');
    addTearDown(() => tempDir.delete(recursive: true));

    final backupService = BackupService(
      profileRepository: profileRepo,
      vocabularyRepository: vocabRepo,
      documentsPathProvider: () async => tempDir.path,
    );

    final exportResult = await backupService.exportProfile(original.id);
    final restoredId = (await backupService.importBackup(exportResult.valueOrNull!)).valueOrNull!;
    final restored = (await profileRepo.getProfile(restoredId)).valueOrNull!;

    expect(restored.highContrast, isTrue);
    expect(restored.fontScale, 1.5);
    expect(restored.ttsRate, 0.3);
  });
}
