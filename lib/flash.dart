part of 'game_demo.dart';

class Flash extends NodeWithSize {
  Flash(super.size, this.duration) {
    MotionTween fade = MotionTween<double>(
      setter: (a) => _opacity = a,
      start: 1.0,
      end: 0.0,
      duration: duration,
    );
    MotionSequence seq = MotionSequence(
      motions: <Motion>[
        fade,
        MotionRemoveNode(node: this),
      ],
    );
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
