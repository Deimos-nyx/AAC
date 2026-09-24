import 'package:flutter/material.dart';

import '../../../../core/constants/grid_sizes.dart';
import '../../../vocabulary/domain/button_model.dart';
import 'aac_button_widget.dart';

/// Lays out AAC buttons using the profile's chosen [GridSize].
///
/// Buttons are always rendered in their persisted `sortOrder` — the same
/// order every time — so a button's screen position stays predictable
/// across sessions (spec section 3: "preserve button positions ... to
/// support consistent motor planning"). If a category has more buttons than
/// fit on one screen, the grid scrolls rather than silently reflowing
/// positions to compress everything in, which would break that guarantee.
class CommunicationGrid extends StatelessWidget {
  final List<ButtonModel> buttons;
  final GridSize gridSize;
  final double buttonSizeScale;
  final double spacingScale;
  final double fontScale;
  final bool reducedAnimation;
  final bool highContrast;
  final void Function(ButtonModel button) onButtonTap;
  final void Function(ButtonModel button)? onButtonLongPress;

  const CommunicationGrid({
    super.key,
    required this.buttons,
    required this.gridSize,
    required this.onButtonTap,
    this.onButtonLongPress,
    this.buttonSizeScale = 1.0,
    this.spacingScale = 1.0,
    this.fontScale = 1.0,
    this.reducedAnimation = false,
    this.highContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseSpacing = 10.0 * spacingScale;
    return GridView.builder(
      padding: EdgeInsets.all(baseSpacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize.columns,
        mainAxisSpacing: baseSpacing,
        crossAxisSpacing: baseSpacing,
        childAspectRatio: 0.92 * buttonSizeScale.clamp(0.7, 1.4),
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final button = buttons[index];
        return AacButtonWidget(
          key: ValueKey(button.id),
          button: button,
          fontScale: fontScale,
          reducedAnimation: reducedAnimation,
          highContrast: highContrast,
          onTap: () => onButtonTap(button),
          onLongPress: onButtonLongPress == null ? null : () => onButtonLongPress!(button),
        );
      },
    );
  }
}
