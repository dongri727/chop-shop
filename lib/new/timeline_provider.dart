/*import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:chop_shop/timeline_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../timeline_entry.dart';

typedef PaintCallback();
//typedef ChangeEraCallback(TimelineEntry era);
//typedef ChangeHeaderColorCallback(Color background, Color text);

class Timeline {
  /// Some aptly named constants for properly aligning the Timeline view.
  static const double LineWidth = 2.0;
  static const double LineSpacing = 10.0;
  static const double DepthOffset = LineSpacing + LineWidth;
  static const double EdgePadding = 8.0;
  static const double MoveSpeed = 10.0;
  static const double MoveSpeedInteracting = 40.0;
  static const double Deceleration = 3.0;
  static const double GutterLeft = 45.0;
  static const double EdgeRadius = 4.0;
  static const double MinChildLength = 50.0;
  static const double BubbleHeight = 50.0;
  static const double BubblePadding = 20.0;
  static const double BubbleTextHeight = 20.0;
  static const double Parallax = 100.0;
  static const double InitialViewportPadding = 100.0;
  static const double TravelViewportPaddingTop = 400.0;
  static const double ViewportPaddingTop = 120.0;
  static const double ViewportPaddingBottom = 100.0;
  static const int SteadyMilliseconds = 500;

  /// The current platform is initialized at boot, to properly initialize
  /// [ScrollPhysics] based on the platform we're on.
  final TargetPlatform _platform;

  double _start = 0.0;
  double _end = 0.0;
  double _renderStart = 0.0;
  double _renderEnd = 0.0;
  double _lastFrameTime = 0.0;
  double _height = 0.0;
  double _firstOnScreenEntryY = 0.0;
  double _lastEntryY = 0.0;
  double _lastOnScreenEntryY = 0.0;
  double _offsetDepth = 0.0;
  double _renderOffsetDepth = 0.0;
  double _labelX = 0.0;
  double _renderLabelX = 0.0;
  double _prevEntryOpacity = 0.0;
  double _distanceToPrevEntry = 0.0;
  double _nextEntryOpacity = 0.0;
  double _distanceToNextEntry = 0.0;
  double _simulationTime = 0.0;
  double _timeMin = 0.0;
  double _timeMax = 0.0;
  double _gutterWidth = GutterLeft;

  bool _isFrameScheduled = false;
  bool _isInteracting = false;
  bool _isScaling = false;
  bool _isActive = false;
  bool _isSteady = false;

  /// Depending on the current [Platform], different values are initialized
  /// so that they behave properly on iOS&Android.
  ScrollPhysics? _scrollPhysics;

  /// [_scrollPhysics] needs a [ScrollMetrics] value to function.
  ScrollMetrics? _scrollMetrics;
  Simulation? _scrollSimulation;

  EdgeInsets padding = EdgeInsets.zero;
  EdgeInsets devicePadding = EdgeInsets.zero;

  Timer? _steadyTimer;

  /// Through these two references, the Timeline can access the era and update
  /// the top label accordingly.
  //TimelineEntry _currentEra;
  //TimelineEntry _lastEra;

  ///前の事象次の事象Button
  /// These references allow to maintain a reference to the next and previous elements
  /// of the Timeline, depending on which elements are currently in focus.
  /// When there's enough space on the top/bottom, the Timeline will render a round button
  /// with an arrow to link to the next/previous element.
  TimelineEntry? _nextEntry;
  TimelineEntry? _renderNextEntry;
  TimelineEntry? _prevEntry;
  TimelineEntry? _renderPrevEntry;

  /// A gradient is shown on the background, depending on the [_currentEra] we're in.
  /// グラデーション
  //List<TimelineBackgroundColor> _backgroundColors;

  /// [Ticks] also have custom colors so that they are always visible with the changing background.
  late List<TickColors> _tickColors;
  //List<HeaderColors> _headerColors;

  /// All the [TimelineEntry]s that are loaded from disk at boot (in [loadFromBundle()]).
  List<TimelineEntry> _entries = [];

  /// Callback set by [TimelineRenderWidget] when adding a reference to this object.
  /// It'll trigger [RenderBox.markNeedsPaint()].
  PaintCallback? onNeedPaint;

  /// These next two callbacks are bound to set the state of the [TimelineWidget]
  /// so it can change the appeareance of the top AppBar.
  /// appBarの領域表示
  //ChangeEraCallback onEraChanged;
  //ChangeHeaderColorCallback onHeaderColorsChanged;

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
  bool get isActive => _isActive;
  //Color get headerTextColor => _headerTextColor;
  //Color get headerBackgroundColor => _headerBackgroundColor;
  TimelineEntry? get nextEntry => _renderNextEntry;
  TimelineEntry? get prevEntry => _renderPrevEntry;
  List<TimelineEntry> get entries => _entries;
  List<TickColors> get tickColors => _tickColors;

  /// When a scale operation is detected, this setter is called:
  /// e.g. [_TimelineWidgetState.scaleStart()].
  set isInteracting(bool value) {
    if (value != _isInteracting) {
      _isInteracting = value;
      _updateSteady();
    }
  }

  /// Used to detect if the current scaling operation is still happening
  /// during the current frame in [advance()].
  set isScaling(bool value) {
    if (value != _isScaling) {
      _isScaling = value;
      _updateSteady();
    }
  }

  /// Toggle/stop rendering whenever the timeline is visible or hidden.
  set isActive(bool isIt) {
    if (isIt != _isActive) {
      _isActive = isIt;
      if (_isActive) {
        _startRendering();
      }
    }
  }

  /// Check that the viewport is steady - i.e. no taps, pans, scales or other gestures are being detected.
  void _updateSteady() {
    bool isIt = !_isInteracting && !_isScaling;

    /// If a timer is currently active, dispose it.
    if (_steadyTimer != null) {
      _steadyTimer!.cancel();
      _steadyTimer;
    }

    if (isIt) {
      /// If another timer is still needed, recreate it.
      _steadyTimer = Timer(Duration(milliseconds: SteadyMilliseconds), () {
        _steadyTimer;
        _isSteady = true;
        _startRendering();
      });
    } else {
      /// Otherwise update the current state and schedule a new frame.
      _isSteady = false;
      _startRendering();
    }
  }

  /// Schedule a new frame.
  void _startRendering() {
    if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  double screenPaddingInTime(double padding, double start, double end) {
    return padding / computeScale(start, end);
  }

  /// Compute the viewport scale from the start/end times.
  double computeScale(double start, double end) {
    return _height == 0.0 ? 1.0 : _height / (end - start);
  }

  /// Load all the resources from the local bundle.
  ///
  /// This function will load and decode `timeline.json` from disk,
  /// decode the JSON file, and populate all the [TimelineEntry]s.
  Future<List<TimelineEntry>> loadFromBundle(String filename) async {
    String data = await rootBundle.loadString(filename);
    List jsonEntries = json.decode(data) as List;

    List<TimelineEntry> allEntries = [];
    _tickColors = [];

    /// The JSON decode doesn't provide strong typing, so we'll iterate
    /// on the dynamic entries in the [jsonEntries] list.
    for (dynamic entry in jsonEntries) {
      Map map = entry as Map;

      /// Sanity check.
      TimelineEntry timelineEntry = TimelineEntry();
      if (map.containsKey("date")) {
        timelineEntry.type = TimelineEntryType.Incident;
        dynamic date = map["date"];
        timelineEntry.start = date is int ? date.toDouble() : date;
      } else if (map.containsKey("start")) {
        timelineEntry.type = TimelineEntryType.Era;
        dynamic start = map["start"];

        timelineEntry.start = start is int ? start.toDouble() : start;
      } else {
        continue;
      }

*//*      /// An accent color is also specified at times.
      dynamic accent = map["accent"];
      if (accent is List && accent.length >= 3) {
        timelineEntry.accent = Color.fromARGB(
            accent.length > 3 ? accent[3] as int : 255,
            accent[0] as int,
            accent[1] as int,
            accent[2] as int);
      }*//*

      /// [Ticks] can also have custom colors, so that everything's is visible
      /// even with custom colored backgrounds.
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
            longColor = Color.fromARGB(long.length > 3 ? long[3] as int : 255,
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
            textColor = Color.fromARGB(text.length > 3 ? text[3] as int : 255,
                text[0] as int, text[1] as int, text[2] as int);
          }

          _tickColors.add(TickColors()
          //..background = bgColor
            ..long = longColor
            ..short = shortColor
            ..text = textColor
            ..start = timelineEntry.start
            ..screenY = 0.0);
        }
      }

*//*      /// Some elements will have an `end` time specified.
      /// If not `end` key is present in this entry, create the value based
      /// on the type of the event:
      if (map.containsKey("end")) {
        dynamic end = map["end"];
        timelineEntry.end = end is int ? end.toDouble() : end;
      } else {
        timelineEntry.end = timelineEntry.start;
      }*//*

      /// The label is a brief description for the current entry.
      if (map.containsKey("label")) {
        timelineEntry.label = map["label"] as String;
      }

      /// Add this entry to the list.
      allEntries.add(timelineEntry);
    }

    /// sort the full list so they are in order of oldest to newest
    allEntries.sort((TimelineEntry a, TimelineEntry b) {
      return a.start.compareTo(b.start);
    });

    _timeMin = double.maxFinite;
    _timeMax = -double.maxFinite;

    /// List for "root" entries, i.e. entries with no parents.
    _entries = [];

    /// Build up hierarchy (Eras are grouped into "Spanning Eras" and Events are placed into the Eras they belong to).
*//*    TimelineEntry previous;
    for (TimelineEntry entry in allEntries) {
      if (entry.start < _timeMin) {
        _timeMin = entry.start;
      }
      if (entry.end > _timeMax) {
        _timeMax = entry.end;
      }
      previous.next = entry;
      entry.previous = previous;
      previous = entry;

      TimelineEntry parent;
      double minDistance = double.maxFinite;
      for (TimelineEntry checkEntry in allEntries) {
        if (checkEntry.type == TimelineEntryType.Era) {
          double distance = entry.start - checkEntry.start;
          double distanceEnd = entry.start - checkEntry.end;
          if (distance > 0 && distanceEnd < 0 && distance < minDistance) {
            minDistance = distance;
            parent = checkEntry;
          }
        }
      }
      if (parent != null) {
        entry.parent = parent;
        parent.children ??= [];
        parent.children.add(entry);
      } else {
        /// no parent, so this is a root entry.
        _entries.add(entry);
      }
    }*//*
    return allEntries;
  }

  /// Make sure that while scrolling we're within the correct timeline bounds.
  clampScroll() {
    _scrollMetrics;
    _scrollPhysics;
    _scrollSimulation;

    /// Get measurements values for the current viewport.
    double scale = computeScale(_start, _end);
    double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
    double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
    bool fixStart = _start < _timeMin - padTop;
    bool fixEnd = _end > _timeMax + padBottom;

    /// As the scale changes we need to re-solve the right padding
    /// Don't think there's an analytical single solution for this
    /// so we do it in steps approaching the correct answer.
    for (int i = 0; i < 20; i++) {
      double scale = computeScale(_start, _end);
      double padTop = (devicePadding.top + ViewportPaddingTop) / scale;
      double padBottom = (devicePadding.bottom + ViewportPaddingBottom) / scale;
      if (fixStart) {
        _start = _timeMin - padTop;
      }
      if (fixEnd) {
        _end = _timeMax + padBottom;
      }
    }
    if (_end < _start) {
      _end = _start + _height / scale;
    }

    /// Be sure to reschedule a new frame.
    if (!_isFrameScheduled) {
      _isFrameScheduled = true;
      _lastFrameTime = 0.0;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  /// This method bounds the current viewport depending on the current start and end positions.
  void setViewport(
      {double start = double.maxFinite,
        bool pad = false,
        double end = double.maxFinite,
        double height = double.maxFinite,
        double velocity = double.maxFinite,
        bool animate = false}) {
    /// Calculate the current height.
    if (height != double.maxFinite) {
      if (_height == 0.0 && _entries.length > 0) {
        double scale = height / (_end - _start);
        _start = _start - padding.top / scale;
        _end = _end + padding.bottom / scale;
      }
      _height = height;
    }

    /// If a value for start&end has been provided, evaluate the top/bottom position
    /// for the current viewport accordingly.
    /// Otherwise build the values separately.
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
    if (velocity != double.maxFinite) {
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
        axisDirection: AxisDirection.down,
        //devicePixelRatio: 0.0
      );

      _scrollSimulation =
          _scrollPhysics?.createBallisticSimulation(_scrollMetrics!, velocity);
    }
    if (onNeedPaint != null) {
      if (!animate) {
        _renderStart = start;
        _renderEnd = end;
        advance(0.0, false);
        onNeedPaint! ();
      } else if (!_isFrameScheduled) {
        _isFrameScheduled = true;
        _lastFrameTime = 0.0;
        SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      }
    }
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

    if (!advance(elapsed, true) && !_isFrameScheduled) {
      _isFrameScheduled = true;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }

    if (onNeedPaint != null) {
      onNeedPaint!();
    }
  }

  TickColors? findTickColors(double screen) {

    for (TickColors color in _tickColors.reversed) {
      if (screen >= color.screenY) {
        return color;
      }
    }

    return screen < _tickColors.first.screenY
        ? _tickColors.first
        : _tickColors.last;
  }

  bool advance(double elapsed, bool animate) {
    if (_height <= 0) {
      /// Done rendering. Need to wait for height.
      return true;
    }

    /// The current scale based on the rendering area.
    double scale = _height / (_renderEnd - _renderStart);

    bool doneRendering = true;
    bool stillScaling = true;

    /// If the timeline is performing a scroll operation adjust the viewport
    /// based on the elapsed time.
    if (_scrollSimulation != null) {
      doneRendering = false;
      _simulationTime += elapsed;
      //double scale = _height / (_end - _start);

      double velocity = _scrollSimulation!.dx(_simulationTime);

      double displace = velocity * elapsed / scale;

      _start -= displace;
      _end -= displace;
    }

    /// If scrolling has terminated, clean up the resources.
    if (_scrollSimulation != null) {
      if (_scrollSimulation!.isDone(_simulationTime)) {
        _scrollMetrics;
        _scrollPhysics;
        _scrollSimulation;
      }
    }


    /// Animate movement.
    double speed =
    min(1.0, elapsed * (_isInteracting ? MoveSpeedInteracting : MoveSpeed));
    double ds = _start - _renderStart;
    double de = _end - _renderEnd;

    /// If the current view is animating, adjust the [_renderStart]/[_renderEnd] based on the interaction speed.
    if (!animate || ((ds * scale).abs() < 1.0 && (de * scale).abs() < 1.0)) {
      stillScaling = false;
      _renderStart = _start;
      _renderEnd = _end;
    } else {
      doneRendering = false;
      _renderStart += ds * speed;
      _renderEnd += de * speed;
    }
    isScaling = stillScaling;

    /// Update scale after changing render range.
    scale = _height / (_renderEnd - _renderStart);

*//*    /// Update color screen positions.
    if (_tickColors.length > 0) {
      double lastStart = _tickColors.first.start;
      for (TickColors color in _tickColors) {
        color.screenY =
            (lastStart + (color.start - lastStart / 2.0) - _renderStart) *
                scale;
        lastStart = color.start;
      }
    }*//*

    /// Check all the visible entries and use the helper function [advanceItems()]
    /// to align their state with the elapsed time.
    /// Set all the initial values to defaults so that everything's consistent.
    _lastEntryY = -double.maxFinite;
    _lastOnScreenEntryY = 0.0;
    _firstOnScreenEntryY = double.maxFinite;
    _labelX = 0.0;
    _offsetDepth = 0.0;
    //_currentEra = null;
    _nextEntry;
    _prevEntry;
    if (_advanceItems(
        _entries, _gutterWidth + LineSpacing, scale, elapsed, animate, 0)) {
      doneRendering = false;
    }

    if (nextEntry != null && _nextEntryOpacity == 0.0) {
      _renderNextEntry = _nextEntry!;
    }

    /// Determine next entry's opacity and interpolate, if needed, towards that value.
    /// 重なって消える機能？
    double targetNextEntryOpacity = _lastOnScreenEntryY > _height / 1.7 ||
        !_isSteady ||
        _distanceToNextEntry < 0.01 ||
        _nextEntry != _renderNextEntry
        ? 0.0
        : 1.0;
    double dt = targetNextEntryOpacity - _nextEntryOpacity;

    if (!animate || dt.abs() < 0.01) {
      _nextEntryOpacity = targetNextEntryOpacity;
    } else {
      doneRendering = false;
      _nextEntryOpacity += dt * min(1.0, elapsed * 10.0);
    }

    if (_prevEntryOpacity == 0.0) {
      _renderPrevEntry = _prevEntry;
    }

    /// Determine previous entry's opacity and interpolate, if needed, towards that value.
    double targetPrevEntryOpacity = _firstOnScreenEntryY < _height / 2.0 ||
        !_isSteady ||
        _distanceToPrevEntry < 0.01 ||
        _prevEntry != _renderPrevEntry
        ? 0.0
        : 1.0;
    dt = targetPrevEntryOpacity - _prevEntryOpacity;

    if (!animate || dt.abs() < 0.01) {
      _prevEntryOpacity = targetPrevEntryOpacity;
    } else {
      doneRendering = false;
      _prevEntryOpacity += dt * min(1.0, elapsed * 10.0);
    }

    /// Interpolate the horizontal position of the label.
    double dl = _labelX - _renderLabelX;
    if (!animate || dl.abs() < 1.0) {
      _renderLabelX = _labelX;
    } else {
      doneRendering = false;
      _renderLabelX += dl * min(1.0, elapsed * 6.0);
    }

    if (_isSteady) {
      double dd = _offsetDepth - renderOffsetDepth;
      if (!animate || dd.abs() * DepthOffset < 1.0) {
        _renderOffsetDepth = _offsetDepth;
      } else {
        /// Needs a second run.
        doneRendering = false;
        _renderOffsetDepth += dd * min(1.0, elapsed * 12.0);
      }
    }

    return doneRendering;
  }

  ///吹き出しサイズ
  double bubbleHeight(TimelineEntry entry) {
    return BubblePadding * 2.0 + entry.lineCount * BubbleTextHeight;
  }

  /// Advance entry [assets] with the current [elapsed] time.
  bool _advanceItems(List<TimelineEntry> items, double x, double scale,
      double elapsed, bool animate, int depth) {
    bool stillAnimating = false;
    double lastEnd = -double.maxFinite;
    for (int i = 0; i < items.length; i++) {
      TimelineEntry item = items[i];

      double start = item.start - _renderStart;
      double end =
      item.type == TimelineEntryType.Era ? item.end - _renderStart : start;

      /// Vertical position for this element.
      double y = start * scale;

      ///+pad;
      if (i > 0 && y - lastEnd < EdgePadding) {
        y = lastEnd + EdgePadding;
      }

      /// Adjust based on current scale value.
      double endY = end * scale;

      ///-pad;
      /// Update the reference to the last found element.
      lastEnd = endY;

      item.length = endY - y;

      /// Calculate the best location for the bubble/label.
      double targetLabelY = y;
      double itemBubbleHeight = bubbleHeight(item);
      double fadeAnimationStart = itemBubbleHeight + BubblePadding / 2.0;
      if (targetLabelY - _lastEntryY < fadeAnimationStart

          /// The best location for our label is occluded, lets see if we can bump it forward...
          &&
          item.type == TimelineEntryType.Era &&
          _lastEntryY + fadeAnimationStart < endY) {
        targetLabelY = _lastEntryY + fadeAnimationStart + 0.5;
      }

      /// Determine if the label is in view.
      double targetLabelOpacity =
      targetLabelY - _lastEntryY < fadeAnimationStart ? 0.0 : 1.0;

      /// Debounce labels becoming visible.
      if (targetLabelOpacity > 0.0 && item.targetLabelOpacity != 1.0) {
        item.delayLabel = 0.5;
      }
      item.targetLabelOpacity = targetLabelOpacity;
      if (item.delayLabel > 0.0) {
        targetLabelOpacity = 0.0;
        item.delayLabel -= elapsed;
        stillAnimating = true;
      }

      double dt = targetLabelOpacity - item.labelOpacity;
      if (!animate || dt.abs() < 0.01) {
        item.labelOpacity = targetLabelOpacity;
      } else {
        stillAnimating = true;
        item.labelOpacity += dt * min(1.0, elapsed * 25.0);
      }

      /// Assign current vertical position.
      item.y = y;
      item.endY = endY;

      double targetLegOpacity = item.length > EdgeRadius ? 1.0 : 0.0;
      double dtl = targetLegOpacity - item.legOpacity;
      if (!animate || dtl.abs() < 0.01) {
        item.legOpacity = targetLegOpacity;
      } else {
        stillAnimating = true;
        item.legOpacity += dtl * min(1.0, elapsed * 20.0);
      }

      double targetItemOpacity = item.parent != null
          ? item.parent.length < MinChildLength ||
          (item.parent.endY < y)
          ? 0.0
          : y > item.parent.y
          ? 1.0
          : 0.0
          : 1.0;
      dtl = targetItemOpacity - item.opacity;
      if (!animate || dtl.abs() < 0.01) {
        item.opacity = targetItemOpacity;
      } else {
        stillAnimating = true;
        item.opacity += dtl * min(1.0, elapsed * 20.0);
      }

      /// Animate the label position.
      double targetLabelVelocity = targetLabelY - item.labelY;
      double dvy = targetLabelVelocity - item.labelVelocity;
      if (dvy.abs() > _height) {
        item.labelY = targetLabelY;
        item.labelVelocity = 0.0;
      } else {
        item.labelVelocity += dvy * elapsed * 18.0;
        item.labelY += item.labelVelocity * elapsed * 20.0;
      }

      /// Check the final position has been reached, otherwise raise a flag.
      if (animate &&
          (item.labelVelocity.abs() > 0.01 ||
              targetLabelVelocity.abs() > 0.01)) {
        stillAnimating = true;
      }

      if (item.targetLabelOpacity > 0.0) {
        _lastEntryY = targetLabelY;
        if (_lastEntryY < _height && _lastEntryY > devicePadding.top) {
          _lastOnScreenEntryY = _lastEntryY;
          if (_firstOnScreenEntryY == double.maxFinite) {
            _firstOnScreenEntryY = _lastEntryY;
          }
        }
      }

      if (item.type == TimelineEntryType.Era &&
          y < 0 &&
          endY > _height &&
          depth > _offsetDepth) {
        _offsetDepth = depth.toDouble();
      }

      /// Check if the bubble is out of view and set the y position to the
      /// target one directly.
      if (y > _height + itemBubbleHeight) {
        item.labelY = y;
        if (_nextEntry == null) {
          _nextEntry = item;
          _distanceToNextEntry = (y - _height) / _height;
        }
      } else if (endY < devicePadding.top) {
        _prevEntry = item;
        _distanceToPrevEntry = ((y - _height) / _height).abs();
      } else if (endY < -itemBubbleHeight) {
        item.labelY = y;
      }

      double lx = x + LineSpacing + LineSpacing;
      if (lx > _labelX) {
        _labelX = lx;
      }

      if (item.isVisible) {
        /// Advance the rest of the hierarchy.
        if (_advanceItems(item.children, x + LineSpacing + LineWidth, scale,
            elapsed, animate, depth + 1)) {
          stillAnimating = true;
        }
      }
    }
    return stillAnimating;
  }
}*/
