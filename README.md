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
  startTimerOnFirstMove: false, // Запускать таймер сразу (false) или после первого хода (true)
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
- 🖼️ Поддержка PNG и SVG изображений для обычных камней
- ⭐ Поддержка PNG и SVG изображений для специальных камней
- 💾 Автоматическое кэширование изображений
- 🎨 Дефолтные значения уже настроены
- 🔄 Fallback на дефолтные иконки если изображение не загрузилось

### Специальные камни
- 🔸 **Горизонтальный взрыв** - при собирании 4 камней в ряд по горизонтали
- 🔹 **Вертикальный взрыв** - при собирании 4 камней в ряд по вертикали  
- 💣 **Бомба (3x3)** - при собирании 5 и более камней в ряд

### Игровой процесс
- ⏱️ Ограничение по времени (60 секунд)
- ⏰ Гибкое управление началом отсчета времени (сразу или после первого хода)
- 🎯 Цель: набрать 1000 очков до окончания времени
- 🔥 Система комбо с множителями очков (до x5)
- 📊 Отображение прогресса и статистики

### Визуальные эффекты
- 🎨 Красивые градиентные камни 6 цветов (красный, синий, зеленый, желтый, фиолетовый, оранжевый)
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
    GemType.orange: Color(0xFFFED7E2),
  },
);

Match3GameWidget(theme: myTheme);
```

#### Тема с PNG изображениями

```dart
final pngTheme = Match3Theme(
  backgroundColor: Color(0xFF2C3E50),
  gemImages: {
    GemType.red: 'assets/gems/red.png',
    GemType.blue: 'assets/gems/blue.png',
    GemType.green: 'assets/gems/green.png',
    GemType.yellow: 'assets/gems/yellow.png',
    GemType.purple: 'assets/gems/purple.png',
    GemType.orange: 'assets/gems/orange.png',
  },
  // Тип определится автоматически по расширению .png
);

Match3GameWidget(theme: pngTheme);
```

#### Тема с SVG изображениями

```dart
final svgTheme = Match3Theme(
  backgroundColor: Color(0xFF2C3E50),
  gemImages: {
    GemType.red: 'assets/gems/red.svg',
    GemType.blue: 'assets/gems/blue.svg',
    GemType.green: 'assets/gems/green.svg',
    GemType.yellow: 'assets/gems/yellow.svg',
    GemType.purple: 'assets/gems/purple.svg',
    GemType.orange: 'assets/gems/orange.svg',
  },
  // Необязательно: изображения для специальных камней
  specialGemImages: {
    SpecialGemType.horizontal: 'assets/special/horizontal.svg',
    SpecialGemType.vertical: 'assets/special/vertical.svg',
    SpecialGemType.bomb: 'assets/special/bomb.svg',
  },
  // Тип определится автоматически по расширению .svg
);

Match3GameWidget(theme: svgTheme);
```

**Примечание:** 
- Тип изображения (PNG/SVG) определяется автоматически по расширению файла
- Изображения кэшируются автоматически для оптимальной производительности
- Если изображение для специального камня не указано, будет нарисована дефолтная иконка (стрелки/звезда)

### Все доступные callbacks

`Match3GameWidget` поддерживает следующие callbacks:

```dart
Match3Game? gameInstance;

Match3GameWidget(
  rows: 8,
  columns: 8,
  
  // Управление таймером
  timeLimit: 60.0,                    // Лимит времени в секундах
  startTimerOnFirstMove: false,       // Запускать таймер сразу (false) или после первого хода (true)
  // Логика: false = таймер сразу, true = таймер после первого успешного хода
  
  // Получение ссылки на игру (для управления)
  onGameReady: (game) {
    gameInstance = game;
    // Теперь можно вызвать game.endGame(GameResult.victory) когда нужно
  },
  
  // Изменение очков
  onScoreChanged: (score) {
    print('Score: $score');
    // Завершаем игру при достижении 1000 очков
    if (score >= 1000) {
      gameInstance?.endGame(GameResult.victory);
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
    }
  },
  
  // Перемешивание доски (когда нет ходов)
  onShuffle: () {
    print('Нет ходов! Перемешиваем...');
    // Показать диалог или уведомление
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔄 Нет ходов!'),
        content: Text('Перемешиваем доску...'),
      ),
    );
  },
  
  // Окончание игры
  onGameEnd: (score, moves, result) {
    print('Game Over!');
    print('Score: $score, Moves: $moves, Result: $result');
    // result - это enum GameResult: victory, timeOut, manual
    // Показать экран результатов
  },
)
```

### Результаты игры (GameResult)

Callback `onGameEnd` возвращает enum `GameResult` с тремя возможными значениями:

```dart
enum GameResult {
  victory,  // Победа - достигнута целевая цель
  timeOut,  // Поражение - закончилось время
  manual,   // Игра завершена вручную через game.endGame()
}
```

Пример использования:

```dart
onGameEnd: (score, moves, result) {
  switch (result) {
    case GameResult.victory:
      print('🎉 Победа! Счет: $score');
      break;
    case GameResult.timeOut:
      print('⏰ Время вышло! Счет: $score');
      break;
    case GameResult.manual:
      print('🛑 Игра остановлена');
      break;
  }
}
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
    // result = GameResult.victory если набрали 1000 очков
    // result = GameResult.timeOut если время вышло
  },
)

