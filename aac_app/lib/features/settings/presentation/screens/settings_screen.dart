import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../caregiver/presentation/caregiver_provider.dart';
import '../../../caregiver/presentation/screens/caregiver_lock_screen.dart';
import '../../../caregiver/presentation/screens/caregiver_settings_screen.dart';
import '../../../profiles/presentation/profile_provider.dart';
import '../../../profiles/presentation/widgets/profile_avatar.dart';

/// The bottom-nav "Settings" tab. Switching profiles is always available
/// (not sensitive); everything that changes configuration lives behind the
/// caregiver PIN gate per spec section 8.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().activeProfile;
    final caregiverUnlocked = context.watch<CaregiverProvider>().isUnlocked;
    if (profile == null) return const SizedBox.shrink();

    final canEnterCaregiver = !profile.editingLocked || caregiverUnlocked;

    return Scaffold(
      appBar: AppBar(title: Text(context.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              ProfileAvatar(name: profile.name, avatarPath: profile.avatarPath, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(profile.name, style: AppTextStyles.sectionTitle),
              ),
              TextButton(
                onPressed: () {
                  context.read<ProfileProvider>().clearActiveProfile();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.profileSelection, (route) => false);
                },
                child: Text(context.t('whoIsCommunicating')),
              ),
            ],
          ),
          const Divider(height: 32),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => canEnterCaregiver
                      ? const CaregiverSettingsScreen()
                      : const CaregiverLockScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      canEnterCaregiver ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(context.t('caregiverSettings'))),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
