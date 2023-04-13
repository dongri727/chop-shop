import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chop_shop/timeline_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'timeline_entry.dart';
import 'timeline_widget.dart';

class Timeline {
  static const double lineWidth = 2.0;
  static const double lineSpacing = 10.0;
  static const double depthOffset = lineSpacing + lineWidth;
  static const double edgePadding = 8.0;
  static const double moveSpeed = 10.0;
  static const double moveSpeedInteracting = 40.0;
  static const double deceleration = 3.0;
  static const double gutterLeft = 45.0;
  static const double gutterLeftExpanded = 75.0;
  static const double edgeRadius = 4.0;
  static const double minChildLength = 50.0;
  static const double bubbleHeight = 50.0;
  static const double bubbleArrowSize = 19.0;
  static const double bubblePadding = 20.0;
  static const double bubbleTextHeight = 20.0;
  static const double assetPadding = 30.0;
  static const double parallax = 100.0;
  static const double assetScreenScale = 0.3;
  static const double initialViewportPadding = 100.0;
  static const double travelViewportPaddingTop = 400.0;
  static const double viewportPaddingTop = 120.0;
  static const double viewportPaddingBottom = 100.0;
  static const int steadyMilliseconds = 500;

  final TargetPlatform _platform;

  double _start = 0.0;
  double _end = 0.0;
  late double _renderStart;
  late double _renderEnd;
  double _lastFrameTime = 0.0;
  double _height = 0.0;
  double _firstOnScreenEntryY = 0.0;
  double _lastEntryY = 0.0;
  double _lastOnScreenEntryY = 0.0;
  double _offsetDepth = 0.0;
  final double _renderOffsetDepth = 0.0;
  double _labelX = 0.0;
  double _renderLabelX = 0.0;
  double _lastAssetY = 0.0;
  double _prevEntryOpacity = 0.0;
  double _distanceToPrevEntry = 0.0;
  double _nextEntryOpacity = 0.0;
  double _distanceToNextEntry = 0.0;
  double _simulationTime = 0.0;
  double _timeMin = 0.0;
  double _timeMax = 0.0;
  double _gutterWidth = gutterLeft;

  //bool _showFavorites = false;
  bool _isFrameScheduled = false;
  bool _isInteracting = false;
  bool _isScaling = false;
  final bool _isActive = false;
  bool _isSteady = false;

  late HeaderColors _currentHeaderColors;
  late Color _headerTextColor;
  late Color _headerBackgroundColor;

  late ScrollPhysics _scrollPhysics;
  late ScrollMetrics _scrollMetrics;
  late Simulation _scrollSimulation;

  EdgeInsets padding = EdgeInsets.zero;
  EdgeInsets devicePadding = EdgeInsets.zero;

  late Timer _steadyTimer;

  // Entry関係を飛ばしている、必要ならここに加える
  Timeline(this._platform) {
    setViewport(start: 1536.0, end: 3072.0);
  }

  double get renderOffsetDepth => _renderOffsetDepth;
  double get renderLabelX => _renderLabelX;
  double get start => _start;
  double get end => _end;
  double get renderStart => _renderStart;
  double get renderEnd => _renderEnd;
  double get gutterWidth => _gutterWidth;
  double get nextEntryOpacity => _nextEntryOpacity;
  double get prevEntryOpacity => _prevEntryOpacity;
  bool get isInteracting => _isInteracting;
  //bool get showFavorites => _showFavorites;
  bool get isActive => _isActive;
  Color get headerTextColor => _headerTextColor;
  Color get headerBackgroundColor => _headerBackgroundColor;
  HeaderColors get currentHeaderColors => _currentHeaderColors;
  //TimelineEntry get currentEra => _currentEra;
  //TimelineEntry get nextEntry => _renderNextEntry;
  //TimelineEntry get prevEntry => _renderPrevEntry;
  //List<TimelineEntry> get entries => _entries;
  List<TimelineBackgroundColor> get backgroundColors => backgroundColors;
  List<TickColors> get tickColors => tickColors;
  //List<TimelineAsset> get renderAssets => _renderAssets;

  set isInteracting(bool value) {
    if (value != _isInteracting) {
      _isInteracting = value;
      _updateSteady();
    }
  }

  set isScaling(bool value) {
    if (value != _isScaling) {
      _isScaling = value;
      _updateSteady();
    }
  }

