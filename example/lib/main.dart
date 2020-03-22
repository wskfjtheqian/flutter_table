import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:htable/htable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _aaa = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            _build(context),
          ],
        ),
      ),
    );
  }

  _build(BuildContext context) {
    return Table(
      children: [
        TableRow(children: [
          InkWell(
            child: Text("data"),
            onTap: _onTap,
          )
        ])
      ],
    );
  }

  void _onTap() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context,state){
            return Material(
              child: HTable(
//              border: BorderSide(color: Color(0xff808080), width: 0.3),
//              columnWidths: {
//                0: HFixedColumnWidth(50),
//              },
                rowCount: 3,
                colCount: 3,
                children: [
                  HTableRow(
                    children: [
                      HTableCell(colspan: 2, child: Text("1")),
                      HTableCell(child: Text("2")),
                    ],
                  ),
                  HTableRow(
                    children: [
                      HTableCell(
                        child: Container(
                          margin: EdgeInsets.all(0.5),
                          color: Colors.deepPurpleAccent,
                          child: Center(
                            child: Text("4"),
                          ),
                        ),
                      ),
                      HTableCell(child: Text("5"), rowspan: 2),
                    ],
                  ),
                  HTableRow(
                    children: [
                      HTableCell(child: Text("6")),
                      HTableCell(
                        rowspan: 2,
                        child: Container(
                          margin: EdgeInsets.all(0.5),
                          color: Colors.deepPurpleAccent,
                          child: InkWell(
                            child: Center(
                              child: Text("${_aaa}"),
                            ),
                            onTap: () {
                              state(() {
                                _aaa++;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
