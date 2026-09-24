import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/pin_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../profiles/presentation/profile_provider.dart';
import '../../../settings/presentation/screens/accessibility_settings_screen.dart';
import '../../../settings/presentation/screens/language_settings_screen.dart';
import '../../../settings/presentation/screens/tts_settings_screen.dart';
import '../../../backup_restore/presentation/screens/backup_restore_screen.dart';
import '../../../vocabulary_editor/presentation/screens/vocabulary_editor_screen.dart';
import '../caregiver_provider.dart';

/// Everything spec section 8 lists as caregiver-protected: vocabulary
/// editing, profile-level settings, backup/restore, and the option to turn
/// the PIN lock off again. Reachable only after [CaregiverLockScreen]
/// succeeds — see the guard in SettingsScreen.
class CaregiverSettingsScreen extends StatelessWidget {
  const CaregiverSettingsScreen({super.key});

  Future<void> _toggleLock(BuildContext context, bool enable) async {
    final profileProvider = context.read<ProfileProvider>();
    final profileId = profileProvider.activeProfile?.id;
    if (profileId == null) return;

    if (!enable) {
      final confirmed = await showConfirmDialog(
        context,
        titleKey: 'lockEditing',
        messageKey: 'disableLockConfirm',
        isDestructive: false,
        confirmLabelKey: 'ok',
      );
      if (!confirmed) return;
      await PinService().clearPin(profileId);
      await profileProvider.setEditingLocked(false);
    } else {
      // Turning it on when no PIN exists yet is handled by CaregiverLockScreen
      // itself (it detects "no PIN" and shows the setup flow), so just route
      // there instead of flipping the flag with no PIN behind it.
      await profileProvider.setEditingLocked(true);
    }
  }

  void _exit(BuildContext context) {
    context.read<CaregiverProvider>().lock();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().activeProfile;
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('caregiverSettings')),
        actions: [
          TextButton(
            onPressed: () => _exit(context),
            child: Text(context.t('exitCaregiverMode')),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.grid_view_rounded),
            title: Text(context.t('categories')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VocabularyEditorScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility_new_rounded),
            title: Text(context.t('accessibility')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AccessibilitySettingsScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over_rounded),
            title: Text(context.t('ttsSettings')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TtsSettingsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(context.t('language')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(context.t('backupRestore')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
            ),
          ),
          const Divider(height: 32),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline_rounded),
            title: Text(context.t('lockEditing')),
            value: profile.editingLocked,
            onChanged: (value) => _toggleLock(context, value),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: AppColors.danger,
            ),
            title: Text(
              context.t('deleteAllData'),
              style: const TextStyle(color: AppColors.danger),
            ),
            onTap: () async {
              final confirmed = await showConfirmDialog(
                context,
                titleKey: 'deleteAllData',
                messageKey: 'deleteAllDataConfirm',
              );
              if (confirmed && context.mounted) {
                await context.read<ProfileProvider>().deleteAllData();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.profileSelection,
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
