part of 'game_demo.dart';

abstract class GameObject extends Node {
  GameObject(this.f);

  double radius = 0.0;
  double removeLimit = 1280.0;
  bool canDamageShip = true;
  bool canBeDamaged = true;
  bool canBeCollected = false;
  double maxDamage = 3.0;
  double damage = 0.0;

  final GameObjectFactory f;

  final Paint _paintDebug = Paint()
    ..color = const Color(0xffff0000)
    ..strokeWidth = 1.0
    ..style = ui.PaintingStyle.stroke;

  bool collidingWith(GameObject obj) {
    return (GameMath.distanceBetweenPoints(position, obj.position) <
        radius + obj.radius);
  }

  void move() {}

  void removeIfOffscreen(double scroll) {
    if (-position.dy > scroll + removeLimit || -position.dy < scroll - 50.0) {
      removeFromParent();
    }
  }

  void destroy() {
    if (parent != null) {
      Explosion? explo = createExplosion();
      if (explo != null) {
        explo.position = position;
        parent!.addChild(explo);
      }

      Collectable? powerUp = createPowerUp();
      if (powerUp != null) {
        f.addGameObject(powerUp, position);
      }

      removeFromParent();
    }
  }

  void collect() {
    removeFromParent();
  }

  void addDamage(double d) {
    if (!canBeDamaged) return;

    damage += d;
    if (damage >= maxDamage) {
      destroy();
      f.playerState.score += (maxDamage * 10).ceil();
    } else {
      f.sounds.playEffect("hit");
    }
  }

  Explosion? createExplosion() {
    return null;
  }

  Collectable? createPowerUp() {
    return null;
  }

  @override
  void paint(Canvas canvas) {
    if (_drawDebug) {
      canvas.drawCircle(Offset.zero, radius, _paintDebug);
    }
    super.paint(canvas);
  }

  void setupActions() {}
}

class LevelLabel extends GameObject {
  LevelLabel(super.f, int level) {
    canDamageShip = false;
    canBeDamaged = false;

    Label lbl = Label("LEVEL $level",
        textAlign: TextAlign.center,
        textStyle: const TextStyle(
            fontFamily: "Orbitron",
            letterSpacing: 10.0,
            color: Color(0xffffffff),
            fontSize: 24.0,
            fontWeight: FontWeight.w600));
    addChild(lbl);
  }
}

class Ship extends GameObject {
  Ship(GameObjectFactory f) : super(f) {
    // Add main ship sprite
    _sprite = Sprite(texture: f.sheet["ship.png"]!);
    _sprite.scale = 0.3;
    _sprite.rotation = -90.0;
    addChild(_sprite);

    _spriteShield = Sprite(texture: f.sheet["shield.png"]!);
    _spriteShield.scale = 0.35;
    _spriteShield.blendMode = ui.BlendMode.plus;
    addChild(_spriteShield);

    radius = 20.0;
    canBeDamaged = false;
    canDamageShip = false;

    // Set start position
    position = const Offset(0.0, 50.0);
  }

  late Sprite _sprite;
  late Sprite _spriteShield;

  void applyThrust(Offset joystickValue, double scroll) {
    Offset oldPos = position;
    Offset target = Offset(
        joystickValue.dx * 160.0, joystickValue.dy * 220.0 - 250.0 - scroll);
    double filterFactor = 0.2;

    position = Offset(GameMath.filter(oldPos.dx, target.dx, filterFactor),
        GameMath.filter(oldPos.dy, target.dy, filterFactor));
  }

  @override
  void setupActions() {
    MotionTween rotate = MotionTween<double>(
      setter: (a) => _spriteShield.rotation = a,
      start: 0.0,
      end: 360.0,
      duration: 1.0,
    );
    _spriteShield.motions.run(MotionRepeatForever(motion: rotate));
  }

  @override
  void update(double dt) {
    // Update shield
    if (f.playerState.shieldActive) {
      if (f.playerState.shieldDeactivating) {
        _spriteShield.visible = !_spriteShield.visible;
      } else {
        _spriteShield.visible = true;
      }
    } else {
      _spriteShield.visible = false;
    }
  }
}

class Laser extends GameObject {
  double impact = 0.0;

  Laser(GameObjectFactory f, int level, double r) : super(f) {
    // Game object properties
    radius = 10.0;
    removeLimit = _gameSizeHeight + radius;
    canDamageShip = false;
    canBeDamaged = false;
    impact = 1.0 + level * 0.5;

    // Offset for movement
    _offset = Offset(math.cos(radians(r)) * 8.0,
        math.sin(radians(r)) * 8.0 - f.playerState.scrollSpeed);

    // Drawing properties
    rotation = r + 90.0;

    addLaserSprites(this, level, r, f.sheet);
  }

