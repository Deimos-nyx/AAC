import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../vocabulary/domain/category_model.dart';
import '../../../vocabulary/presentation/vocabulary_provider.dart';

const List<String> _categoryIcons = [
  '🍽️', '🥤', '🧑‍🤝‍🧑', '📍', '🧸', '⚽', '🏫', '🩺', '😊', '🖐️', '👕', '🐾', '💬',
];

const List<String> _categoryColors = [
  'FFFCE7B0',
  'FFB9DFC4',
  'FFBFD9F2',
  'FFF6C6C0',
  'FFD9C7EC',
  'FFFFD9A8',
  'FFF3B8CE',
  'FFC9E4DE',
  'FFE3E3DD',
];

/// Opens a bottom sheet to create a new category, or edit [existing]. The
/// caller doesn't need to know which — this handles both.
Future<void> showCategoryEditSheet(BuildContext context, {CategoryModel? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CategoryEditSheet(existing: existing),
  );
}

class _CategoryEditSheet extends StatefulWidget {
  final CategoryModel? existing;

  const _CategoryEditSheet({this.existing});

  @override
  State<_CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends State<_CategoryEditSheet> {
  late final TextEditingController _nameController;
  String? _iconKey;
  String? _colorHex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _iconKey = widget.existing?.iconKey ?? _categoryIcons.first;
    _colorHex = widget.existing?.colorHex ?? _categoryColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSaving = true);
    final vocabulary = context.read<VocabularyProvider>();
    final existing = widget.existing;
    if (existing != null) {
      await vocabulary.updateCategory(
        existing.copyWith(name: name, iconKey: _iconKey, colorHex: _colorHex),
      );
    } else {
      await vocabulary.createCategory(name, iconKey: _iconKey, colorHex: _colorHex);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t(widget.existing != null ? 'editButton' : 'newCategory'),
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: context.t('categoryName')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoryIcons.map((icon) {
              return ChoiceChip(
                label: Text(icon, style: const TextStyle(fontSize: 18)),
                selected: _iconKey == icon,
                onSelected: (_) => setState(() => _iconKey = icon),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _categoryColors.map((hex) {
              final selected = _colorHex == hex;
              return GestureDetector(
                onTap: () => setState(() => _colorHex = hex),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(int.parse(hex, radix: 16)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving || _nameController.text.trim().isEmpty ? null : _save,
              child: Text(context.t('save')),
            ),
          ),
        ],
      ),
    );
  }
}
