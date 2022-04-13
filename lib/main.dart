// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

import 'game_demo.dart';

late PersistantGameState _gameState;

const Color _darkTextColor = Color(0xff3c3f4a);

typedef SelectTabCallback = void Function(int index);
typedef UpgradePowerUpCallback = void Function(PowerUpType type);

late ImageMap _imageMap;
late SpriteSheet _spriteSheet;
late SpriteSheet _spriteSheetUI;

late SoundAssets _sounds;

main() async {
  // We need to call ensureInitialized if we are loading images before runApp
  // is called.
  // TODO: This should be refactored to use a loading screen
  WidgetsFlutterBinding.ensureInitialized();

  // Hide all menu bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Load game state
  _gameState = PersistantGameState();
  await _gameState.load();

  // Load images
  _imageMap = ImageMap(rootBundle);

  await _imageMap.load(<String>[
    'assets/nebula.png',
    'assets/sprites.png',
    'assets/starfield.png',
    'assets/game_ui.png',
    'assets/ui_bg_top.png',
    'assets/ui_bg_bottom.png',
    'assets/ui_popup.png',
  ]);

  // TODO: Fix sounds
  _sounds = SoundAssets(rootBundle);
//  loads.addAll([
//    _sounds.load('explosion_0'),
//    _sounds.load('explosion_1'),
//    _sounds.load('explosion_2'),
//    _sounds.load('explosion_boss'),
//    _sounds.load('explosion_player'),
//    _sounds.load('laser'),
//    _sounds.load('hit'),
//    _sounds.load('levelup'),
//    _sounds.load('pickup_0'),
//    _sounds.load('pickup_1'),
//    _sounds.load('pickup_2'),
//    _sounds.load('pickup_powerup'),
//    _sounds.load('click'),
//    _sounds.load('buy_upgrade'),
//  ]);

//  await Future.wait(loads);

  // Load sprite sheets
  String json = await rootBundle.loadString('assets/sprites.json');
  _spriteSheet = SpriteSheet(_imageMap['assets/sprites.png']!, json);

  json = await rootBundle.loadString('assets/game_ui.json');
  _spriteSheetUI = SpriteSheet(_imageMap['assets/game_ui.png']!, json);

  // All game assets are loaded - we are good to go!
  runApp(const GameDemo());
}

class GameDemo extends StatefulWidget {
  const GameDemo({Key? key}) : super(key: key);

  @override
  GameDemoState createState() => GameDemoState();
}

class GameDemoState extends State<GameDemo> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Title(
          title: 'Space Blast',
          color: const Color(0xFF9900FF),
          child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (RouteSettings settings) {
                switch (settings.name) {
                  case '/game':
                    return _buildGameSceneRoute();
                  default:
                    return _buildMainSceneRoute();
                }
              })),
    );
  }

  PageRoute _buildGameSceneRoute() {
    return MaterialPageRoute(builder: (BuildContext context) {
      return GameScene(
          onGameOver: (int lastScore, int coins, int levelReached) {
            setState(() {
              _gameState.lastScore = lastScore;
              _gameState.coins += coins;
              _gameState.reachedLevel(levelReached);
            });
          },
          gameState: _gameState);
    });
  }

  PageRoute _buildMainSceneRoute() {
    return MaterialPageRoute(builder: (BuildContext context) {
      return MainScene(
          gameState: _gameState,
          onUpgradePowerUp: (PowerUpType type) {
            setState(() {
              if (_gameState.upgradePowerUp(type)) {
                _sounds.play('buy_upgrade');
              } else {
                _sounds.play('click');
              }
            });
          },
          onUpgradeLaser: () {
            setState(() {
              if (_gameState.upgradeLaser()) {
                _sounds.play('buy_upgrade');
              } else {
                _sounds.play('click');
              }
            });
          },
          onStartLevelUp: () {
            setState(() {
              _gameState.currentStartingLevel++;
              _sounds.play('click');
            });
          },
          onStartLevelDown: () {
            setState(() {
              _gameState.currentStartingLevel--;
              _sounds.play('click');
            });
          });
    });
  }
}

class GameScene extends StatefulWidget {
  const GameScene({
    this.onGameOver,
    this.gameState,
    Key? key,
  }) : super(key: key);

  final GameOverCallback? onGameOver;
  final PersistantGameState? gameState;

  @override
  State<GameScene> createState() => GameSceneState();
}

class GameSceneState extends State<GameScene> {
  late NodeWithSize _game;

