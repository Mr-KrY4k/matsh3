# Match3 Game Engine 💎

Игровой движок Match-3 для Flutter с использованием Flame Game Engine.

Этот пакет предоставляет **только игровую логику и компоненты**. UI экраны (меню, результаты и т.д.) вы создаете сами в своем приложении. Полный пример UI доступен в папке `example/`.

## Быстрый старт

```dart
Match3GameWidget(
  rows: 8,
  columns: 8,
  timeLimit: 60.0,        // 60 секунд (или null для бесконечной игры)
  targetScore: 1000,      // Цель (или null)
  theme: Match3Theme(     // Необязательно - есть дефолтные цвета
    backgroundColor: Color(0xFF2C3E50),
    gemColors: {...},
  ),
  onScoreChanged: (score) => print('Score: $score'),
  onTimeChanged: (time) => print('Time: $time'),
  onGameEnd: (score, moves, result) => print('Game Over: $result'),
)
```

## Особенности

### Игровая механика
- ✅ Классический геймплей Match-3
- ✅ Интуитивное управление через тап и свайп
- ✅ Система гравитации и автоматического заполнения
- ✅ Обнаружение отсутствия возможных ходов с автоматическим перемешиванием
- ✅ Адаптивный размер игрового поля (5x5 до 12x12)

### Темы и кастомизация
- 🎨 Настройка фона игры
- 🎨 Настройка цветов для каждого типа камня
- 🖼️ Поддержка PNG и SVG изображений для камней
- 💾 Автоматическое кэширование изображений
- 🎨 Дефолтные значения уже настроены

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

Просто используйте виджет и передайте callbacks:

```dart
import 'package:flutter/material.dart';
import 'package:match3/match3.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  int moves = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Ваш UI
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Score: $score'),
                Text('Moves: $moves'),
              ],
            ),
          ),
          
          // Игровое поле
          Expanded(
            child: Match3GameWidget(
              rows: 8,
              columns: 8,
              onScoreChanged: (newScore) {
                setState(() => score = newScore);
              },
              onMovesChanged: (newMoves) {
                setState(() => moves = newMoves);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Настройка темы (необязательно)

По умолчанию игра использует стандартные цвета. Если хотите изменить внешний вид:

#### Тема с цветами

```dart
final myTheme = Match3Theme(
  backgroundColor: Color(0xFF1a1a2e),
  gemColors: {
    GemType.red: Color(0xFFFF6B6B),
    GemType.blue: Color(0xFF4ECDC4),
    GemType.green: Color(0xFF95E1D3),
    GemType.yellow: Color(0xFFFFA07A),
    GemType.purple: Color(0xFFB794F4),
    GemType.pink: Color(0xFFFED7E2),
  },
);

Match3GameWidget(theme: myTheme);
```

#### Тема с PNG изображениями

```dart
final pngTheme = Match3Theme(
  backgroundColor: Color(0xFF2C3E50),
  gemImageType: GemImageType.png,
  gemImages: {
    GemType.red: 'assets/gems/red.png',
    GemType.blue: 'assets/gems/blue.png',
    GemType.green: 'assets/gems/green.png',
    GemType.yellow: 'assets/gems/yellow.png',
    GemType.purple: 'assets/gems/purple.png',
    GemType.pink: 'assets/gems/pink.png',
  },
);

Match3GameWidget(theme: pngTheme);
```

#### Тема с SVG изображениями

```dart
final svgTheme = Match3Theme(
  backgroundColor: Color(0xFF2C3E50),
  gemImageType: GemImageType.svg,
  gemImages: {
    GemType.red: 'assets/gems/red.svg',
    GemType.blue: 'assets/gems/blue.svg',
    GemType.green: 'assets/gems/green.svg',
    GemType.yellow: 'assets/gems/yellow.svg',
    GemType.purple: 'assets/gems/purple.svg',
    GemType.pink: 'assets/gems/pink.svg',
  },
);

Match3GameWidget(theme: svgTheme);
```

**Примечание:** Изображения кэшируются автоматически для оптимальной производительности.

### Все доступные callbacks

`Match3GameWidget` поддерживает следующие callbacks:

```dart
Match3Game? gameInstance;

Match3GameWidget(
  rows: 8,
  columns: 8,
  
  // Получение ссылки на игру (для управления)
  onGameReady: (game) {
    gameInstance = game;
    // Теперь можно вызвать game.endGame('victory') когда нужно
  },
  
  // Изменение очков
  onScoreChanged: (score) {
    print('Score: $score');
    // Завершаем игру при достижении 1000 очков
    if (score >= 1000) {
      gameInstance?.endGame('victory');
    }
  },
  
  // Изменение количества ходов
  onMovesChanged: (moves) {
    print('Moves: $moves');
  },
  
  // Изменение комбо множителя
  onComboChanged: (combo) {
    print('Combo: x$combo');
    // combo > 1 означает активное комбо
  },
  
  // Системные сообщения
  onMessage: (message) {
    if (message.isNotEmpty) {
      print('Message: $message');
      // Например: "Нет ходов! Перемешиваем..."
    }
  },
  
  // Окончание игры
  onGameEnd: (score, moves, result) {
    print('Game Over!');
    print('Score: $score, Moves: $moves, Result: $result');
    // result может быть: 'victory', 'defeat', 'timeout', и т.д.
    // Показать экран результатов
  },
)
```

### Режимы игры

Настройте правила игры через параметры:

```dart
// Игра с таймером и целью (классический режим)
Match3GameWidget(
  timeLimit: 60.0,      // 60 секунд
  targetScore: 1000,     // Цель: 1000 очков
  onTimeChanged: (time) => print('Time left: $time'),
  onGameEnd: (score, moves, result) {
    // result = 'victory' если набрали 1000 очков
    // result = 'timeout' если время вышло
  },
)

