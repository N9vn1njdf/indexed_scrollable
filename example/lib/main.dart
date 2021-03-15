import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:indexed_scrollable/indexed_scrollable.dart';

import './data.dart';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  IndexedScrollController controller;

  /// Тестовые данные для SliverList. По сути это просто ключи для элементов списка
  /// Важно! Каждое значение должно быть уникальным, в рамках обоих массивов.
  /// Т.е  каждый ключ должен быть уникален в рамках одного Viewport
  List<String> data1 = [];
  List<String> data2 = [];

  @override
  void initState() {
    super.initState();
    controller = IndexedScrollController();

    data1 = Data.get(20);
    data2 = Data.get(20);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  IndexedWidget builder(BuildContext context, int i, String prefix, List<String> data) {
    final key = '$prefix\_$i';

    return IndexedWidget(
      indexKey: key,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Wrap(children: [
          Text('indexKey: $key', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 15, width: double.infinity),
          Text(data[i]),
        ]),
        color: Colors.greenAccent,
        margin: EdgeInsets.only(bottom: 10),
      ),
    );
  }

  Widget jumpButton(String key) {
    return FlatButton(
      color: Colors.green,
      onPressed: () => controller.jumpToKey(key),
      child: Text(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<SliverList> slivers = [
      /// Учитываются только [SliverList] с [SliverChildBuilderDelegate]
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (c, i) => builder(c, i, 'item_1', data1),
          childCount: data1.length,
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (c, i) => builder(c, i, 'item_2', data2),
          childCount: data2.length,
        ),
      ),
    ];

    final scrollable = CustomScrollable(
      controller: controller,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return Viewport(
          offset: offset,
          slivers: slivers,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: 350,
            child: scrollable,
          ),
          Wrap(
            spacing: 5,
            children: [
              jumpButton('item_1_0'),
              jumpButton('item_1_5'),
              jumpButton('item_1_15'),
              jumpButton('item_2_0'),
              jumpButton('item_2_1'),
              jumpButton('item_2_2'),
              jumpButton('item_2_3'),
              jumpButton('item_2_15'),
              jumpButton('item_2_14'),
            ],
          ),
          FlatButton(
            color: Colors.blueAccent,
            onPressed: () => controller.index(),
            child: Text(
              'Index content',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
