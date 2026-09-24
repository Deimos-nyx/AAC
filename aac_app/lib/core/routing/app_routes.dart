/// Route name constants. Kept as plain strings (not a routing package) per
/// spec section 16 ("use simple navigation") — this app's navigation is a
/// shallow tree, not deep-linked, so Navigator + named routes is enough.
class AppRoutes {
  AppRoutes._();

  static const String profileSelection = '/profiles';
  static const String home = '/home';
  static const String textMode = '/text-mode';
  static const String settings = '/settings';
  static const String accessibilitySettings = '/settings/accessibility';
  static const String ttsSettings = '/settings/tts';
  static const String languageSettings = '/settings/language';
  static const String backupRestore = '/settings/backup-restore';
  static const String caregiverLock = '/caregiver/lock';
  static const String caregiverSettings = '/caregiver/settings';
  static const String vocabularyEditor = '/caregiver/vocabulary';
  static const String buttonEdit = '/caregiver/vocabulary/button';
  static const String categoryEdit = '/caregiver/vocabulary/category';
}
