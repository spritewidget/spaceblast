part of 'game_demo.dart';

class PersistantGameState {
  Future load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('game_prefs');
    if (json == null) return;

    JsonDecoder decoder = const JsonDecoder();
    Map data = decoder.convert(json);

    coins = data['coins'];
    _powerupLevels = data['powerUpLevels'].cast<int>();
    _currentStartingLevel = data['currentStartingLevel'];
    maxStartingLevel = data['maxStartingLevel'];
    laserLevel = data['laserLevel'];
    _lastScore = data['lastScore'];
    weeklyBestScore = data['bestScore'];
  }

  Future store() async {
    final prefs = await SharedPreferences.getInstance();

    Map data = {
      'coins': coins,
      'powerUpLevels': _powerupLevels,
      'currentStartingLevel': _currentStartingLevel,
      'maxStartingLevel': maxStartingLevel,
      'laserLevel': laserLevel,
      'lastScore': _lastScore,
      'bestScore': weeklyBestScore
    };
    JsonEncoder encoder = const JsonEncoder();
    String json = encoder.convert(data);
    prefs.setString('game_prefs', json);
  }

  int coins = 0;

  List<int> _powerupLevels = <int>[0, 0, 0, 0];

  int powerupLevel(PowerUpType type) {
    return _powerupLevels[type.index];
  }

  int maxPowerUpLevel = 8;

  int _currentStartingLevel = 0;

  int get currentStartingLevel => _currentStartingLevel;

  set currentStartingLevel(int currentStartingLevel) {
    if (currentStartingLevel >= 0 && currentStartingLevel <= maxStartingLevel) {
      _currentStartingLevel = currentStartingLevel;
    }
  }

  int maxStartingLevel = 0;

  int laserLevel = 0;

  int maxLaserLevel = 11;

  int _lastScore = 0;

  int get lastScore => _lastScore;

  set lastScore(int lastScore) {
    _lastScore = lastScore;
    if (lastScore > weeklyBestScore) weeklyBestScore = lastScore;
  }

  int weeklyBestScore = 0;

  int powerUpUpgradePrice(PowerUpType type) {
    int level = powerupLevel(type) + 1;
    return level * 50 + 50;
  }

  int powerUpFrames(PowerUpType type) {
    int level = powerupLevel(type);

    if (type == PowerUpType.speedBoost) {
      return 150 + 25 * level;
    } else {
      return 300 + 50 * level;
    }
  }

  bool upgradePowerUp(PowerUpType type) {
    int price = powerUpUpgradePrice(type);

    if (coins >= price && _powerupLevels[type.index] < maxPowerUpLevel) {
      coins -= price;
      _powerupLevels[type.index] += 1;
      store();
      return true;
    } else {
      return false;
    }
  }

  int laserUpgradePrice() {
    return laserLevel * 100 + 200;
  }

  bool upgradeLaser() {
    if (coins >= laserUpgradePrice() && laserLevel < maxLaserLevel) {
      coins -= laserUpgradePrice();
      laserLevel++;
      store();
      return true;
    } else {
      return false;
    }
  }

  void reachedLevel(int level) {
    if (level > maxStartingLevel && level < 9) {
      maxStartingLevel = level;
      _currentStartingLevel = level;
    }
    store();
  }
}
