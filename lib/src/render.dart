import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HTableColumnWidth {
  const HTableColumnWidth();
}

class HFlexColumnWidth extends HTableColumnWidth {
  final double flex;

  const HFlexColumnWidth(this.flex);
}

class HFixedColumnWidth extends HTableColumnWidth {
  final double value;

  const HFixedColumnWidth(this.value);
}

class HTableRenderData extends BoxParentData {
  final int x;
  final int y;
  final int rowspan;
  final int colspan;

  Rect _darwRect;

  HTableRenderData({
    this.x,
    this.y,
    this.rowspan,
    this.colspan,
  });
}

class RenderHTableBox extends RenderBox {
  RenderHTableBox({
    ImageConfiguration configuration = ImageConfiguration.empty,
    RenderBox child,
    List<double> rowHeights,
    int colCount,
    int rowCount,
    Map<int, HTableColumnWidth> columnWidths,
    HTableColumnWidth defaultColumnWidth,
    BorderSide border,
  }) : assert(configuration != null) {
    if (null != child) {
      this._children.add(child);
    }
    _configuration = configuration;
    _rowHeights = rowHeights;
    _colCount = colCount;
    _rowCount = rowCount;
    _columnWidths = columnWidths ?? {};
    _defaultColumnWidth = defaultColumnWidth;
    _border = border;
  }

  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;

