import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../vocabulary/domain/category_model.dart';
import '../../../vocabulary/presentation/vocabulary_provider.dart';
import 'category_buttons_screen.dart';
import 'category_edit_screen.dart';

/// Entry point for all vocabulary customization (spec section 3): manage
/// categories here, then drill into core words or any one category to
/// add/edit/delete/reorder its buttons.
class VocabularyEditorScreen extends StatelessWidget {
  const VocabularyEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vocabulary = context.watch<VocabularyProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('categories'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.catCore,
              child: Icon(
                Icons.push_pin_outlined,
                color: AppColors.textPrimary,
              ),
            ),
            title: Text(context.t('board')),
            subtitle: Text('${vocabulary.coreButtons.length}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CategoryButtonsScreen(
                  title: context.t('board'),
                  isCore: true,
                ),
              ),
            ),
          ),
          const Divider(height: 24),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vocabulary.categories.length,
            onReorderItem: (index, newIndex) {
              final ids = vocabulary.categories.map((c) => c.id).toList();
              final moved = ids.removeAt(index);
              ids.insert(newIndex, moved);
              vocabulary.reorderCategories(ids);
            },
            itemBuilder: (context, index) {
              final category = vocabulary.categories[index];
              return _CategoryTile(
                key: ValueKey(category.id),
                category: category,
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(context.t('newCategory')),
              onPressed: () => showCategoryEditSheet(context),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;

  const _CategoryTile({super.key, required this.category});

  Color get _color {
    final hex = category.colorHex;
    if (hex == null) return AppColors.catMisc;
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return AppColors.catMisc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _color,
        child: Text(category.iconKey ?? '📁'),
      ),
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showCategoryEditSheet(context, existing: category),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.danger,
            ),
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                titleKey: 'deleteButtonConfirm',
                messageKey: 'deleteButtonConfirm',
              );
              if (confirmed && context.mounted) {
                context.read<VocabularyProvider>().deleteCategory(category.id);
              }
            },
          ),
          const Icon(Icons.drag_handle),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryButtonsScreen(
            title: category.name,
            categoryId: category.id,
          ),
        ),
      ),
    );
  }
}