  late Offset _offset;

  @override
  void move() {
    position += _offset;
  }

  @override
  Explosion createExplosion() {
    return ExplosionMini(f.sheet);
  }
}

Color colorForDamage(double damage, double maxDamage, [Color? toColor]) {
  int r, g, b;
  if (toColor == null) {
    r = 255;
    g = 3;
    b = 86;
  } else {
    r = toColor.red;
    g = toColor.green;
    b = toColor.blue;
  }

  int alpha = ((200.0 * damage) ~/ maxDamage).clamp(0, 200);
  return Color.fromARGB(alpha, r, g, b);
}

abstract class Obstacle extends GameObject {
  Obstacle(super.f);

  double explosionScale = 1.0;

  @override
  Explosion createExplosion() {
    f.sounds.playEffect("explosion_${randomInt(3)}");
    Explosion explo = ExplosionBig(f.sheet);
    explo.scale = explosionScale;
    return explo;
  }
}

abstract class Asteroid extends Obstacle {
  Asteroid(super.f);

  late Sprite _sprite;

  @override
  void setupActions() {
    // Rotate obstacle
    int direction = 1;
    if (randomBool()) direction = -1;
    MotionTween rotate = MotionTween<double>(
      setter: (a) => _sprite.rotation = a,
      start: 0.0,
      end: 360.0 * direction,
      duration: 5.0 + 5.0 * randomDouble(),
    );
    _sprite.motions.run(MotionRepeatForever(motion: rotate));
  }

  @override
  set damage(double d) {
    super.damage = d;
    _sprite.colorOverlay = colorForDamage(d, maxDamage);
  }

  @override
  Collectable createPowerUp() {
    return Coin(f);
  }
}

class AsteroidBig extends Asteroid {
  AsteroidBig(GameObjectFactory f) : super(f) {
    _sprite = Sprite(texture: f.sheet["asteroid_big_${randomInt(3)}.png"]!);
    _sprite.scale = 0.3;
    radius = 25.0;
    maxDamage = 5.0;
    addChild(_sprite);
  }
}

class AsteroidSmall extends Asteroid {
  AsteroidSmall(GameObjectFactory f) : super(f) {
    _sprite = Sprite(texture: f.sheet["asteroid_small_${randomInt(3)}.png"]!);
    _sprite.scale = 0.3;
    radius = 12.0;
    maxDamage = 3.0;
    addChild(_sprite);
  }
}

class AsteroidPowerUp extends AsteroidBig {
  late PowerUpType _powerUpType;

  AsteroidPowerUp(GameObjectFactory f) : super(f) {
    _powerUpType = nextPowerUpType();

    removeAllChildren();

    Sprite powerUpBg = Sprite(
      texture: f.sheet["powerup.png"]!,
    );
    powerUpBg.scale = 0.3;
    addChild(powerUpBg);

    Sprite powerUpIcon = Sprite(
      texture: f.sheet["powerup_${_powerUpType.index}.png"]!,
    );
    powerUpIcon.scale = 0.3;
    addChild(powerUpIcon);

    _sprite = Sprite(
      texture: f.sheet["crystal_${randomInt(2)}.png"]!,
    );
    _sprite.scale = 0.3;
    addChild(_sprite);
  }

  @override
  void setupActions() {}

  @override
  Collectable createPowerUp() {
    return PowerUp(f, _powerUpType);
  }

  @override
  set damage(double d) {
    super.damage = d;
    _sprite.colorOverlay =
        colorForDamage(d, maxDamage, const Color.fromARGB(255, 200, 200, 255));
  }
}

class EnemyScout extends Obstacle {
  EnemyScout(GameObjectFactory f, int level) : super(f) {
    _sprite = Sprite(texture: f.sheet["enemy_scout_$level.png"]!);
    _sprite.scale = 0.32;

    radius = 12.0 + level * 2.0;

    if (level == 0) {
      maxDamage = 1.0;
    } else if (level == 1) {
      maxDamage = 4.0;
    } else if (level == 2) {
      maxDamage = 8.0;
    }

    addChild(_sprite);

    constraints = <Constraint>[ConstraintRotationToMovement(dampening: 0.5)];
  }

  final double _swirlSpacing = 80.0;

  _addRandomSquare(List<Offset> offsets, double x, double y) {
    double xMove = (randomBool()) ? _swirlSpacing : -_swirlSpacing;
    double yMove = (randomBool()) ? _swirlSpacing : -_swirlSpacing;

    if (randomBool()) {
      offsets.addAll(<Offset>[
        Offset(x, y),
        Offset(xMove + x, y),
        Offset(xMove + x, yMove + y),
        Offset(x, yMove + y),
        Offset(x, y)
      ]);
    } else {
      offsets.addAll(<Offset>[
        Offset(x, y),
        Offset(x, y + yMove),
        Offset(xMove + x, yMove + y),
        Offset(xMove + x, y),
        Offset(x, y)
      ]);
    }
  }

