import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/tts_provider.dart';
import '../../../profiles/presentation/profile_provider.dart';

/// Switches the interface language for the active profile (spec section
/// 12). This only changes UI chrome and which TTS voice list is offered —
/// it deliberately does not rewrite existing vocabulary button labels,
/// since a caregiver's custom word text is their content to keep, not
/// something a language switch should silently overwrite.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.activeProfile;
    if (profile == null) return const SizedBox.shrink();

    Future<void> select(String code) async {
      await profileProvider.setLocaleCode(code);
      if (context.mounted) {
        await context.read<TtsProvider>().refreshVoicesFor(code);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.t('language'))),
      body: RadioGroup<String>(
        groupValue: profile.localeCode,
        onChanged: (value) => value != null ? select(value) : null,
        child: ListView(
          children: const [
            RadioListTile<String>(
              title: Text('English'),
              value: 'en',
            ),
            RadioListTile<String>(
              title: Text('नेपाली (Nepali)'),
              value: 'ne',
            ),
          ],
        ),
      ),
    );
  }
}
