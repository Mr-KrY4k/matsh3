import '../models/board_position.dart';
import '../models/special_gem_type.dart';

/// Вспомогательный класс для активации специальных камней
class SpecialGemActivator {
  /// Получить список позиций для взрыва специального камня
  static List<BoardPosition> getExplosionPositions(
    BoardPosition pos,
    SpecialGemType specialType,
    int rows,
    int columns,
  ) {
    final positions = <BoardPosition>[];

    switch (specialType) {
      case SpecialGemType.horizontal:
        // Взрываем всю горизонтальную линию
        for (int col = 0; col < columns; col++) {
          final targetPos = BoardPosition(pos.row, col);
          if (targetPos.isValid(rows, columns)) {
            positions.add(targetPos);
          }
        }
        break;

      case SpecialGemType.vertical:
        // Взрываем всю вертикальную линию
        for (int row = 0; row < rows; row++) {
          final targetPos = BoardPosition(row, pos.col);
          if (targetPos.isValid(rows, columns)) {
            positions.add(targetPos);
          }
        }
        break;

      case SpecialGemType.bomb:
        // Взрываем область 3x3
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final targetPos = BoardPosition(pos.row + dr, pos.col + dc);
            if (targetPos.isValid(rows, columns)) {
              positions.add(targetPos);
            }
          }
        }
        break;

      case SpecialGemType.none:
        break;
    }

    return positions;
  }
}
