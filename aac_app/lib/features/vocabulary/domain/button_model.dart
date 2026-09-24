/// A single AAC communication button. This is the core unit of the app —
/// everything on the board, in a category, or found via text-mode word
/// prediction is ultimately a [ButtonModel].
class ButtonModel {
  final String id;
  final String profileId;
  final String? categoryId;
  final String label;
  final String? spokenPhrase;
  final String? pronunciationOverride;
  final String? iconKey;
  final String? imagePath;
  final String? backgroundColorHex;
  final int? gridPosition;
  final int sortOrder;
  final bool isCore;
  final bool isFolder;
  final String? folderTargetCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ButtonModel({
    required this.id,
    required this.profileId,
    this.categoryId,
    required this.label,
    this.spokenPhrase,
    this.pronunciationOverride,
    this.iconKey,
    this.imagePath,
    this.backgroundColorHex,
    this.gridPosition,
    this.sortOrder = 0,
    this.isCore = false,
    this.isFolder = false,
    this.folderTargetCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// What TTS should actually say. Falls back to the visible label when no
  /// spoken-phrase override or custom pronunciation was set.
  String get speechText {
    if (pronunciationOverride != null && pronunciationOverride!.trim().isNotEmpty) {
      return pronunciationOverride!;
    }
    if (spokenPhrase != null && spokenPhrase!.trim().isNotEmpty) {
      return spokenPhrase!;
    }
    return label;
  }

  ButtonModel copyWith({
    String? categoryId,
    bool clearCategory = false,
    String? label,
    String? spokenPhrase,
    bool clearSpokenPhrase = false,
    String? pronunciationOverride,
    bool clearPronunciationOverride = false,
    String? iconKey,
    bool clearIconKey = false,
    String? imagePath,
    bool clearImage = false,
    String? backgroundColorHex,
    bool clearBackgroundColor = false,
    int? gridPosition,
    bool clearGridPosition = false,
    int? sortOrder,
    bool? isCore,
    bool? isFolder,
    String? folderTargetCategoryId,
    DateTime? updatedAt,
  }) {
    return ButtonModel(
      id: id,
      profileId: profileId,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      label: label ?? this.label,
      spokenPhrase: clearSpokenPhrase ? null : (spokenPhrase ?? this.spokenPhrase),
      pronunciationOverride: clearPronunciationOverride
          ? null
          : (pronunciationOverride ?? this.pronunciationOverride),
      iconKey: clearIconKey ? null : (iconKey ?? this.iconKey),
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      backgroundColorHex: clearBackgroundColor ? null : (backgroundColorHex ?? this.backgroundColorHex),
      gridPosition: clearGridPosition ? null : (gridPosition ?? this.gridPosition),
      sortOrder: sortOrder ?? this.sortOrder,
      isCore: isCore ?? this.isCore,
      isFolder: isFolder ?? this.isFolder,
      folderTargetCategoryId: folderTargetCategoryId ?? this.folderTargetCategoryId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, Object?> toDbMap() => {
        'id': id,
        'profile_id': profileId,
        'category_id': categoryId,
        'label': label,
        'spoken_phrase': spokenPhrase,
        'pronunciation_override': pronunciationOverride,
        'icon_key': iconKey,
        'image_path': imagePath,
        'background_color_hex': backgroundColorHex,
        'grid_position': gridPosition,
        'sort_order': sortOrder,
        'is_core': isCore ? 1 : 0,
        'is_folder': isFolder ? 1 : 0,
        'folder_target_category_id': folderTargetCategoryId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory ButtonModel.fromDbMap(Map<String, Object?> map) => ButtonModel(
        id: map['id'] as String,
        profileId: map['profile_id'] as String,
        categoryId: map['category_id'] as String?,
        label: map['label'] as String,
        spokenPhrase: map['spoken_phrase'] as String?,
        pronunciationOverride: map['pronunciation_override'] as String?,
        iconKey: map['icon_key'] as String?,
        imagePath: map['image_path'] as String?,
        backgroundColorHex: map['background_color_hex'] as String?,
        gridPosition: map['grid_position'] as int?,
        sortOrder: map['sort_order'] as int? ?? 0,
        isCore: (map['is_core'] as int? ?? 0) == 1,
        isFolder: (map['is_folder'] as int? ?? 0) == 1,
        folderTargetCategoryId: map['folder_target_category_id'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      );

  Map<String, Object?> toBackupJson() => {
        'id': id,
        'categoryId': categoryId,
        'label': label,
        'spokenPhrase': spokenPhrase,
        'pronunciationOverride': pronunciationOverride,
        'iconKey': iconKey,
        // Note: imagePath is intentionally NOT included as an absolute path;
        // BackupService handles copying the actual image bytes into the
        // archive and rewrites this field on import. See backup_service.dart.
        'hasCustomImage': imagePath != null,
        'backgroundColorHex': backgroundColorHex,
        'gridPosition': gridPosition,
        'sortOrder': sortOrder,
        'isCore': isCore,
        'isFolder': isFolder,
        'folderTargetCategoryId': folderTargetCategoryId,
      };
}
