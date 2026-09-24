import 'package:flutter/foundation.dart';

import '../../../core/services/image_storage_service.dart';
import '../../../core/utils/id_generator.dart';
import '../data/vocabulary_repository.dart';
import '../domain/button_model.dart';
import '../domain/category_model.dart';

/// Owns categories + buttons for whichever profile is currently active.
/// Call [loadForProfile] whenever the active profile changes (ProfileProvider
/// switch, app start) — see app.dart for the wiring between the two.
class VocabularyProvider extends ChangeNotifier {
  final VocabularyRepository _repository;

  VocabularyProvider({VocabularyRepository? repository})
      : _repository = repository ?? VocabularyRepository();

  String? _profileId;
  List<CategoryModel> _categories = [];
  List<ButtonModel> _coreButtons = [];
  List<ButtonModel> _categoryButtons = [];
  String? _selectedCategoryId; // null == "core / all" view
  bool _isLoading = true;
  String? _lastError;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<ButtonModel> get coreButtons => List.unmodifiable(_coreButtons);
  List<ButtonModel> get categoryButtons => List.unmodifiable(_categoryButtons);
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  bool get hasAnyVocabulary => _coreButtons.isNotEmpty || _categoryButtons.isNotEmpty;

  Future<void> loadForProfile(String profileId) async {
    _profileId = profileId;
    _isLoading = true;
    notifyListeners();

    final categoriesResult = await _repository.getCategories(profileId);
    final coreResult = await _repository.getCoreButtons(profileId);

    _categories = categoriesResult.valueOrNull ?? const [];
    _coreButtons = coreResult.valueOrNull ?? const [];
    _lastError = categoriesResult.errorOrNull ?? coreResult.errorOrNull;

    // Default to the first real category rather than the "uncategorized"
    // bucket (categoryId == null), since a brand-new profile's uncategorized
    // bucket is normally empty and would otherwise look like a blank board.
    _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
    final fringeResult = await _repository.getButtonsForCategory(profileId, _selectedCategoryId);
    _categoryButtons = fringeResult.valueOrNull ?? const [];
    _lastError ??= fringeResult.errorOrNull;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectCategory(String? categoryId) async {
    final profileId = _profileId;
    if (profileId == null) return;
    _selectedCategoryId = categoryId;
    notifyListeners();

    final result = await _repository.getButtonsForCategory(profileId, categoryId);
    _categoryButtons = result.valueOrNull ?? const [];
    notifyListeners();
  }

  Future<void> _refreshCurrentView() async {
    final profileId = _profileId;
    if (profileId == null) return;
    final coreResult = await _repository.getCoreButtons(profileId);
    _coreButtons = coreResult.valueOrNull ?? _coreButtons;
    final result = await _repository.getButtonsForCategory(profileId, _selectedCategoryId);
    _categoryButtons = result.valueOrNull ?? const [];
    notifyListeners();
  }

  Future<CategoryModel?> createCategory(String name, {String? iconKey, String? colorHex}) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final result = await _repository.createCategory(
      profileId: profileId,
      name: name,
      iconKey: iconKey,
      colorHex: colorHex,
    );
    if (result.isOk) {
      _categories = [..._categories, result.valueOrNull!];
      notifyListeners();
      return result.valueOrNull;
    }
    _lastError = result.errorOrNull;
    notifyListeners();
    return null;
  }

  Future<void> updateCategory(CategoryModel category) async {
    final result = await _repository.updateCategory(category);
    if (result.isOk) {
      _categories = _categories.map((c) => c.id == category.id ? category : c).toList();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    _categories = _categories.where((c) => c.id != categoryId).toList();
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    }
    await _refreshCurrentView();
  }

  Future<void> reorderCategories(List<String> orderedIds) async {
    await _repository.reorderCategories(orderedIds);
    final byId = {for (final c in _categories) c.id: c};
    _categories = orderedIds.map((id) => byId[id]).whereType<CategoryModel>().toList();
    notifyListeners();
  }

  Future<ButtonModel?> createButton({
    required String label,
    String? spokenPhrase,
    String? pronunciationOverride,
    String? iconKey,
    String? imagePath,
    String? backgroundColorHex,
    String? categoryId,
    bool isCore = false,
  }) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final now = DateTime.now();
    final siblingCount = isCore ? _coreButtons.length : _categoryButtons.length;
    final button = ButtonModel(
      id: IdGenerator.newId(),
      profileId: profileId,
      categoryId: isCore ? null : categoryId,
      label: label,
      spokenPhrase: spokenPhrase,
      pronunciationOverride: pronunciationOverride,
      iconKey: iconKey,
      imagePath: imagePath,
      backgroundColorHex: backgroundColorHex,
      sortOrder: siblingCount,
      isCore: isCore,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _repository.createButton(button);
    if (result.isOk) {
      await _refreshCurrentView();
      return result.valueOrNull;
    }
    _lastError = result.errorOrNull;
    notifyListeners();
    return null;
  }

  Future<void> updateButton(ButtonModel button) async {
    await _repository.updateButton(button);
    await _refreshCurrentView();
  }

  Future<void> deleteButton(String buttonId) async {
    // Look up the button first (while it's still in memory) so its custom
    // photo — if any — can be cleaned up from disk too, rather than left
    // behind as an orphaned file.
    ButtonModel? button;
    for (final b in [..._coreButtons, ..._categoryButtons]) {
      if (b.id == buttonId) {
        button = b;
        break;
      }
    }
    await _repository.deleteButton(buttonId);
    if (button?.imagePath != null) {
      await ImageStorageService().deleteIfExists(button!.imagePath);
    }
    await _refreshCurrentView();
  }

  /// Reorders buttons within whatever list is currently displayed
  /// (core or the selected category), preserving positions for the rest —
  /// this is the operation the drag-and-drop grid editor calls.
  Future<void> reorderWithinCurrentView(List<String> orderedButtonIds) async {
    for (var i = 0; i < orderedButtonIds.length; i++) {
      await _repository.moveButton(buttonId: orderedButtonIds[i], newSortOrder: i);
    }
    await _refreshCurrentView();
  }

  Future<List<ButtonModel>> searchAllButtons(String query) async {
    final profileId = _profileId;
    if (profileId == null) return [];
    final result = await _repository.searchButtons(profileId, query);
    return result.valueOrNull ?? [];
  }
}
