import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Компонент прогресс-бара для очков
class ScoreProgressBar extends PositionComponent {
  int _score = 0;
  double _displayScore = 0; // Для плавной анимации
  static const int maxScore = 1000;
  final double barWidth = 200;
  final double barHeight = 18.0;

  final TextPaint _scorePaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
      ],
    ),
  );

  ScoreProgressBar({required Vector2 position})
    : super(position: position, size: Vector2(200 + 30, 30));

  void updateScore(int score) {
    _score = score;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Плавная анимация заполнения
    if (_displayScore < _score) {
      _displayScore += dt * 200; // Скорость анимации
      if (_displayScore > _score) {
        _displayScore = _score.toDouble();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_displayScore / maxScore).clamp(0.0, 1.0);
    final fillWidth = barWidth * progress;

    // Фон прогресс-бара с более темным цветом
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 6, barWidth, barHeight),
      const Radius.circular(9),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Заполнение прогресс-бара с анимированным градиентом
    if (progress > 0) {
      final gradient = LinearGradient(
        colors: [
          const Color(0xFFFFEB3B), // Яркий желтый
          const Color(0xFFFFD700), // Золотой
          const Color(0xFFFFA000), // Оранжево-золотой
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      final fillRect = Rect.fromLTWH(0, 6, fillWidth, barHeight);
      final fillPaint = Paint()
        ..shader = gradient.createShader(fillRect)
        ..style = PaintingStyle.fill;
      final fillRRect = RRect.fromRectAndRadius(
        fillRect,
        const Radius.circular(9),
      );
      canvas.drawRRect(fillRRect, fillPaint);

      // Световой эффект сверху для объема
      final lightRect = Rect.fromLTWH(0, 6, fillWidth, barHeight / 2);
      final lightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(lightRect)
        ..style = PaintingStyle.fill;
      final lightRRect = RRect.fromRectAndRadius(
        lightRect,
        const Radius.circular(9),
      );
      canvas.drawRRect(lightRRect, lightPaint);
    }

    // Граница прогресс-бара
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(backgroundRect, borderPaint);

    // Текст с очками в центре бара
    final scoreText = '${_score.toInt()} / $maxScore';
    _scorePaint.render(canvas, scoreText, Vector2(barWidth / 2 - 30, 9));

    // Монетка в конце
    _drawCoin(canvas, barWidth + 8, 15);
  }

  /// Рисует монетку
  void _drawCoin(Canvas canvas, double x, double y) {
    final center = Offset(x, y);
    final radius = 12.0;

    // Тень монетки
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(x + 1, y + 1), radius, shadowPaint);

    // Основной круг монеты с градиентом
    final gradient = RadialGradient(
      colors: [
        const Color(0xFFFFD700),
        const Color(0xFFFFAA00),
        const Color(0xFFFF8800),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    final coinPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, coinPaint);

    // Граница монеты
    final borderPaint = Paint()
      ..color = const Color(0xFFFFAA00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Внутренний круг (детали монеты)
    final innerBorderPaint = Paint()
      ..color = const Color(0xFFFFE55C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.7, innerBorderPaint);

    // Символ доллара или алмаза на монетке
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFF8800),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(canvas, '💎', Vector2(x - 7, y - 7));
  }
}
