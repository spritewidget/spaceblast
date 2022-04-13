part of game;

class StarField extends NodeWithSize {
  late ui.Image _image;
  final SpriteSheet _spriteSheet;
  final int _numStars;
  final bool _autoScroll;

  late List<Offset> _starPositions;
  late List<double> _starScales;
  late List<Rect> _rects;
  List<Color>? _colors;

  final double _padding = 50.0;
  Size _paddedSize = Size.zero;

  final Paint _paint = Paint()
    ..filterQuality = ui.FilterQuality.low
    ..isAntiAlias = false
    ..blendMode = ui.BlendMode.plus;

  StarField(this._spriteSheet, this._numStars, [this._autoScroll = false])
      : super(Size.zero) {
    _image = _spriteSheet.image;
  }

  void addStars() {
    _starPositions = <Offset>[];
    _starScales = <double>[];
    _colors = <Color>[];
    _rects = <Rect>[];

    size = spriteBox!.visibleArea!.size;
    _paddedSize =
        Size(size.width + _padding * 2.0, size.height + _padding * 2.0);

    for (int i = 0; i < _numStars; i++) {
      _starPositions.add(
        Offset(
          randomDouble() * _paddedSize.width,
          randomDouble() * _paddedSize.height,
        ),
      );
      _starScales.add(randomDouble() * 0.4);
      _colors!.add(
        Color.fromARGB(
          (255.0 * (randomDouble() * 0.5 + 0.5)).toInt(),
          255,
          255,
          255,
        ),
      );
      _rects.add(_spriteSheet["star_${randomInt(2)}.png"]!.frame);
    }
  }

  @override
  void spriteBoxPerformedLayout() {
    addStars();
  }

  @override
  void paint(Canvas canvas) {
    // Create a transform for each star
    List<ui.RSTransform> transforms = <ui.RSTransform>[];
    for (int i = 0; i < _numStars; i++) {
      ui.RSTransform transform = ui.RSTransform(_starScales[i], 0.0,
          _starPositions[i].dx - _padding, _starPositions[i].dy - _padding);

      transforms.add(transform);
    }

    // Draw the stars
    canvas.drawAtlas(_image, transforms, _rects, _colors, ui.BlendMode.modulate,
        null, _paint);
  }

  void move(double dx, double dy) {
    for (int i = 0; i < _numStars; i++) {
      double xPos = _starPositions[i].dx;
      double yPos = _starPositions[i].dy;
      double scale = _starScales[i];

      xPos += dx * scale;
      yPos += dy * scale;

      if (xPos >= _paddedSize.width) xPos -= _paddedSize.width;
      if (xPos < 0) xPos += _paddedSize.width;
      if (yPos >= _paddedSize.height) yPos -= _paddedSize.height;
      if (yPos < 0) yPos += _paddedSize.height;

      _starPositions[i] = Offset(xPos, yPos);
    }
  }

  @override
  void update(double dt) {
    if (_autoScroll) {
      move(0.0, dt * 100.0);
    }
  }
}