  set isActive(bool isIt) {
/*    if (isIt != _isActive) {
      _isActive = isIt;
      if(_isActive) {
        _startRendering();
      }*/
    }

    void _updateSteady() {
      bool isIt = !_isInteracting && !_isScaling;
      // よく理解できないif文を飛ばしている
    }

    void _startRendering() {
/*      if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        _lastFrameTime = 0.0;
        SchedulerBinding.instance.scheduleFrameCallback(biginFrame);
      }*/
    }

    double screenPaddingInTime(double padding, double start, double end) {
      return padding / computeScale(start, end);
    }

    double computeScale(double start, double end) {
      return _height == 0.0 ? 1.0 : _height / (end -start);
    }

    //todo 表示の要っぽい jsonを読み込む
    Future<List> loadFromBundle(String filename) async {
      String data = await rootBundle.loadString(filename);
      List jsonEntries = json.decode(data) as List;
      List<dynamic> allEntries = [];
      List<TimelineBackgroundColor> backgroundColors = [];
      List<Colors> tickColors = [];
      List<Colors> headerColors = [];

      for (dynamic entry in jsonEntries) {
        Map map = entry as Map;
        if (map != null) {
          //todo 事象が「日付」指定なら、○一つの「出来事」
          TimelineEntry timelineEntry = TimelineEntry();
          if (map.containsKey("date")) {
            timelineEntry.type = TimelineEntryType.Incident;
            dynamic date = map["date"];
            timelineEntry.start = date is int ? date.toDouble() : date;
          }
          //todo 事象が「始め」指定なら、○ー○の「時代」
          else if (map.containsKey("start")) {
            timelineEntry.type = TimelineEntryType.Era;
            dynamic start = map["start"];
            timelineEntry.start = LinearBorder.start()is double
                ? LinearBorder.start()
                : start();
          } else {
            continue;
          }

          //todo 「背景」は時代による青みの変化
          if (map.containsKey("background")) {
            dynamic bg = map["background"];
            if (bg is List && bg.length >= 3) {
              backgroundColors.add(TimelineBackgroundColor()
                ..color = Color.fromARGB(
                    255, bg[0] as int, bg[1] as int, bg[2] as int)
                ..start = timelineEntry.start);
            }
          }
          //todo ○に関するよくわからない指定　○じゃないとか？
          dynamic accent = map["accent"];
          if (accent is List && accent.length >= 3) {
            timelineEntry.accent = Color.fromARGB(
                accent.length > 3 ? accent[3] as int : 255,
                accent[0] as int,
                accent[1] as int,
                accent[2] as int);
          }
          //todo 目盛りの背景色や長短の線の色、数字の色　全体の背景色に連動
          if (map.containsKey("ticks")) {
            dynamic ticks = map["ticks"];
            if (ticks is Map) {
              Color bgColor = Colors.black;
              Color longColor = Colors.black;
              Color shortColor = Colors.black;
              Color textColor = Colors.black;

              dynamic bg = ticks["background"];
              if (bg is List && bg.length >= 3) {
                bgColor = Color.fromARGB(bg.length > 3 ? bg[3] as int : 255,
                    bg[0] as int, bg[1] as int, bg[2] as int);
              }
              dynamic long = ticks["long"];
              if (long is List && long.length >= 3) {
                longColor =
                    Color.fromARGB(long.length > 3 ? long[3] as int : 255,
                        long[0] as int, long[1] as int, long[2] as int);
              }
              dynamic short = ticks["short"];
              if (short is List && short.length >= 3) {
                shortColor = Color.fromARGB(
                    short.length > 3 ? short[3] as int : 255,
                    short[0] as int,
                    short[1] as int,
                    short[2] as int);
              }
              dynamic text = ticks["text"];
              if (text is List && text.length >= 3) {
                textColor =
                    Color.fromARGB(text.length > 3 ? text[3] as int : 255,
                        text[0] as int, text[1] as int, text[2] as int);
              }
              tickColors.add((TickColors()
                ..background = bgColor
                ..long = longColor
                ..short = shortColor
                ..text = textColor
                ..start = timelineEntry.start
                ..screenY = 0.0) as Colors);
            }
          }

          //todo 画面上部の時代名が書いてある部分の背景色など
          if (map.containsKey("header")) {
            dynamic header = map["header"];
            if (header is Map) {
              Color bgColor = Colors.black;
              Color textColor = Colors.black;

              dynamic bg = header["background"];
              if (bg is List && bg.length >= 3) {
                bgColor = Color.fromARGB(bg.length > 3 ? bg[3] as int : 255,
                    bg[0] as int, bg[1] as int, bg[2] as int);
              }
              dynamic text = header["text"];
              if (text is List && text.length >= 3) {
                textColor =
                    Color.fromARGB(text.length > 3 ? text[3] as int : 255,
                        text[0] as int, text[1] as int, text[2] as int);
              }

              headerColors.add((HeaderColors()
                ..background = bgColor
                ..text = textColor
                ..start = timelineEntry.start
                ..screenY = 0.0) as Colors);
            }
          }

          /// ○ー○の後端
          if (map.containsKey("end")) {
            dynamic end = map["end"];
            timelineEntry.end = end is int ? end.toDouble() : end;
          } else if (timelineEntry.type == TimelineEntryType.Era) {
            timelineEntry.end = DateTime
                .now()
                .year
                .toDouble() * 10.0;
          } else {
            timelineEntry.end = timelineEntry.start;
          }

          /// The label is a brief description for the current entry.
          if (map.containsKey("label")) {
            timelineEntry.label = map["label"] as String;
          }

          /// Some entries will also have an id
          /// なんのためのidがまだわからない
/*          if (map.containsKey("id")) {
            timelineEntry.id = map["id"] as String;
            _entriesById[timelineEntry.id] = timelineEntry;
          }*/

          ///記事とanimationは省略
          allEntries.add(timelineEntry);
        }
      }

      allEntries.sort((TimelineBackgroundColor a, TimelineBackgroundColor b) {
        return a.start.compareTo(b.start);
      } as int Function(dynamic a, dynamic b)?); ///この１行足さないと赤がでるけど、意味は不明。

      _timeMin = double.maxFinite;
      _timeMax = double.maxFinite;
      //_entries = List<TimelineEntry>(); ///こっちが元のcodeでerror
      List<dynamic> entries = [];///こっちが推奨されたcode

      TimelineEntry previous;
      for (TimelineEntry entry in allEntries) {
/*        if (entry.start < _timeMin) {
          _timeMin = entry.start;
        }
        if (entry.end > _timeMax) {
          _timeMax = entry.end;
        }
        if (previous != null) {
          previous.next = entry;
        }*/
        //entry.previous = previous;
        previous = entry;

        TimelineEntry parent;
        double minDistance = double.maxFinite;
        for (TimelineEntry checkEntry in allEntries) {
          if (checkEntry.runtimeType == TimelineEntryType.Era) {
            double distance = entry.start - checkEntry.start;
            double distanceEnd = entry.start - checkEntry.end;
            if (distance > 0 && distanceEnd < 0 && distance < minDistance) {
              minDistance = distance;
              parent = checkEntry;
            }
          }
        }
///複雑な分岐を止めてみる
/*        if (parent != null) {
          entry.parent = parent;
          //if(parent.children == null) {
          // parent.children = List<TimelineEntry>();} ///これが元のcodeでerror
          parent.children ??= _entries;///こっちが推奨されたcode
          parent.children.add(entry);
        } else {
          _entries.add(entry);
        }*/
      }
      return allEntries;
    }
/*    TimelineEntry? getById(String id) {
      return _entriesById[id];
    }*/

