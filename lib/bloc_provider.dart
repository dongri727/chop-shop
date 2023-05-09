import 'package:chop_shop/timeline.dart';
import 'package:chop_shop/timeline_entry.dart';
import "package:flutter/widgets.dart";

/// This [InheritedWidget] wraps the whole app, and provides access
/// to the [Timeline] object.
class BlocProvider extends InheritedWidget {
  final Timeline timeline;

  BlocProvider(
      {Key key,
        Timeline t,
        @required Widget child,
        TargetPlatform platform = TargetPlatform.iOS})
      : timeline = t ?? Timeline(platform),
        super(key: key, child: child) {
    timeline
        .loadFromBundle(
      "assets/height_depth.json"
       // "assets/timeline.json",

    )
        .then((List<TimelineEntry> entries) {
      timeline.setViewport(
          start: entries.first.start * 2.0,
          end: entries.first.start,
          animate: true);

      /// Advance the timeline to its starting position.
      timeline.advance(0.0, false);

    });
  }

  @override
  updateShouldNotify(InheritedWidget oldWidget) => true;

  /// static accessor for the [Timeline].
  /// e.g. [_MainMenuWidgetState.navigateToTimeline] uses this static getter to access build the [TimelineWidget].
  static Timeline getTimeline(BuildContext context) {
    BlocProvider bp =
    context.dependOnInheritedWidgetOfExactType<BlocProvider>();
    Timeline bloc = bp?.timeline;
    return bloc;
  }
}
