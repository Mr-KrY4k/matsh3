# Match3 Game Engine 💎

Игровой движок Match-3 для Flutter с использованием Flame Game Engine.

Этот пакет предоставляет **только игровую логику и компоненты**. UI экраны (меню, результаты и т.д.) вы создаете сами в своем приложении. Полный пример UI доступен в папке `example/`.

## Особенности

### Игровая механика
- ✅ Классический геймплей Match-3
- ✅ Интуитивное управление через тап и свайп
- ✅ Система гравитации и автоматического заполнения
- ✅ Обнаружение отсутствия возможных ходов с автоматическим перемешиванием
- ✅ Адаптивный размер игрового поля (5x5 до 12x12)

### Специальные камни
- 🔸 **Горизонтальный взрыв** - при собирании 4 камней в ряд по горизонтали
- 🔹 **Вертикальный взрыв** - при собирании 4 камней в ряд по вертикали  
- 💣 **Бомба (3x3)** - при собирании 5 и более камней в ряд

### Игровой процесс
- ⏱️ Ограничение по времени (60 секунд)
- 🎯 Цель: набрать 1000 очков до окончания времени
- 🔥 Система комбо с множителями очков (до x5)
- 📊 Отображение прогресса и статистики

### Визуальные эффекты
- 🎨 Красивые градиентные камни 6 цветов
- ✨ Плавные анимации перемещения, появления и исчезновения
- 🌟 Эффекты свечения и теней
- 🔥 Анимированный фитиль таймера с пламенем
- 💫 Динамический прогресс-бар очков

## Установка

Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  match3: ^1.0.0
```

Или установите из локального пути:

```yaml
dependencies:
  match3:
    path: ../match3
```

Затем выполните:

```bash
flutter pub get
```

## Использование

### Базовое использование

Создайте игру и встройте её в свой UI:

```dart
import 'package:flutter/material.dart';
import 'package:match3/match3.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;

  const GameScreen({
    super.key,
    required this.rows,
    required this.columns,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Match3Game game;
  int score = 0;

  @override
  void initState() {
    super.initState();
    game = Match3Game(rows: widget.rows, columns: widget.columns);

    // Подписываемся на события
    game.onScoreChanged = (newScore) {
      setState(() => score = newScore);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Игровое поле
          Match3GameWidget(game: game),
          
          // Ваш UI поверх
          Positioned(
            top: 20,
            left: 20,
            child: Text('Score: $score'),
          ),
        ],
      ),
    );
  }
}
```

### Кастомизация с Callbacks

Игра предоставляет callbacks для отслеживания всех событий:

```dart
import 'package:match3/match3.dart';

final game = Match3Game(rows: 10, columns: 10);

// Отслеживание изменения очков
game.onScoreChanged = (score) {
  print('Score: $score');
  // Обновите ваш UI
};

// Отслеживание ходов
game.onMovesChanged = (moves) {
  print('Moves: $moves');
};

// Отслеживание комбо
game.onComboChanged = (combo) {
  print('Combo: x$combo');
};

// Сообщения (перемешивание и т.д.)
game.onMessage = (message) {
  if (message.isNotEmpty) {
    print('Message: $message');
  }
};
```

### Важно

**Пакет НЕ зависит от прямого импорта Flame в вашем приложении!**

Используйте `Match3GameWidget` вместо `GameWidget` из Flame:

```dart
// ❌ НЕ НУЖНО
import 'package:flame/game.dart';
GameWidget(game: game);

// ✅ ПРАВИЛЬНО
import 'package:match3/match3.dart';
Match3GameWidget(game: game);
```

### Дополнительные компоненты

Пакет также экспортирует Flame компоненты для продвинутого использования:
- `ScoreProgressBar` - прогресс бар очков
- `TimerFuse` - таймер с анимацией
- `ScoreDisplay` - отображение ходов и комбо  
- `MessageDisplay` - временные сообщения

Эти компоненты можно добавить в игру вручную, но в примере мы показываем как сделать UI проще через Flutter виджеты.

## Структура пакета

```
lib/
├── match3.dart              # Главный файл экспорта
└── src/
    ├── widgets/             # Flutter виджеты
    │   └── match3_game_widget.dart
    ├── components/          # Flame компоненты
    │   ├── gem_component.dart
    │   ├── message_display.dart
    │   ├── score_display.dart
    │   ├── score_progress_bar.dart
    │   └── timer_fuse.dart
    ├── game/                # Игровая логика
    │   ├── board_manager.dart
    │   ├── match3_game.dart
    │   └── special_gem_activator.dart
    └── models/              # Модели данных
        ├── board_position.dart
        ├── gem_type.dart
        ├── match.dart
        └── special_gem_type.dart

example/
└── lib/
    ├── main.dart
    └── screens/             # Пример UI экранов
        ├── menu_screen.dart
        ├── game_screen.dart
        └── game_over_screen.dart
```

## Основные компоненты

### Match3GameWidget
**Главный виджет для отображения игры.** Оборачивает Flame GameWidget, чтобы вам не нужно было импортировать Flame в своем приложении.

### Match3Game
Класс игры на базе FlameGame. Управляет игровым процессом, обнаруживает совпадения, обрабатывает специальные камни. Используйте callbacks (`onScoreChanged`, `onMovesChanged`, и т.д.) для отслеживания событий.

### BoardManager  
Менеджер игрового поля. Обрабатывает логику доски: инициализация, поиск совпадений, гравитация, заполнение.

### GemComponent
Визуальный компонент драгоценного камня с анимациями.

### Flame компоненты (опционально)
- `ScoreProgressBar` - прогресс-бар очков
- `TimerFuse` - таймер с анимацией пламени
- `ScoreDisplay` - отображение ходов и комбо
- `MessageDisplay` - временные сообщения

**Примечание**: Эти Flame компоненты для продвинутого использования. В примере показано как сделать UI проще через обычные Flutter виджеты.

## Правила игры

1. **Цель**: Набрать 1000 очков за 60 секунд
2. **Управление**: 
   - Тапайте на камень для выбора
   - Тапайте на соседний камень для обмена
   - Или используйте свайпы для обмена
3. **Очки**:
   - 3 камня = 10 очков × комбо
   - 4 камня = 40 очков × комбо (+ специальный камень)
   - 5+ камней = 50+ очков × комбо (+ бомба)
4. **Комбо**: Множитель увеличивается до x5 при цепных реакциях

## Требования

- Flutter SDK: >=3.8.0
- Dart SDK: >=3.8.0
- Зависимости:
  - flame: ^1.32.0
  - flame_svg: ^1.11.16

## Пример

Полный пример использования доступен в папке `example/`.

Для запуска примера:

```bash
cd example
flutter run
```

## Лицензия

MIT License - см. файл LICENSE для деталей.

## Автор

Создано с ❤️ для Flutter сообщества.

## Скриншоты

### Меню
- Выбор размера игрового поля
- Минималистичный дизайн

### Игровой процесс
- Динамичный геймплей
- Красивые анимации
- Прогресс-бар и таймер
- Система комбо

### Результаты
- Отображение финального счета
- Статистика ходов
- Возможность начать новую игру

## Возможности для расширения

Пакет легко расширяется:
- Добавление новых типов специальных камней
- Кастомные цветовые схемы
- Различные игровые режимы
- Система достижений
- Звуковые эффекты
- Сохранение рекордов

## Поддержка

Если у вас есть вопросы или предложения, создайте issue в репозитории.
