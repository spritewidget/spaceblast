part of 'game_demo.dart';

const int _maxLevel = 9;

class GameObjectFactory {
  GameObjectFactory(this.sheet, this.sounds, this.level, this.playerState);

  SpriteSheet sheet;
  SoundAssets sounds;
  Level level;
  PlayerState playerState;

  void addAsteroids(int level, double yPos) {
    int numAsteroids = 10 + level * 4;
    double distribution = (level * 0.2).clamp(0.0, 0.8);

    for (int i = 0; i < numAsteroids; i++) {
      GameObject obj;
      if (i == 0) {
        obj = AsteroidPowerUp(this);
      } else if (randomDouble() < distribution) {
        obj = AsteroidBig(this);
      } else {
        obj = AsteroidSmall(this);
      }

      Offset pos = Offset(
          randomSignedDouble() * 160.0, yPos + _chunkSpacing * randomDouble());
      addGameObject(obj, pos);
    }
  }

  void addEnemyScoutSwarm(int level, double yPos) {
    int numEnemies = (3 + level * 3).clamp(0, 12);
    late List<int> types;
    int swarmLevel = level % _maxLevel;

    if (swarmLevel == 0) {
      types = [0, 0, 0];
    } else if (swarmLevel == 1) {
      types = [0, 1, 0];
    } else if (swarmLevel == 2) {
      types = [1, 0, 1];
    } else if (swarmLevel == 3) {
      types = [1, 1, 1];
    } else if (swarmLevel == 4) {
      types = [0, 1, 2];
    } else if (swarmLevel == 5) {
      types = [1, 2, 1];
    } else if (swarmLevel == 6) {
      types = [2, 1, 2];
    } else if (swarmLevel == 7) {
      types = [2, 1, 2];
    } else if (swarmLevel == 8) {
      types = [2, 2, 2];
    }

    for (int i = 0; i < numEnemies; i++) {
      int type = types[i % 3];
      double spacing = math.max(_chunkSpacing / (numEnemies + 1.0), 80.0);
      double y = yPos +
          _chunkSpacing / 2.0 -
          (numEnemies - 1) * spacing / 2.0 +
          i * spacing;
      addGameObject(EnemyScout(this, type), Offset(0.0, y));
    }
  }

  void addEnemyDestroyerSwarm(int level, double yPos) {
    int numEnemies = (2 + level).clamp(2, 10);
    late List<int> types;
    int swarmLevel = level % _maxLevel;

    if (swarmLevel == 0) {
      types = [0, 0, 0];
    } else if (swarmLevel == 1) {
      types = [0, 1, 0];
    } else if (swarmLevel == 2) {
      types = [1, 0, 1];
    } else if (swarmLevel == 3) {
      types = [1, 1, 1];
    } else if (swarmLevel == 4) {
      types = [0, 1, 2];
    } else if (swarmLevel == 5) {
      types = [1, 2, 1];
    } else if (swarmLevel == 6) {
      types = [2, 1, 2];
    } else if (swarmLevel == 7) {
      types = [2, 1, 2];
    } else if (swarmLevel == 8) {
      types = [2, 2, 2];
    }

    for (int i = 0; i < numEnemies; i++) {
      int type = types[i % 3];
      addGameObject(
          EnemyDestroyer(this, type),
          Offset(randomSignedDouble() * 120.0,
              yPos + _chunkSpacing * randomDouble()));
    }
  }

  void addGameObject(GameObject obj, Offset pos) {
    obj.position = pos;
    obj.setupActions();

    level.addChild(obj);
  }

  void addBossFight(int level, double yPos) {
    // Add boss
    EnemyBoss boss = EnemyBoss(this, level);
    Offset pos = Offset(0.0, yPos + _chunkSpacing / 2.0);

    addGameObject(boss, pos);

    playerState.boss = boss;

    int destroyerLevel = (level - 1 ~/ 3).clamp(0, 2);

    // Add boss's helpers
    if (level >= 1) {
      EnemyDestroyer destroyer0 = EnemyDestroyer(this, destroyerLevel);
      addGameObject(
          destroyer0, Offset(-80.0, yPos + _chunkSpacing / 2.0 + 70.0));

      EnemyDestroyer destroyer1 = EnemyDestroyer(this, destroyerLevel);
      addGameObject(
          destroyer1, Offset(80.0, yPos + _chunkSpacing / 2.0 + 70.0));

      if (level >= 2) {
        EnemyDestroyer destroyer0 = EnemyDestroyer(this, destroyerLevel);
        addGameObject(
            destroyer0, Offset(-80.0, yPos + _chunkSpacing / 2.0 - 70.0));

        EnemyDestroyer destroyer1 = EnemyDestroyer(this, destroyerLevel);
        addGameObject(
            destroyer1, Offset(80.0, yPos + _chunkSpacing / 2.0 - 70.0));
      }
    }
  }
}

const List<Color> laserColors = [
  Color(0xff95f4fb),
  Color(0xff5bff35),
  Color(0xffff886c),
  Color(0xffffd012),
  Color(0xfffd7fff),
];

void addLaserSprites(Node node, int level, double r, SpriteSheet sheet) {
  int numLasers = level % 3 + 1;
  Color laserColor = laserColors[(level ~/ 3) % laserColors.length];

  // Add sprites
  List<Sprite> sprites = <Sprite>[];
  for (int i = 0; i < numLasers; i++) {
    Sprite sprite = Sprite(texture: sheet["explosion_particle.png"]!);
    sprite.scale = 0.5;
    sprite.colorOverlay = laserColor;
    sprite.blendMode = ui.BlendMode.plus;
    node.addChild(sprite);
    sprites.add(sprite);
  }

  // Position the individual sprites
  if (numLasers == 2) {
    sprites[0].position = const Offset(-3.0, 0.0);
    sprites[1].position = const Offset(3.0, 0.0);
  } else if (numLasers == 3) {
    sprites[0].position = const Offset(-4.0, 0.0);
    sprites[1].position = const Offset(4.0, 0.0);
    sprites[2].position = const Offset(0.0, -2.0);
  }
}