  @override
  void initState() {
    super.initState();

    _game = GameDemoNode(
        _imageMap, _spriteSheet, _spriteSheetUI, _sounds, widget.gameState!,
        (int score, int coins, int levelReached) {
      Navigator.pop(context);
      widget.onGameOver!(score, coins, levelReached);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SpriteWidget(
      _game,
      transformMode: SpriteBoxTransformMode.fixedWidth,
    );
  }
}

class MainScene extends StatefulWidget {
  const MainScene({
    Key? key,
    required this.gameState,
    required this.onUpgradePowerUp,
    required this.onUpgradeLaser,
    required this.onStartLevelUp,
    required this.onStartLevelDown,
  }) : super(key: key);

  final PersistantGameState gameState;
  final UpgradePowerUpCallback onUpgradePowerUp;
  final VoidCallback onUpgradeLaser;
  final VoidCallback onStartLevelUp;
  final VoidCallback onStartLevelDown;

  @override
  State<MainScene> createState() => MainSceneState();
}

class MainSceneState extends State<MainScene> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var notchOffset = MediaQuery.of(context).padding.top;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          height: notchOffset,
        ),
        Expanded(
          child: CoordinateSystem(
            systemSize: const Size(320.0, 320.0),
            child: DefaultTextStyle(
              style: const TextStyle(fontFamily: "Orbitron", fontSize: 20.0),
              child: Stack(
                children: <Widget>[
                  const MainSceneBackground(),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 320.0,
                        height: 98.0,
                        child: TopBar(
                          gameState: widget.gameState,
                        ),
                      ),
                      Expanded(
                        child: CenterArea(
                          onUpgradeLaser: widget.onUpgradeLaser,
                          onUpgradePowerUp: widget.onUpgradePowerUp,
                          gameState: widget.gameState,
                        ),
                      ),
                      SizedBox(
                        width: 320.0,
                        height: 93.0,
                        child: BottomBar(
                          onPlay: () {
                            Navigator.pushNamed(context, '/game');
                          },
                          onStartLevelUp: widget.onStartLevelUp,
                          onStartLevelDown: widget.onStartLevelDown,
                          gameState: widget.gameState,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    required this.gameState,
    Key? key,
  }) : super(key: key);

  final PersistantGameState gameState;

  @override
  Widget build(BuildContext context) {
    TextStyle scoreLabelStyle = const TextStyle(
        fontFamily: "Orbitron",
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: _darkTextColor);

    return Stack(
      children: <Widget>[
        Positioned(
          left: 18.0,
          top: 13.0,
          child: Text("Last Score", style: scoreLabelStyle),
        ),
        Positioned(
          left: 18.0,
          top: 39.0,
          child: Text("Weekly Best", style: scoreLabelStyle),
        ),
        Positioned(
          right: 18.0,
          top: 13.0,
          child: Text("${gameState.lastScore}", style: scoreLabelStyle),
        ),
        Positioned(
          right: 18.0,
          top: 39.0,
          child: Text("${gameState.weeklyBestScore}", style: scoreLabelStyle),
        ),
        Positioned(
          left: 18.0,
          top: 80.0,
          child: TextureImage(
              texture: _spriteSheetUI['icn_crystal.png']!,
              width: 12.0,
              height: 18.0),
        ),
        Positioned(
          left: 36.0,
          top: 81.0,
          child: Text(
            "${gameState.coins}",
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: _darkTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class CenterArea extends StatelessWidget {
  const CenterArea({
    // required this.selection,
    required this.onUpgradeLaser,
    required this.gameState,
    required this.onUpgradePowerUp,
    Key? key,
  }) : super(key: key);

  // final int selection;
  final VoidCallback onUpgradeLaser;
  final UpgradePowerUpCallback onUpgradePowerUp;
  final PersistantGameState gameState;

  @override
  Widget build(BuildContext context) {
    return _buildCenterArea();
  }

  Widget _buildCenterArea() {
    return _buildUpgradePanel();
  }

  Widget _buildUpgradePanel() {
    return Column(
      children: <Widget>[
        const Text("Upgrade Laser"),
        _buildLaserUpgradeButton(),
        const Text("Upgrade Power-Ups"),
        Row(children: <Widget>[
          _buildPowerUpButton(PowerUpType.shield),
          _buildPowerUpButton(PowerUpType.sideLaser),
          _buildPowerUpButton(PowerUpType.speedBoost),
          _buildPowerUpButton(PowerUpType.speedLaser),
        ], mainAxisAlignment: MainAxisAlignment.center)
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      key: const Key("upgradePanel"),
    );
  }

  Widget _buildPowerUpButton(PowerUpType type) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          TextureButton(
            texture: _spriteSheetUI['btn_powerup_${type.index}.png']!,
            width: 57.0,
            height: 57.0,
            label: "${gameState.powerUpUpgradePrice(type)}",
            labelOffset: const Offset(3.0, 18.5),
            textStyle: const TextStyle(
                fontFamily: "Orbitron", fontSize: 11.0, color: _darkTextColor),
            textAlign: TextAlign.center,
            onPressed: () => onUpgradePowerUp(type),
          ),
          Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("Lvl ${gameState.powerupLevel(type) + 1}",
                  style: const TextStyle(fontSize: 12.0)))
        ],
      ),
    );
  }

  Widget _buildLaserUpgradeButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 18.0),
      child: Stack(
        children: <Widget>[
          TextureButton(
            texture: _spriteSheetUI['btn_laser_upgrade.png']!,
            width: 137.0,
            height: 63.0,
            label: "${gameState.laserUpgradePrice()}",
            labelOffset: const Offset(2.0, 18.0),
            textStyle: const TextStyle(
                fontFamily: "Orbitron", fontSize: 12.0, color: _darkTextColor),
            textAlign: TextAlign.center,
            onPressed: onUpgradeLaser,
          ),
          Positioned(
            child: LaserDisplay(level: gameState.laserLevel),
            left: 19.5,
            top: 14.0,
          ),
          Positioned(
            child: LaserDisplay(level: gameState.laserLevel + 1),
            right: 19.5,
            top: 14.0,
          )
        ],
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    required this.onPlay,
    required this.gameState,
    required this.onStartLevelUp,
    required this.onStartLevelDown,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPlay;
  final VoidCallback onStartLevelUp;
  final VoidCallback onStartLevelDown;
  final PersistantGameState gameState;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned(
          left: 18.0,
          top: 14.0,
          child: TextureImage(
              texture: _spriteSheetUI['level_display.png']!,
              width: 62.0,
              height: 62.0)),
      Positioned(
          left: 18.0,
          top: 14.0,
          child: TextureImage(
              texture: _spriteSheetUI[
                  'level_display_${gameState.currentStartingLevel + 1}.png']!,
              width: 62.0,
              height: 62.0)),
      Positioned(
          left: 85.0,
          top: 14.0,
          child: TextureButton(
              texture: _spriteSheetUI['btn_level_up.png']!,
              width: 30.0,
              height: 30.0,
              onPressed: onStartLevelUp)),
      Positioned(
          left: 85.0,
          top: 46.0,
          child: TextureButton(
              texture: _spriteSheetUI['btn_level_down.png']!,
              width: 30.0,
              height: 30.0,
              onPressed: onStartLevelDown)),
      Positioned(
          left: 120.0,
          top: 14.0,
          child: TextureButton(
              onPressed: onPlay,
              texture: _spriteSheetUI['btn_play.png']!,
              label: "PLAY",
              textStyle: const TextStyle(
                  fontFamily: "Orbitron", fontSize: 28.0, letterSpacing: 3.0),
              textAlign: TextAlign.center,
              width: 181.0,
              height: 62.0))
    ]);
  }
}

class MainSceneBackground extends StatefulWidget {
  const MainSceneBackground({Key? key}) : super(key: key);

  @override
  MainSceneBackgroundState createState() => MainSceneBackgroundState();
}

class MainSceneBackgroundState extends State<MainSceneBackground> {
  late MainSceneBackgroundNode _backgroundNode;

  @override
  void initState() {
    super.initState();
    _backgroundNode = MainSceneBackgroundNode();
  }

  @override
  Widget build(BuildContext context) {
    return SpriteWidget(
      _backgroundNode,
      transformMode: SpriteBoxTransformMode.fixedWidth,
    );
  }
}

class MainSceneBackgroundNode extends NodeWithSize {
  late Sprite _bgTop;
  late Sprite _bgBottom;
  late RepeatedImage _background;
  late RepeatedImage _nebula;

  MainSceneBackgroundNode() : super(const Size(320.0, 320.0)) {
    // Add background
    _background = RepeatedImage(_imageMap["assets/starfield.png"]!);
    addChild(_background);

    StarField starField = StarField(_spriteSheet, 200, true);
    addChild(starField);

    // Add nebula
    _nebula = RepeatedImage(_imageMap["assets/nebula.png"]!, BlendMode.plus);
    addChild(_nebula);

    _bgTop = Sprite.fromImage(_imageMap["assets/ui_bg_top.png"]!);
    _bgTop.pivot = Offset.zero;
    _bgTop.size = const Size(320.0, 108.0);
    addChild(_bgTop);

    _bgBottom = Sprite.fromImage(_imageMap["assets/ui_bg_bottom.png"]!);
    _bgBottom.pivot = const Offset(0.0, 1.0);
    _bgBottom.size = const Size(320.0, 97.0);
    addChild(_bgBottom);
  }

  @override
  void paint(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0.0, 0.0, 320.0, 320.0),
        Paint()..color = const Color(0xff000000));
    super.paint(canvas);
  }

  @override
  void spriteBoxPerformedLayout() {
    _bgBottom.position = Offset(0.0, spriteBox!.visibleArea!.size.height);
  }

  @override
  void update(double dt) {
    _background.move(10.0 * dt);
    _nebula.move(100.0 * dt);
  }
}

class LaserDisplay extends StatelessWidget {
  const LaserDisplay({
    required this.level,
    Key? key,
  }) : super(key: key);

  final int level;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        child: SizedBox(
            child: SpriteWidget(LaserDisplayNode(level)),
            width: 26.0,
            height: 26.0));
  }
}

class LaserDisplayNode extends NodeWithSize {
  LaserDisplayNode(int level) : super(const Size(16.0, 16.0)) {
    Node placementNode = Node();
    placementNode.position = const Offset(8.0, 8.0);
    placementNode.scale = 0.7;
    addChild(placementNode);
    addLaserSprites(placementNode, level, 0.0, _spriteSheet);
  }
}
