part of game;

typedef PointSetterCallback = void Function(Offset value);

class ActionCircularMove extends MotionInterval {
  ActionCircularMove(
    this.setter,
    this.center,
    this.radius,
    this.startAngle,
    this.clockWise,
    double duration,
  ) : super(duration);

  final PointSetterCallback setter;
  final Offset center;
  final double radius;
  final double startAngle;
  final bool clockWise;

  @override
  void update(double t) {
    if (!clockWise) t = -t;
    double rad = radians(startAngle + t * 360.0);
    Offset offset = Offset(math.cos(rad) * radius, math.sin(rad) * radius);
    Offset pos = center + offset;
    setter(pos);
  }
}

class ActionOscillate extends MotionInterval {
  ActionOscillate(this.setter, this.center, this.radius, double duration)
      : super(duration);

  final PointSetterCallback setter;
  final Offset center;
  final double radius;

  @override
  void update(double t) {
    double rad = radians(t * 360.0);
    Offset offset = Offset(math.sin(rad) * radius, 0.0);
    setter(center + offset);
  }
}
