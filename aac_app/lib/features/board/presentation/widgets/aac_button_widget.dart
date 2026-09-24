import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../vocabulary/domain/button_model.dart';

/// A single tile on the communication board.
///
/// Kept as a `StatelessWidget` with no internal animation beyond the
/// system's default ink splash — spec section 13 explicitly asks us to
/// avoid excessive animation/decoration so the button's meaning is never
/// competing with motion for the user's attention.
class AacButtonWidget extends StatelessWidget {
  final ButtonModel button;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double fontScale;
  final bool reducedAnimation;
  final bool highContrast;

  const AacButtonWidget({
    super.key,
    required this.button,
    required this.onTap,
    this.onLongPress,
    this.fontScale = 1.0,
    this.reducedAnimation = false,
    this.highContrast = false,
  });

  Color get _background {
    if (highContrast) return Colors.black;
    final hex = button.backgroundColorHex;
    if (hex == null) return AppColors.surface;
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = highContrast ? AppColors.hcBorder : AppColors.border;
    final textColor = highContrast ? AppColors.hcText : AppColors.textPrimary;

    return Semantics(
      button: true,
      label: button.label,
      child: Material(
        color: _background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          onLongPress: onLongPress,
          // A short, fixed splash instead of a custom animated affordance —
          // still gives tap feedback without extra motion to design around.
          splashFactory: reducedAnimation
              ? NoSplash.splashFactory
              : InkRipple.splashFactory,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: highContrast ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: _Visual(button: button)),
                const SizedBox(height: 4),
                Text(
                  button.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.buttonLabel.copyWith(
                    fontSize: AppTextStyles.buttonLabel.fontSize! * fontScale,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The picture half of a button: a caregiver photo if one was set, else the
/// symbol/emoji, else the first letter of the label as a last-resort visual
/// anchor so a button is never blank.
class _Visual extends StatelessWidget {
  final ButtonModel button;

  const _Visual({required this.button});

  @override
  Widget build(BuildContext context) {
    final imagePath = button.imagePath;
    if (imagePath != null && File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => _fallbackGlyph(),
        ),
      );
    }
    return FittedBox(fit: BoxFit.contain, child: _fallbackGlyph());
  }

  Widget _fallbackGlyph() {
    final icon = button.iconKey;
    if (icon != null && icon.isNotEmpty) {
      return Text(icon, style: const TextStyle(fontSize: 32));
    }
    final letter = button.label.trim().isNotEmpty
        ? button.label.trim()[0].toUpperCase()
        : '?';
    return Text(
      letter,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}
