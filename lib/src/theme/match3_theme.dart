import 'package:flutter/material.dart';
import '../models/gem_type.dart';
import '../models/special_gem_type.dart';

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
///   gemImages: {
///     GemType.red: 'assets/gems/red.png',    // Автоматически PNG
///     GemType.blue: 'assets/gems/blue.svg',  // Автоматически SVG
///     // Тип определяется по расширению
///   },
/// );
/// ```
class Match3Theme {
  /// Цвет фона игры
  final Color backgroundColor;

  /// Цвета для каждого типа камня (используется если нет изображений)
  final Map<GemType, Color> gemColors;

  /// Пути к изображениям для каждого типа камня (PNG или SVG)
  /// Тип определяется автоматически по расширению файла
  final Map<GemType, String> gemImages;

  /// Пути к изображениям для специальных камней (необязательно)
  /// Если не указано, будут рисоваться дефолтные иконки
  final Map<SpecialGemType, String> specialGemImages;

  /// Дефолтный цвет фона
  static const Color defaultBackgroundColor = Color(0xFF2C3E50);

  /// Дефолтные цвета камней
  static const Map<GemType, Color> defaultGemColors = {
    GemType.red: Color(0xFFE74C3C),
    GemType.blue: Color(0xFF3498DB),
    GemType.green: Color(0xFF2ECC71),
    GemType.yellow: Color(0xFFF39C12),
    GemType.purple: Color(0xFF9B59B6),
    GemType.orange: Color(0xFFF07720),
  };

  const Match3Theme({
    this.backgroundColor = defaultBackgroundColor,
    this.gemColors = defaultGemColors,
    this.gemImages = const {},
    this.specialGemImages = const {},
  });

  /// Получить цвет для типа камня
  Color getGemColor(GemType type) {
    return gemColors[type] ?? const Color(0xFFFFFFFF);
  }

  /// Получить путь к изображению для типа камня
  String? getGemImage(GemType type) {
    return gemImages[type];
  }

  /// Получить путь к изображению для специального камня
  String? getSpecialGemImage(SpecialGemType type) {
    return specialGemImages[type];
  }

  /// Определить тип изображения по расширению файла
  GemImageType getImageType(String? path) {
    if (path == null || path.isEmpty) return GemImageType.color;

    if (path.toLowerCase().endsWith('.svg')) {
      return GemImageType.svg;
    } else if (path.toLowerCase().endsWith('.png') ||
        path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg')) {
      return GemImageType.png;
    }

    return GemImageType.color;
  }
}