  set configuration(ImageConfiguration value) {
    assert(value != null);
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  List<double> _colWidths = [];

  int _colCount;

  set rowCount(int value) {
    _rowCount = value;
    markNeedsLayout();
  }

  Map<int, HTableColumnWidth> _columnWidths;

  set columnWidths(Map<int, HTableColumnWidth> value) {
    _columnWidths = value ?? {};
    markNeedsLayout();
  }

  HTableColumnWidth _defaultColumnWidth;

  set defaultColumnWidth(HTableColumnWidth value) {
    _defaultColumnWidth = value;
    markNeedsLayout();
  }

  List<double> _rowHeights;

  set rowHeights(List<double> value) {
    _rowHeights = value;
    markNeedsLayout();
  }

  int _rowCount;

  set colCount(int value) {
    _colCount = value;
    markNeedsLayout();
  }

  set children(List<RenderBox> value) {
    _children = value;
    markNeedsLayout();
  }

  BorderSide _border;

  set border(BorderSide value) {
    if (_border == value) return;
    _border = value;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(size.width != null);
    assert(size.height != null);
    final ImageConfiguration filledConfiguration = configuration.copyWith(size: size);

    try {
      for (var item in _children) {
        context.paintChild(item, offset + (item.parentData as HTableRenderData)._darwRect.topLeft);
      }
      double _borderWidth = BorderStyle.solid == _border.style ? _border.width : 0;
      if (0 < _borderWidth) {
        Paint paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _border.width
          ..color = _border.color ?? Color(0xfff0f0f0);
        for (var item in _children) {
          context.canvas.drawRect((item.parentData as HTableRenderData)._darwRect.shift(offset), paint);
        }
        context.canvas.drawRect(offset & size, paint);
      }
    } catch (e) {}
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageConfiguration>('configuration', configuration));
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! HTableRenderData) child.parentData = HTableRenderData();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
//    if (child != null) return child.getMinIntrinsicWidth(height);
//    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
//    if (child != null) return child.getMaxIntrinsicWidth(height);
//    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
//    if (child != null) return child.getMinIntrinsicHeight(width);
//    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
//    if (child != null) return child.getMaxIntrinsicHeight(width);
//    return 0.0;
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    if (_children != null) {
      for (var child in _children) {
        child.getDistanceToActualBaseline(baseline);
      }
    } else {
      return super.computeDistanceToActualBaseline(baseline);
    }
  }

  double _getHeight(int start, int rowspan) {
    double height = 0;
    for (int i = start; i < start + rowspan && i < _rowCount; ++i) {
      height += _rowHeights[i];
    }
    return height;
  }

  double _getWidth(int start, int colspan) {
    double height = 0;
    for (int i = start; i < start + colspan && i < _colCount; ++i) {
      height += _colWidths[i];
    }
    return height;
  }

  void _computeColumnWidths(BoxConstraints constraints) {
    double fixed = 0;
    double flex = 0;
    for (int i = 0; i < _colCount; ++i) {
      var columnWidth = _columnWidths[i] ?? _defaultColumnWidth;
      if (columnWidth is HFixedColumnWidth) {
        fixed += columnWidth.value;
      } else if (columnWidth is HFlexColumnWidth) {
        flex += columnWidth.flex;
      }
    }

    double width = 0 < flex ? (constraints.biggest.width - fixed) / flex : 0;
    final List<double> widths = List<double>(_colCount);
    for (int i = 0; i < _colCount; ++i) {
      var columnWidth = _columnWidths[i] ?? _defaultColumnWidth;
      if (columnWidth is HFixedColumnWidth) {
        widths[i] = columnWidth.value;
      } else if (columnWidth is HFlexColumnWidth) {
        widths[i] = width * columnWidth.flex;
      }
    }
    _colWidths = widths;
  }

  @override
  void performLayout() {
    _computeColumnWidths(constraints);
    if (_children != null) {
      for (var item in _children) {
        var data = (item.parentData as HTableRenderData);
        data._darwRect = Rect.fromLTWH(
          _getWidth(0, data.x),
          _getHeight(0, data.y),
          _getWidth(data.x, data.colspan),
          _getHeight(data.y, data.rowspan),
        );

        data.offset = data._darwRect.topLeft;

        item.layout(
          BoxConstraints.tightFor(
            width: data._darwRect.width,
            height: data._darwRect.height,
          ),
          parentUsesSize: true,
        );
      }
      size = constraints.biggest;
    } else {
      performResize();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    for (int index = _children.length - 1; index >= 0; index -= 1) {
      final child = _children[index];
      if (child != null) {
        final BoxParentData childParentData = child.parentData as BoxParentData;
        final bool isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child.hitTest(result, position: transformed);
          },
        );
        if (isHit) return true;
      }
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}

  //////////////////////////////////////////////////////////////////////////////////
  List<RenderBox> _children = [];

  void insertChild(RenderBox value) {
    if (null != value) {
      _children.add(value);
      adoptChild(value);
    }
  }

  void removeChild(RenderBox value) {
    if (null != value) {
      _children.remove(value);
      dropChild(value);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (var child in _children) {
      if (child != null) child.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    for (var _child in _children) {
      if (_child != null) _child.detach();
    }

    markNeedsPaint();
  }

  @override
  void redepthChildren() {
    for (var child in _children) {
      if (child != null) redepthChild(child);
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    for (var child in _children) {
      if (child != null) visitor(child);
    }
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return _children.map((e) => e.toDiagnosticsNode(name: 'child'))?.toList() ?? <DiagnosticsNode>[];
  }

  bool debugValidateChild(RenderObject child) {
    assert(() {
      if (child is! RenderBox) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('A $runtimeType expected a child of type RenderBox but received a '
              'child of type ${child.runtimeType}.'),
          ErrorDescription(
            'RenderObjects expect specific types of children because they '
            'coordinate with their children during layout and paint. For '
            'example, a RenderSliver cannot be the child of a RenderBox because '
            'a RenderSliver does not understand the RenderBox layout protocol.',
          ),
          ErrorSpacer(),
          DiagnosticsProperty<dynamic>(
            'The $runtimeType that expected a RenderBox child was created by',
            debugCreator,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
          ErrorSpacer(),
          DiagnosticsProperty<dynamic>(
            'The ${child.runtimeType} that did not match the expected child type '
            'was created by',
            child.debugCreator,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
        ]);
      }
      return true;
    }());
    return true;
  }
}

class RenderHTableCellBox extends RenderProxyBox {
  final int rowspan;
  final int colspan;
  final int x;
  final int y;

  RenderHTableCellBox({
    this.rowspan,
    this.colspan,
    this.x,
    this.y,
  }) {
    parentData = HTableRenderData(
      rowspan: rowspan,
      colspan: colspan,
      x: x,
      y: y,
    );
  }

  @override
  bool hitTestSelf(Offset position) {
    return child.hitTestSelf(position);
  }

  @override
  bool get sizedByParent => child.sizedByParent;
}
