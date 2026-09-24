/// The fixed set of grid sizes a profile can choose from. Stored as
/// "columns x rows" so persistence is a single string like "5x4".
class GridSize {
  final int columns;
  final int rows;

  const GridSize(this.columns, this.rows);

  int get cellCount => columns * rows;

  String get storageKey => '${columns}x$rows';

  static GridSize fromStorageKey(String key) {
    final parts = key.split('x');
    if (parts.length != 2) return GridSizes.defaultSize;
    final cols = int.tryParse(parts[0]);
    final rows = int.tryParse(parts[1]);
    if (cols == null || rows == null) return GridSizes.defaultSize;
    return GridSize(cols, rows);
  }

  @override
  bool operator ==(Object other) =>
      other is GridSize && other.columns == columns && other.rows == rows;

  @override
  int get hashCode => Object.hash(columns, rows);

  @override
  String toString() => storageKey;
}

class GridSizes {
  GridSizes._();

  static const twoByTwo = GridSize(2, 2);
  static const threeByThree = GridSize(3, 3);
  static const fourByFour = GridSize(4, 4);
  static const fiveByFour = GridSize(5, 4);
  static const sixByFive = GridSize(6, 5);
  static const sevenBySix = GridSize(7, 6);

  static const List<GridSize> all = [
    twoByTwo,
    threeByThree,
    fourByFour,
    fiveByFour,
    sixByFive,
    sevenBySix,
  ];

  static const GridSize defaultSize = fourByFour;
}
