import '../../../core/constants/grid_sizes.dart';

/// A single AAC user's full configuration. Everything that should differ
/// between two people sharing one device lives here rather than in a global
/// settings table.
class ProfileModel {
  final String id;
  final String name;
  final String? avatarPath;
  final String localeCode;
  final GridSize gridSize;
  final double buttonSizeScale;
  final double buttonSpacingScale;
  final double fontScale;
  final bool highContrast;
  final bool reducedAnimation;
  final String? ttsVoiceId;
  final double ttsRate;
  final double ttsPitch;
  final double ttsVolume;
  final bool editingLocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;

  const ProfileModel({
    required this.id,
    required this.name,
    this.avatarPath,
    this.localeCode = 'en',
    this.gridSize = GridSizes.defaultSize,
    this.buttonSizeScale = 1.0,
    this.buttonSpacingScale = 1.0,
    this.fontScale = 1.0,
    this.highContrast = false,
    this.reducedAnimation = false,
    this.ttsVoiceId,
    this.ttsRate = 0.5,
    this.ttsPitch = 1.0,
    this.ttsVolume = 1.0,
    this.editingLocked = false,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
  });

  ProfileModel copyWith({
    String? name,
    String? avatarPath,
    bool clearAvatar = false,
    String? localeCode,
    GridSize? gridSize,
    double? buttonSizeScale,
    double? buttonSpacingScale,
    double? fontScale,
    bool? highContrast,
    bool? reducedAnimation,
    String? ttsVoiceId,
    double? ttsRate,
    double? ttsPitch,
    double? ttsVolume,
    bool? editingLocked,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      localeCode: localeCode ?? this.localeCode,
      gridSize: gridSize ?? this.gridSize,
      buttonSizeScale: buttonSizeScale ?? this.buttonSizeScale,
      buttonSpacingScale: buttonSpacingScale ?? this.buttonSpacingScale,
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
      reducedAnimation: reducedAnimation ?? this.reducedAnimation,
      ttsVoiceId: ttsVoiceId ?? this.ttsVoiceId,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      editingLocked: editingLocked ?? this.editingLocked,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, Object?> toDbMap() => {
        'id': id,
        'name': name,
        'avatar_path': avatarPath,
        'locale_code': localeCode,
        'grid_size': gridSize.storageKey,
        'button_size_scale': buttonSizeScale,
        'button_spacing_scale': buttonSpacingScale,
        'font_scale': fontScale,
        'high_contrast': highContrast ? 1 : 0,
        'reduced_animation': reducedAnimation ? 1 : 0,
        'tts_voice_id': ttsVoiceId,
        'tts_rate': ttsRate,
        'tts_pitch': ttsPitch,
        'tts_volume': ttsVolume,
        'editing_locked': editingLocked ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'sort_order': sortOrder,
      };

  factory ProfileModel.fromDbMap(Map<String, Object?> map) => ProfileModel(
        id: map['id'] as String,
        name: map['name'] as String,
        avatarPath: map['avatar_path'] as String?,
        localeCode: map['locale_code'] as String? ?? 'en',
        gridSize: GridSize.fromStorageKey(map['grid_size'] as String? ?? '4x4'),
        buttonSizeScale: (map['button_size_scale'] as num?)?.toDouble() ?? 1.0,
        buttonSpacingScale: (map['button_spacing_scale'] as num?)?.toDouble() ?? 1.0,
        fontScale: (map['font_scale'] as num?)?.toDouble() ?? 1.0,
        highContrast: (map['high_contrast'] as int? ?? 0) == 1,
        reducedAnimation: (map['reduced_animation'] as int? ?? 0) == 1,
        ttsVoiceId: map['tts_voice_id'] as String?,
        ttsRate: (map['tts_rate'] as num?)?.toDouble() ?? 0.5,
        ttsPitch: (map['tts_pitch'] as num?)?.toDouble() ?? 1.0,
        ttsVolume: (map['tts_volume'] as num?)?.toDouble() ?? 1.0,
        editingLocked: (map['editing_locked'] as int? ?? 0) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
        sortOrder: map['sort_order'] as int? ?? 0,
      );

  /// JSON shape used by the backup/export format. Kept separate from the DB
  /// map so we can evolve the on-disk backup schema independently of SQLite
  /// column names.
  Map<String, Object?> toBackupJson() => {
        'id': id,
        'name': name,
        'localeCode': localeCode,
        'gridSize': gridSize.storageKey,
        'buttonSizeScale': buttonSizeScale,
        'buttonSpacingScale': buttonSpacingScale,
        'fontScale': fontScale,
        'highContrast': highContrast,
        'reducedAnimation': reducedAnimation,
        'ttsVoiceId': ttsVoiceId,
        'ttsRate': ttsRate,
        'ttsPitch': ttsPitch,
        'ttsVolume': ttsVolume,
      };
}
