part of game;

class Flash extends NodeWithSize {
  Flash(Size size, this.duration) : super(size) {
    MotionTween fade = MotionTween<double>((a) {
      _opacity = a;
    }, 1.0, 0.0, duration);
    MotionSequence seq = MotionSequence(<Motion>[fade, MotionRemoveNode(this)]);
    motions.run(seq);
  }

  double duration;
  double _opacity = 1.0;
  final Paint _cachedPaint = Paint();

  @override
  void paint(Canvas canvas) {
    // Update the color
    _cachedPaint.color =
        Color.fromARGB((255.0 * _opacity).toInt(), 255, 255, 255);
    // Fill the area
    applyTransformForPivot(canvas);
    canvas.drawRect(
        Rect.fromLTRB(0.0, 0.0, size.width, size.height), _cachedPaint);
  }
}
