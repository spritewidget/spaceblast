part of game;

class PowerBar extends NodeWithSize {
  PowerBar(Size size, [this.power = 1.0]) : super(size);

  double power;

  final Paint _paintFill = Paint()..color = const Color(0xffffffff);
  final Paint _paintOutline = Paint()
    ..color = const Color(0xffffffff)
    ..strokeWidth = 1.0
    ..style = ui.PaintingStyle.stroke;

  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);

    canvas.drawRect(
      Rect.fromLTRB(0.0, 0.0, size.width - 0.0, size.height - 0.0),
      _paintOutline,
    );
    canvas.drawRect(
      Rect.fromLTRB(2.0, 2.0, (size.width - 2.0) * power, size.height - 2.0),
      _paintFill,
    );
  }
}
