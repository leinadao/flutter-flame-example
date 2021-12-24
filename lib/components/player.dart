import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import '../helpers/direction.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef, Hitbox, Collidable {
  Direction _direction = Direction.none;
  double _altitude = 0;
  Direction _lastNonNoneDirection =
      Direction.none; // TODO: Update enum so never none at start??
  final double _movementSpeed = 100.0;
  final int _jumpHeight = 100; // Pixels // TODO: extend a type?
  final double _jumpTime = 0.5; // ms // TODO: extend a type?
  final double _animationSpeed = 0.15;
  final _spriteRowDown = 0;
  final _spriteRowLeft = 1;
  final _spriteRowUp = 2;
  final _spriteRowRight = 3;
  late final SpriteAnimation _runDownAnimation;
  late final SpriteAnimation _runLeftAnimation;
  late final SpriteAnimation _runUpAnimation;
  late final SpriteAnimation _runRightAnimation;
  late final SpriteAnimation _standingDownAnimation;
  late final SpriteAnimation _standingLeftAnimation;
  late final SpriteAnimation _standingUpAnimation;
  late final SpriteAnimation _standingRightAnimation;
  Direction _collisionDirection = Direction.none;
  bool _hasCollided =
      false; // TODO: Not needed by using collisionDirection = none?
  late final Timer _jumpTimer;

  Player()
      : super(
          size: Vector2.all(50.0),
        ) {
    addHitbox(HitboxRectangle());
    _jumpTimer = Timer(_jumpTime);
  }

  Direction get direction {
    return _direction;
  }

  void set direction(Direction newDirection) {
    if (newDirection != Direction.none) {
      _lastNonNoneDirection = newDirection;
    }
    _direction = newDirection;
  }

  @override
  Future<void> onLoad() async {
    _loadAnimations().then((_) => {animation = _standingDownAnimation});
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('player_spritesheet.png'),
      srcSize: Vector2(29.0, 32.0),
    );

    _runDownAnimation = spriteSheet.createAnimation(
      row: _spriteRowDown,
      stepTime: _animationSpeed,
      to: 4,
    );
    _runLeftAnimation = spriteSheet.createAnimation(
      row: _spriteRowLeft,
      stepTime: _animationSpeed,
      to: 4,
    );
    _runUpAnimation = spriteSheet.createAnimation(
      row: _spriteRowUp,
      stepTime: _animationSpeed,
      to: 4,
    );
    _runRightAnimation = spriteSheet.createAnimation(
      row: _spriteRowRight,
      stepTime: _animationSpeed,
      to: 4,
    );
    _standingDownAnimation = spriteSheet.createAnimation(
      row: _spriteRowDown,
      stepTime: _animationSpeed,
      to: 1,
    );
    _standingLeftAnimation = spriteSheet.createAnimation(
      row: _spriteRowLeft,
      stepTime: _animationSpeed,
      to: 1,
    );
    _standingUpAnimation = spriteSheet.createAnimation(
      row: _spriteRowUp,
      stepTime: _animationSpeed,
      to: 1,
    );
    _standingRightAnimation = spriteSheet.createAnimation(
      row: _spriteRowRight,
      stepTime: _animationSpeed,
      to: 1,
    );
  }

  void startJump() {
    if (!_jumpTimer.isRunning()) {
      _jumpTimer.start();
    }
  }

  void _updateJump(double dt) {
    _jumpTimer.update(dt);
    // TODO: Calc a parabola?
    final desiredHeight =
        _jumpHeight * (0.5 - (-0.5 + _jumpTimer.progress).abs());
    position.add(Vector2(0, _altitude - desiredHeight));
    _altitude = desiredHeight;
  }

  @override
  void update(double dt) {
    super.update(dt);
    movePlayer(dt);
    _updateJump(dt);
  }

  void movePlayer(double dt) {
    switch (_direction) {
      case Direction.up:
        if (canPlayerMoveUp()) {
          animation = _runUpAnimation;
          moveUp(dt);
        }
        break;
      case Direction.down:
        if (canPlayerMoveDown()) {
          animation = _runDownAnimation;
          moveDown(dt);
        }
        break;
      case Direction.left:
        if (canPlayerMoveLeft()) {
          animation = _runLeftAnimation;
          moveLeft(dt);
        }
        break;
      case Direction.right:
        if (canPlayerMoveRight()) {
          animation = _runRightAnimation;
          moveRight(dt);
        }
        break;
      case Direction.none:
        switch (_lastNonNoneDirection) {
          case Direction.up:
            animation = _standingUpAnimation;
            break;
          case Direction.left:
            animation = _standingLeftAnimation;
            break;
          case Direction.right:
            animation = _standingRightAnimation;
            break;
          default:
            animation = _standingDownAnimation;
            break;
        }
        break;
    }
  }

  bool get hasCollided {
    // TODO: Temp: Need object heights...
    return _hasCollided &&
        _altitude < 0.2; // TODO: arbitrary and will get stuck on things.
  }

  bool canPlayerMoveUp() {
    if (hasCollided && _collisionDirection == Direction.up) {
      return false;
    }
    return true;
  }

  bool canPlayerMoveDown() {
    if (hasCollided && _collisionDirection == Direction.down) {
      return false;
    }
    return true;
  }

  bool canPlayerMoveLeft() {
    if (hasCollided && _collisionDirection == Direction.left) {
      return false;
    }
    return true;
  }

  bool canPlayerMoveRight() {
    if (hasCollided && _collisionDirection == Direction.right) {
      return false;
    }
    return true;
  }

  void moveUp(double dt) {
    position.add(Vector2(0, -1.0 * dt * _movementSpeed));
  }

  void moveDown(double dt) {
    position.add(Vector2(0, dt * _movementSpeed));
  }

  void moveLeft(double dt) {
    position.add(Vector2(-1.0 * dt * _movementSpeed, 0));
  }

  void moveRight(double dt) {
    position.add(Vector2(dt * _movementSpeed, 0));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (!_hasCollided) {
      _hasCollided = true;
      _collisionDirection = _direction;
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    _hasCollided = false;
  }
}