  @override
  void setupActions() {
    List<Offset> offsets = <Offset>[];
    _addRandomSquare(offsets, -_swirlSpacing, 0.0);
    _addRandomSquare(offsets, _swirlSpacing, 0.0);
    offsets.add(Offset(-_swirlSpacing, 0.0));

    List<Offset> points = <Offset>[];
    for (Offset offset in offsets) {
      points.add(position + offset);
    }

    MotionSpline spline = MotionSpline(
      setter: (Offset a) => position = a,
      points: points,
      duration: 6.0,
    );
    spline.tension = 0.7;
    motions.run(MotionRepeatForever(motion: spline));
  }

  @override
  Collectable createPowerUp() {
    return Coin(f);
  }

  @override
  set damage(double d) {
    super.damage = d;
    _sprite.colorOverlay = colorForDamage(d, maxDamage);
  }

  late Sprite _sprite;
}

class EnemyDestroyer extends Obstacle {
  EnemyDestroyer(GameObjectFactory f, int level) : super(f) {
    _sprite = Sprite(texture: f.sheet["enemy_destroyer_$level.png"]!);
    _sprite.scale = 0.32;

    radius = 24.0 + level * 2;

    if (level == 0) {
      maxDamage = 4.0;
    } else if (level == 1) {
      maxDamage = 8.0;
    } else if (level == 2) {
      maxDamage = 16.0;
    }

    addChild(_sprite);

    constraints = <Constraint>[
      ConstraintRotationToNode(targetNode: f.level.ship, dampening: 0.05)
    ];
  }

  int _countDown = randomInt(120) + 240;

  @override
  void setupActions() {
    ActionCircularMove circle = ActionCircularMove((Offset a) {
      position = a;
    }, position, 40.0, 360.0 * randomDouble(), randomBool(), 3.0);
    motions.run(MotionRepeatForever(motion: circle));
  }

  @override
  Collectable createPowerUp() {
    return Coin(f);
  }

  @override
  void update(double dt) {
    _countDown -= 1;
    if (_countDown <= 0) {
      // Shoot at player
      f.sounds.playEffect("laser");

      EnemyLaser laser = EnemyLaser(f, rotation, 5.0, const Color(0xffffe38e));
      laser.position = position;
      f.level.addChild(laser);

      _countDown = 60 + randomInt(120);
    }
  }

  @override
  set damage(double d) {
    super.damage = d;
    _sprite.colorOverlay = colorForDamage(d, maxDamage);
  }

  late Sprite _sprite;
}

class EnemyLaser extends Obstacle {
  EnemyLaser(GameObjectFactory f, double rotation, double speed, Color color)
      : super(f) {
    _sprite = Sprite(texture: f.sheet["explosion_particle.png"]!);
    _sprite.scale = 0.5;
    _sprite.rotation = rotation + 90;
    _sprite.colorOverlay = color;
    addChild(_sprite);

    canDamageShip = true;
    canBeDamaged = false;

    double rad = radians(rotation);
    _movement = Offset(math.cos(rad) * speed, math.sin(rad) * speed);
  }

  late Sprite _sprite;
  late Offset _movement;

  @override
  void move() {
    position += _movement;
  }
}

class EnemyBoss extends Obstacle {
  EnemyBoss(GameObjectFactory f, int level) : super(f) {
    radius = 48.0;
    _sprite = Sprite(texture: f.sheet["enemy_boss_${level % 3}.png"]!);
    _sprite.scale = 0.32;
    addChild(_sprite);
    maxDamage = 40.0 + 20.0 * level;

    constraints = <Constraint>[
      ConstraintRotationToNode(targetNode: f.level.ship, dampening: 0.05)
    ];

    _powerBar = PowerBar(const Size(60.0, 10.0));
    _powerBar.pivot = const Offset(0.5, 0.5);
    f.level.addChild(_powerBar);
    _powerBar.constraints = <Constraint>[
      ConstraintPositionToNode(
        targetNode: this,
        dampening: 0.5,
        offset: const Offset(0.0, -70.0),
      )
    ];
  }

  late Sprite _sprite;
  late PowerBar _powerBar;

  int _countDown = randomInt(120) + 240;

  @override
  void update(double dt) {
    _countDown -= 1;
    if (_countDown <= 0) {
      // Shoot at player
      f.sounds.playEffect("laser");

      fire(10.0);
      fire(0.0);
      fire(-10.0);

      _countDown = 60 + randomInt(120);
    }
  }

