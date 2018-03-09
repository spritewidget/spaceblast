part of game;

class CoordinateSystem extends SingleChildRenderObjectWidget {
  CoordinateSystem({ Key key, this.systemSize, this.systemType: CoordinateSystemType.fixedWidth, Widget child })
    : super(key: key, child: child) {
    assert(systemSize != null);
  }

  final Size systemSize;
  final CoordinateSystemType systemType;

  RenderCoordinateSystem createRenderObject(BuildContext context) {
    return new RenderCoordinateSystem(systemSize: systemSize, systemType: systemType);
  }

  void updateRenderObject(BuildContext context, RenderCoordinateSystem renderObject) {
    renderObject.systemSize = systemSize;
    renderObject.systemType = systemType;
  }
}
