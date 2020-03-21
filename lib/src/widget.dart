import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:htable/src/render.dart';

class HTable extends RenderObjectWidget {
  final List<HTableRow> children;
  BorderSide _border;
  final int rowCount;
  final int colCount;
  final Map<int, HTableColumnWidth> columnWidths;
  final HTableColumnWidth defaultColumnWidth;
  final double defaultRowHight;
  final AlignmentGeometry alignment;

  HTable({
    this.children = const <HTableRow>[],
    BorderSide border,
    this.rowCount = 1,
    this.colCount = 1,
    this.columnWidths,
    this.defaultRowHight = 50,
    this.defaultColumnWidth = const HFlexColumnWidth(1.0),
    this.alignment = Alignment.center,
  })  : assert(null != defaultRowHight),
        assert(null != defaultColumnWidth),
        assert(null != rowCount && 0 < rowCount),
        assert(null != colCount && 0 < colCount),
        assert(null != children && children.isNotEmpty) {
    _border = border ?? BorderSide();
  }

  @override
  RenderObjectElement createElement() {
    return _HTableElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return HTableRender(
      rowHeights: _getRowHeights(),
      colCount: colCount,
      rowCount: rowCount,
      columnWidths: columnWidths,
      defaultColumnWidth: defaultColumnWidth,
      border: _border,
    );
  }

  @override
  void updateRenderObject(BuildContext context, HTableRender renderObject) {
    renderObject
      ..rowHeights = _getRowHeights()
      ..colCount = colCount
      ..rowCount = rowCount
      ..columnWidths = columnWidths
      ..defaultColumnWidth = defaultColumnWidth
      ..border = _border;
  }

  List<double> _getRowHeights() {
    List<double> heights = [];
    for (int i = 0; i < rowCount; ++i) {
      if (i < children.length) {
        heights.add(children[i].height ?? defaultRowHight);
      } else {
        heights.add(defaultRowHight);
      }
    }
    return heights;
  }
}

class HTableRow {
  final double height;
  final List<HTableCell> children;

  HTableRow({
    this.height = 50,
    this.children,
  }) : assert(null != children);
}

class HTableCell {
  final Widget child;
  final int rowspan;
  final int colspan;

  HTableCell({
    this.child,
    this.rowspan = 1,
    this.colspan = 1,
  });
}

class _HTableElement extends RenderObjectElement {
  _HTableElement(RenderObjectWidget widget) : super(widget);
  List<_HTableData> _children = [];

  @override
  HTable get widget => super.widget as HTable;

  @override
  HTableRender get renderObject => super.renderObject as HTableRender;

  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    _stor(widget);
  }

  void _stor(HTable htable) {
    var ys = List<int>.generate(htable.rowCount, (index) => 0);
    for (int y = 0; y < htable.colCount; ++y) {
      var rows = htable.children[y];
      int xs = 0;
      for (int x = 0; x < htable.rowCount; ++x) {
        if (y >= ys[x] && xs < rows.children.length) {
          var cell = rows.children[xs];
          _children.add(
            _HTableData(
              x: x,
              y: y < ys[x] ? ys[x] : y,
              colspan: cell.colspan,
              rowspan: cell.rowspan,
              element: inflateWidget(Align(child: cell.child, alignment: htable.alignment), null),
            ),
          );
          for (var r = x; r < x + cell.colspan; ++r) {
            ys[r] += cell.rowspan;
          }
          xs++;
        }
      }
    }
  }

  @override
  void insertChildRenderObject(RenderObject child, slot) {
    renderObject.setupParentData(child);
  }

  @override
  void moveChildRenderObject(RenderObject child, slot) {}

  @override
  void removeChildRenderObject(RenderObject child) {
    final TableCellParentData childParentData = child.parentData as TableCellParentData;
    renderObject.setChild(childParentData.x, childParentData.y, null);
  }

  @override
  void update(RenderObjectWidget newWidget) {
    _stor(newWidget);

    renderObject.children = _children.map<RenderBox>((e) {
      return (e.element.renderObject)
        ..parentData = HTableRenderData(
          x: e.x,
          y: e.y,
          rowspan: e.rowspan,
          colspan: e.colspan,
        );
    }).toList();
    super.update(newWidget);
  }
}

class _HTableData {
  final Element element;
  final int x;
  final int y;
  final int rowspan;
  final int colspan;

  _HTableData({
    this.x,
    this.y,
    this.rowspan,
    this.colspan,
    this.element,
  });
}
