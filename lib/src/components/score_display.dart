import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Компонент отображения ходов и комбо
class ScoreDisplay extends PositionComponent {
  int _moves = 0;
  int _combo = 0;

  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
      ],
    ),
  );

  final TextPaint _comboPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFD700), // Золотой цвет
      fontSize: 26,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
      ],
    ),
  );

  ScoreDisplay({required Vector2 position}) : super(position: position);

  void updateMoves(int moves) {
    _moves = moves;
  }

  void updateCombo(int combo) {
    _combo = combo;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _textPaint.render(canvas, 'Ходы: $_moves', Vector2(0, 0));

    // Показываем комбо только если оно больше 1
    if (_combo > 1) {
      final comboMultiplier = (_combo).clamp(1, 5);
      _comboPaint.render(canvas, 'COMBO x$comboMultiplier 🔥', Vector2(0, 35));
    }
  }
}
