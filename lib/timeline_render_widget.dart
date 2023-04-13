import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:chop_shop/timeline.dart';

class TimelineRenderWidget extends LeafRenderObjectWidget {
  final timeline;

  TimelineRenderWidget( {Key? key, required this.timeline}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TimelineRenderObject()
        ..timeline = timeline;
  }

  @override
  void didUnmountRenderObject(covariant TimelineRenderObject renderObject) {
    renderObject.timeline.isActive = false;
  }
}

class TimelineRenderObject extends RenderBox {
  static const List<Color> lineColors = [
    Color.fromARGB(255, 125, 195, 184),
    Color.fromARGB(255, 190, 224, 146),
    Color.fromARGB(255, 238, 155, 75),
    Color.fromARGB(255, 202, 79, 63),
    Color.fromARGB(255, 128, 28, 15)
  ];

  late Timeline _timeline;

  @override
  Timeline get timeline => _timeline;

  set timeline(Timeline value) {
    if (_timeline == value) {
      return;
    }
    _timeline = value;
  }
}