/// A grouping of fringe vocabulary (Food, Places, Feelings, ...). Core
/// vocabulary buttons typically have `categoryId == null` and instead stay
/// pinned on every board via [ButtonModel.isCore].
class CategoryModel {
  final String id;
  final String profileId;
  final String name;
  final String? iconKey;
  final String? colorHex;
  final int sortOrder;
  final bool isSystem;

  const CategoryModel({
    required this.id,
    required this.profileId,
    required this.name,
    this.iconKey,
    this.colorHex,
    this.sortOrder = 0,
    this.isSystem = false,
  });

  CategoryModel copyWith({
    String? name,
    String? iconKey,
    String? colorHex,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id,
      profileId: profileId,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem,
    );
  }

  Map<String, Object?> toDbMap() => {
        'id': id,
        'profile_id': profileId,
        'name': name,
        'icon_key': iconKey,
        'color_hex': colorHex,
        'sort_order': sortOrder,
        'is_system': isSystem ? 1 : 0,
      };

  factory CategoryModel.fromDbMap(Map<String, Object?> map) => CategoryModel(
        id: map['id'] as String,
        profileId: map['profile_id'] as String,
        name: map['name'] as String,
        iconKey: map['icon_key'] as String?,
        colorHex: map['color_hex'] as String?,
        sortOrder: map['sort_order'] as int? ?? 0,
        isSystem: (map['is_system'] as int? ?? 0) == 1,
      );

  Map<String, Object?> toBackupJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorHex': colorHex,
        'sortOrder': sortOrder,
        'isSystem': isSystem,
      };

  factory CategoryModel.fromBackupJson(Map<String, Object?> json, String profileId) =>
      CategoryModel(
        id: json['id'] as String,
        profileId: profileId,
        name: json['name'] as String,
        iconKey: json['iconKey'] as String?,
        colorHex: json['colorHex'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
        isSystem: json['isSystem'] as bool? ?? false,
      );
}
