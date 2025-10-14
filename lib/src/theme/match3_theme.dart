import 'package:flutter/material.dart';
import '../models/gem_type.dart';

/// Тема для Match3 игры
///
/// Позволяет настроить цвет фона и цвета для каждого типа камня.
///
/// Пример использования:
/// ```dart
/// final theme = Match3Theme(
///   backgroundColor: Color(0xFF2C3E50),
///   gemColors: {
///     GemType.red: Color(0xFFE74C3C),
///     GemType.blue: Color(0xFF3498DB),
///     GemType.green: Color(0xFF2ECC71),
///     GemType.yellow: Color(0xFFF39C12),
///     GemType.purple: Color(0xFF9B59B6),
///     GemType.pink: Color(0xFFFF4081),
///   },
/// );
/// ```
class Match3Theme {
  /// Цвет фона игры
  final Color backgroundColor;

  /// Цвета для каждого типа камня
  final Map<GemType, Color> gemColors;

  /// Дефолтный цвет фона
  static const Color defaultBackgroundColor = Color(0xFF2C3E50);

  /// Дефолтные цвета камней
  static const Map<GemType, Color> defaultGemColors = {
    GemType.red: Color(0xFFE74C3C),
    GemType.blue: Color(0xFF3498DB),
    GemType.green: Color(0xFF2ECC71),
    GemType.yellow: Color(0xFFF39C12),
    GemType.purple: Color(0xFF9B59B6),
    GemType.pink: Color(0xFFFF4081),
  };

  const Match3Theme({
    this.backgroundColor = defaultBackgroundColor,
    this.gemColors = defaultGemColors,
  });

  /// Получить цвет для типа камня
  Color getGemColor(GemType type) {
    return gemColors[type] ?? const Color(0xFFFFFFFF);
  }
}
