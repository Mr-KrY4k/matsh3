import 'dart:ui';

/// Типы драгоценных камней в игре
enum GemType {
  red,
  blue,
  green,
  yellow,
  purple,
  pink;

  /// Получить цвет для типа камня
  Color get color {
    switch (this) {
      case GemType.red:
        return const Color(0xFFE74C3C);
      case GemType.blue:
        return const Color(0xFF3498DB);
      case GemType.green:
        return const Color(0xFF2ECC71);
      case GemType.yellow:
        return const Color(0xFFF39C12);
      case GemType.purple:
        return const Color(0xFF9B59B6);
      case GemType.pink:
        return const Color(0xFFFF4081); // Розовый вместо оранжевого
    }
  }
}
