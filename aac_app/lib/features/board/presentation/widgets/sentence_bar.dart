import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../vocabulary/domain/button_model.dart';

/// The message bar above the board (spec section 1): shows the sentence
/// being built and exposes Speak / Delete / Clear / Repeat / Stop.
class SentenceBar extends StatelessWidget {
  final List<ButtonModel> items;
  final bool isSpeaking;
  final bool highContrast;
  final double fontScale;
  final VoidCallback onSpeak;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onRepeat;
  final VoidCallback onStop;

  const SentenceBar({
    super.key,
    required this.items,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onDelete,
    required this.onClear,
    required this.onRepeat,
    required this.onStop,
    this.highContrast = false,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final background = highContrast ? Colors.black : AppColors.surface;
    final borderColor = highContrast ? AppColors.hcBorder : AppColors.border;
    final textColor = highContrast ? AppColors.hcText : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: items.isEmpty
                ? Center(
                    child: Text(
                      context.t('tapToBuildSentence'),
                      style: AppTextStyles.caption.copyWith(
                        color: highContrast
                            ? AppColors.hcText.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final button = items[index];
                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: highContrast
                              ? Colors.black
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          button.label,
                          style: AppTextStyles.sentenceBarWord.copyWith(
                            fontSize: AppTextStyles.sentenceBarWord.fontSize! *
                                fontScale,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ControlButton(
                icon: isSpeaking
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_rounded,
                labelKey: isSpeaking ? 'stop' : 'speak',
                onPressed:
                    isSpeaking ? onStop : (items.isEmpty ? null : onSpeak),
                emphasized: true,
                highContrast: highContrast,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                icon: Icons.backspace_outlined,
                labelKey: 'delete',
                onPressed: items.isEmpty ? null : onDelete,
                highContrast: highContrast,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                icon: Icons.replay_rounded,
                labelKey: 'repeat',
                onPressed: onRepeat,
                highContrast: highContrast,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                icon: Icons.clear_all_rounded,
                labelKey: 'clear',
                onPressed: items.isEmpty ? null : onClear,
                highContrast: highContrast,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final VoidCallback? onPressed;
  final bool emphasized;
  final bool highContrast;

  const _ControlButton({
    required this.icon,
    required this.labelKey,
    required this.onPressed,
    this.emphasized = false,
    this.highContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = highContrast
        ? AppColors.hcPrimary
        : (emphasized ? Colors.white : AppColors.textPrimary);
    final bg = highContrast
        ? Colors.black
        : (emphasized ? AppColors.primary : AppColors.background);

    return Expanded(
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            context.t(labelKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg.withValues(alpha: 0.5),
            disabledForegroundColor: fg.withValues(alpha: 0.5),
            elevation: 0,
            side: highContrast
                ? const BorderSide(color: AppColors.hcBorder)
                : BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ),
    );
  }
}
