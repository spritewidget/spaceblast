part of 'game_demo.dart';

class CoordinateSystem extends SingleChildRenderObjectWidget {
  const CoordinateSystem({
    super.key,
    required this.systemSize,
    this.systemType = CoordinateSystemType.fixedWidth,
    required Widget super.child,
  });

  final Size systemSize;
  final CoordinateSystemType systemType;

  @override
  RenderCoordinateSystem createRenderObject(BuildContext context) {
    return RenderCoordinateSystem(
      systemSize: systemSize,
      systemType: systemType,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCoordinateSystem renderObject,
  ) {
    renderObject.systemSize = systemSize;
    renderObject.systemType = systemType;
  }
}
