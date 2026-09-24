/// Small set of app-level (not per-profile) preferences, stored as rows in
/// the `app_settings` key/value table. Kept separate from [ProfileModel]
/// because these values matter before any profile is even selected.
class AppSettingsKeys {
  AppSettingsKeys._();

  static const String lastActiveProfileId = 'last_active_profile_id';
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String globalCaregiverPinSet = 'global_caregiver_pin_set';
}
