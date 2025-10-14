/// Позиция на игровом поле
class BoardPosition {
  final int row;
  final int col;

  const BoardPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'BoardPosition($row, $col)';

  /// Проверка валидности позиции
  bool isValid(int rows, int columns) {
    return row >= 0 && row < rows && col >= 0 && col < columns;
  }
}
