part of 'game_demo.dart';

enum CoordinateSystemType {
  fixedWidth,
  fixedHeight,
  stretch,
}

class RenderCoordinateSystem extends RenderProxyBox {
  RenderCoordinateSystem({
    required Size systemSize,
    required CoordinateSystemType systemType,
    RenderBox? child,
  }) : super(child) {
    _systemSize = systemSize;
    _systemType = systemType;
  }

  Size get systemSize => _systemSize;
  late Size _systemSize;
  set systemSize(Size systemSize) {
    if (_systemSize == systemSize) return;
    _systemSize = systemSize;
    markNeedsPaint();
  }

  CoordinateSystemType get systemType => _systemType;
  late CoordinateSystemType _systemType;
  set systemType(CoordinateSystemType systemType) {
    if (_systemType == systemType) return;
    _systemType = systemType;
    markNeedsPaint();
  }

  Matrix4 get _effectiveTransform {
    double scaleX = 1.0;
    double scaleY = 1.0;

    switch (systemType) {
      case CoordinateSystemType.stretch:
        scaleX = size.width / systemSize.width;
        scaleY = size.height / systemSize.height;
        break;
      case CoordinateSystemType.fixedWidth:
        scaleX = size.width / systemSize.width;
        scaleY = scaleX;
        break;
      case CoordinateSystemType.fixedHeight:
        scaleY = size.height / systemSize.height;
        scaleX = scaleY;
        break;
      default:
        assert(false);
    }

    Matrix4 transformMatrix = Matrix4.identity();
    transformMatrix.scale(scaleX, scaleY);

    return transformMatrix;
  }

  @override
  bool hitTest(HitTestResult result, {required Offset position}) {
    Matrix4 inverse = Matrix4.zero();
    // TODO(abarth): Check the determinant for degeneracy.
    inverse.copyInverse(_effectiveTransform);

    Vector3 position3 = Vector3(position.dx, position.dy, 0.0);
    Vector3 transformed3 = inverse.transform3(position3);
    Offset transformed = Offset(transformed3.x, transformed3.y);
    return super.hitTest(result as BoxHitTestResult, position: transformed);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      Matrix4 transform = _effectiveTransform;
      Offset? childOffset = MatrixUtils.getAsTranslation(transform);
      if (childOffset == null) {
        context.pushTransform(needsCompositing, offset, transform, super.paint);
      } else {
        super.paint(context, offset + childOffset);
      }
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    transform.multiply(_effectiveTransform);
    super.applyPaintTransform(child, transform);
  }

//  void debugDescribeChildren(List<String> settings) {
//    super.debugDescribeChildren(settings);
//    settings.add('systemSize: $systemSize');
//    settings.add('systemType: $systemType');
//  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  // Perform layout
  @override
  void performLayout() {
    double xScale = _effectiveTransform[0];
    double yScale = _effectiveTransform[5];

    if (child != null) {
      child!.layout(BoxConstraints.tightFor(
          width: size.width / xScale, height: size.height / yScale));
    }
  }
}
