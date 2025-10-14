import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/match3_game.dart';

/// Виджет для отображения Match3 игры
///
/// Оборачивает Flame GameWidget, чтобы пользователи пакета
/// не зависели от Flame напрямую.
class Match3GameWidget extends StatelessWidget {
  final Match3Game game;

  const Match3GameWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