  void fire(double r) {
    r += rotation;
    EnemyLaser laser = EnemyLaser(f, r, 5.0, const Color(0xffffe38e));

    double rad = radians(r);
    Offset startOffset = Offset(math.cos(rad) * 30.0, math.sin(rad) * 30.0);

    laser.position = position + startOffset;
    f.level.addChild(laser);
  }

  @override
  void setupActions() {
    ActionOscillate oscillate = ActionOscillate((Offset a) {
      position = a;
    }, position, 120.0, 3.0);
    motions.run(MotionRepeatForever(motion: oscillate));
  }

  @override
  void destroy() {
    f.playerState.boss = null;
    if (_powerBar.parent != null) _powerBar.removeFromParent();

    // Flash the screen
    NodeWithSize screen = f.playerState.parent as NodeWithSize;
    screen.addChild(Flash(screen.size, 1.0));
    super.destroy();

    // Add coins
    for (int i = 0; i < 20; i++) {
      Coin coin = Coin(f);
      Offset pos = Offset(randomSignedDouble() * 160,
          position.dy + randomSignedDouble() * 160.0);
      f.addGameObject(coin, pos);
    }
  }

  @override
  Explosion createExplosion() {
    f.sounds.playEffect("explosion_boss");
    ExplosionBig explo = ExplosionBig(f.sheet);
    explo.scale = 1.5;
    return explo;
  }

  @override
  set damage(double d) {
    super.damage = d;
    _sprite.motions.stopAll();
    _sprite.motions.run(
      MotionTween<Color>(
        setter: (a) => _sprite.colorOverlay = a,
        start: const Color.fromARGB(180, 255, 3, 86),
        end: const Color(0x00000000),
        duration: 0.3,
      ),
    );

    _powerBar.power = (1.0 - (damage / maxDamage)).clamp(0.0, 1.0);
  }
}

class Collectable extends GameObject {
  Collectable(super.f) {
    canDamageShip = false;
    canBeDamaged = false;
    canBeCollected = true;

    zPosition = 20.0;
  }
}

class Coin extends Collectable {
  Coin(GameObjectFactory f) : super(f) {
    _sprite = Sprite(texture: f.sheet["coin.png"]!);
    _sprite.scale = 0.7;
    addChild(_sprite);

    radius = 7.5;
  }

  @override
  void setupActions() {
    // Rotate
    MotionTween rotate = MotionTween<double>(
      setter: (a) => _sprite.rotation = a,
      start: 0.0,
      end: 360.0,
      duration: 1.0,
    );
    motions.run(MotionRepeatForever(motion: rotate));

    // Fade in
    MotionTween fadeIn = MotionTween<double>(
      setter: (a) => _sprite.opacity = a,
      start: 0.0,
      end: 1.0,
      duration: 0.6,
    );
    motions.run(fadeIn);
  }

  late Sprite _sprite;

  @override
  void collect() {
    f.sounds.playEffect("pickup_0");
    f.playerState.addCoin(this);
    super.collect();
  }
}

enum PowerUpType {
  shield,
  speedLaser,
  sideLaser,
  speedBoost,
}

List<PowerUpType> _powerUpTypes = List<PowerUpType>.from(PowerUpType.values);
int _lastPowerUp = _powerUpTypes.length;

PowerUpType nextPowerUpType() {
  if (_lastPowerUp >= _powerUpTypes.length) {
    _powerUpTypes.shuffle();
    _lastPowerUp = 0;
  }

  PowerUpType type = _powerUpTypes[_lastPowerUp];
  _lastPowerUp++;

  return type;
}

class PowerUp extends Collectable {
  PowerUp(GameObjectFactory f, this.type) : super(f) {
    _sprite = Sprite(texture: f.sheet["powerup.png"]!);
    _sprite.scale = 0.3;
    addChild(_sprite);

    Sprite powerUpIcon = Sprite(texture: f.sheet["powerup_${type.index}.png"]!);
    powerUpIcon.scale = 0.3;
    addChild(powerUpIcon);

    radius = 10.0;
  }

  late Sprite _sprite;
  PowerUpType type;

  @override
  void setupActions() {
    MotionTween rotate = MotionTween<double>(
      setter: (a) => _sprite.rotation = a,
      start: 0.0,
      end: 360.0,
      duration: 1.0,
    );
    motions.run(MotionRepeatForever(motion: rotate));

    // Fade in
    MotionTween fadeIn = MotionTween<double>(
      setter: (a) => _sprite.opacity = a,
      start: 0.0,
      end: 1.0,
      duration: 0.6,
    );
    motions.run(fadeIn);
  }

  @override
  void collect() {
    f.sounds.playEffect("buy_upgrade");
    f.playerState.activatePowerUp(type);
    super.collect();
  }
}