// Игра только на время (без целевого счета)
Match3GameWidget(
  timeLimit: 120.0,      // 2 минуты
  targetScore: null,     // Нет цели
  onGameEnd: (score, moves, result) {
    // result = 'timeout' 
    // score - сколько успели набрать
  },
)

// Игра только на очки (без таймера)
Match3GameWidget(
  timeLimit: null,       // Без лимита времени
  targetScore: 5000,     // Цель: 5000 очков
  onGameEnd: (score, moves, result) {
    // result = 'victory'
    // moves - сколько ходов потребовалось
  },
)

// Бесконечная игра (просто играть)
Match3GameWidget(
  timeLimit: null,       // Без лимита
  targetScore: null,     // Без цели
  // Игра никогда не закончится сама
  // Можно завершить вручную через game.endGame('custom_reason')
)
```

### Важно

**Пакет НЕ требует знания Flame или создания игры вручную!**

Просто используйте виджет:

```dart
// ❌ СТАРЫЙ способ (не нужно)
final game = Match3Game(...);
game.onScoreChanged = ...;
GameWidget(game: game);

// ✅ НОВЫЙ способ (просто и удобно)
Match3GameWidget(
  rows: 8,
  columns: 8,
  onScoreChanged: (score) => ...,
)
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
    ├── theme/               # Темы
    │   └── match3_theme.dart
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
**Главный виджет для отображения игры.** Это всё что вам нужно!

Параметры:
- `rows` (int, default: 8) - количество строк
- `columns` (int, default: 8) - количество столбцов
- `theme` (Match3Theme?, необязательный) - тема игры (фон и цвета камней)
- `timeLimit` (double?, необязательный) - лимит времени в секундах (null = бесконечная игра)
- `targetScore` (int?, необязательный) - целевой счет для победы (null = нет цели)
- `onGameReady` (Function(Match3Game)?) - вызывается при инициализации игры
- `onTimeChanged` (Function(double)?) - callback при изменении времени
- `onScoreChanged` (Function(int)?) - callback при изменении очков
- `onMovesChanged` (Function(int)?) - callback при изменении ходов
- `onComboChanged` (Function(int)?) - callback при изменении комбо
- `onMessage` (Function(String)?) - callback для системных сообщений
- `onGameEnd` (Function(int, int, String)?) - callback при окончании игры

Виджет сам создает игру внутри себя - вам не нужно ничего настраивать вручную!

### Match3Theme
**Класс темы игры** для настройки внешнего вида.

Параметры (все необязательные):
- `backgroundColor` (Color, default: `Color(0xFF2C3E50)`) - цвет фона игры
- `gemImageType` (GemImageType, default: `GemImageType.color`) - тип отображения:
  - `GemImageType.color` - цветные квадраты (по умолчанию)
  - `GemImageType.png` - PNG изображения
  - `GemImageType.svg` - SVG изображения
- `gemColors` (Map<GemType, Color>) - цвета для каждого типа камня
- `gemImages` (Map<GemType, String>) - пути к изображениям (для PNG/SVG)

Если не передавать параметры, будут использованы стандартные цветные квадраты.

### Match3Game (для продвинутых)
Внутренний класс игры на базе FlameGame. Обычно вам не нужно работать с ним напрямую, но он доступен если нужна продвинутая кастомизация.

Публичные свойства:
- `score` (int) - текущий счет
- `moves` (int) - количество ходов
- `combo` (int) - текущий множитель комбо

Публичные методы:
- `endGame(String result)` - завершить игру с указанным результатом

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

### Управление
- Тапайте на камень для выбора
- Тапайте на соседний камень для обмена
- Или используйте свайпы для обмена

### Очки
- 3 камня = 10 очков × комбо
- 4 камня = 40 очков × комбо (+ специальный камень)
- 5+ камней = 50+ очков × комбо (+ бомба)

### Комбо
Множитель увеличивается до x5 при цепных реакциях

### Режимы игры
Вы сами определяете правила через параметры `timeLimit` и `targetScore`:
- **Классический**: `timeLimit: 60.0`, `targetScore: 1000` - набрать 1000 очков за 60 секунд
- **На время**: `timeLimit: 120.0`, `targetScore: null` - набрать максимум очков за 2 минуты
- **На очки**: `timeLimit: null`, `targetScore: 5000` - набрать 5000 очков без ограничения времени
- **Бесконечный**: `timeLimit: null`, `targetScore: null` - играть бесконечно

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
