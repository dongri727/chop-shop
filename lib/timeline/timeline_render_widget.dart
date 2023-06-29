import 'dart:ui' as ui;

import 'package:chop_shop/menu/menu_data.dart';
import 'package:chop_shop/timeline/ticks.dart';
import 'package:chop_shop/timeline/timeline.dart';
import 'package:chop_shop/timeline/timeline_entry.dart';
import 'package:chop_shop/timeline/timeline_utils.dart';
import 'package:flutter/material.dart';

/// These two callbacks are used to detect if a bubble or an entry have been tapped.
typedef TouchBubbleCallback = Function(TapTarget bubble);
typedef TouchEntryCallback = Function(TimelineEntry entry);

/// This couples with [TimelineRenderObject].
/// This widget's fields are accessible from the [RenderBox] so that it can
/// be aligned with the current state.
class TimelineRenderWidget extends LeafRenderObjectWidget {
  final Timeline timeline;
  final double topOverlap;
  final MenuItemData focusItem;
  final TouchBubbleCallback touchBubble;
  final TouchEntryCallback touchEntry;

  const TimelineRenderWidget({
    Key? key,
    required this.timeline,
    required this.topOverlap,
    required this.focusItem,
    required this.touchBubble,
    required this.touchEntry,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TimelineRenderObject()
      ..timeline = timeline
      ..topOverlap = topOverlap
      ..focusItem = focusItem
      ..touchBubble = touchBubble
      ..touchEntry = touchEntry;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TimelineRenderObject renderObject) {
    renderObject
      ..timeline = timeline
      ..focusItem = focusItem
      ..touchBubble = touchBubble
      ..touchEntry = touchEntry
      ..topOverlap = topOverlap;
  }

  @override
  didUnmountRenderObject(covariant TimelineRenderObject renderObject) {
    renderObject.timeline.isActive = false;
  }
}

/// A custom renderer is used for the the timeline object.
/// The [Timeline] serves as an abstraction layer for the positioning and advancing logic.
/// The core method of this object is [paint()]: this is where all the elements
/// are actually drawn to screen.
class TimelineRenderObject extends RenderBox {
  static const List<Color> LineColors = [];

  double _topOverlap = 0.0;
  final Ticks _ticks = Ticks();
  Timeline? _timeline;
  MenuItemData? _focusItem;
  MenuItemData? _processedFocusItem;
  final List<TapTarget> _tapTargets = [];
  late TouchBubbleCallback touchBubble;
  late TouchEntryCallback touchEntry;

  @override
  bool get sizedByParent => true;

  double get topOverlap => _topOverlap;
  Timeline get timeline => _timeline!;
  MenuItemData get focusItem => _focusItem!;

  set topOverlap(double value) {
    if (_topOverlap == value) {
      return;
    }
    _topOverlap = value;
    updateFocusItem();
    markNeedsPaint();
    markNeedsLayout();
  }

  set timeline(Timeline value) {
    if (_timeline == value) {
      return;
    }
    _timeline = value;
    updateFocusItem();
    _timeline?.onNeedPaint = markNeedsPaint;
    markNeedsPaint();
    markNeedsLayout();
  }

  set focusItem(MenuItemData value) {
    if (_focusItem == value) {
      return;
    }
    _focusItem = value;
    _processedFocusItem;
    updateFocusItem();
  }

  /// If [_focusItem] has been updated with a new value, update the current view.
  void updateFocusItem() {
    if (_processedFocusItem == _focusItem) {
      return;
    }
    if (topOverlap == 0.0) {
      return;
    }

    /// Adjust the current timeline padding and consequently the viewport.
    if (_focusItem!.pad) {
      timeline.padding = EdgeInsets.only(
          top: topOverlap + _focusItem!.padTop + Timeline.Parallax,
          bottom: _focusItem!.padBottom);
      timeline.setViewport(
          start: _focusItem!.start,
          end: _focusItem!.end,
          animate: true,
          pad: true);
    } else {
      timeline.padding = EdgeInsets.zero;
      timeline.setViewport(
          start: _focusItem!.start, end: _focusItem!.end, animate: true);
    }
    _processedFocusItem = _focusItem!;
  }

  /// Check if the current tap on the screen has hit a bubble.
  @override
  bool hitTestSelf(Offset screenOffset) {
    //touchEntry == null;
    for (TapTarget bubble in _tapTargets.reversed) {
      if (bubble.rect.contains(screenOffset)) {
        touchBubble(bubble);
        return true;
      }
    }
    //touchBubble == null;
    return true;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  /// Adjust the viewport when needed.
  @override
  void performLayout() {
    _timeline!.setViewport(height: size.height, animate: true);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    if (_timeline == null) {
      return;
    }

    _tapTargets.clear();
    double renderStart = _timeline!.renderStart;
    double renderEnd = _timeline!.renderEnd;
    double scale = size.height / (renderEnd - renderStart);

    // Scaleの制限を追加
    const double minScale = 0;
    const double maxScale = 4.0;
    if (scale < minScale) {
      scale = minScale;
    }
    if (scale > maxScale) {
      scale = maxScale;
    }

    /// Paint the [Ticks] on the left side of the screen.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        offset.dx, offset.dy + topOverlap, size.width, size.height));
    _ticks.paint(
        context, offset, -renderStart * scale, scale, size.height, timeline);
    canvas.restore();

    /// And then draw the rest of the timeline.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(offset.dx + _timeline!.gutterWidth, offset.dy,
        size.width - _timeline!.gutterWidth, size.height));
    drawItems(
        context,
        offset,
        _timeline!.entries,
        _timeline!.gutterWidth +
            Timeline.LineSpacing -
            Timeline.DepthOffset * _timeline!.renderOffsetDepth,
        scale,
        0);
    canvas.restore();
  }

