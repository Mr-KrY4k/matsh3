import 'board_position.dart';
import 'gem_type.dart';

enum MatchDirection { horizontal, vertical }

/// Представляет найденное совпадение на доске
class GemMatch {
  final GemType gemType;
  final List<BoardPosition> positions;
  final MatchDirection direction;

  GemMatch(this.gemType, this.positions, this.direction);

  int get length => positions.length;

  /// Позиция для создания специального камня (в центре совпадения)
  BoardPosition get specialGemPosition {
    return positions[positions.length ~/ 2];
  }

  @override
  String toString() =>
      'GemMatch($gemType, ${positions.length} gems, $direction)';
}
