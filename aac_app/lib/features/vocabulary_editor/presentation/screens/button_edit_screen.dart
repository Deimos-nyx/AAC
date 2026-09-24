import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../vocabulary/domain/button_model.dart';
import '../../../vocabulary/presentation/vocabulary_provider.dart';

/// Navigation argument for [ButtonEditScreen]. Exactly one of [existing] /
/// (`categoryId`, `isCore`) applies: pass [existing] to edit a button that
/// already exists, or [categoryId]/[isCore] to say where a brand-new button
/// should be created.
class ButtonEditArgs {
  final ButtonModel? existing;
  final String? categoryId;
  final bool isCore;

  const ButtonEditArgs({this.existing, this.categoryId, this.isCore = false});
}

const List<String> _quickEmoji = [
  '🙂',
  '👍',
  '👎',
  '❤️',
  '🍎',
  '💧',
  '🏠',
  '🚗',
  '📖',
  '🎵',
  '⚽',
  '🐶',
  '🐱',
  '👋',
  '🛑',
  '➕',
  '❓',
  '✅',
  '❌',
  '🤲',
];

class ButtonEditScreen extends StatefulWidget {
  final ButtonEditArgs args;

  const ButtonEditScreen({super.key, required this.args});

  @override
  State<ButtonEditScreen> createState() => _ButtonEditScreenState();
}

class _ButtonEditScreenState extends State<ButtonEditScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _spokenController;
  late final TextEditingController _pronunciationController;

  String? _iconKey;
  String? _imagePath;
  String? _backgroundColorHex;
  String? _categoryId;
  bool _isSaving = false;

  final _imageService = ImageStorageService();

  bool get _isEditing => widget.args.existing != null;
  bool get _isCore => widget.args.existing?.isCore ?? widget.args.isCore;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.existing;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _spokenController = TextEditingController(
      text: existing?.spokenPhrase ?? '',
    );
    _pronunciationController = TextEditingController(
      text: existing?.pronunciationOverride ?? '',
    );
    _iconKey = existing?.iconKey;
    _imagePath = existing?.imagePath;
    _backgroundColorHex = existing?.backgroundColorHex;
    _categoryId = existing?.categoryId ?? widget.args.categoryId;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _spokenController.dispose();
    _pronunciationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final result = await _imageService.pickAndStore(
      source: source,
      subDirectory: AppConstants.buttonImagesDir,
    );
    if (!mounted) return;
    if (result.isOk) {
      setState(() => _imagePath = result.valueOrNull);
    } else if (result.errorOrNull != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t(result.errorOrNull!))));
    }
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;
    setState(() => _isSaving = true);

    final vocabulary = context.read<VocabularyProvider>();
    final spoken = _spokenController.text.trim();
    final pronunciation = _pronunciationController.text.trim();

    if (_isEditing) {
      final existing = widget.args.existing!;
      await vocabulary.updateButton(
        existing.copyWith(
          label: label,
          spokenPhrase: spoken.isEmpty ? null : spoken,
          clearSpokenPhrase: spoken.isEmpty,
          pronunciationOverride: pronunciation.isEmpty ? null : pronunciation,
          clearPronunciationOverride: pronunciation.isEmpty,
          iconKey: _iconKey,
          clearIconKey: _iconKey == null,
          imagePath: _imagePath,
          clearImage: _imagePath == null,
          backgroundColorHex: _backgroundColorHex,
          clearBackgroundColor: _backgroundColorHex == null,
          categoryId: _isCore ? null : _categoryId,
          clearCategory: !_isCore && _categoryId == null,
        ),
      );
    } else {
      await vocabulary.createButton(
        label: label,
        spokenPhrase: spoken.isEmpty ? null : spoken,
        pronunciationOverride: pronunciation.isEmpty ? null : pronunciation,
        iconKey: _iconKey,
        imagePath: _imagePath,
        backgroundColorHex: _backgroundColorHex,
        categoryId: _isCore ? null : _categoryId,
        isCore: _isCore,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      titleKey: 'deleteButtonConfirm',
      messageKey: 'deleteButtonConfirm',
    );
    if (!confirmed) return;
    if (!mounted) return;
    await context.read<VocabularyProvider>().deleteButton(
          widget.args.existing!.id,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vocabulary = context.watch<VocabularyProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t(_isEditing ? 'editButton' : 'addButton')),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _delete,
              tooltip: context.t('delete'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: _ImagePreview(
              imagePath: _imagePath,
              iconKey: _iconKey,
              label: _labelController.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(context.t('takePhoto')),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              TextButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(context.t('chooseFromGallery')),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
          if (_imagePath != null)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _imagePath = null),
                child: Text(context.t('useIcon')),
              ),
            ),
          const SizedBox(height: 8),
          Text(context.t('useIcon'), style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickEmoji.map((emoji) {
              final selected = _iconKey == emoji;
              return ChoiceChip(
                label: Text(emoji, style: const TextStyle(fontSize: 20)),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _iconKey = selected ? null : emoji),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(labelText: context.t('label')),
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _spokenController,
            decoration: InputDecoration(labelText: context.t('spokenPhrase')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pronunciationController,
            decoration: InputDecoration(
              labelText: context.t('spokenPhrase'),
              helperText: 'e.g. "Sean" pronounced "Shawn"',
            ),
          ),
          const SizedBox(height: 20),
          if (!_isCore) ...[
            Text(context.t('category'), style: AppTextStyles.caption),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(context.t('allCategories')),
                ),
                ...vocabulary.categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 20),
          ],
          Text(context.t('appearance'), style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              null,
              'FFFFFFFF',
              'FFFCE7B0',
              'FFB9DFC4',
              'FFBFD9F2',
              'FFF6C6C0',
              'FFD9C7EC',
              'FFFFD9A8',
            ].map((hex) {
              final color = hex == null
                  ? AppColors.surface
                  : Color(int.parse(hex, radix: 16));
              final selected = _backgroundColorHex == hex;
              return GestureDetector(
                onTap: () => setState(() => _backgroundColorHex = hex),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
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
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving || _labelController.text.trim().isEmpty
                  ? null
                  : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.t('save')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String? imagePath;
  final String? iconKey;
  final String label;

  const _ImagePreview({
    required this.imagePath,
    required this.iconKey,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imagePath != null && File(imagePath!).existsSync()) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imagePath!),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    } else if (iconKey != null && iconKey!.isNotEmpty) {
      child = Text(iconKey!, style: const TextStyle(fontSize: 56));
    } else {
      final letter =
          label.trim().isNotEmpty ? label.trim()[0].toUpperCase() : '?';
      child = Text(
        letter,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      );
    }
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