    clampScroll() {
      _scrollMetrics;
      _scrollPhysics;
      _scrollSimulation;

      /// Get measurements values for the current viewport.
      double scale = computeScale(_start, _end);
      //double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
      //double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
      //bool fixStart = _start < _timeMin - padTop;
      //bool fixEnd = _end > _timeMax + padBottom;

      /// As the scale changes we need to re-solve the right padding
      /// Don't think there's an analytical single solution for this
      /// so we do it in steps approaching the correct answer.
 /*     for (int i = 0; i < 20; i++) {
        double scale = computeScale(_start, _end);
        double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
        double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
        if (fixStart) {
          _start = _timeMin - padTop;
        }
        if (fixEnd) {
          _end = _timeMax + padBottom;
        }
      }*/
      if (_end < _start) {
        _end = _start + _height / scale;
      }
      /// Be sure to reschedule a new frame.
/*      if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        _lastFrameTime = 0.0;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }*/
    }

    void setViewport(
        {double start = double.maxFinite,
          bool pad = false,
          double end = double.maxFinite,
          double height = double.maxFinite,
          double velocity = double.maxFinite,
          bool animate = false}) {
/*      if (height != double.maxFinite) {
        if (_height == 0.0 && _entries != null && _entries.length > 0) {
          double scale = height / (_end - _start);
          _start = _start - padding.top / scale;
          _end = _end + padding.bottom / scale;
        }
        _height = height;
      }*/

      /// If a value for start&end has been provided, evaluate the top/bottom position
      /// for the current viewport accordingly.
      /// Otherwise build the values separately.
      /// 時代推移に係わる何か？
      if (start != double.maxFinite && end != double.maxFinite) {
        _start = start;
        _end = end;
        if (pad && _height != 0.0) {
          double scale = _height / (_end - _start);
          _start = _start - padding.top / scale;
          _end = _end + padding.bottom / scale;
        }
      } else {
        if (start != double.maxFinite) {
          double scale = height / (_end - _start);
          _start = pad ? start - padding.top / scale : start;
        }
        if (end != double.maxFinite) {
          double scale = height / (_end - _start);
          _end = pad ? end + padding.bottom / scale : end;
        }
      }

      /// If a velocity value has been passed, use the [ScrollPhysics] to create
      /// a simulation and perform scrolling natively to the current platform.
      /// スクロールのスピードに関する何か？
/*      if (velocity != double.maxFinite) {
        double scale = computeScale(_start, _end);
        double padTop =
            (devicePadding.top + ViewportPaddingTop) / computeScale(_start, _end);
        double padBottom = (devicePadding.bottom + ViewportPaddingBottom) /
            computeScale(_start, _end);
        double rangeMin = (_timeMin - padTop) * scale;
        double rangeMax = (_timeMax + padBottom) * scale - _height;
        if (rangeMax < rangeMin) {
          rangeMax = rangeMin;
        }

        _simulationTime = 0.0;
        if (_platform == TargetPlatform.iOS) {
          _scrollPhysics = BouncingScrollPhysics();
        } else {
          _scrollPhysics = ClampingScrollPhysics();
        }
        _scrollMetrics = FixedScrollMetrics(
            minScrollExtent: double.negativeInfinity,
            maxScrollExtent: double.infinity,
            pixels: 0.0,
            viewportDimension: _height,
            axisDirection: AxisDirection.down, devicePixelRatio: 0);

        _scrollSimulation =
        _scrollPhysics.createBallisticSimulation(_scrollMetrics, velocity)!;
      }
      if (!animate) {
        _renderStart = start;
        _renderEnd = end;
        advance(0.0, false);
        if (onNeedPaint != null) {
          onNeedPaint();
        }
      } else if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        _lastFrameTime = 0.0;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }*/
    }

