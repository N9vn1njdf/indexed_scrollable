import 'package:flutter/widgets.dart';

class IndexedWidget extends StatelessWidget {
  final String indexKey;
  final Widget child;

  IndexedWidget({@required this.indexKey, @required this.child}) : super(key: Key(indexKey));

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
