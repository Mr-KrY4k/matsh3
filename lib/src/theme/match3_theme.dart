import 'package:flutter/material.dart';
import '../models/gem_type.dart';

/// Тип изображения камня
enum GemImageType {
  color, // Обычный цветной квадрат
  png, // PNG изображение
  svg, // SVG изображение
}

/// Тема для Match3 игры
///
/// Позволяет настроить цвет фона и внешний вид камней (цвета или изображения).
///
/// Пример с цветами:
/// ```dart
/// final theme = Match3Theme(
///   backgroundColor: Color(0xFF2C3E50),
///   gemColors: {
///     GemType.red: Color(0xFFE74C3C),
///     GemType.blue: Color(0xFF3498DB),
///     // ...
///   },
/// );
/// ```
///
/// Пример с изображениями:
/// ```dart
/// final theme = Match3Theme(
///   backgroundColor: Color(0xFF2C3E50),
///   gemImageType: GemImageType.png,
///   gemImages: {
///     GemType.red: 'assets/gems/red.png',
///     GemType.blue: 'assets/gems/blue.png',
///     // ...
///   },
/// );
/// ```
class Match3Theme {
  /// Цвет фона игры
  final Color backgroundColor;

  /// Тип изображения камней
  final GemImageType gemImageType;

  /// Цвета для каждого типа камня (используется если gemImageType = color)
  final Map<GemType, Color> gemColors;

  /// Пути к изображениям для каждого типа камня (используется если gemImageType = png/svg)
  final Map<GemType, String> gemImages;

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
    this.gemImageType = GemImageType.color,
    this.gemColors = defaultGemColors,
    this.gemImages = const {},
  });

  /// Получить цвет для типа камня
  Color getGemColor(GemType type) {
    return gemColors[type] ?? const Color(0xFFFFFFFF);
  }

  /// Получить путь к изображению для типа камня
  String? getGemImage(GemType type) {
    return gemImages[type];
  }
}
