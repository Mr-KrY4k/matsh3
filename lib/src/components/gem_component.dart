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
  // SVG теперь растеризуются в Image при загрузке
  static final Map<String, ui.Image> _cachedImages = {};

  ui.Image? _loadedImage;
  ui.Image? _loadedSpecialImage;
  bool _isLoading = false;
  bool _isLoadingSpecial = false;

  // Кэш для часто используемых объектов рендеринга
  Paint? _shadowPaint;
  Paint? _darkenPaint;
  Paint? _gradientPaint;
  Rect? _cachedRect;
  RRect? _cachedRRect;
  RRect? _cachedShadowRRect;

  // Кэш для размеров изображений
  static const double _imageScale = 0.7;
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

  /// Универсальный метод загрузки изображения (SVG или PNG)
  /// Возвращает загруженное изображение или SVG из кэша или создает новое
  Future<({ui.Image? image, Svg? svg})> _loadImageFromPath(
    String imagePath,
  ) async {
    final imageType = theme.getImageType(imagePath);

    try {
      if (imageType == GemImageType.svg) {
        // Проверяем кэш изображений (SVG будет растеризован в Image)
        final cachedImage = _cachedImages[imagePath];
        if (cachedImage != null) {
          return (image: cachedImage, svg: null);
        }

        // Загружаем SVG и преобразуем его в растровое изображение
        final svgPath = imagePath.startsWith('assets/')
            ? imagePath.substring(7)
            : imagePath;
        final svg = await Svg.load(svgPath);

        try {
          // Растеризуем SVG в фиксированное изображение
          // Используем фиксированный размер для всех SVG (высокое качество)
          const rasterSize = 256.0;
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);

          // Рендерим SVG напрямую
          svg.render(canvas, Vector2.all(rasterSize));

          final picture = recorder.endRecording();

          // Создаем изображение с фиксированным размером
          final image = await picture.toImage(
            rasterSize.toInt(),
            rasterSize.toInt(),
          );

          _cachedImages[imagePath] = image;
          picture.dispose();

          return (image: image, svg: null);
        } catch (e) {
          print('❌ Не удалось растеризовать SVG $imagePath: $e');
          print('   Используем SVG напрямую');
          // Возвращаем SVG для рендеринга напрямую (старый способ)
          return (image: null, svg: svg);
        }
      } else if (imageType == GemImageType.png) {
        // Проверяем кэш PNG
        final cachedImage = _cachedImages[imagePath];
        if (cachedImage != null) {
          return (image: cachedImage, svg: null);
        }

        // Загружаем новый PNG
        final data = await rootBundle.load(imagePath);
        final bytes = data.buffer.asUint8List();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;
        _cachedImages[imagePath] = image;
        return (image: image, svg: null);
      }
    } catch (e) {
      print('❌ ОШИБКА загрузки изображения $imagePath: $e');
    }

    return (image: null, svg: null);
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

    final result = await _loadImageFromPath(imagePath);
    _loadedImage = result.image;

    _isLoading = false;
  }

  /// Загрузить изображение для специального камня
  Future<void> _loadSpecialImage() async {
    if (_isLoadingSpecial) return;
    _isLoadingSpecial = true;

    if (specialType == SpecialGemType.none) {
      _isLoadingSpecial = false;
      return;
    }

    final imagePath = theme.getSpecialGemImage(specialType);
    if (imagePath == null || imagePath.isEmpty) {
      _isLoadingSpecial = false;
      return;
    }

    final result = await _loadImageFromPath(imagePath);
    _loadedSpecialImage = result.image;

    _isLoadingSpecial = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Проверка на валидность размеров
    if (gemSize <= 0 || gemSize.isNaN || gemSize.isInfinite) {
      print('❌ GemComponent: Невалидный gemSize = $gemSize для типа $gemType');
      return;
    }

    final center = size / 2;
    final gemPadding = gemSize * 0.03;

    // Кэшируем rect и rrect если еще не созданы
    _cachedRect ??= Rect.fromCenter(
      center: Offset(center.x, center.y),
      width: gemSize - gemPadding * 2,
      height: gemSize - gemPadding * 2,
    );
    final rect = _cachedRect!;

    // Проверка на валидность rect
    if (rect.width <= 0 || rect.width.isNaN || rect.width.isInfinite) {
      print(
        '❌ GemComponent: Невалидный rect.width = ${rect.width} для типа $gemType',
      );
      return;
    }

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
      if (_loadedImage != null) {
        // Рисуем изображение (PNG или растеризованный SVG) - кэшируем rect
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
      if (_loadedSpecialImage != null) {
        _drawSpecialImagePng(canvas, rect);
      } else {
        // Иначе рисуем дефолтную иконку (стрелки/звезда)
        _drawSpecialIcon(canvas, center);
      }
    }
  }

  /// Рисует изображение специального камня (PNG или растеризованный SVG)
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

  /// Асинхронная анимация перемещения (ждет завершения)
  Future<void> moveToAsync(
    Vector2 newPosition, {
    double duration = 0.15,
  }) async {
    final effect = MoveEffect.to(
      newPosition,
      EffectController(duration: duration),
    );
    add(effect);
    await effect.completed;
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
  Future<void> appear() async {
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.3, curve: Curves.elasticOut),
      ),
    );

    // Загружаем изображение специального камня если оно есть
    if (specialType != SpecialGemType.none) {
      await _loadSpecialImage();
    }
  }

  /// Очистить весь кэш изображений (полезно для освобождения памяти)
  static void clearImageCache() {
    _cachedImages.clear();
  }

  /// Очистить кэш конкретного изображения
  static void clearCachedImage(String imagePath) {
    _cachedImages.remove(imagePath);
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
    _cachedImageRect = null;
  }
}
