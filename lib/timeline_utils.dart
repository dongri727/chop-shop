import 'dart:math';
import 'dart:ui';
import 'timeline_entry.dart';

class TickColors {
  //Color background;
  late Color long;
  late Color short;
  late Color text;
  late double start;
  late double screenY;
}

class TapTarget {
  late TimelineEntry entry;
  late Rect rect;
  bool zoom = false;
}
