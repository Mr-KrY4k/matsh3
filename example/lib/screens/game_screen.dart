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
  // Игровая статистика для UI
  int score = 0;
  int moves = 0;
  int combo = 0;
  String message = '';
  double timeLeft = 60.0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
  }

  void _endGame(bool isVictory) {
    if (isGameOver) return;

    setState(() {
      isGameOver = true;
    });

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: SafeArea(
        child: Column(
          children: [
            // UI панель сверху
            Container(
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
                  // Кнопка домой и прогресс бар
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildScoreProgressBar()),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Таймер
                  _buildTimer(),
                  const SizedBox(height: 12),

                  // Ходы и комбо
                  _buildStats(),
                ],
              ),
            ),

            // Сообщение (если есть)
            if (message.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(20),
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

            // Игровое поле
            Expanded(
              child: Center(
                child: Match3GameWidget(
                  rows: widget.rows,
                  columns: widget.columns,
                  theme: const Match3Theme(backgroundColor: Colors.white),
                  onTimeChanged: (newTimeLeft) {
                    setState(() => timeLeft = newTimeLeft);
                  },
                  onScoreChanged: (newScore) {
                    setState(() => score = newScore);
                  },
                  onMovesChanged: (newMoves) {
                    setState(() => moves = newMoves);
                  },
                  onComboChanged: (newCombo) {
                    setState(() => combo = newCombo);
                  },
                  onMessage: (msg) {
                    setState(() => message = msg);
                  },
                  // Обработка окончания игры
                  onGameEnd: (finalScore, finalMoves, result) {
                    if (!isGameOver) {
                      _endGame(result == 'victory');
                    }
                  },
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
