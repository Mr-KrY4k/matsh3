import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/match3_game.dart';
import '../theme/match3_theme.dart';

/// Виджет для отображения Match3 игры
///
/// Создает игру внутри себя и настраивает все callbacks.
/// Использование:
/// ```dart
/// Match3GameWidget(
///   rows: 8,
///   columns: 8,
///   onScoreChanged: (score) => print('Score: $score'),
///   onMovesChanged: (moves) => print('Moves: $moves'),
/// )
/// ```
class Match3GameWidget extends StatefulWidget {
  /// Количество строк на игровом поле
  final int rows;

  /// Количество столбцов на игровом поле
  final int columns;

  /// Тема игры (цвета фона и камней)
  final Match3Theme theme;

  /// Лимит времени в секундах (null = бесконечная игра)
  final double? timeLimit;

  /// Целевой счет для победы (null = нет цели)
  final int? targetScore;

  /// Запускать таймер после первого хода (true) или сразу (false)
  final bool startTimerOnFirstMove;

  /// Callback при изменении времени (если задан лимит)
  final Function(double timeLeft)? onTimeChanged;

  /// Callback при изменении очков
  final Function(int score)? onScoreChanged;

  /// Callback при изменении количества ходов
  final Function(int moves)? onMovesChanged;

  /// Callback при изменении комбо
  final Function(int combo)? onComboChanged;

  /// Callback для системных сообщений
  final Function(String message)? onMessage;

  /// Callback при перемешивании доски (когда нет ходов)
  final Function()? onShuffle;

  /// Callback при окончании игры
  /// Параметры: score - финальный счет, moves - количество ходов, result - результат
  final Function(int score, int moves, String result)? onGameEnd;

  /// Callback при инициализации игры
  /// Передает ссылку на игру для возможности управления (например, вызова endGame)
  final Function(Match3Game game)? onGameReady;

  /// Callback при первом взаимодействии с игрой (первом успешном ходе)
  final Function()? onFirstMove;

  const Match3GameWidget({
    super.key,
    this.rows = 8,
    this.columns = 8,
    this.theme = const Match3Theme(),
    this.timeLimit,
    this.targetScore,
    this.startTimerOnFirstMove = false,
    this.onTimeChanged,
    this.onScoreChanged,
    this.onMovesChanged,
    this.onComboChanged,
    this.onMessage,
    this.onShuffle,
    this.onGameEnd,
    this.onGameReady,
    this.onFirstMove,
  });

  @override
  State<Match3GameWidget> createState() => _Match3GameWidgetState();
}

class _Match3GameWidgetState extends State<Match3GameWidget> {
  late Match3Game game;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    game = Match3Game(
      rows: widget.rows,
      columns: widget.columns,
      theme: widget.theme,
      timeLimit: widget.timeLimit,
      targetScore: widget.targetScore,
      startTimerOnFirstMove: widget.startTimerOnFirstMove,
    );

    // Настраиваем callbacks с отложенным вызовом
    game.onTimeChanged = (time) {
      Future.microtask(() => widget.onTimeChanged?.call(time));
    };

    game.onScoreChanged = (score) {
      Future.microtask(() {
        widget.onScoreChanged?.call(score);
        // Проверяем достижение целевого счета
        if (widget.targetScore != null && score >= widget.targetScore!) {
          game.endGame('victory');
        }
      });
    };

    game.onMovesChanged = (moves) {
      Future.microtask(() => widget.onMovesChanged?.call(moves));
    };

    game.onComboChanged = (combo) {
      Future.microtask(() => widget.onComboChanged?.call(combo));
    };

    game.onMessage = (message) {
      Future.microtask(() => widget.onMessage?.call(message));
    };

    game.onShuffle = () {
      Future.microtask(() => widget.onShuffle?.call());
    };

    game.onGameEnd = (score, moves, result) {
      Future.microtask(() => widget.onGameEnd?.call(score, moves, result));
    };

    game.onFirstMove = () {
      Future.microtask(() => widget.onFirstMove?.call());
    };

    // Уведомляем что игра готова
    widget.onGameReady?.call(game);
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
