import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gem_type.dart';
import '../models/board_position.dart';
import '../models/special_gem_type.dart';
import '../theme/match3_theme.dart';

/// Компонент драгоценного камня
class GemComponent extends PositionComponent {
  final GemType gemType;
  final BoardPosition boardPosition;
  final double gemSize;
  final Match3Theme theme;
  bool isSelected = false;
  bool isMatched = false;
  SpecialGemType specialType;

  static const double _specialIconSize =
      0.4; // Размер иконки специального камня

  // Кэш для загруженных изображений (статический - общий для всех компонентов)
  static final Map<String, ui.Image> _cachedImages = {};
  static final Map<String, Svg> _cachedSvgs = {};

  ui.Image? _loadedImage;
  Svg? _loadedSvg;
  bool _isLoading = false;

  GemComponent({
    required this.gemType,
    required this.boardPosition,
    required this.gemSize,
    required Vector2 position,
    required this.theme,
    this.specialType = SpecialGemType.none,
  }) : super(
         position: position,
         size: Vector2.all(gemSize),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Загружаем изображение если нужно
    if (theme.gemImageType != GemImageType.color) {
      await _loadImage();
    }
  }

  /// Загрузить изображение для камня
  Future<void> _loadImage() async {
    if (_isLoading) return;
    _isLoading = true;

    final imagePath = theme.getGemImage(gemType);
    if (imagePath == null || imagePath.isEmpty) {
      _isLoading = false;
      return;
    }

    try {
      if (theme.gemImageType == GemImageType.svg) {
        // Загружаем SVG
        if (_cachedSvgs.containsKey(imagePath)) {
          _loadedSvg = _cachedSvgs[imagePath];
        } else {
          final svgPath = imagePath.startsWith('assets/')
              ? imagePath.substring(7)
              : imagePath;
          final svg = await Svg.load(svgPath);
          _cachedSvgs[imagePath] = svg;
          _loadedSvg = svg;
        }
      } else if (theme.gemImageType == GemImageType.png) {
        // Загружаем PNG
        if (_cachedImages.containsKey(imagePath)) {
          _loadedImage = _cachedImages[imagePath];
        } else {
          final data = await rootBundle.load(imagePath);
          final bytes = data.buffer.asUint8List();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          _cachedImages[imagePath] = frame.image;
          _loadedImage = frame.image;
        }
      }
    } catch (e) {
      // Игнорируем ошибки - будет рисоваться цветной квадрат
      print('Не удалось загрузить изображение $imagePath: $e');
    }

    _isLoading = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;
    final gemPadding = gemSize * 0.03;
    final rect = Rect.fromCenter(
      center: Offset(center.x, center.y),
      width: gemSize - gemPadding * 2,
      height: gemSize - gemPadding * 2,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(gemSize * 0.15),
    );

    // Рисуем тень
    final shadowRect = rect.translate(2, 2);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, Radius.circular(gemSize * 0.15)),
      shadowPaint,
    );

    // Рисуем изображение или цветной квадрат
    if (theme.gemImageType == GemImageType.svg && _loadedSvg != null) {
      // Рисуем SVG
      canvas.save();
      canvas.translate(rect.left, rect.top);
      canvas.clipRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, rect.width, rect.height),
          Radius.circular(gemSize * 0.15),
        ),
      );
      _loadedSvg!.render(canvas, Vector2(rect.width, rect.height));
      canvas.restore();
    } else if (theme.gemImageType == GemImageType.png && _loadedImage != null) {
      // Рисуем PNG
      canvas.save();
      canvas.clipRRect(rrect);
      paintImage(
        canvas: canvas,
        rect: rect,
        image: _loadedImage!,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else {
      // Рисуем цветной квадрат (дефолт или если изображение не загрузилось)
      final gemColor = theme.getGemColor(gemType);
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gemColor, gemColor.withOpacity(0.7)],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rrect, paint);
    }

    // Затемнение при выделении
    if (isSelected) {
      final darkenPaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, darkenPaint);
    }

    // Рисуем иконку специального камня
    if (specialType != SpecialGemType.none) {
      _drawSpecialIcon(canvas, center);
    }
  }

  /// Рисует иконку специального камня
  void _drawSpecialIcon(Canvas canvas, Vector2 center) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final iconSize = gemSize * _specialIconSize;
    final centerOffset = Offset(center.x, center.y);

    switch (specialType) {
      case SpecialGemType.horizontal:
        // Горизонтальные стрелки ←→
        final arrowPath = Path();
        // Левая стрелка
        arrowPath.moveTo(center.x - iconSize * 0.4, center.y);
        arrowPath.lineTo(center.x - iconSize * 0.2, center.y - iconSize * 0.15);
        arrowPath.lineTo(center.x - iconSize * 0.2, center.y + iconSize * 0.15);
        arrowPath.close();
        // Правая стрелка
        arrowPath.moveTo(center.x + iconSize * 0.4, center.y);
        arrowPath.lineTo(center.x + iconSize * 0.2, center.y - iconSize * 0.15);
        arrowPath.lineTo(center.x + iconSize * 0.2, center.y + iconSize * 0.15);
        arrowPath.close();
        // Линия
        arrowPath.addRect(
          Rect.fromCenter(
            center: centerOffset,
            width: iconSize * 0.6,
            height: iconSize * 0.1,
          ),
        );
        canvas.drawPath(arrowPath, iconPaint);
        break;

      case SpecialGemType.vertical:
        // Вертикальные стрелки ↑↓
        final arrowPath = Path();
        // Верхняя стрелка
        arrowPath.moveTo(center.x, center.y - iconSize * 0.4);
        arrowPath.lineTo(center.x - iconSize * 0.15, center.y - iconSize * 0.2);
        arrowPath.lineTo(center.x + iconSize * 0.15, center.y - iconSize * 0.2);
        arrowPath.close();
        // Нижняя стрелка
        arrowPath.moveTo(center.x, center.y + iconSize * 0.4);
        arrowPath.lineTo(center.x - iconSize * 0.15, center.y + iconSize * 0.2);
        arrowPath.lineTo(center.x + iconSize * 0.15, center.y + iconSize * 0.2);
        arrowPath.close();
        // Линия
        arrowPath.addRect(
          Rect.fromCenter(
            center: centerOffset,
            width: iconSize * 0.1,
            height: iconSize * 0.6,
          ),
        );
        canvas.drawPath(arrowPath, iconPaint);
        break;

      case SpecialGemType.bomb:
        // Звезда взрыва
        final starPath = Path();
        final points = 8;
        for (int i = 0; i < points * 2; i++) {
          final angle = (i * math.pi) / points;
          final radius = i.isEven ? iconSize * 0.4 : iconSize * 0.2;
          final x = center.x + radius * math.cos(angle);
          final y = center.y + radius * math.sin(angle);
          if (i == 0) {
            starPath.moveTo(x, y);
          } else {
            starPath.lineTo(x, y);
          }
        }
        starPath.close();
        canvas.drawPath(starPath, iconPaint);
        break;

      case SpecialGemType.none:
        break;
    }
  }

  /// Анимация перемещения к новой позиции
  void moveTo(Vector2 newPosition, {double duration = 0.15}) {
    add(MoveEffect.to(newPosition, EffectController(duration: duration)));
  }

  /// Анимация исчезновения
  Future<void> disappear() async {
    isMatched = true;

    // Эффект масштабирования и исчезновения
    final effect = SequenceEffect([
      ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.08)),
      ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.12)),
    ]);
    add(effect);
    await effect.completed;
  }

  /// Анимация появления
  void appear() {
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.3, curve: Curves.elasticOut),
      ),
    );
  }

  /// Эффект дрожания при неверном свопе
  void shake() {
    add(
      SequenceEffect([
        MoveEffect.by(Vector2(5, 0), EffectController(duration: 0.05)),
        MoveEffect.by(Vector2(-10, 0), EffectController(duration: 0.1)),
        MoveEffect.by(Vector2(5, 0), EffectController(duration: 0.05)),
      ]),
    );
  }
}
