class CellPosition {
  final int row;
  final int col;

  const CellPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ (col.hashCode * 31);

  @override
  String toString() => '($row, $col)';
}

class PlacedWord {
  final String word;
  final String category;
  final List<CellPosition> positions;
  bool found;
  int? colorIndex;

  PlacedWord({
    required this.word,
    required this.category,
    required this.positions,
    this.found = false,
    this.colorIndex,
  });
}
