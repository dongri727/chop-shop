import 'dart:developer';
import 'package:flutter/material.dart';

import 'timeline.dart';
import 'timeline_entry.dart';
import 'timeline_render_widget.dart';

class TimelineWidget extends StatefulWidget {
  final Timeline timeline;

  const TimelineWidget(this.timeline,
      {Key? key}) : super(key: key);

  @override
  TimelineWidgetState createState() => TimelineWidgetState();
}

class TimelineWidgetState extends State<TimelineWidget> {
  static const String defaultEraName = "Birth of the Universe";

  double _scaleStartYearStart = -100.0;
  double _scaleStartYearEnd = 100.0;


  /// Which era the Timeline is currently focused on.
  /// Defaults to [DefaultEraName].
  late String _eraName;

  /// Syntactic-sugar-getter.
  Timeline get timeline => widget.timeline;

  late Color _headerTextColor;
  late Color _headerBackgroundColor;

  void _scaleStart(ScaleStartDetails details) {
    //_lastFocalPoint = details.focalPoint;
    _scaleStartYearStart = timeline.start;
    _scaleStartYearEnd = timeline.end;
    timeline.isInteracting = true;
    timeline.setViewport(velocity: 0.0, animate: true);
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    double changeScale = details.scale;
    double scale =
        (_scaleStartYearEnd - _scaleStartYearStart) / context.size!.height;

    double focus = _scaleStartYearStart + details.focalPoint.dy * scale;
  }

  void _scaleEnd(ScaleEndDetails details) {
    timeline.isInteracting = false;
    timeline.setViewport();
  }

  void _longPress() {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
/*    if (_touchedBubble != null) {
      MenuItemData target = MenuItemData.fromEntry(_touchedBubble.entry);

      timeline.padding = EdgeInsets.only(
          top: TopOverlap +
              devicePadding.top +
              target.padTop +
              Timeline.Parallax,
          bottom: target.padBottom);
      timeline.setViewport(
          start: target.start, end: target.end, animate: true, pad: true);
    }*/
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
/*    if (timeline != null) {
      widget.timeline.isActive = true;
      _eraName = timeline.currentEra != null
          ? timeline.currentEra.label
          : defaultEraName;
      timeline.onHeaderColorsChanged = (Color background, Color text) {
        setState(() {
          _headerTextColor = text;
          _headerBackgroundColor = background;
        });
      };
      /// Update the label for the [Timeline] object.
      timeline.onEraChanged = (TimelineEntry entry) {
        setState(() {
          _eraName = entry != null ? entry.label : defaultEraName;
        });
      };

      _headerTextColor = timeline.headerTextColor;
      _headerBackgroundColor = timeline.headerBackgroundColor;
      //_showFavorites = timeline.showFavorites;
    }*/
  }

  @override
  void didUpdateWidget(covariant TimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

/*    if (timeline != oldWidget.timeline && timeline != null) {
      setState(() {
        _headerTextColor = timeline.headerTextColor;
        _headerBackgroundColor = timeline.headerBackgroundColor;
      });

      timeline.onHeaderColorsChanged = (Color background, Color text) {
        setState(() {
          _headerTextColor = text;
          _headerBackgroundColor = background;
        });
      };
      timeline.onEraChanged = (TimelineEntry entry) {
        setState(() {
          _eraName = entry != null ? entry.label : DefaultEraName;
        });
      };
      setState(() {
        _eraName =
        timeline.currentEra != null ? timeline.currentEra : DefaultEraName;
        _showFavorites = timeline.showFavorites;
      });
    }*/
  }

  @override
  deactivate() {
    super.deactivate();
/*    if (timeline != null) {
      timeline.onHeaderColorsChanged;
      timeline.onEraChanged ;
    }*/
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    if (timeline != null) {
      timeline.devicePadding = devicePadding;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
          onLongPress: _longPress,
          //onTapDown: _tapDown,
          onScaleStart: _scaleStart,
          onScaleUpdate: _scaleUpdate,
          onScaleEnd: _scaleEnd,
          //onTapUp: _tapUp,
          child: Stack(children: <Widget>[
            TimelineRenderWidget(
                timeline: timeline,
                //favorites: BlocProvider.favorites(context).favorites,
                //topOverlap: TopOverlap + devicePadding.top,
                //focusItem: widget.focusItem,
                //touchBubble: onTouchBubble,
                //touchEntry: onTouchEntry
              ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      height: devicePadding.top,
                      color: _headerBackgroundColor != null
                          ? _headerBackgroundColor
                          : Color.fromRGBO(238, 240, 242, 0.81)),
                  Container(
                      color: _headerBackgroundColor != null
                          ? _headerBackgroundColor
                          : Color.fromRGBO(238, 240, 242, 0.81),
                      height: 56.0,
                      width: double.infinity,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
/*                            IconButton(
                              padding:
                              EdgeInsets.only(left: 20.0, right: 20.0),
                              color: _headerTextColor != null
                                  ? _headerTextColor
                                  : Colors.black.withOpacity(0.5),
                              alignment: Alignment.centerLeft,
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                widget.timeline.isActive = false;
                                Navigator.of(context).pop();
                                return true;
                              },
                            ),*/
                            Text(
                              _eraName,
                              textAlign: TextAlign.left,
/*                              style: TextStyle(
                                  fontFamily: "RobotoMedium",
                                  fontSize: 20.0,
                                  color: _headerTextColor != null
                                      ? _headerTextColor
                                      : darkText.withOpacity(
                                      darkText.opacity * 0.75)),*/
                            ),
/*                            Expanded(
                                child: GestureDetector(
                                    child: Transform.translate(
                                        offset: const Offset(0.0, 0.0),
                                        child: Container(
                                          height: 60.0,
                                          width: 60.0,
                                          padding: EdgeInsets.all(18.0),
                                          color:
                                          Colors.white.withOpacity(0.0),
                                          child: FlareActor(
                                              "assets/heart_toolbar.flr",
                                              animation: _showFavorites
                                                  ? "On"
                                                  : "Off",
                                              shouldClip: false,
                                              color: _headerTextColor !=
                                                  null
                                                  ? _headerTextColor
                                                  : darkText.withOpacity(
                                                  darkText.opacity *
                                                      0.75),
                                              alignment:
                                              Alignment.centerRight),
                                        )),
                                    onTap: () {
                                      timeline.showFavorites =
                                      !timeline.showFavorites;
                                      setState(() {
                                        _showFavorites =
                                            timeline.showFavorites;
                                      });
                                    })),*/
                          ]))
                ])
          ])),
    );
  }






}