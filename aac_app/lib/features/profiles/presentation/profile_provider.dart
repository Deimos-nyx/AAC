import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/grid_sizes.dart';
import '../../../core/services/image_storage_service.dart';
import '../../../core/services/pin_service.dart';
import '../../settings/domain/app_settings_model.dart';
import '../data/profile_repository.dart';
import '../data/vocabulary_seeder.dart';
import '../domain/profile_model.dart';

/// Owns the list of profiles and which one is currently active. Every
/// per-profile setting (grid size, appearance, TTS voice, ...) is mutated
/// through this provider so there is one place that writes to the
/// `profiles` table and notifies listeners.
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  final VocabularySeeder _seeder;

  ProfileProvider({
    ProfileRepository? repository,
    VocabularySeeder? seeder,
  })  : _repository = repository ?? ProfileRepository(),
        _seeder = seeder ?? VocabularySeeder();

  List<ProfileModel> _profiles = [];
  ProfileModel? _activeProfile;
  bool _isLoading = true;
  String? _lastError;

  List<ProfileModel> get profiles => List.unmodifiable(_profiles);
  ProfileModel? get activeProfile => _activeProfile;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get hasProfiles => _profiles.isNotEmpty;

  Future<void> loadProfiles() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getAllProfiles();
    if (result.isOk) {
      _profiles = result.valueOrNull ?? const [];
    } else {
      _lastError = result.errorOrNull;
    }

    if (_profiles.isNotEmpty) {
      final lastActiveIdResult =
          await _repository.getAppSetting(AppSettingsKeys.lastActiveProfileId);
      final lastId = lastActiveIdResult.valueOrNull;
      _activeProfile = _profiles.firstWhere(
        (p) => p.id == lastId,
        orElse: () => _profiles.first,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ProfileModel?> createProfile({
    required String name,
    String localeCode = AppConstants.defaultLocaleCode,
  }) async {
    final result = await _repository.createProfile(name: name, localeCode: localeCode);
    if (result.isError) {
      _lastError = result.errorOrNull;
      notifyListeners();
      return null;
    }
    final profile = result.valueOrNull!;
    await _seeder.seedProfile(profileId: profile.id, localeCode: localeCode);
    _profiles = [..._profiles, profile];
    await selectProfile(profile.id);
    return profile;
  }

  Future<void> selectProfile(String profileId) async {
    final matches = _profiles.where((p) => p.id == profileId);
    if (matches.isEmpty) return;
    _activeProfile = matches.first;
    await _repository.setAppSetting(AppSettingsKeys.lastActiveProfileId, profileId);
    notifyListeners();
  }

  void clearActiveProfile() {
    _activeProfile = null;
    notifyListeners();
  }

  Future<void> updateActiveProfile(ProfileModel Function(ProfileModel current) update) async {
    final current = _activeProfile;
    if (current == null) return;
    final updated = update(current);
    final result = await _repository.updateProfile(updated);
    if (result.isOk) {
      _activeProfile = updated;
      _profiles = _profiles.map((p) => p.id == updated.id ? updated : p).toList();
    } else {
      _lastError = result.errorOrNull;
    }
    notifyListeners();
  }

  Future<void> renameProfile(String profileId, String newName) async {
    final matches = _profiles.where((p) => p.id == profileId);
    if (matches.isEmpty) return;
    final updated = matches.first.copyWith(name: newName);
    final result = await _repository.updateProfile(updated);
    if (result.isOk) {
      _profiles = _profiles.map((p) => p.id == profileId ? updated : p).toList();
      if (_activeProfile?.id == profileId) _activeProfile = updated;
      notifyListeners();
    }
  }

  Future<void> deleteProfile(String profileId) async {
    await _repository.deleteProfile(profileId);
    _profiles = _profiles.where((p) => p.id != profileId).toList();
    if (_activeProfile?.id == profileId) {
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    notifyListeners();
  }

  // Convenience setters used by the settings screens. Each is a thin
  // wrapper over updateActiveProfile so screens don't need to know about
  // ProfileModel.copyWith directly.

  Future<void> setGridSize(GridSize size) =>
      updateActiveProfile((p) => p.copyWith(gridSize: size));

  Future<void> setHighContrast(bool value) =>
      updateActiveProfile((p) => p.copyWith(highContrast: value));

  Future<void> setReducedAnimation(bool value) =>
      updateActiveProfile((p) => p.copyWith(reducedAnimation: value));

  Future<void> setFontScale(double value) =>
      updateActiveProfile((p) => p.copyWith(fontScale: value));

  Future<void> setButtonSizeScale(double value) =>
      updateActiveProfile((p) => p.copyWith(buttonSizeScale: value));

  Future<void> setButtonSpacingScale(double value) =>
      updateActiveProfile((p) => p.copyWith(buttonSpacingScale: value));

  Future<void> setLocaleCode(String code) =>
      updateActiveProfile((p) => p.copyWith(localeCode: code));

  Future<void> setTtsVoice(String voiceId) =>
      updateActiveProfile((p) => p.copyWith(ttsVoiceId: voiceId));

  Future<void> setTtsRate(double rate) => updateActiveProfile((p) => p.copyWith(ttsRate: rate));

  Future<void> setTtsPitch(double pitch) =>
      updateActiveProfile((p) => p.copyWith(ttsPitch: pitch));

  Future<void> setTtsVolume(double volume) =>
      updateActiveProfile((p) => p.copyWith(ttsVolume: volume));

  Future<void> setEditingLocked(bool locked) =>
      updateActiveProfile((p) => p.copyWith(editingLocked: locked));

  Future<void> deleteAllData() async {
    // Clear every profile's PIN from secure storage first — once the
    // `profiles` rows are gone we'd have no record of which IDs to clear.
    final pinService = PinService();
    for (final profile in _profiles) {
      await pinService.clearPin(profile.id);
    }
    await ImageStorageService().deleteAllStoredMedia([
      AppConstants.buttonImagesDir,
      AppConstants.profileAvatarsDir,
      AppConstants.backupsDir,
    ]);
    await _repository.deleteAllData();
    _profiles = [];
    _activeProfile = null;
    notifyListeners();
  }
}
