import 'dart:math';
import '../models/gem_type.dart';
import '../models/board_position.dart';
import '../models/match.dart' as gem_match;

/// Менеджер игрового поля
class BoardManager {
  final int rows;
  final int columns;
  late List<List<GemType?>> _board;
  final Random _random = Random();

  BoardManager({this.rows = 8, this.columns = 8}) {
    _board = List.generate(rows, (i) => List.generate(columns, (j) => null));
  }

  /// Получить камень на позиции
  GemType? getGem(BoardPosition pos) {
    if (!pos.isValid(rows, columns)) return null;
    return _board[pos.row][pos.col];
  }

  /// Установить камень на позицию
  void setGem(BoardPosition pos, GemType? gem) {
    if (!pos.isValid(rows, columns)) return;
    _board[pos.row][pos.col] = gem;
  }

  /// Обменять два камня местами
  void swapGems(BoardPosition pos1, BoardPosition pos2) {
    final temp = getGem(pos1);
    setGem(pos1, getGem(pos2));
    setGem(pos2, temp);
  }

  /// Инициализировать доску случайными камнями (без начальных совпадений)
  void initializeBoard() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        GemType gem;
        do {
          gem = _randomGemType();
        } while (_wouldCreateMatch(BoardPosition(row, col), gem));

        _board[row][col] = gem;
      }
    }
  }

  /// Проверить, создаст ли размещение камня совпадение
  bool _wouldCreateMatch(BoardPosition pos, GemType gem) {
    // Проверка горизонтали слева
    int leftCount = 0;
    for (int c = pos.col - 1; c >= 0; c--) {
      if (_board[pos.row][c] == gem) {
        leftCount++;
      } else {
        break;
      }
    }

    // Проверка вертикали сверху
    int upCount = 0;
    for (int r = pos.row - 1; r >= 0; r--) {
      if (_board[r][pos.col] == gem) {
        upCount++;
      } else {
        break;
      }
    }

    return leftCount >= 2 || upCount >= 2;
  }

  /// Получить случайный тип камня
  GemType _randomGemType() {
    return GemType.values[_random.nextInt(GemType.values.length)];
  }

  /// Найти все совпадения на доске
  List<gem_match.GemMatch> findMatches() {
    final List<gem_match.GemMatch> matches = [];
    final Set<BoardPosition> processedPositions = {};

    // Поиск горизонтальных совпадений
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns - 2; col++) {
        final gem = _board[row][col];
        if (gem == null) continue;

        final List<BoardPosition> matchPositions = [BoardPosition(row, col)];

        for (int c = col + 1; c < columns; c++) {
          if (_board[row][c] == gem) {
            matchPositions.add(BoardPosition(row, c));
          } else {
            break;
          }
        }

        if (matchPositions.length >= 3) {
          // Проверяем, что позиции еще не обработаны
          bool isNew = matchPositions.any(
            (pos) => !processedPositions.contains(pos),
          );
          if (isNew) {
            matches.add(
              gem_match.GemMatch(
                gem,
                matchPositions,
                gem_match.MatchDirection.horizontal,
              ),
            );
            processedPositions.addAll(matchPositions);
          }
        }
      }
    }

    // Поиск вертикальных совпадений
    for (int col = 0; col < columns; col++) {
      for (int row = 0; row < rows - 2; row++) {
        final gem = _board[row][col];
        if (gem == null) continue;

        final List<BoardPosition> matchPositions = [BoardPosition(row, col)];

        for (int r = row + 1; r < rows; r++) {
          if (_board[r][col] == gem) {
            matchPositions.add(BoardPosition(r, col));
          } else {
            break;
          }
        }

        if (matchPositions.length >= 3) {
          // Проверяем, что позиции еще не обработаны
          bool isNew = matchPositions.any(
            (pos) => !processedPositions.contains(pos),
          );
          if (isNew) {
            matches.add(
              gem_match.GemMatch(
                gem,
                matchPositions,
                gem_match.MatchDirection.vertical,
              ),
            );
            processedPositions.addAll(matchPositions);
          }
        }
      }
    }

    return matches;
  }

  /// Удалить совпадения с доски
  void removeMatches(List<gem_match.GemMatch> matches) {
    for (final match in matches) {
      for (final pos in match.positions) {
        setGem(pos, null);
      }
    }
  }

  /// Применить гравитацию - опустить камни вниз
  /// Возвращает Map с новыми позициями для каждого камня
  Map<BoardPosition, BoardPosition> applyGravity() {
    final Map<BoardPosition, BoardPosition> movements = {};

    for (int col = 0; col < columns; col++) {
      int emptyRow = rows - 1;

      // Идем снизу вверх
      for (int row = rows - 1; row >= 0; row--) {
        final gem = _board[row][col];
        if (gem != null) {
          if (row != emptyRow) {
            // Перемещаем камень вниз
            movements[BoardPosition(row, col)] = BoardPosition(emptyRow, col);
            _board[emptyRow][col] = gem;
            _board[row][col] = null;
          }
          emptyRow--;
        }
      }
    }

    return movements;
  }

  /// Заполнить пустые ячейки новыми камнями
  /// Возвращает список новых позиций
  List<BoardPosition> fillEmpty() {
    final List<BoardPosition> newPositions = [];

    for (int col = 0; col < columns; col++) {
      for (int row = 0; row < rows; row++) {
        if (_board[row][col] == null) {
          _board[row][col] = _randomGemType();
          newPositions.add(BoardPosition(row, col));
        }
      }
    }

    return newPositions;
  }

  /// Проверить, являются ли две позиции соседними
  bool areAdjacent(BoardPosition pos1, BoardPosition pos2) {
    final rowDiff = (pos1.row - pos2.row).abs();
    final colDiff = (pos1.col - pos2.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  /// Проверить, есть ли возможные ходы
  bool hasPossibleMoves() {
    // Проверяем все возможные свопы
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final gem = _board[row][col];
        if (gem == null) continue;

        final pos = BoardPosition(row, col);

        // Проверяем обмен вправо
        if (col < columns - 1) {
          final rightGem = _board[row][col + 1];
          if (rightGem != null) {
            final rightPos = BoardPosition(row, col + 1);
            swapGems(pos, rightPos);
            final hasMatch = findMatches().isNotEmpty;
            swapGems(pos, rightPos); // Возвращаем обратно
            if (hasMatch) return true;
          }
        }

        // Проверяем обмен вниз
        if (row < rows - 1) {
          final downGem = _board[row + 1][col];
          if (downGem != null) {
            final downPos = BoardPosition(row + 1, col);
            swapGems(pos, downPos);
            final hasMatch = findMatches().isNotEmpty;
            swapGems(pos, downPos); // Возвращаем обратно
            if (hasMatch) return true;
          }
        }
      }
    }

    return false;
  }

  /// Перемешать доску
  void shuffleBoard() {
    final allGems = <GemType>[];

    // Собираем все камни
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final gem = _board[row][col];
        if (gem != null) {
          allGems.add(gem);
        }
      }
    }

    // Перемешиваем
    allGems.shuffle(_random);

    // Размещаем обратно
    int index = 0;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (index < allGems.length) {
          _board[row][col] = allGems[index++];
        }
      }
    }
  }
}
