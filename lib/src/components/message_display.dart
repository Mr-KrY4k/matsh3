import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Компонент для отображения временных сообщений
class MessageDisplay extends PositionComponent {
  String _message = '';
  bool _isVisible = false;
  final Vector2 gameSize;

  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 42,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 8),
        Shadow(color: Colors.black, offset: Offset(-2, -2), blurRadius: 4),
      ],
    ),
  );

  MessageDisplay({required this.gameSize})
    : super(position: Vector2.zero(), size: gameSize, priority: 1000);

  void showMessage(String message) {
    _message = message;
    _isVisible = true;
  }

  void hideMessage() {
    _isVisible = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!_isVisible) return;

    final centerX = gameSize.x / 2;
    final centerY = gameSize.y / 2;

    // Затемнение всего экрана
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(0, 0, gameSize.x, gameSize.y), overlayPaint);

    // Адаптивный размер карточки (не больше 90% ширины экрана)
    final cardWidth = (gameSize.x * 0.9).clamp(250.0, 400.0);
    final cardHeight = 150.0;

    // Карточка с сообщением
    final cardPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cardWidth,
        height: cardHeight,
      ),
      const Radius.circular(30),
    );
    canvas.drawRRect(rect, cardPaint);

    // Внешняя граница (яркая)
    final outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRRect(rect, outerBorderPaint);

    // Внутренняя граница для эффекта
    final innerBorderPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cardWidth - 15,
        height: cardHeight - 15,
      ),
      const Radius.circular(25),
    );
    canvas.drawRRect(innerRect, innerBorderPaint);

    // Вычисляем примерную ширину текста для центрирования
    final textWidth =
        _message.length * 23.0; // Примерная ширина для 42px шрифта

    // Текст точно по центру
    _textPaint.render(
      canvas,
      _message,
      Vector2(centerX - textWidth / 2, centerY - 22),
    );
  }
}
