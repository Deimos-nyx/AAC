import 'package:flutter/material.dart';

import '../../features/backup_restore/presentation/screens/backup_restore_screen.dart';
import '../../features/caregiver/presentation/screens/caregiver_lock_screen.dart';
import '../../features/caregiver/presentation/screens/caregiver_settings_screen.dart';
import '../../features/profiles/presentation/screens/profile_selection_screen.dart';
import '../../features/settings/presentation/screens/accessibility_settings_screen.dart';
import '../../features/settings/presentation/screens/language_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/tts_settings_screen.dart';
import '../../features/text_mode/presentation/screens/text_mode_screen.dart';
import '../../features/vocabulary_editor/presentation/screens/button_edit_screen.dart';
import '../../features/vocabulary_editor/presentation/screens/vocabulary_editor_screen.dart';
import 'app_routes.dart';
import 'home_shell.dart';

/// Single `onGenerateRoute` for the whole app. A plain Navigator + named
/// routes is enough here (spec section 16: "use simple navigation") — the
/// screen tree is shallow and nothing needs deep-linking.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.profileSelection:
        return MaterialPageRoute(builder: (_) => const ProfileSelectionScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case AppRoutes.textMode:
        return MaterialPageRoute(builder: (_) => const TextModeScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.accessibilitySettings:
        return MaterialPageRoute(builder: (_) => const AccessibilitySettingsScreen());
      case AppRoutes.ttsSettings:
        return MaterialPageRoute(builder: (_) => const TtsSettingsScreen());
      case AppRoutes.languageSettings:
        return MaterialPageRoute(builder: (_) => const LanguageSettingsScreen());
      case AppRoutes.backupRestore:
        return MaterialPageRoute(builder: (_) => const BackupRestoreScreen());
      case AppRoutes.caregiverLock:
        return MaterialPageRoute(builder: (_) => const CaregiverLockScreen());
      case AppRoutes.caregiverSettings:
        return MaterialPageRoute(builder: (_) => const CaregiverSettingsScreen());
      case AppRoutes.vocabularyEditor:
        return MaterialPageRoute(builder: (_) => const VocabularyEditorScreen());
      case AppRoutes.buttonEdit:
        final args = settings.arguments as ButtonEditArgs? ?? const ButtonEditArgs();
        return MaterialPageRoute(builder: (_) => ButtonEditScreen(args: args));
      default:
        return MaterialPageRoute(builder: (_) => const ProfileSelectionScreen());
    }
  }
}
