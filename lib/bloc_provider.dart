import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'load_from_bundle.dart';

import 'timeline_entry.dart';
import 'timeline.dart';

class BlocProvider extends InheritedWidget {
  late final Timeline timeline;

  BlocProvider(
    {Key? key,
      required Timeline t,
      required Widget child,
      TargetPlatform platform = TargetPlatform.iOS })
    : timeline = t,
      super(key: key, child: child) {
    timeline
        .loadFromBundle('assets/timeline.json')
        .then((List<TimelineEntry> entries) {
       timeline.setViewport(
         start: entries.first.start * 2.0,
         end: entries.first.start,
         animate: true,
       );
       //timeline.advance(0.0, false);
    } as FutureOr Function(List value));
  }

  @override
  updateShouldNotify(InheritedWidget oldWidget) => true;

/*  /// static accessor for the [FavoritesBloc].
  /// e.g. [ArticleWidget] retrieves the favorites information using this static getter.
  static FavoritesBloc favorites(BuildContext context) {
    BlocProvider bp =
    (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider);
    FavoritesBloc bloc = bp?.favoritesBloc;
    return bloc;
  }*/

  /// static accessor for the [Timeline].
  /// e.g. [_MainMenuWidgetState.navigateToTimeline] uses this static getter to access build the [TimelineWidget].
  static Timeline? getTimeline(BuildContext context) {
    BlocProvider bp =
    (context.dependOnInheritedWidgetOfExactType<BlocProvider>() as BlocProvider);
    Timeline? bloc = bp?.timeline;
    return bloc;
  }
}
