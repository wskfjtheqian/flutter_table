import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'render.dart';

class HTable extends RenderObjectWidget {
  HTable({
    Key key,
    this.children = const <HTableRow>[],
    BorderSide border,
    this.rowCount = 1,
    this.colCount = 1,
    this.columnWidths,
    this.defaultRowHight = 50,
    this.defaultColumnWidth = const HFlexColumnWidth(1.0),
    this.alignment = Alignment.center,
  }) : super(key: key) {
    _border = border ?? BorderSide(width: 0.5);
  }

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}

  final List<HTableRow> children;
  final int rowCount;
  final int colCount;
  final Map<int, HTableColumnWidth> columnWidths;
  final HTableColumnWidth defaultColumnWidth;
  final double defaultRowHight;
  final AlignmentGeometry alignment;
  BorderSide _border;

  @override
  _HTableRenderObjectElement createElement() => _HTableRenderObjectElement(this);

  @override
  RenderHTableBox createRenderObject(BuildContext context) {
    return RenderHTableBox(
      configuration: createLocalImageConfiguration(context),
      rowHeights: _getRowHeights(),
      colCount: colCount,
      rowCount: rowCount,
      columnWidths: columnWidths,
      defaultColumnWidth: defaultColumnWidth,
      border: _border,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHTableBox renderObject) {
    renderObject
      ..configuration = createLocalImageConfiguration(context)
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

  List<HTableCell> get storChildren {
    List<HTableCell> ret = [];
    var ys = List<int>.generate(colCount, (index) => 0);
    for (int y = 0; y < rowCount; y++) {
      var rows = children[y];
      int xs = 0;
      for (int x = 0; x < colCount; ++x) {
        if (y >= ys[x] && xs < rows.children.length) {
          var cell = rows.children[xs];
          cell._x = x;
          cell._y = y;
          ret.add(cell);
          for (var r = x; r < x + cell.colspan; ++r) {
            ys[r] += cell.rowspan;
          }
          xs++;
        }
      }
    }
    return ret;
  }
}

class _HTableRenderObjectElement extends RenderObjectElement {
  /// Creates an element that uses the given widget as its configuration.
  _HTableRenderObjectElement(HTable widget) : super(widget);

  @override
  HTable get widget => super.widget as HTable;

  List<Element> _children = [];

  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) visitor(child);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _children = updateChildren(_children, widget.storChildren);
  }

  @override
  void update(HTable newWidget) {
    super.update(newWidget);
    _children = updateChildren(_children, widget.storChildren, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
    assert(widget == newWidget);
  }

  @override
  void insertChildRenderObject(RenderObject child, IndexedSlot slot) {
    final RenderHTableBox renderObject = this.renderObject;

    assert(renderObject.debugValidateChild(child));
    renderObject.insertChild(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, IndexedSlot slot) {
    assert(false);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    final RenderHTableBox renderObject = this.renderObject;

    renderObject.removeChild(child);
    assert(renderObject == this.renderObject);
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

class HTableCell extends SingleChildRenderObjectWidget {
  final Widget child;
  final int rowspan;
  final int colspan;

  int _x;
  int _y;

  HTableCell({
    Key key,
    this.rowspan = 1,
    this.colspan = 1,
    this.child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHTableCellBox(
      colspan: colspan,
      rowspan: rowspan,
      x: _x,
      y: _y,
    );
  }
}
