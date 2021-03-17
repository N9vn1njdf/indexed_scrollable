import 'package:flutter/material.dart';
import 'package:indexed_scrollable/indexed_scrollable.dart';

class SliverListWrapper extends StatelessWidget {
  final String prefix;
  final List<String> data;

  SliverListWrapper(this.prefix, this.data);

  IndexedWidget builder(BuildContext context, int i) {
    final key = '$prefix\_$i';

    return IndexedWidget(
      indexKey: key,
      child: Container(
        padding: EdgeInsets.all(10),
        height: 500,
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

  @override
  Widget build(BuildContext context) {
    ///
    /// Учитываются только [SliverList] с [SliverChildBuilderDelegate]
    ///
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        builder,
        childCount: data.length,
      ),
    );
  }
}
