import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../vocabulary/domain/category_model.dart';

/// Horizontally scrollable row of category tabs. A fixed, predictable order
/// (the caregiver-controlled sortOrder) matters here just as much as it
/// does on the grid itself — same motor-planning rationale.
class CategoryTabBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelected;
  final bool highContrast;

  const CategoryTabBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    this.highContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;
          final color = _parseColor(category.colorHex) ?? AppColors.catMisc;
          return ChoiceChip(
            label: Text('${category.iconKey ?? ''} ${category.name}'.trim()),
            selected: isSelected,
            onSelected: (_) => onSelected(category.id),
            backgroundColor:
                highContrast ? Colors.black : color.withValues(alpha: 0.5),
            selectedColor: highContrast ? AppColors.hcPrimary : color,
            side: BorderSide(
              color: highContrast ? AppColors.hcBorder : AppColors.border,
            ),
            labelStyle: TextStyle(
              color: highContrast
                  ? (isSelected ? Colors.black : AppColors.hcText)
                  : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        },
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }
}