// Игра только на время (без целевого счета)
Match3GameWidget(
  timeLimit: 120.0,      // 2 минуты
  targetScore: null,     // Нет цели
  onGameEnd: (score, moves, result) {
    // result = GameResult.timeOut 
    // score - сколько успели набрать
  },
)

// Игра только на очки (без таймера)
Match3GameWidget(
  timeLimit: null,       // Без лимита времени
  targetScore: 5000,     // Цель: 5000 очков
  onGameEnd: (score, moves, result) {
    // result = GameResult.victory
    // moves - сколько ходов потребовалось
  },
)

// Бесконечная игра (просто играть)
Match3GameWidget(
  timeLimit: null,       // Без лимита
  targetScore: null,     // Без цели
  // Игра никогда не закончится сама
  // Можно завершить вручную через game.endGame(GameResult.manual)
)
```

### Важно

**Пакет НЕ требует знания Flame или создания игры вручную!**

Просто используйте виджет:

```dart
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

**Примечание**: Эти компоненты для продвинутого использования. В примере показано как сделать UI проще через Flutter виджеты.

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
- `startTimerOnFirstMove` (bool, default: false) - запускать таймер сразу (false) или после первого хода (true)
- `onGameReady` (Function(Match3Game)?) - вызывается при инициализации игры
- `onTimeChanged` (Function(double)?) - callback при изменении времени
- `onScoreChanged` (Function(int)?) - callback при изменении очков
- `onMovesChanged` (Function(int)?) - callback при изменении ходов
- `onComboChanged` (Function(int)?) - callback при изменении комбо
- `onMessage` (Function(String)?) - callback для системных сообщений
- `onShuffle` (Function()?) - callback при перемешивании доски (когда нет ходов)
- `onGameEnd` (Function(int, int, String)?) - callback при окончании игры

Виджет сам создает игру внутри себя - вам не нужно ничего настраивать вручную!

### Match3Theme
**Класс темы игры** для настройки внешнего вида.

Параметры (все необязательные):
- `backgroundColor` (Color, default: `Color(0xFF2C3E50)`) - цвет фона игры
- `gemColors` (Map<GemType, Color>) - цвета для каждого типа камня (используется если нет изображений)
- `gemImages` (Map<GemType, String>) - пути к изображениям (PNG/SVG определяется автоматически)
- `specialGemImages` (Map<SpecialGemType, String>) - пути к изображениям для специальных камней

**Автоматическое определение типа:**
- Если путь заканчивается на `.svg` → загружается как SVG
- Если путь заканчивается на `.png`, `.jpg`, `.jpeg` → загружается как растровое изображение
- Если путь не указан → используется цвет из `gemColors`

Если не указать `specialGemImages`, будут рисоваться дефолтные иконки (стрелки для линий, звезда для бомбы).

### Внутренние компоненты (для продвинутых)

- `Match3Game` - основной класс игры на базе FlameGame
- `BoardManager` - менеджер игрового поля и логики
- `GemComponent` - визуальный компонент камня с анимациями
- `Match3Theme` - система тем и кастомизации

**Примечание**: Обычно вам не нужно работать с этими компонентами напрямую - используйте `Match3GameWidget`.

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

## Возможности для расширения

Пакет легко расширяется:
- Добавление новых типов специальных камней
- Кастомные темы и изображения
- Различные игровые режимы
- Система достижений и рекордов
- Звуковые эффекты
- Гибкое управление таймером
