import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/profiles/data/profile_repository.dart';
import '../../features/vocabulary/data/vocabulary_repository.dart';
import '../../features/vocabulary/domain/button_model.dart';
import '../../features/vocabulary/domain/category_model.dart';
import '../constants/app_constants.dart';
import '../utils/id_generator.dart';
import '../utils/result.dart';
import 'logger_service.dart';

/// Exports one profile — vocabulary, categories, settings, and any custom
/// button photos — into a single `.vpbackup` file (a zip archive under the
/// hood), and can import that file back as a new profile.
///
/// The on-disk format is versioned (`formatVersion`) precisely so a future
/// app release can still read backups made by this version (spec section
/// 11: "design the data format so future app versions can migrate old
/// backups").
class BackupService {
  static const int formatVersion = 1;
  static const String fileExtension = '.vpbackup';

  final ProfileRepository _profileRepo;
  final VocabularyRepository _vocabRepo;
  final Future<String> Function() _documentsPath;

  BackupService({
    ProfileRepository? profileRepository,
    VocabularyRepository? vocabularyRepository,
    @visibleForTesting Future<String> Function()? documentsPathProvider,
  })  : _profileRepo = profileRepository ?? ProfileRepository(),
        _vocabRepo = vocabularyRepository ?? VocabularyRepository(),
        _documentsPath = documentsPathProvider ??
            (() async => (await getApplicationDocumentsDirectory()).path);

  Future<Result<String>> exportProfile(String profileId) async {
    try {
      final profileResult = await _profileRepo.getProfile(profileId);
      final profile = profileResult.valueOrNull;
      if (profile == null) return const Result.error('somethingWentWrong');

      final categoriesResult = await _vocabRepo.getCategories(profileId);
      final buttonsResult = await _vocabRepo.getAllButtons(profileId);
      final categories = categoriesResult.valueOrNull ?? const <CategoryModel>[];
      final buttons = buttonsResult.valueOrNull ?? const <ButtonModel>[];

      final archive = Archive();

      // Copy any custom button images into the archive under images/, and
      // remember which archive entry belongs to which button.
      final imageEntryByButtonId = <String, String>{};
      for (final button in buttons) {
        final path = button.imagePath;
        if (path == null) continue;
        final file = File(path);
        if (!await file.exists()) continue;
        final ext = p.extension(path);
        final entryName = 'images/${button.id}$ext';
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(entryName, bytes.length, bytes));
        imageEntryByButtonId[button.id] = entryName;
      }

      final manifest = {
        'formatVersion': formatVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': profile.toBackupJson(),
        'categories': categories.map((c) => c.toBackupJson()).toList(),
        'buttons': buttons
            .map((b) => {
                  ...b.toBackupJson(),
                  if (imageEntryByButtonId.containsKey(b.id))
                    'imageArchivePath': imageEntryByButtonId[b.id],
                })
            .toList(),
      };
      final manifestBytes = utf8.encode(jsonEncode(manifest));
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) return const Result.error('somethingWentWrong');

      final docsPath = await _documentsPath();
      final backupsDir = Directory(p.join(docsPath, AppConstants.backupsDir));
      if (!await backupsDir.exists()) await backupsDir.create(recursive: true);

      final safeName = profile.name.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
      final fileName = '${safeName}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final outFile = File(p.join(backupsDir.path, fileName));
      await outFile.writeAsBytes(zipBytes);

