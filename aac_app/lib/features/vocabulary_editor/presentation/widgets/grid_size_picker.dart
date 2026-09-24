import 'package:flutter/material.dart';

import '../../../../core/constants/grid_sizes.dart';
import '../../../../core/theme/app_colors.dart';

/// Lets a caregiver pick one of the fixed grid sizes from spec section 4.
/// Deliberately a closed set of choices (not a free-form rows/columns
/// stepper) so every size has been checked to render legibly.
class GridSizePicker extends StatelessWidget {
  final GridSize selected;
  final ValueChanged<GridSize> onChanged;

  const GridSizePicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: GridSizes.all.map((size) {
        final isSelected = size == selected;
        return ChoiceChip(
          label: Text(size.storageKey),
          selected: isSelected,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) => onChanged(size),
        );
      }).toList(),
    );
  }
}
