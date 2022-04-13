part of game;

class CoordinateSystem extends SingleChildRenderObjectWidget {
  const CoordinateSystem({
    Key? key,
    required this.systemSize,
    this.systemType = CoordinateSystemType.fixedWidth,
    required Widget child,
  }) : super(key: key, child: child);

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
