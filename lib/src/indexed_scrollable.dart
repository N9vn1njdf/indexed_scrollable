import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import './indexed_scroll_controller.dart';

/// Обертка для Scrollable
/// Все аргументы конструктора(кроме [key]) прокидываются в оригинальный [Scrollable]
///
/// При первом кадре вычисляет размеры всех виджетов в [SilverList], внутри [Viewport]
/// Затем передает эти данные в текущий [Scrollable.ScrollPosition], через [scrollableKey.currentState.position]
///
/// Логика:
///
/// 1. Получаем [Viewport], переданный через [viewportBuilder].
/// 2. Получаем массив [SliverList], который передан в [slivers].
/// 3. Для каждого [SliverList] получаем всех детей и определяем их размер и индекс.
class IndexedScrollable extends StatefulWidget {
  final Key key;
  final AxisDirection axisDirection;
  final IndexedScrollController controller;
  final ScrollPhysics physics;
  final Widget Function(BuildContext, ViewportOffset) viewportBuilder;
  final double Function(ScrollIncrementDetails) incrementCalculator;
  final bool excludeFromSemantics;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final String restorationId;

  IndexedScrollable({
    this.key,
    this.axisDirection = AxisDirection.down,
    this.controller,
    this.physics,
    this.viewportBuilder,
    this.incrementCalculator,
    this.excludeFromSemantics = false,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.restorationId,
  }) : super(key: key);

  @override
  _CustomScrollableState createState() => _CustomScrollableState();
}

class _CustomScrollableState extends State<IndexedScrollable> {
  /// Для доступа к [ScrollableState]
  final scrollableKey = GlobalKey<ScrollableState>();

  /// Оригинальный [Scrollable]
  Scrollable scrollable;

  /// [ScrollableState.ScrollPosition]
  /// Создается оригинальным [Scrollable], через [ScrollController.createScrollPosition]
  IndexedScrollPosition get position => scrollableKey.currentState?.position;

  /// Текущий [Viewport], который создан через [viewportBuilder]
  Viewport viewport;

  /// Виджеты, для которых нужно узнать размер
  Map<Key, Widget> children = {};

  /// Проходит ли индексация в текущий момент
  bool indexing = false;
  Completer<void> indexingCompleter;

  @override
  void initState() {
    super.initState();

    scrollable = Scrollable(
      key: scrollableKey,
      axisDirection: widget.axisDirection,
      controller: widget.controller,
      physics: widget.physics,
      viewportBuilder: widget.viewportBuilder,
      incrementCalculator: widget.incrementCalculator,
      excludeFromSemantics: widget.excludeFromSemantics,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      restorationId: widget.restorationId,
    );

    /// Получаем текущий [Viewport]
    viewport = scrollable.viewportBuilder(context, ViewportOffset.zero()) as MultiChildRenderObjectWidget;

    /// Запускаем индексирование
    // index();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      position.indexCallback = index;
    });
  }

  /// Ищет все [SliverList] в [scrollable]
  List<SliverList> _getSliverLists() {
    final List<SliverList> result = [];

    void visitor(Element element) {
      if (element.widget is SliverList) {
        result.add(element.widget);
      }
      element.visitChildren(visitor);
    }

    scrollableKey.currentContext.visitChildElements(visitor);
    return result;
  }

  /// Индексирует всех детей, чтобы получить их размеры и порядковый номер во [Viewport]
  Future<void> index() {
    if (indexing) {
      return null;
    }
    print('Indexing content...');

    indexingCompleter = new Completer();

    final List<Widget> rawChildren = [];

    final lists = _getSliverLists();
    lists.forEach((SliverList list) {
      final childs = getSliverListChildren(list);
      rawChildren.addAll(childs);
    });

    for (var i = 0; i < rawChildren.length; i++) {
      final child = rawChildren[i];

      /// Не должно быть одинаковых ключей внутри [Viewport]
      assert(children.containsKey(child.key) == false);

      children[child.key] = SizeComputator(
        child: child,
        childKey: child.key,
        childIndex: i,
        callback: sizeCallback,
      );
    }

    if (rawChildren.isEmpty) {
      print('Viewport is empty');
    }

    setState(() {});

    return indexingCompleter.future;
  }

  /// Обрабатывает информацию, полученную от [SizeComputator]
  /// Затем удаляет объект из [children]
  ///
  /// Если [children] пуст, вызывает [setState], чтобы рисовать только оригинальный [Viewport]
  void sizeCallback(Key childKey, int childIndex, Size size) {
    children.remove(childKey);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      position.setChildSize(childKey, childIndex, size);
      position.indexCallback = index;
    });

    if (children.isEmpty) {
      setState(() => indexing = false);
      print('Indexing done');

      SchedulerBinding.instance.addPostFrameCallback((_) {
        indexingCompleter.complete();
      });
    }
  }

  /// Возвращает массив детей [SliverList], которые билдятся через [SliverChildBuilderDelegate.builder]
  /// Для этого вызываем [builder] вручную, на каждом объекте
  List<Widget> getSliverListChildren(SliverList sliverList) {
    assert(sliverList.delegate is SliverChildBuilderDelegate);
    final delegate = sliverList.delegate as SliverChildBuilderDelegate;

    final List<Widget> result = [];
    for (var i = 0; i < delegate.childCount; i++) {
      result.add(delegate.builder(context, i));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    position?.indexCallback = index;

    if (children.isEmpty) {
      return scrollable;
    }

    return Stack(
      children: [
        scrollable,
        ...children.values.toList(),
      ],
    );
  }
}

/// Обертка для вычисления размеров [child]
///
/// Логика:
/// 1. Оборачиваем [child] в [Opacity] с нулевым значением
/// 2. После первой отрисовки отправляем в [callback] данные о размерах, ключе и индексе
class SizeComputator extends StatefulWidget {
  final Widget child;
  final Key childKey;
  final int childIndex;
  final Function(Key childKey, int childIndex, Size childSize) callback;

  SizeComputator({
    @required this.child,
    @required this.childKey,
    @required this.childIndex,
    @required this.callback,
  });

  @override
  _SizeComputatorState createState() => _SizeComputatorState();
}

class _SizeComputatorState extends State<SizeComputator> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = context.findRenderObject();
      widget.callback(widget.childKey, widget.childIndex, renderBox.size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Opacity(
        opacity: 0,
        child: widget.child,
      ),
      bottom: 0,
      left: 0,
      right: 0,
    );
  }
}
