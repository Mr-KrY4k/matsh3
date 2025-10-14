import 'dart:async';
import 'package:flutter/material.dart';
import 'package:match3/match3.dart';

import '../gen/assets.gen.dart';

/// Экран игры с UI оверлеем
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Игровая статистика для UI

  final int targetScore = 2000;
  final double timeLimit = 60;

  late final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  late final ValueNotifier<int> movesNotifier = ValueNotifier(0);
  late final ValueNotifier<int> comboNotifier = ValueNotifier(0);
  late final ValueNotifier<String> messageNotifier = ValueNotifier('');
  late final ValueNotifier<double> timeLeftNotifier = ValueNotifier(timeLimit);
  late final ValueNotifier<bool> isGameOverNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  void _endGame(bool isVictory) {
    if (isGameOverNotifier.value) return;

    setState(() {
      isGameOverNotifier.value = true;
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
                          ValueListenableBuilder(
                            valueListenable: scoreNotifier,
                            builder: (context, value, child) => Text(
                              '${scoreNotifier.value}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
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
                          ValueListenableBuilder(
                            valueListenable: movesNotifier,
                            builder: (context, value, child) => Text(
                              '$value',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
            if (messageNotifier.value.isNotEmpty)
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
                  messageNotifier.value,
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
                  timeLimit: timeLimit,
                  targetScore: targetScore,
                  theme: Match3Theme(
                    backgroundColor: Colors.white,
                    gemImages: {
                      GemType.red: Assets.svg.red.path,
                      GemType.blue: Assets.svg.blue.path,
                      GemType.green: Assets.svg.green.path,
                      GemType.yellow: Assets.svg.yellow.path,
                      GemType.purple: Assets.svg.purple.path,
                      GemType.orange: Assets.svg.orange.path,
                    },
                    specialGemImages: {
                      SpecialGemType.bomb: Assets.svg.bomb.path,
                      SpecialGemType.horizontal: Assets.svg.horizontal.path,
                      SpecialGemType.vertical: Assets.svg.vertical.path,
                    },
                  ),
                  onTimeChanged: (newTimeLeft) {
                    timeLeftNotifier.value = newTimeLeft;
                  },
                  onScoreChanged: (newScore) {
                    scoreNotifier.value = newScore;
                  },
                  onMovesChanged: (newMoves) {
                    movesNotifier.value = newMoves;
                  },
                  onComboChanged: (newCombo) {
                    comboNotifier.value = newCombo;
                  },
                  onMessage: (msg) {
                    messageNotifier.value = msg;
                  },
                  // Callback при перемешивании
                  onShuffle: () {
                    if (mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const AlertDialog(
                          title: Text('🔄 Нет ходов!'),
                          content: Text('Перемешиваем доску...'),
                        ),
                      );
                      // Автоматически закроем диалог через секунду
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted) Navigator.of(context).pop();
                      });
                    }
                  },
                  // Обработка окончания игры
                  onGameEnd: (finalScore, finalMoves, result) {
                    if (!isGameOverNotifier.value) {
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
    return ValueListenableBuilder(
      valueListenable: scoreNotifier,
      builder: (context, value, child) {
        final progress = (value / targetScore).clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Очки: $value / $targetScore',
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
      },
    );
  }

  Widget _buildTimer() {
    return ValueListenableBuilder(
      valueListenable: timeLeftNotifier,
      builder: (context, value, child) {
        final minutes = timeLeftNotifier.value.toInt() ~/ timeLimit;
        final seconds = timeLeftNotifier.value.toInt() % timeLimit.toInt();
        final color = timeLeftNotifier.value < 10 ? Colors.red : Colors.black;
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
      },
    );
  }

  Widget _buildStats() {
    return ValueListenableBuilder(
      valueListenable: comboNotifier,
      builder: (context, value, child) {
        return SizedBox(
          width: double.infinity,
          height: 40,
          child: Row(
            children: [
              if (value > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COMBO x$value 🔥',
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
      },
    );
  }
}
