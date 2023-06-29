import 'package:flutter/material.dart';

/// A label for [TimelineEntry].
/// なんだかわからないが消すとまずい
enum TimelineEntryType { Era, Incident }

/// Each entry in the timeline is represented by an instance of this object.
/// Each favorite, search result and detail page will grab the information from a reference
/// to this object.
///
/// They are all initialized at startup time by the [BlocProvider] constructor.
class TimelineEntry {
  late TimelineEntryType type;

  late String _label; // if you use current json
  late String _name; // change to your name of field
  Color accent = Colors.blueGrey;

  /// Each entry constitues an element of a tree:
  /// eras are grouped into spanning eras and events are placed into the eras they belong to.
  TimelineEntry? parent;
  List<TimelineEntry> children = [];

  /// All the timeline entries are also linked together to easily access the next/previous event.
  /// After a couple of seconds of inactivity on the timeline, a previous/next entry button will appear
  /// to allow the user to navigate faster between adjacent events.
  TimelineEntry? next;
  TimelineEntry? previous;

  /// All these parameters are used by the [Timeline] object to properly position the current entry.
  late double start;
  late double end;
  double y = 0.0;
  double endY = 0.0;
  double length = 0.0;
  double opacity = 0.0;
  double labelOpacity = 0.0;
  double targetLabelOpacity = 0.0;
  double delayLabel = 0.0;
  double legOpacity = 0.0;
  double labelY = 0.0;
  double labelVelocity = 0.0;

  bool get isVisible {
    return opacity > 0.0;
  }

  ///if you use current json
  String get label => _label;

  /// change to your name of field
  String get name => _name;

  ///if you use current json
  set label(String value) {
    _label = value;
  }

  /// change to your name of field
  set name(String value) {
    _name = value;
  }
}
