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
  ui.Image? _loadedSpecialImage;
  Svg? _loadedSpecialSvg;
  bool _isLoading = false;

  // Кэш для часто используемых объектов рендеринга
  Paint? _shadowPaint;
  Paint? _darkenPaint;
  Paint? _gradientPaint;
  Rect? _cachedRect;
  RRect? _cachedRRect;
  RRect? _cachedShadowRRect;

  // Кэш для размеров изображений
  static const double _imageScale = 0.7;
  double? _cachedImageSize;
  double? _cachedImageOffset;
  Rect? _cachedImageRect;

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

    // Загружаем изображение если указан путь
    final imagePath = theme.getGemImage(gemType);
    if (imagePath != null && imagePath.isNotEmpty) {
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

    // Определяем тип автоматически по расширению
    final imageType = theme.getImageType(imagePath);

    try {
      if (imageType == GemImageType.svg) {
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
      } else if (imageType == GemImageType.png) {
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
      print('ОШИБКА загрузки изображения $imagePath: $e');
    }

    _isLoading = false;
  }

  /// Загрузить изображение для специального камня
  Future<void> _loadSpecialImage() async {
    if (specialType == SpecialGemType.none) return;

    final imagePath = theme.getSpecialGemImage(specialType);
    if (imagePath == null || imagePath.isEmpty) return;

    // Определяем тип автоматически по расширению
    final imageType = theme.getImageType(imagePath);

    try {
      if (imageType == GemImageType.svg) {
        // Загружаем SVG
        if (_cachedSvgs.containsKey(imagePath)) {
          _loadedSpecialSvg = _cachedSvgs[imagePath];
        } else {
          final svgPath = imagePath.startsWith('assets/')
              ? imagePath.substring(7)
              : imagePath;
          final svg = await Svg.load(svgPath);
          _cachedSvgs[imagePath] = svg;
          _loadedSpecialSvg = svg;
        }
      } else if (imageType == GemImageType.png) {
        // Загружаем PNG
        if (_cachedImages.containsKey(imagePath)) {
          _loadedSpecialImage = _cachedImages[imagePath];
        } else {
          final data = await rootBundle.load(imagePath);
          final bytes = data.buffer.asUint8List();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          _cachedImages[imagePath] = frame.image;
          _loadedSpecialImage = frame.image;
        }
      }
    } catch (e) {
      print(
        'Не удалось загрузить изображение специального камня $imagePath: $e',
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;
    final gemPadding = gemSize * 0.03;

    // Кэшируем rect и rrect если еще не созданы
    _cachedRect ??= Rect.fromCenter(
      center: Offset(center.x, center.y),
      width: gemSize - gemPadding * 2,
      height: gemSize - gemPadding * 2,
    );
    final rect = _cachedRect!;

    _cachedRRect ??= RRect.fromRectAndRadius(
      rect,
      Radius.circular(gemSize * 0.15),
    );
    final rrect = _cachedRRect!;

    // Рисуем тень (кэшируем Paint)
    final shadowRect = rect.translate(2, 2);
    _shadowPaint ??= Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    _cachedShadowRRect ??= RRect.fromRectAndRadius(
      shadowRect,
      Radius.circular(gemSize * 0.15),
    );
    canvas.drawRRect(_cachedShadowRRect!, _shadowPaint!);

    // Сначала ВСЕГДА рисуем цветной квадрат (как фон)
    // Кэшируем градиент и Paint
    if (_gradientPaint == null) {
      final gemColor = theme.getGemColor(gemType);
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gemColor, gemColor.withOpacity(0.7)],
      );
      _gradientPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;
    }

    canvas.drawRRect(rrect, _gradientPaint!);

    // Потом рисуем изображение ПОВЕРХ (если есть)
    // НО: для специальных камней рисуем только специальную иконку
    if (specialType == SpecialGemType.none) {
      // Обычный камень - рисуем его изображение (если есть)
      if (_loadedSvg != null) {
        // Рисуем SVG (кэшируем размеры)
        _cachedImageSize ??= rect.width * _imageScale;
        _cachedImageOffset ??= (rect.width - _cachedImageSize!) / 2;

        canvas.save();
        canvas.translate(
          rect.left + _cachedImageOffset!,
          rect.top + _cachedImageOffset!,
        );
        _loadedSvg!.render(
          canvas,
          Vector2(_cachedImageSize!, _cachedImageSize!),
        );
        canvas.restore();
      } else if (_loadedImage != null) {
        // Рисуем PNG (кэшируем rect)
        _cachedImageRect ??= Rect.fromCenter(
          center: rect.center,
          width: rect.width * _imageScale,
          height: rect.width * _imageScale,
        );

        paintImage(
          canvas: canvas,
          rect: _cachedImageRect!,
          image: _loadedImage!,
          fit: BoxFit.contain,
        );
      }
    }

    // Затемнение при выделении (кэшируем Paint)
    if (isSelected) {
      _darkenPaint ??= Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, _darkenPaint!);
    }

    // Рисуем иконку специального камня (поверх всего)
    if (specialType != SpecialGemType.none) {
      // Если есть загруженное изображение специального камня - рисуем его
      if (_loadedSpecialSvg != null) {
        _drawSpecialImageSvg(canvas, rect);
      } else if (_loadedSpecialImage != null) {
        _drawSpecialImagePng(canvas, rect);
      } else {
        // Иначе рисуем дефолтную иконку (стрелки/звезда)
        _drawSpecialIcon(canvas, center);
      }
    }
  }

  /// Рисует SVG изображение специального камня
  void _drawSpecialImageSvg(Canvas canvas, Rect rect) {
    final imageScale = 0.7; // Такой же размер как у обычных камней
    final imageSize = rect.width * imageScale;
    final imageOffset = (rect.width - imageSize) / 2;

    canvas.save();
    canvas.translate(rect.left + imageOffset, rect.top + imageOffset);
    _loadedSpecialSvg!.render(canvas, Vector2(imageSize, imageSize));
    canvas.restore();
  }

  /// Рисует PNG изображение специального камня
  void _drawSpecialImagePng(Canvas canvas, Rect rect) {
    final imageScale = 0.7; // Такой же размер как у обычных камней
    final imageSize = rect.width * imageScale;
    final imageRect = Rect.fromCenter(
      center: rect.center,
      width: imageSize,
      height: imageSize,
    );

    paintImage(
      canvas: canvas,
      rect: imageRect,
      image: _loadedSpecialImage!,
      fit: BoxFit.contain,
    );
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

    // Загружаем изображение специального камня если оно есть
    if (specialType != SpecialGemType.none) {
      _loadSpecialImage();
    }
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

  /// Очистить кэш рендеринга (вызывается при изменении состояния камня)
  /// Это необходимо когда камень становится специальным или меняет тип
  void invalidateRenderCache() {
    _gradientPaint = null;
    _cachedRect = null;
    _cachedRRect = null;
    _cachedShadowRRect = null;
    _cachedImageSize = null;
    _cachedImageOffset = null;
    _cachedImageRect = null;
  }
}
