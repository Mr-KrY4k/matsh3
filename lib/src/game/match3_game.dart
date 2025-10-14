import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/gem_component.dart';
import '../models/board_position.dart';
import '../models/gem_type.dart';
import '../models/match.dart' as gem_match;
import '../models/special_gem_type.dart';
import '../theme/match3_theme.dart';
import 'board_manager.dart';
import 'special_gem_activator.dart';

/// Основной класс игры Match-3
///
/// Предоставляет чистую игровую логику без встроенного UI.
/// Используйте callbacks для отслеживания событий игры.
class Match3Game extends FlameGame with TapCallbacks, DragCallbacks {
  final int rows;
  final int columns;
  final Match3Theme theme;
  final double? timeLimit; // Лимит времени (null = без лимита)
  final int? targetScore; // Целевой счет (null = без цели)

  static const double screenPadding = 20.0; // Отступы от краев экрана
  static const double swipeThreshold =
      20.0; // Минимальное расстояние для свайпа

  late BoardManager boardManager;
  late List<List<GemComponent?>> gemComponents;

  // Динамические размеры, вычисляемые в onLoad
  late double gemSize;
  late double offsetX;
  late double offsetY;

  BoardPosition? selectedPosition;
  bool isProcessing = false;

  // Игровая статистика
  int score = 0;
  int moves = 0;
  int combo = 0; // Счетчик комбо
  double comboResetTimer = 0; // Таймер для автоматического сброса комбо

  // Игровой таймер
  double? timeLeft; // null если нет лимита времени

  // Callbacks для событий игры
  Function(double timeLeft)? onTimeChanged;
  Function(int score)? onScoreChanged;
  Function(int moves)? onMovesChanged;
  Function(int combo)? onComboChanged;
  Function(String message)? onMessage;
  Function(int score, int moves, String result)? onGameEnd;

  // Для обработки свайпов
  Vector2? dragStartPosition;
  Vector2? dragCurrentPosition;
  BoardPosition? dragStartBoardPosition;

  /// Конструктор игры
  /// [rows] - количество строк
  /// [columns] - количество столбцов
  /// [theme] - тема игры
  /// [timeLimit] - лимит времени в секундах (null = без лимита)
  /// [targetScore] - целевой счет для победы (null = без цели)
  Match3Game({
    this.rows = 8,
    this.columns = 8,
    this.theme = const Match3Theme(),
    this.timeLimit,
    this.targetScore,
  }) {
    // Инициализируем таймер если задан лимит
    if (timeLimit != null) {
      timeLeft = timeLimit;
    }
  }

  @override
  Color backgroundColor() => theme.backgroundColor;