  /// Given a list of [entries], draw the label with its bubble beneath.
  /// Draw also the dots&lines on the left side of the timeline. These represent
  /// the starting/ending points for a given event and are meant to give the idea of
  /// the time-span encompassing that event, as well as putting the vent into context
  /// relative to the other events.
  void drawItems(PaintingContext context, Offset offset,
      List<TimelineEntry> entries, double x, double scale, int depth) {
    final Canvas canvas = context.canvas;

    for (TimelineEntry item in entries) {
      if (!item.isVisible ||
          item.y > size.height + Timeline.BubbleHeight ||
          item.endY < -Timeline.BubbleHeight) {
        /// Don't paint this item.
        continue;
      }

      //double legOpacity = item.legOpacity * item.opacity;
      Offset entryOffset = Offset(x + Timeline.LineWidth / 2.0, item.y);

      /// Draw the small circle on the left side of the timeline.
      /// ドット描画
      canvas.drawCircle(entryOffset, Timeline.EdgeRadius,
          Paint()..color = (item.accent).withOpacity(item.opacity));
/*      if (legOpacity > 0.0) {
        Paint legPaint = Paint()..color = (item.accent).withOpacity(legOpacity);
      }*/

      const double MaxLabelWidth = 1200.0;
      const double BubblePadding = 20.0;

      /// Let the timeline calculate the height for the current item's bubble.
      double bubbleHeight = timeline.bubbleHeight(item);

      /// Use [ui.ParagraphBuilder] to construct the label for canvas.
      ui.ParagraphBuilder builder = ui.ParagraphBuilder(
          ui.ParagraphStyle(textAlign: TextAlign.start, fontSize: 12.0))
        ..pushStyle(
            ui.TextStyle(color: const Color.fromRGBO(240, 240, 240, 1.0)));

      builder.addText(item.label);
      ui.Paragraph labelParagraph = builder.build();
      labelParagraph.layout(ui.ParagraphConstraints(width: MaxLabelWidth));

      double textWidth =
          labelParagraph.maxIntrinsicWidth * item.opacity * item.labelOpacity;
      double bubbleX = _timeline!.renderLabelX -
          Timeline.DepthOffset * _timeline!.renderOffsetDepth;
      double bubbleY = item.labelY - bubbleHeight / 2.0;

      canvas.save();
      canvas.translate(bubbleX, bubbleY);

      /// Get the bubble's path based on its width&height, draw it, and then add the label on top.
      Path bubble =
          makeBubblePath(textWidth + BubblePadding * 2.0, bubbleHeight);

      canvas.drawPath(
          bubble,
          Paint()
            ..color =
                (item.accent).withOpacity(item.opacity * item.labelOpacity));
      canvas
          .clipRect(Rect.fromLTWH(BubblePadding, 0.0, textWidth, bubbleHeight));
      _tapTargets.add(TapTarget()
        ..entry = item
        ..rect = Rect.fromLTWH(
            bubbleX, bubbleY, textWidth + BubblePadding * 2.0, bubbleHeight));

      canvas.drawParagraph(
          labelParagraph,
          Offset(
              BubblePadding, bubbleHeight / 2.0 - labelParagraph.height / 2.0));
      canvas.restore();
      drawItems(context, offset, item.children, x + Timeline.DepthOffset, scale,
          depth + 1);
    }
  }

  /// Given a width and a height, design a path for the bubble that lies behind events' labels
  /// on the timeline, and return it.
  Path makeBubblePath(double width, double height) {
    const double ArrowSize = 0.0;
    const double CornerRadius = 10.0;

    const double circularConstant = 0.55;
    const double icircularConstant = 1.0 - circularConstant;

    Path path = Path();

    path.moveTo(CornerRadius, 0.0);
    path.lineTo(width - CornerRadius, 0.0);
    path.cubicTo(width - CornerRadius + CornerRadius * circularConstant, 0.0,
        width, CornerRadius * icircularConstant, width, CornerRadius);
    path.lineTo(width, height - CornerRadius);
    path.cubicTo(
        width,
        height - CornerRadius + CornerRadius * circularConstant,
        width - CornerRadius * icircularConstant,
        height,
        width - CornerRadius,
        height);
    path.lineTo(CornerRadius, height);
    path.cubicTo(CornerRadius * icircularConstant, height, 0.0,
        height - CornerRadius * icircularConstant, 0.0, height - CornerRadius);

    path.lineTo(0.0, height / 2.0 + ArrowSize / 2.0);
    path.lineTo(-ArrowSize / 2.0, height / 2.0);
    path.lineTo(0.0, height / 2.0 - ArrowSize / 2.0);

    path.lineTo(0.0, CornerRadius);

    path.cubicTo(0.0, CornerRadius * icircularConstant,
        CornerRadius * icircularConstant, 0.0, CornerRadius, 0.0);

    path.close();

    return path;
  }
}
