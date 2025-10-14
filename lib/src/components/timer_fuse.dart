import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Компонент таймера в виде горящего фитиля
class TimerFuse extends PositionComponent {
  double _timeLeft = 60.0;
  static const double maxTime = 60.0;
  final double barWidth = 200;
  final double barHeight = 16.0;
  double _flameAnimation = 0;

  final TextPaint _timePaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
      ],
    ),
  );

  TimerFuse({required Vector2 position})
    : super(position: position, size: Vector2(200, 28));

  void updateTime(double timeLeft) {
    _timeLeft = timeLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _flameAnimation += dt * 10;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_timeLeft / maxTime).clamp(0.0, 1.0);
    final fillWidth = barWidth * progress;

    // Фон фитиля (темный)
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 6, barWidth, barHeight),
      const Radius.circular(8),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Заполнение фитиля с градиентом (от зеленого к красному)
    if (progress > 0) {
      Color startColor;
      Color endColor;

      if (progress > 0.5) {
        // Зеленый диапазон
        startColor = const Color(0xFF4CAF50);
        endColor = const Color(0xFF8BC34A);
      } else if (progress > 0.2) {
        // Желтый/оранжевый диапазон
        startColor = const Color(0xFFFF9800);
        endColor = const Color(0xFFFFEB3B);
      } else {
        // Красный диапазон (опасность!)
        startColor = const Color(0xFFFF1744);
        endColor = const Color(0xFFFF5252);
      }

      final gradient = LinearGradient(colors: [startColor, endColor]);
      final fillRect = Rect.fromLTWH(0, 6, fillWidth, barHeight);
      final fillPaint = Paint()
        ..shader = gradient.createShader(fillRect)
        ..style = PaintingStyle.fill;
      final fillRRect = RRect.fromRectAndRadius(
        fillRect,
        const Radius.circular(8),
      );
      canvas.drawRRect(fillRRect, fillPaint);

      // Анимированное пламя на конце фитиля
      if (progress < 1.0) {
        _drawFlame(canvas, fillWidth, 6 + barHeight / 2);
      }
    }

    // Граница
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(backgroundRect, borderPaint);

    // Текст со временем
    final minutes = _timeLeft.toInt() ~/ 60;
    final seconds = _timeLeft.toInt() % 60;
    final timeText = '⏱️ $minutes:${seconds.toString().padLeft(2, '0')}';
    _timePaint.render(canvas, timeText, Vector2(barWidth / 2 - 25, 9));
  }

  /// Рисует анимированное пламя
  void _drawFlame(Canvas canvas, double x, double y) {
    final flamePaint = Paint()..style = PaintingStyle.fill;

    // Три языка пламени разной высоты (анимация)
    for (int i = 0; i < 3; i++) {
      final offset = math.sin(_flameAnimation + i * 2) * 1.5;
      final height = 6.0 + offset;

      final flamePath = Path();
      flamePath.moveTo(x, y);
      flamePath.quadraticBezierTo(x - 3, y - height / 2, x, y - height);
      flamePath.quadraticBezierTo(x + 3, y - height / 2, x, y);

      // Градиент пламени
      final flameGradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFFF9800), // Оранжевый внизу
          const Color(0xFFFFEB3B), // Желтый вверху
        ],
      );
      flamePaint.shader = flameGradient.createShader(
        Rect.fromLTWH(x - 3, y - height, 6, height),
      );
      canvas.drawPath(flamePath, flamePaint);
    }

    // Яркое свечение пламени
    final glowPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(x, y - 3), 5, glowPaint);
  }
}