    /// Make sure that all the visible assets are being rendered and advanced
    /// according to the current state of the timeline.
    void beginFrame(Duration timeStamp) {
      _isFrameScheduled = false;
      final double t =
          timeStamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;
      if (_lastFrameTime == 0.0) {
        _lastFrameTime = t;
        _isFrameScheduled = true;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
        return;
      }

      double elapsed = t - _lastFrameTime;
      _lastFrameTime = t;

/*      if (!advance(elapsed, true) && !_isFrameScheduled) {
        _isFrameScheduled = true;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }*/

/*      if (onNeedPaint != null) {
        onNeedPaint();
      }*/
    }

    ///目盛りの色？
    TickColors? findTickColors(double screen) {
      if (tickColors == null) {
        return null;
      }
      for (TickColors color in tickColors.reversed) {
        if (screen >= color.screenY) {
          return color;
        }
      }

      return screen < tickColors.first.screenY
          ? tickColors.first
          : tickColors.last;
    }

/*    ///ヘッダーの色？
    HeaderColors? _findHeaderColors(double screen) {
      if (_headerColors == null) {
        return null;
      }
      for (HeaderColors color in _headerColors.reversed) {
        if (screen >= color.screenY) {
          return color;
        }
      }

      return screen < _headerColors.first.screenY
          ? _headerColors.first
          : _headerColors.last;
    }*/
    ///サイズの計算？
    bool advance(double elapsed, bool animate) {
      if (_height <= 0) {
        /// Done rendering. Need to wait for height.
        return true;
      }
      double scale = _height / (_renderEnd - renderStart);
      bool doneRendering = true;
      bool stillScaling = true;

      /// If the timeline is performing a scroll operation adjust the viewport
      /// based on the elapsed time.
      /// 重なったら消えるヤツ？
      if (_scrollSimulation != null) {
        doneRendering = false;
        _simulationTime += elapsed;
        double scale = _height / (_end - _start);
        double velocity = _scrollSimulation.dx(_simulationTime);

        double displace = velocity * elapsed / scale;

        _start -= displace;
        _end -= displace;

        /// If scrolling has terminated, clean up the resources.
        if (_scrollSimulation.isDone(_simulationTime)) {
          _scrollMetrics;
          _scrollPhysics;
          _scrollSimulation;
        }
      }

      /// Check if the left-hand side gutter has been toggled.
      /// If visible, make room for it .
      /// 目盛りの左にお気に入りマークが出るヤツ？
/*      double targetGutterWidth = _showFavorites ? GutterLeftExpanded : GutterLeft;
      double dgw = targetGutterWidth - _gutterWidth;
      if (!animate || dgw.abs() < 1) {
        _gutterWidth = targetGutterWidth;
      } else {
        doneRendering = false;
        _gutterWidth += dgw * min(1.0, elapsed * 10.0);
      }*/

      ///animation関連？を飛ばしている
      ///animate movement
      /// If the current view is animating, adjust the [_renderStart]/[_renderEnd] based on the interaction speed.

      /// Update scale after changing render range.
      scale = _height / (_renderEnd - _renderStart);

      /// Update color screen positions.
      /// 目盛りの色に関する何か？
      if (tickColors != null && tickColors.length > 0) {
        double lastStart = tickColors.first.start;
        for (TickColors color in tickColors) {
          color.screenY =
              (lastStart + (color.start - lastStart / 2.0) - _renderStart) *
                  scale;
          lastStart = color.start;
        }
      }
/*      if (_headerColors != null && _headerColors.length > 0) {
        double lastStart = _headerColors.first.start;
        for (HeaderColors color in _headerColors) {
          color.screenY =
              (lastStart + (color.start - lastStart / 2.0) - _renderStart) *
                  scale;
          lastStart = color.start;
        }
      }*/
/*      ///ヘッダーに関する何か？
      _currentHeaderColors = _findHeaderColors(0.0)!;

      if (_currentHeaderColors != null) {
        if (_headerTextColor == null) {
          _headerTextColor = _currentHeaderColors.text;
          _headerBackgroundColor = _currentHeaderColors.background;
        } else {
          bool stillColoring = false;
          Color headerTextColor = interpolateColor(
              _headerTextColor, _currentHeaderColors.text, elapsed);

          if (headerTextColor != _headerTextColor) {
            _headerTextColor = headerTextColor;
            stillColoring = true;
            doneRendering = false;
          }
          Color headerBackgroundColor = interpolateColor(
              _headerBackgroundColor, _currentHeaderColors.background, elapsed);
          if (headerBackgroundColor != _headerBackgroundColor) {
            _headerBackgroundColor = headerBackgroundColor;
            stillColoring = true;
            doneRendering = false;
          }
          if (stillColoring) {
            if (onHeaderColorsChanged != null) {
              onHeaderColorsChanged(_headerBackgroundColor, _headerTextColor);
            }
          }
        }
      }*/

      /// Check all the visible entries and use the helper function [advanceItems()]
      /// to align their state with the elapsed time.
      /// Set all the initial values to defaults so that everything's consistent.
      _lastEntryY = -double.maxFinite;
      _lastOnScreenEntryY = 0.0;
      _firstOnScreenEntryY = double.maxFinite;
      _lastAssetY = -double.maxFinite;
      _labelX = 0.0;
      _offsetDepth = 0.0;
/*      _currentEra;
      _nextEntry;
      _prevEntry;
      if (_entries != null) {
        /// Advance the items hierarchy one level at a time.
        if (_advanceItems(
            _entries, _gutterWidth + LineSpacing, scale, elapsed, animate, 0)) {
          doneRendering = false;
        }*/

      /// Advance all the assets and add the rendered ones into [_renderAssets].
      /// animation関連を飛ばしている


      ///時代変異関連を飛ばしている
      /// Determine previous entry's opacity and interpolate, if needed, towards that value.
      /// If a new era is currently in view, callback.


      double bubbleHeight;

      bool stillAnimating = false;
      return stillAnimating;
  }
}
