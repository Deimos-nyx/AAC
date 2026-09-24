/// App-wide constant values. Keep this file free of anything that changes
/// per-profile — those belong in [AppSettingsModel]/[ProfileModel] instead.
class AppConstants {
  AppConstants._();

  static const String appName = 'VoicePath';
  static const String databaseName = 'voicepath.db';
  static const int databaseVersion = 1;

  /// Directory (relative to app documents) where per-button custom photos
  /// are copied so the app owns a stable, sandboxed copy of the file.
  static const String buttonImagesDir = 'button_images';
  static const String profileAvatarsDir = 'profile_avatars';
  static const String backupsDir = 'backups';

  /// PIN constraints.
  static const int pinMinLength = 4;
  static const int pinMaxLength = 8;

  /// Debounce for persisting free-text edits (text mode) to avoid excessive
  /// writes while the user is still typing.
  static const Duration textPersistDebounce = Duration(milliseconds: 400);

  /// Maximum sentence bar items before we start visually compacting them.
  static const int sentenceBarSoftLimit = 12;

  static const List<String> supportedLocaleCodes = ['en', 'ne'];
  static const String defaultLocaleCode = 'en';
}
