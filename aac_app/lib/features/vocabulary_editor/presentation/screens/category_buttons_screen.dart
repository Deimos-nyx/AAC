import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vocabulary/domain/button_model.dart';
import '../../../vocabulary/presentation/vocabulary_provider.dart';
import 'button_edit_screen.dart';

/// Shows every button in one category (or the core set) as a reorderable
/// list. Drag-to-reorder here is what backs "Move buttons" / "Reorder
/// vocabulary" from spec section 3 — the resulting order is exactly what
/// the board grid renders, so this is a true WYSIWYG editor, not a
/// secondary representation that could drift from the board.
class CategoryButtonsScreen extends StatefulWidget {
  final String title;
  final String? categoryId;
  final bool isCore;

  const CategoryButtonsScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.isCore = false,
  });

  @override
  State<CategoryButtonsScreen> createState() => _CategoryButtonsScreenState();
}

class _CategoryButtonsScreenState extends State<CategoryButtonsScreen> {
  @override
  void initState() {
    super.initState();
    // Make sure the provider's "current view" matches what this screen
    // edits, since reorderWithinCurrentView / _refreshCurrentView act on
    // whatever the provider currently considers selected.
    if (!widget.isCore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VocabularyProvider>().selectCategory(widget.categoryId);
      });
    }
  }

  List<ButtonModel> _buttonsFrom(VocabularyProvider vocabulary) {
    return widget.isCore ? vocabulary.coreButtons : vocabulary.categoryButtons;
  }

  @override
  Widget build(BuildContext context) {
    final vocabulary = context.watch<VocabularyProvider>();
    final buttons = _buttonsFrom(vocabulary);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: buttons.isEmpty
          ? Center(child: Text(context.t('noVocabularyYet')))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: buttons.length,
              onReorderItem: (index, newIndex) {
                final ids = buttons.map((b) => b.id).toList();
                final moved = ids.removeAt(index);
                ids.insert(newIndex, moved);
                context
                    .read<VocabularyProvider>()
                    .reorderWithinCurrentView(ids);
              },
              itemBuilder: (context, index) {
                final button = buttons[index];
                return ListTile(
                  key: ValueKey(button.id),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Text(
                      button.iconKey?.isNotEmpty == true
                          ? button.iconKey!
                          : button.label.isNotEmpty
                              ? button.label[0].toUpperCase()
                              : '?',
                    ),
                  ),
                  title: Text(button.label),
                  subtitle: button.spokenPhrase != null
                      ? Text(button.spokenPhrase!)
                      : null,
                  trailing: const Icon(Icons.drag_handle),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ButtonEditScreen(
                          args: ButtonEditArgs(existing: button)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ButtonEditScreen(
              args: ButtonEditArgs(
                  categoryId: widget.categoryId, isCore: widget.isCore),
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
