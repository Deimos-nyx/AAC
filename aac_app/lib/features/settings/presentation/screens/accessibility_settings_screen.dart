import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profiles/presentation/profile_provider.dart';
import '../../../vocabulary_editor/presentation/widgets/grid_size_picker.dart';

/// Every knob spec section 13 asks for: large touch targets are the default
/// everywhere already, so this screen covers the parts that need to be
/// user-adjustable (contrast, text size, button size/spacing, motion,
/// grid density).
class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.activeProfile;
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('accessibility'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.t('highContrast')),
            value: profile.highContrast,
            onChanged: profileProvider.setHighContrast,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.t('reducedAnimation')),
            value: profile.reducedAnimation,
            onChanged: profileProvider.setReducedAnimation,
          ),
          const Divider(height: 32),
          Text(context.t('fontSize'), style: AppTextStyles.sectionTitle),
          Slider(
            value: profile.fontScale.clamp(0.8, 2.0),
            min: 0.8,
            max: 2.0,
            divisions: 12,
            label: '${(profile.fontScale * 100).round()}%',
            onChanged: profileProvider.setFontScale,
          ),
          const SizedBox(height: 16),
          Text(context.t('buttonSize'), style: AppTextStyles.sectionTitle),
          Slider(
            value: profile.buttonSizeScale.clamp(0.7, 1.4),
            min: 0.7,
            max: 1.4,
            divisions: 7,
            label: '${(profile.buttonSizeScale * 100).round()}%',
            onChanged: profileProvider.setButtonSizeScale,
          ),
          const SizedBox(height: 16),
          Text(context.t('buttonSpacing'), style: AppTextStyles.sectionTitle),
          Slider(
            value: profile.buttonSpacingScale.clamp(0.5, 2.0),
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: '${(profile.buttonSpacingScale * 100).round()}%',
            onChanged: profileProvider.setButtonSpacingScale,
          ),
          const Divider(height: 32),
          Text(context.t('gridSize'), style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          GridSizePicker(
            selected: profile.gridSize,
            onChanged: profileProvider.setGridSize,
          ),
        ],
      ),
    );
  }
}
