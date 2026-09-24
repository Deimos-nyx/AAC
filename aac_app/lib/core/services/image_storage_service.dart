import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/id_generator.dart';
import '../utils/result.dart';
import 'logger_service.dart';

/// Safe handling for user-supplied images (spec section 14: "safe file/image
/// handling"). Never trusts the picked file's path long-term — instead
/// copies bytes into an app-owned sandboxed directory under a generated
/// name, and validates it's actually an image-like file by extension
/// allow-list before doing so.
class ImageStorageService {
  static const _allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  final ImagePicker _picker = ImagePicker();

  Future<Result<String>> pickAndStore({
    required ImageSource source,
    required String subDirectory,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return const Result.error('imageUnavailable');
      return await _storeFile(File(picked.path), subDirectory);
    } catch (e, st) {
      AppLogger.error('ImageStorageService.pickAndStore', e, st);
      return const Result.error('imageUnavailable');
    }
  }

  Future<Result<String>> _storeFile(File source, String subDirectory) async {
    final ext = p.extension(source.path).toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      return const Result.error('imageUnavailable');
    }
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(docsDir.path, subDirectory));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      final targetPath = p.join(targetDir.path, '${IdGenerator.newId()}$ext');
      await source.copy(targetPath);
      return Result.ok(targetPath);
    } catch (e, st) {
      AppLogger.error('ImageStorageService._storeFile', e, st);
      return const Result.error('imageUnavailable');
    }
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, st) {
      // Non-fatal: a stray orphaned file is far less bad than a crash.
      AppLogger.error('ImageStorageService.deleteIfExists', e, st);
    }
  }

  /// Wipes every app-owned media directory (button photos, profile
  /// avatars). Used by the "delete all data on this device" action so a
  /// full reset really is full — see spec section 15.
  Future<void> deleteAllStoredMedia(List<String> subDirectories) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      for (final subDirectory in subDirectories) {
        final dir = Directory(p.join(docsDir.path, subDirectory));
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      }
    } catch (e, st) {
      AppLogger.error('ImageStorageService.deleteAllStoredMedia', e, st);
    }
  }
}
