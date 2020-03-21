import 'dart:collection';

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

  List<_HTableData> get storChildren {
    List<_HTableData> ret = [];
    var ys = List<int>.generate(colCount, (index) => 0);
    for (int y = 0; y < rowCount; y++) {
      var rows = children[y];
      int xs = 0;
      for (int x = 0; x < colCount; ++x) {
        if (y >= ys[x] && xs < rows.children.length) {
          var cell = rows.children[xs];
          ret.add(
            _HTableData(
              x: x,
              y: y < ys[x] ? ys[x] : y,
              colspan: cell.colspan,
              rowspan: cell.rowspan,
              child: Align(child: cell.child, alignment: alignment),
            ),
          );
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
  List<Element> _children = [];

  @override
  HTable get widget => super.widget as HTable;

  @override
  HTableRender get renderObject => super.renderObject as HTableRender;
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void insertChildRenderObject(RenderObject child, IndexedSlot<Element> slot) {
    final HTableRender renderObject = this.renderObject;
//    assert(renderObject.debugValidateChild(child));
//    renderObject.insert(child, after: slot?.value?.renderObject);
//    assert(renderObject == this.renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, IndexedSlot<Element> slot) {
//    final HTableRender renderObject = this.renderObject;
//    assert(child.parent == renderObject);
//    renderObject.move(child, after: slot?.value?.renderObject);
//    assert(renderObject == this.renderObject);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
//    final ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>> renderObject =
//        this.renderObject as ContainerRenderObjectMixin<RenderObject, ContainerParentDataMixin<RenderObject>>;
//    assert(child.parent == renderObject);
//    renderObject.remove(child);
//    assert(renderObject == this.renderObject);
  }

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
    _children = List<Element>(widget.storChildren.length);
    Element previousChild;
    for (int i = 0; i < _children.length; i += 1) {
      final Element newChild = inflateWidget(widget.storChildren[i], IndexedSlot<Element>(i, previousChild));
      _children[i] = newChild;
      previousChild = newChild;
    }
  }

  @override
  void update(HTable newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _children = updateChildren(_children, widget.storChildren, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();

    renderObject.children = _children.map<RenderBox>((e) {
      return (e.renderObject)
        ..parentData = HTableRenderData(
          x: (e.widget as _HTableData).x,
          y: (e.widget as _HTableData).y,
          rowspan: (e.widget as _HTableData).rowspan,
          colspan: (e.widget as _HTableData).colspan,
        );
    }).toList();
  }
}

class _HTableData extends StatelessWidget {
  final Widget child;
  final int x;
  final int y;
  final int rowspan;
  final int colspan;

  _HTableData({
    this.x,
    this.y,
    this.rowspan,
    this.colspan,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
