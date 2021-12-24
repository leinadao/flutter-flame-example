import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../helpers/direction.dart';
import '../helpers/map_loader.dart';
import 'components/player.dart';
import 'components/world_collidable.dart';
import 'components/world.dart';

class FFEGame extends FlameGame with HasCollidables {
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

  void addWorldCollision() async =>
      (await MapLoader.readCollisionMap()).forEach((rect) {
        add(WorldCollidable()
          ..position = Vector2(rect.left, rect.top)
          ..width = rect.width
          ..height = rect.height);
      });
}
