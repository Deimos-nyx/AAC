import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/profile_model.dart';
import '../profile_provider.dart';
import '../widgets/profile_avatar.dart';

/// First screen on launch (spec section 16: "Home/profile selection").
/// Lets multiple people share one device (spec section 7) by picking who is
/// communicating before anything else loads.
class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('appName'))),
      body: Consumer<ProfileProvider>(
        builder: (context, profiles, _) {
          if (profiles.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profiles.lastError != null && profiles.profiles.isEmpty) {
            return AppErrorView(onRetry: profiles.loadProfiles);
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('whoIsCommunicating'),
                    style: AppTextStyles.screenTitle,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 160,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: profiles.profiles.length + 1,
                      itemBuilder: (context, index) {
                        if (index == profiles.profiles.length) {
                          return _AddProfileCard(
                            onTap: () => _showCreateProfileSheet(context),
                          );
                        }
                        final profile = profiles.profiles[index];
                        return _ProfileCard(
                          profile: profile,
                          onTap: () async {
                            await profiles.selectProfile(profile.id);
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.home);
                            }
                          },
                          onLongPress: () =>
                              _showProfileOptions(context, profile),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateProfileSheet(),
    );
  }

  void _showProfileOptions(BuildContext context, ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(sheetContext.t('editProfile')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showRenameDialog(context, profile);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger,
                ),
                title: Text(
                  sheetContext.t('deleteProfile'),
                  style: const TextStyle(color: AppColors.danger),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirmed = await showConfirmDialog(
                    context,
                    titleKey: 'deleteProfile',
                    messageKey: 'deleteProfileConfirm',
                  );
                  if (confirmed && context.mounted) {
                    await context.read<ProfileProvider>().deleteProfile(
                      profile.id,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, ProfileModel profile) {
    final controller = TextEditingController(text: profile.name);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.t('editProfile')),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: dialogContext.t('profileName'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  context.read<ProfileProvider>().renameProfile(
                    profile.id,
                    name,
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: Text(dialogContext.t('save')),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileAvatar(
                name: profile.name,
                avatarPath: profile.avatarPath,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                profile.name,
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(context.t('addProfile'), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateProfileSheet extends StatefulWidget {
  const _CreateProfileSheet();

  @override
  State<_CreateProfileSheet> createState() => _CreateProfileSheetState();
}

class _CreateProfileSheetState extends State<_CreateProfileSheet> {
  final _controller = TextEditingController();
  String _localeCode = AppConstants.defaultLocaleCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so the Save button enables/disables live.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final profile = await context.read<ProfileProvider>().createProfile(
      name: _controller.text.trim(),
      localeCode: _localeCode,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (profile != null) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('newProfile'), style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: context.t('profileName')),
          ),
          const SizedBox(height: 16),
          Text(context.t('language'), style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('English'),
                selected: _localeCode == 'en',
                onSelected: (_) => setState(() => _localeCode = 'en'),
              ),
              ChoiceChip(
                label: const Text('नेपाली'),
                selected: _localeCode == 'ne',
                onSelected: (_) => setState(() => _localeCode = 'ne'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving || _controller.text.trim().isEmpty
                  ? null
                  : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.t('save')),
            ),
          ),
        ],
      ),
    );
  }
}
