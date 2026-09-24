import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/tts_provider.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profiles/presentation/profile_provider.dart';

/// Voice / rate / pitch / volume controls (spec section 6). Every change
/// takes effect immediately and is saved to the active profile, and "Test
/// voice" always speaks the same short sample so changes are easy to A/B.
class TtsSettingsScreen extends StatefulWidget {
  const TtsSettingsScreen({super.key});

  @override
  State<TtsSettingsScreen> createState() => _TtsSettingsScreenState();
}

class _TtsSettingsScreenState extends State<TtsSettingsScreen> {
  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().activeProfile;
    if (profile != null) {
      context.read<TtsProvider>().refreshVoicesFor(profile.localeCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().activeProfile;
    final tts = context.watch<TtsProvider>();
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('ttsSettings'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.t('voice'), style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          if (tts.availableVoices.isEmpty)
            Text(context.t('speechUnavailable'), style: AppTextStyles.caption)
          else
            DropdownButtonFormField<String>(
              initialValue: profile.ttsVoiceId,
              items: tts.availableVoices
                  .map((v) => DropdownMenuItem(value: v.id, child: Text(v.displayName)))
                  .toList(),
              onChanged: (value) {
                if (value != null) context.read<ProfileProvider>().setTtsVoice(value);
              },
            ),
          const SizedBox(height: 24),
          _SliderSetting(
            labelKey: 'speechRate',
            value: profile.ttsRate,
            min: 0.1,
            max: 1.0,
            onChanged: (v) => context.read<ProfileProvider>().setTtsRate(v),
          ),
          _SliderSetting(
            labelKey: 'pitch',
            value: profile.ttsPitch,
            min: 0.5,
            max: 2.0,
            onChanged: (v) => context.read<ProfileProvider>().setTtsPitch(v),
          ),
          _SliderSetting(
            labelKey: 'volume',
            value: profile.ttsVolume,
            min: 0.0,
            max: 1.0,
            onChanged: (v) => context.read<ProfileProvider>().setTtsVolume(v),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.volume_up_rounded),
            label: Text(context.t('testVoice')),
            onPressed: () => tts.previewVoice(
              profile.localeCode == 'ne' ? 'नमस्ते, म तयार छु' : 'Hello, I am ready',
              localeCode: profile.localeCode,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String labelKey;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.labelKey,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t(labelKey), style: AppTextStyles.body),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