      return Result.ok(outFile.path);
    } catch (e, st) {
      AppLogger.error('BackupService.exportProfile', e, st);
      return const Result.error('somethingWentWrong');
    }
  }

  /// Imports a backup file as a brand-new profile (never overwrites an
  /// existing one), so a restore can never silently clobber someone's
  /// current vocabulary.
  Future<Result<String>> importBackup(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final manifestFile = archive.files.firstWhere(
        (f) => f.name == 'manifest.json',
        orElse: () => throw const FormatException('missing manifest'),
      );
      final manifestJson = jsonDecode(utf8.decode(manifestFile.content as List<int>))
          as Map<String, dynamic>;

      final version = manifestJson['formatVersion'] as int? ?? 1;
      final migrated = _migrateManifest(manifestJson, version);

      final profileJson = migrated['profile'] as Map<String, dynamic>;
      final now = DateTime.now();

      final createResult = await _profileRepo.createProfile(
        name: '${profileJson['name'] as String? ?? 'Imported'} (restored)',
        localeCode: profileJson['localeCode'] as String? ?? 'en',
      );
      final newProfile = createResult.valueOrNull;
      if (newProfile == null) return const Result.error('somethingWentWrong');

      final updated = newProfile.copyWith(
        gridSize: newProfile.gridSize,
        buttonSizeScale: (profileJson['buttonSizeScale'] as num?)?.toDouble() ?? 1.0,
        buttonSpacingScale: (profileJson['buttonSpacingScale'] as num?)?.toDouble() ?? 1.0,
        fontScale: (profileJson['fontScale'] as num?)?.toDouble() ?? 1.0,
        highContrast: profileJson['highContrast'] as bool? ?? false,
        reducedAnimation: profileJson['reducedAnimation'] as bool? ?? false,
        ttsRate: (profileJson['ttsRate'] as num?)?.toDouble() ?? 0.5,
        ttsPitch: (profileJson['ttsPitch'] as num?)?.toDouble() ?? 1.0,
        ttsVolume: (profileJson['ttsVolume'] as num?)?.toDouble() ?? 1.0,
      );
      await _profileRepo.updateProfile(updated);

      final categoryIdMap = <String, String>{};
      final categoriesJson = (migrated['categories'] as List<dynamic>? ?? []);
      for (final raw in categoriesJson) {
        final json = raw as Map<String, dynamic>;
        final oldId = json['id'] as String;
        final created = await _vocabRepo.createCategory(
          profileId: newProfile.id,
          name: json['name'] as String,
          iconKey: json['iconKey'] as String?,
          colorHex: json['colorHex'] as String?,
        );
        final newCat = created.valueOrNull;
        if (newCat != null) categoryIdMap[oldId] = newCat.id;
      }

      final docsPath = await _documentsPath();
      final buttonsJson = (migrated['buttons'] as List<dynamic>? ?? []);
      for (final raw in buttonsJson) {
        final json = raw as Map<String, dynamic>;
        String? newImagePath;
        final archivePath = json['imageArchivePath'] as String?;
        if (archivePath != null) {
          final imageFile = archive.files.where((f) => f.name == archivePath).firstOrNull;
          if (imageFile != null) {
            final targetDir = Directory(p.join(docsPath, AppConstants.buttonImagesDir));
            if (!await targetDir.exists()) await targetDir.create(recursive: true);
            final ext = p.extension(archivePath);
            final targetPath = p.join(targetDir.path, '${IdGenerator.newId()}$ext');
            await File(targetPath).writeAsBytes(imageFile.content as List<int>);
            newImagePath = targetPath;
          }
        }

        final oldCategoryId = json['categoryId'] as String?;
        final button = ButtonModel(
          id: IdGenerator.newId(),
          profileId: newProfile.id,
          categoryId: oldCategoryId != null ? categoryIdMap[oldCategoryId] : null,
          label: json['label'] as String? ?? '',
          spokenPhrase: json['spokenPhrase'] as String?,
          pronunciationOverride: json['pronunciationOverride'] as String?,
          iconKey: json['iconKey'] as String?,
          imagePath: newImagePath,
          backgroundColorHex: json['backgroundColorHex'] as String?,
          gridPosition: json['gridPosition'] as int?,
          sortOrder: json['sortOrder'] as int? ?? 0,
          isCore: json['isCore'] as bool? ?? false,
          isFolder: json['isFolder'] as bool? ?? false,
          createdAt: now,
          updatedAt: now,
        );
        await _vocabRepo.createButton(button);
      }

      return Result.ok(newProfile.id);
    } catch (e, st) {
      AppLogger.error('BackupService.importBackup', e, st);
      return const Result.error('somethingWentWrong');
    }
  }

  /// Seam for handling older backup format versions. A no-op today; when
  /// `formatVersion` increments, add a case here that reshapes the older
  /// JSON into the current shape rather than changing what's written above.
  Map<String, dynamic> _migrateManifest(Map<String, dynamic> manifest, int fromVersion) {
    return manifest;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
