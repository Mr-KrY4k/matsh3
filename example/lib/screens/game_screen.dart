import 'dart:async';
import 'package:flutter/material.dart';
import 'package:match3/match3.dart';
import 'game_over_screen.dart';

/// Экран игры с UI оверлеем
class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;

  const GameScreen({super.key, required this.rows, required this.columns});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Match3Game game;

  // Игровая статистика для UI
  int score = 0;
  int moves = 0;
  int combo = 0;
  String message = '';

  // Игровой таймер (60 секунд)
  double timeLeft = 60.0;
  Timer? gameTimer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    game = Match3Game(rows: widget.rows, columns: widget.columns);

    // Подписываемся на события игры
    game.onScoreChanged = (newScore) {
      setState(() {
        score = newScore;
      });
      // Проверка на победу
      if (score >= 1000 && !isGameOver) {
        _endGame(true);
      }
    };

    game.onMovesChanged = (newMoves) {
      setState(() {
        moves = newMoves;
      });
    };

    game.onComboChanged = (newCombo) {
      setState(() {
        combo = newCombo;
      });
    };

    game.onMessage = (msg) {
      setState(() {
        message = msg;
      });
    };

    // Запускаем игровой таймер
    _startGameTimer();
  }

  void _startGameTimer() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || isGameOver) {
        timer.cancel();
        return;
      }

      setState(() {
        timeLeft -= 0.1;
        if (timeLeft <= 0) {
          timeLeft = 0;
          _endGame(false);
        }
      });
    });
  }

  void _endGame(bool isVictory) {
    if (isGameOver) return;

    setState(() {
      isGameOver = true;
    });

    gameTimer?.cancel();

    // Показываем экран результатов
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameOverScreen(
              score: score,
              moves: moves,
              isVictory: isVictory,
              rows: widget.rows,
              columns: widget.columns,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: SafeArea(
        child: Stack(
          children: [
            // Игровое поле
            Match3GameWidget(game: game),

            // UI Overlay сверху
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Прогресс бар очков
                    _buildScoreProgressBar(),
                    const SizedBox(height: 12),

                    // Таймер
                    _buildTimer(),
                    const SizedBox(height: 12),

                    // Ходы и комбо
                    _buildStats(),
                  ],
                ),
              ),
            ),

            // Кнопка возврата в меню
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 28),
                ),
                onPressed: () {
                  gameTimer?.cancel();
                  Navigator.pop(context);
                },
              ),
            ),

            // Сообщения
            if (message.isNotEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreProgressBar() {
    final progress = (score / 1000).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Очки: $score / 1000',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress < 0.3
                  ? Colors.red
                  : progress < 0.7
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    final minutes = timeLeft.toInt() ~/ 60;
    final seconds = timeLeft.toInt() % 60;
    final color = timeLeft < 10 ? Colors.red : Colors.white;

    return Row(
      children: [
        Icon(Icons.timer, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$minutes:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Text(
          'Ходы: $moves',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (combo > 1) ...[
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'COMBO x$combo 🔥',
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
