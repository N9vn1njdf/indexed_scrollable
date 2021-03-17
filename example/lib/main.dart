import 'package:example/reversed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:indexed_scrollable/indexed_scrollable.dart';

import './data.dart';
import 'default.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndexedScrollable Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Default()),
              );
            },
            child: Text('Default list'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Reversed()),
              );
            },
            child: Text('Reversed list'),
          ),
        ],
      ),
    );
  }
}