  @override
  void render(Canvas canvas) {
    // Сохраняем состояние канваса
    canvas.save();

    // Обрезаем область рисования - скрываем всё что за пределами поля
    final boardWidth = columns * gemSize;
    final boardHeight = rows * gemSize;
    final borderRect = Rect.fromLTWH(offsetX, offsetY, boardWidth, boardHeight);

    canvas.clipRRect(
      RRect.fromRectAndRadius(borderRect, const Radius.circular(8)),
    );

    // Рисуем всё внутри (камни отрисуются через super.render)
    super.render(canvas);

    // Восстанавливаем канвас
    canvas.restore();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Вычисляем оптимальный размер камня на основе размера экрана
    final availableWidth = size.x - screenPadding * 2;
    final availableHeight = size.y - screenPadding * 2;

    // Выбираем меньший размер, чтобы доска влезла
    final maxGemSizeByWidth = availableWidth / columns;
    final maxGemSizeByHeight = availableHeight / rows;
    gemSize = maxGemSizeByWidth < maxGemSizeByHeight
        ? maxGemSizeByWidth
        : maxGemSizeByHeight;

    // Вычисляем размер доски и центрируем её
    final boardPixelWidth = columns * gemSize;
    final boardPixelHeight = rows * gemSize;
    offsetX = (size.x - boardPixelWidth) / 2;
    offsetY = (size.y - boardPixelHeight) / 2;

    // Инициализация менеджера доски
    boardManager = BoardManager(rows: rows, columns: columns);
    boardManager.initializeBoard();

    // Создание компонентов камней
    gemComponents = List.generate(
      rows,
      (i) => List.generate(columns, (j) => null),
    );

    // Создаем компоненты для всех камней
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final pos = BoardPosition(row, col);
        final gemType = boardManager.getGem(pos);

        if (gemType != null) {
          final gemComponent = createGemComponent(gemType, pos);
          gemComponents[row][col] = gemComponent;
          await add(gemComponent);
        }
      }
    }

    // Проверяем наличие ходов после инициализации
    while (!boardManager.hasPossibleMoves()) {
      // Перемешиваем доску если нет ходов
      boardManager.shuffleBoard();

      // Обновляем компоненты
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          final gem = gemComponents[row][col];
          if (gem != null) {
            remove(gem);
          }
        }
      }

      // Создаем новые компоненты после перемешивания
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          final pos = BoardPosition(row, col);
          final gemType = boardManager.getGem(pos);

          if (gemType != null) {
            final gemComponent = createGemComponent(gemType, pos);
            gemComponents[row][col] = gemComponent;
            await add(gemComponent);
          }
        }
      }

      // Удаляем случайные совпадения если появились
      while (true) {
        final matches = boardManager.findMatches();
        if (matches.isEmpty) break;

        for (final match in matches) {
          for (final pos in match.positions) {
            boardManager.setGem(pos, null);
          }
        }
        boardManager.applyGravity();
        boardManager.fillEmpty();
      }

      // Обновляем компоненты после очистки совпадений
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          final gem = gemComponents[row][col];
          if (gem != null) {
            remove(gem);
          }
        }
      }

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          final pos = BoardPosition(row, col);
          final gemType = boardManager.getGem(pos);

          if (gemType != null) {
            final gemComponent = createGemComponent(gemType, pos);
            gemComponents[row][col] = gemComponent;
            await add(gemComponent);
          }
        }
      }
    }
  }

  /// Создать компонент камня
  GemComponent createGemComponent(
    GemType gemType,
    BoardPosition boardPos, [
    double? customOffsetX,
    double? customOffsetY,
  ]) {
    final ox = customOffsetX ?? offsetX;
    final oy = customOffsetY ?? offsetY;
    final x = ox + boardPos.col * gemSize + gemSize / 2;
    final y = oy + boardPos.row * gemSize + gemSize / 2;

    return GemComponent(
      gemType: gemType,
      boardPosition: boardPos,
      gemSize: gemSize,
      position: Vector2(x, y),
      theme: theme,
    );
  }

  /// Получить позицию на доске по координатам экрана
  BoardPosition? getPositionFromScreen(Vector2 screenPosition) {
    final localX = screenPosition.x - offsetX;
    final localY = screenPosition.y - offsetY;

    if (localX < 0 || localY < 0) return null;

    final col = (localX / gemSize).floor();
    final row = (localY / gemSize).floor();

    final pos = BoardPosition(row, col);
    return pos.isValid(rows, columns) ? pos : null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isProcessing) return;

    final position = getPositionFromScreen(event.localPosition);
    if (position == null) return;

    handleTap(position);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isProcessing) return;

    dragStartPosition = event.localPosition;
    dragCurrentPosition = event.localPosition;
    dragStartBoardPosition = getPositionFromScreen(event.localPosition);

    // Визуально выделяем начальный камень
    if (dragStartBoardPosition != null) {
      selectGem(dragStartBoardPosition!);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (dragCurrentPosition != null) {
      dragCurrentPosition = dragCurrentPosition! + event.localDelta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (isProcessing ||
        dragStartPosition == null ||
        dragCurrentPosition == null ||
        dragStartBoardPosition == null) {
      deselectGem();
      dragStartPosition = null;
      dragCurrentPosition = null;
      dragStartBoardPosition = null;
      return;
    }

    final delta = dragCurrentPosition! - dragStartPosition!;

    // Проверяем, достаточно ли длинный свайп
    if (delta.length < swipeThreshold) {
      deselectGem();
      dragStartPosition = null;
      dragCurrentPosition = null;
      dragStartBoardPosition = null;
      return;
    }

    // Определяем направление свайпа
    final absX = delta.x.abs();
    final absY = delta.y.abs();

    BoardPosition targetPosition;

    if (absX > absY) {
      // Горизонтальный свайп
      if (delta.x > 0) {
        // Вправо
        targetPosition = BoardPosition(
          dragStartBoardPosition!.row,
          dragStartBoardPosition!.col + 1,
        );
      } else {
        // Влево
        targetPosition = BoardPosition(
          dragStartBoardPosition!.row,
          dragStartBoardPosition!.col - 1,
        );
      }
    } else {
      // Вертикальный свайп
      if (delta.y > 0) {
        // Вниз
        targetPosition = BoardPosition(
          dragStartBoardPosition!.row + 1,
          dragStartBoardPosition!.col,
        );
      } else {
        // Вверх
        targetPosition = BoardPosition(
          dragStartBoardPosition!.row - 1,
          dragStartBoardPosition!.col,
        );
      }
    }

    // Проверяем валидность целевой позиции
    if (targetPosition.isValid(rows, columns)) {
      // Пытаемся обменять камни
      attemptSwap(dragStartBoardPosition!, targetPosition);
    } else {
      deselectGem();
    }

    dragStartPosition = null;
    dragCurrentPosition = null;
    dragStartBoardPosition = null;
  }

  /// Обработка нажатия на камень
  void handleTap(BoardPosition position) {
    if (selectedPosition == null) {
      // Первое нажатие - выделяем камень
      selectGem(position);
    } else {
      // Второе нажатие
      if (position == selectedPosition) {
        // Отменяем выделение
        deselectGem();
      } else if (boardManager.areAdjacent(selectedPosition!, position)) {
        // Пытаемся обменять камни
        attemptSwap(selectedPosition!, position);
      } else {
        // Выбираем новый камень
        deselectGem();
        selectGem(position);
      }
    }
  }

  /// Выделить камень
  void selectGem(BoardPosition position) {
    selectedPosition = position;
    final gem = gemComponents[position.row][position.col];
    if (gem != null) {
      gem.isSelected = true;
    }
  }

  /// Снять выделение
  void deselectGem() {
    if (selectedPosition != null) {
      final gem = gemComponents[selectedPosition!.row][selectedPosition!.col];
      if (gem != null) {
        gem.isSelected = false;
      }
      selectedPosition = null;
    }
  }

  /// Попытка обменять камни
  Future<void> attemptSwap(BoardPosition pos1, BoardPosition pos2) async {
    isProcessing = true;
    deselectGem();

    // Сбрасываем таймер и комбо перед новым ходом
    comboResetTimer = 0;
    combo = 0;
    onComboChanged?.call(combo);

    // Выполняем обмен
    await swapGems(pos1, pos2);

    // Проверяем совпадения
    final matches = boardManager.findMatches();

    if (matches.isEmpty) {
      // Нет совпадений - возвращаем обратно
      await swapGems(pos1, pos2);

      // Эффект дрожания
      gemComponents[pos1.row][pos1.col]?.shake();
      gemComponents[pos2.row][pos2.col]?.shake();

      isProcessing = false;
    } else {
      // Есть совпадения - засчитываем ход
      moves++;
      onMovesChanged?.call(moves);

      // Обрабатываем совпадения
      await processMatches();

      isProcessing = false;
    }
  }

  /// Обменять два камня
  Future<void> swapGems(BoardPosition pos1, BoardPosition pos2) async {
    final gem1 = gemComponents[pos1.row][pos1.col];
    final gem2 = gemComponents[pos2.row][pos2.col];

    if (gem1 == null || gem2 == null) return;

    // Обмен в массиве компонентов
    gemComponents[pos1.row][pos1.col] = gem2;
    gemComponents[pos2.row][pos2.col] = gem1;

    // Обмен на доске
    boardManager.swapGems(pos1, pos2);

    // Анимация перемещения
    final pos1Screen = gem1.position.clone();
    final pos2Screen = gem2.position.clone();

    gem1.moveTo(pos2Screen);
    gem2.moveTo(pos1Screen);

    // Ждем завершения анимации
    await Future.delayed(const Duration(milliseconds: 150));
  }

  /// Обработать совпадения
  Future<void> processMatches() async {
    // Сбрасываем таймер
    comboResetTimer = 0;

    while (true) {
      // Находим все совпадения
      final matches = boardManager.findMatches();
      if (matches.isEmpty) break;

      // Обновляем счет для каждой группы совпадений
      for (final match in matches) {
        combo++; // Увеличиваем комбо за каждую группу

        // Вычисляем множитель комбо (максимум x5)
        final comboMultiplier = (combo).clamp(1, 5);

        // Добавляем очки за эту группу
        score += match.length * 10 * comboMultiplier;
      }

      onComboChanged?.call(combo);
      onScoreChanged?.call(score);

      // Удаляем совпавшие камни и создаем специальные
      await removeMatches(matches);

      // Применяем гравитацию
      await applyGravity();

      // Заполняем пустые ячейки
      await fillEmptyCells();

      // Небольшая задержка перед следующей проверкой
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Запускаем таймер для автоматического сброса комбо через 1 секунду
    if (combo > 0) {
      comboResetTimer = 1.0;
    }

    // Проверяем, есть ли возможные ходы
    while (!boardManager.hasPossibleMoves()) {
      // Уведомляем о перемешивании
      onMessage?.call('Нет ходов! Перемешиваем...');
      await Future.delayed(const Duration(milliseconds: 1000));

      // Перемешиваем доску
      await shuffleBoard();

      // Проверяем снова после перемешивания
      // Если ходов все еще нет, цикл повторится
    }

    // Скрываем сообщение когда ходы найдены
    onMessage?.call('');
  }

  /// Собрать все позиции для взрыва с учетом цепных реакций
  Set<BoardPosition> _collectExplosionPositions(
    BoardPosition pos,
    SpecialGemType specialType,
    Set<BoardPosition> alreadyProcessed,
  ) {
    final positions = <BoardPosition>{};

    // Если уже обработали эту позицию - пропускаем
    if (alreadyProcessed.contains(pos)) {
      return positions;
    }

    alreadyProcessed.add(pos);

    // Получаем позиции взрыва для текущего специального камня
    final explosionPositions = SpecialGemActivator.getExplosionPositions(
      pos,
      specialType,
      rows,
      columns,
    );

    positions.addAll(explosionPositions);

    // Проверяем каждую позицию на наличие других специальных камней
    for (final explosionPos in explosionPositions) {
      final gem = gemComponents[explosionPos.row][explosionPos.col];
      if (gem != null &&
          gem.specialType != SpecialGemType.none &&
          !alreadyProcessed.contains(explosionPos)) {
        // Рекурсивно собираем позиции от этого специального камня
        final chainPositions = _collectExplosionPositions(
          explosionPos,
          gem.specialType,
          alreadyProcessed,
        );
        positions.addAll(chainPositions);
      }
    }

    return positions;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Обновляем игровой таймер (если есть лимит)
    if (timeLeft != null && !isProcessing) {
      timeLeft = timeLeft! - dt;
      onTimeChanged?.call(timeLeft!);

      if (timeLeft! <= 0) {
        timeLeft = 0;
        endGame('timeout'); // Время вышло
      }
    }

    // Обновляем таймер сброса комбо
    if (comboResetTimer > 0) {
      comboResetTimer -= dt;
      if (comboResetTimer <= 0) {
        comboResetTimer = 0;
        combo = 0;
        onComboChanged?.call(combo);
      }
    }
  }

  /// Завершить игру с результатом
  ///
  /// Параметры:
  /// - [result] - результат игры (например: "victory", "defeat", "timeout", и т.д.)
  ///
  /// Вызовет callback `onGameEnd` с текущими очками, ходами и результатом
  void endGame(String result) {
    isProcessing = true; // Блокируем дальнейшие действия
    onGameEnd?.call(score, moves, result);
  }

  /// Удалить совпавшие камни и создать специальные при необходимости
  Future<void> removeMatches(List<gem_match.GemMatch> matches) async {
    final allPositionsToRemove = <BoardPosition>{};
    final specialGemsToTransform = <MapEntry<GemComponent, SpecialGemType>>[];
    final alreadyProcessed = <BoardPosition>{};

    for (final match in matches) {
      // Проверяем, есть ли уже специальный камень в этом совпадении
      BoardPosition? existingSpecialPos;
      SpecialGemType? existingSpecialType;

      for (final pos in match.positions) {
        final gem = gemComponents[pos.row][pos.col];
        if (gem != null && gem.specialType != SpecialGemType.none) {
          existingSpecialPos = pos;
          existingSpecialType = gem.specialType;
          break;
        }
      }

      // Если есть специальный камень в совпадении - собираем ВСЕ позиции с цепной реакцией
      if (existingSpecialPos != null && existingSpecialType != null) {
        final beforeCount = alreadyProcessed.length;

        // Рекурсивно собираем все позиции (включая цепные специальные камни)
        final explosionPositions = _collectExplosionPositions(
          existingSpecialPos,
          existingSpecialType,
          alreadyProcessed,
        );
        allPositionsToRemove.addAll(explosionPositions);

        // Увеличиваем комбо за каждый активированный специальный камень
        final activatedCount = alreadyProcessed.length - beforeCount;
        combo += activatedCount;
        onComboChanged?.call(combo);
      }

      // Добавляем позиции из обычного совпадения
      for (final pos in match.positions) {
        allPositionsToRemove.add(pos);
      }
    }

    // ОДНОВРЕМЕННО удаляем ВСЕ камни (обычные + все цепные специальные)
    final futures = <Future>[];
    final gemsToRemove = <GemComponent>[];

    for (final pos in allPositionsToRemove) {
      final gem = gemComponents[pos.row][pos.col];
      if (gem != null) {
        // Проверяем, нужно ли создать специальный камень на этой позиции
        bool shouldTransform = false;
        SpecialGemType? transformType;

        // Проверяем все совпадения без специальных камней
        for (final match in matches) {
          // Пропускаем совпадения где уже есть специальный камень
          bool hasSpecial = false;
          for (final p in match.positions) {
            final g = gemComponents[p.row][p.col];
            if (g != null && g.specialType != SpecialGemType.none) {
              hasSpecial = true;
              break;
            }
          }

          if (!hasSpecial &&
              match.positions.contains(pos) &&
              match.length >= 4) {
            final specialGemPos = match.specialGemPosition;
            if (specialGemPos == pos) {
              shouldTransform = true;
              if (match.length >= 5) {
                transformType = SpecialGemType.bomb;
              } else {
                transformType =
                    match.direction == gem_match.MatchDirection.horizontal
                    ? SpecialGemType.horizontal
                    : SpecialGemType.vertical;
              }
              break;
            }
          }
        }

        futures.add(gem.disappear());

        if (shouldTransform && transformType != null) {
          specialGemsToTransform.add(MapEntry(gem, transformType));
        } else {
          gemsToRemove.add(gem);
          gemComponents[pos.row][pos.col] = null;
        }

        // Обновляем доску
        if (!shouldTransform) {
          boardManager.setGem(pos, null);
        }
      }
    }

    // Ждем завершения ВСЕХ анимаций одновременно
    await Future.wait(futures);

    // Удаляем компоненты
    for (final gem in gemsToRemove) {
      remove(gem);
    }

    // Преобразуем камни в специальные
    for (final entry in specialGemsToTransform) {
      entry.key.specialType = entry.value;
      entry.key.appear();
    }

    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Применить гравитацию
  Future<void> applyGravity() async {
    final movements = boardManager.applyGravity();

    for (final entry in movements.entries) {
      final from = entry.key;
      final to = entry.value;

      final gem = gemComponents[from.row][from.col];
      if (gem == null) continue;

      gemComponents[from.row][from.col] = null;
      gemComponents[to.row][to.col] = gem;

      // Вычисляем новую позицию на экране
      final newScreenPos = Vector2(
        offsetX + to.col * gemSize + gemSize / 2,
        offsetY + to.row * gemSize + gemSize / 2,
      );

      gem.moveTo(newScreenPos);
    }

    if (movements.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  /// Заполнить пустые ячейки
  Future<void> fillEmptyCells() async {
    final newPositions = boardManager.fillEmpty();

    // Группируем позиции по столбцам
    final columnGroups = <int, List<BoardPosition>>{};
    for (final pos in newPositions) {
      columnGroups.putIfAbsent(pos.col, () => []).add(pos);
    }

    // Запускаем падение для каждого столбца параллельно
    final futures = <Future>[];

    for (final col in columnGroups.keys) {
      final positions = columnGroups[col]!;
      // Сортируем по строкам (сверху вниз)
      positions.sort((a, b) => a.row.compareTo(b.row));

      // Создаем асинхронную функцию для каждого столбца
      futures.add(() async {
        for (int i = 0; i < positions.length; i++) {
          final pos = positions[i];
          final gemType = boardManager.getGem(pos);
          if (gemType == null) continue;

          // Создаем камень выше доски
          final startY = offsetY - gemSize;
          final gemComponent = GemComponent(
            gemType: gemType,
            boardPosition: pos,
            gemSize: gemSize,
            position: Vector2(
              offsetX + pos.col * gemSize + gemSize / 2,
              startY,
            ),
            theme: theme,
          );

          gemComponents[pos.row][pos.col] = gemComponent;
          await add(gemComponent);

          // Анимация падения
          final targetY = offsetY + pos.row * gemSize + gemSize / 2;
          gemComponent.moveTo(Vector2(gemComponent.position.x, targetY));
          gemComponent.appear();

          // Задержка перед следующим камнем в этом столбце (только если не последний)
          if (i < positions.length - 1) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
      }());
    }

    // Ждем завершения всех столбцов
    await Future.wait(futures);

    if (newPositions.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  /// Перемешать доску
  Future<void> shuffleBoard() async {
    // Удаляем все текущие компоненты
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final gem = gemComponents[row][col];
        if (gem != null) {
          remove(gem);
          gemComponents[row][col] = null;
        }
      }
    }

    // Перемешиваем доску
    boardManager.shuffleBoard();

    await Future.delayed(const Duration(milliseconds: 300));

    // Создаем новые компоненты
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final pos = BoardPosition(row, col);
        final gemType = boardManager.getGem(pos);

        if (gemType != null) {
          final gemComponent = createGemComponent(gemType, pos);
          gemComponent.appear();
          gemComponents[row][col] = gemComponent;
          await add(gemComponent);
        }
      }
    }

    // Проверяем и удаляем случайные совпадения после перемешивания
    await Future.delayed(const Duration(milliseconds: 500));

    while (true) {
      final matches = boardManager.findMatches();
      if (matches.isEmpty) break;

      // Удаляем случайные совпадения (без начисления очков)
      await removeMatchesWithoutScore(matches);
      await applyGravity();
      await fillEmptyCells();
    }
  }

  /// Удалить совпадения без начисления очков (для перемешивания)
  Future<void> removeMatchesWithoutScore(
    List<gem_match.GemMatch> matches,
  ) async {
    final futures = <Future>[];
    final gemsToRemove = <GemComponent>[];

    for (final match in matches) {
      for (final BoardPosition pos in match.positions) {
        final gem = gemComponents[pos.row][pos.col];
        if (gem != null) {
          futures.add(gem.disappear());
          gemsToRemove.add(gem);
          gemComponents[pos.row][pos.col] = null;
        }
      }
    }

    // Ждем завершения всех анимаций исчезновения параллельно
    await Future.wait(futures);

    // Удаляем компоненты
    for (final gem in gemsToRemove) {
      remove(gem);
    }

    // Обновляем доску
    boardManager.removeMatches(matches);

    await Future.delayed(const Duration(milliseconds: 200));
  }
}
