import 'dart:async';
import 'package:flutter/material.dart';
import 'package:match3/match3.dart';

/// Экран игры с UI оверлеем
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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

    // Показываем диалог с результатами
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(
              isVictory ? '🎉 Победа!' : '⏰ Время вышло',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isVictory ? Colors.green : Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVictory ? 'Вы набрали 1000 очков!' : 'Попробуйте еще раз',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '💎 Очки:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '$score',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🎯 Ходов:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '$moves',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрыть диалог
                  Navigator.of(context).pop(); // Вернуться в меню
                },
                child: const Text('В меню'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрыть диалог
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: const Text('Новая игра'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //прогресс бар
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildScoreProgressBar(),
                  const SizedBox(height: 12),
                  // Таймер
                  _buildTimer(),
                  const SizedBox(height: 12),
                  // комбо
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
                  rows: 7,
                  columns: 5,
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
            color: Colors.black,
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
            backgroundColor: Colors.black.withOpacity(0.2),
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
    final color = timeLeft < 10 ? Colors.red : Colors.black;

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
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        children: [
          if (combo > 1) ...[
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
      ),
    );
  }
}
