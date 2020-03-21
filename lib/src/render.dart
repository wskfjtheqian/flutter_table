import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

class HTableRender extends RenderBox {
  List<RenderBox> _children = [];
  List<double> _rowHeights;
  int _colCount;
  int _rowCount;
  Map<int, HTableColumnWidth> _columnWidths;
  HTableColumnWidth _defaultColumnWidth;
  BorderSide _border;
  List<double> _colWidths = [];

  HTableRender({
    List<double> rowHeights,
    int colCount,
    int rowCount,
    Map<int, HTableColumnWidth> columnWidths,
    HTableColumnWidth defaultColumnWidth,
    BorderSide border,
  }) {
    _rowHeights = rowHeights;
    _colCount = colCount;
    _rowCount = rowCount;
    _columnWidths = columnWidths ?? {};
    _defaultColumnWidth = defaultColumnWidth;
    _border = border;
  }

  set rowCount(int value) {
    _rowCount = value;
    markNeedsLayout();
  }

  set columnWidths(Map<int, HTableColumnWidth> value) {
    _columnWidths = value ?? {};
    markNeedsLayout();
  }

  set defaultColumnWidth(HTableColumnWidth value) {
    _defaultColumnWidth = value;
    markNeedsLayout();
  }

  set rowHeights(List<double> value) {
    _rowHeights = value;
    markNeedsLayout();
  }

  set colCount(int value) {
    _colCount = value;
    markNeedsLayout();
  }

  set children(List<RenderBox> value) {
    _children = value;
    markNeedsLayout();
  }

  set border(BorderSide value) {
    if (_border == value) return;
    _border = value;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

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

  @override
  void performLayout() {
    _computeColumnWidths(constraints);
    for (var item in _children) {
      var data = (item.parentData as HTableRenderData);
      data._darwRect = Rect.fromLTWH(
        _getWidth(0, data.x),
        _getHeight(0, data.y),
        _getWidth(data.x, data.colspan),
        _getHeight(data.y, data.rowspan),
      );

      item.layout(
        BoxConstraints.tightFor(
          width: data._darwRect.width,
          height: data._darwRect.height,
        ),
        parentUsesSize: true,
      );
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    super.performResize();
    size = constraints.biggest;
  }

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    for (var item in _children) {
      item.markNeedsLayout();
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    for (final item in _children) {
      visitor(item);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final item in _children) {
      item.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    for (final item in _children) {
      item.detach();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    try {
      for (var item in _children) {
        context.paintChild(item, offset + (item.parentData as HTableRenderData)._darwRect.topLeft);
      }
      double _borderWidth = BorderStyle.solid == _border.style ? _border.width : 0;
      if (0 < _borderWidth) {
        Paint paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _border.width
          ..color = _border.color ?? Colors.grey;
        for (var item in _children) {
          context.canvas.drawRect((item.parentData as HTableRenderData)._darwRect.shift(offset), paint);
        }
        context.canvas.drawRect(offset & size, paint);
      }
    } catch (e) {}
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

  void setChild(int x, int y, param2) {}
}
