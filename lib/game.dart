import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../helpers/direction.dart';
import '../helpers/map_loader.dart';
import 'components/player.dart';
import 'components/world_collidable.dart';
import 'components/world.dart';

import 'package:flutter/foundation.dart';

class FFEGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, DoubleTapDetector {
  final Player _player = Player();
  final World _world = World();

  @override
  Future<void> onLoad() async {
    await add(_world);
    add(_player);
    _player.position = _world.size / 2;
    camera.followComponent(
      _player,
      worldBounds: Rect.fromLTRB(0, 0, _world.size.x, _world.size.y),
    );
    addWorldCollision();
  }

  void onJoypadDirectionChanged(Direction direction) {
    _player.direction = direction;
  }

  @override
  void onDoubleTap() {
    _player.startJump();
  }

  void addWorldCollision() async =>
      (await MapLoader.readCollisionMap()).forEach((rect) {
        add(WorldCollidable()
          ..position = Vector2(rect.left, rect.top)
          ..width = rect.width
          ..height = rect.height);
      });

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;
    Direction? keyDirection = null;

    if ([LogicalKeyboardKey.keyA, LogicalKeyboardKey.arrowLeft]
        .contains(event.logicalKey)) {
      keyDirection = Direction.left;
    } else if ([LogicalKeyboardKey.keyD, LogicalKeyboardKey.arrowRight]
        .contains(event.logicalKey)) {
      keyDirection = Direction.right;
    } else if ([LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp]
        .contains(event.logicalKey)) {
      keyDirection = Direction.up;
    } else if ([LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown]
        .contains(event.logicalKey)) {
      keyDirection = Direction.down;
    } else if (isKeyDown && event.logicalKey == LogicalKeyboardKey.space) {
      _player.startJump();
    }

    if (isKeyDown && keyDirection != null) {
      _player.direction = keyDirection;
    } else if (_player.direction == keyDirection) {
      _player.direction = Direction.none;
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
