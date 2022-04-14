part of game;

class RepeatedImage extends Node {
  late Sprite _sprite0;
  late Sprite _sprite1;

  RepeatedImage(ui.Image image, [ui.BlendMode? mode]) {
    _sprite0 = Sprite.fromImage(image);
    _sprite0.size = const Size(1024.0, 1024.0);
    _sprite0.pivot = Offset.zero;
    _sprite1 = Sprite.fromImage(image);
    _sprite1.size = const Size(1024.0, 1024.0);
    _sprite1.pivot = Offset.zero;
    _sprite1.position = const Offset(0.0, -1024.0);

    if (mode != null) {
      _sprite0.blendMode = mode;
      _sprite1.blendMode = mode;
    }

    addChild(_sprite0);
    addChild(_sprite1);
  }

  void move(double dy) {
    double yPos = (position.dy + dy) % 1024.0;
    position = Offset(0.0, yPos);
  }
}
