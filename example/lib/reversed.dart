import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:indexed_scrollable/indexed_scrollable.dart';

import 'data.dart';
import 'sliver_list_wrapper.dart';

class Reversed extends StatefulWidget {
  @override
  _ReversedState createState() => _ReversedState();
}

class _ReversedState extends State<Reversed> {
  IndexedScrollController controller;

  /// Тестовые данные для SliverList. По сути это просто ключи для элементов списка
  /// Важно! Каждое значение должно быть уникальным, в рамках обоих массивов.
  /// Т.е  каждый ключ должен быть уникален в рамках одного Viewport
  List<String> data1 = [];
  List<String> data2 = [];

  @override
  void initState() {
    super.initState();
    controller = IndexedScrollController(reversed: true);

    data1 = Data.get(20);
    data2 = Data.get(20);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
    const direction = AxisDirection.up;

    final scrollable = IndexedScrollable(
      controller: controller,
      axisDirection: direction,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return Viewport(
          offset: offset,
          anchor: 1,
          axisDirection: direction,
          slivers: [
            SliverListWrapper('item_1', data1),
            SliverListWrapper('item_2', data2),
          ],
        );
      },
    );

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: 350,
            child: Scrollbar(
              controller: controller,
              isAlwaysShown: true,
              child: scrollable,
            ),
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
            onPressed: () => {
              controller.index().then((value) {
                print('Index completed!');
                print(controller?.offset);
                // controller.jumpToKey('item_1_3', offset: 10);
              })
            },
            child: Text(
              'Index content and jump to item_1_3',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
