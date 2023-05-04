import "dart:async";

import 'package:chop_shop/bloc_provider.dart';
import 'package:chop_shop/color.dart';
import 'package:chop_shop/main_menu_section.dart';
import 'package:chop_shop/menu_data.dart';
import 'package:chop_shop/timeline_entry.dart';
import 'package:chop_shop/timeline_widget.dart';
import "package:flutter/material.dart";

/// The Main Page of the Timeline App.
///
/// This Widget lays out the search bar at the top of the page,
/// the three card-sections for accessing the main events on the Timeline,
/// and it'll provide on the bottom three links for quick access to your Favorites,
/// a Share Menu and the About Page.
class MainMenuWidget extends StatefulWidget {

  MainMenuWidget({Key key}) : super(key: key);

  @override
  _MainMenuWidgetState createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {
  /// State is maintained for two reasons:
  ///
  /// 1. Search Functionality:
  /// When the search bar is tapped, the Widget view is filled with all the
  /// search info -- i.e. the [ListView] containing all the results.
  bool _isSearching = false;

  /// 2. Section Animations:
  /// Each card section contains a Flare animation that's playing in the background.
  /// These animations are paused when they're not visible anymore (e.g. when search is visible instead),
  /// and are played again once they're back in view.
  bool _isSectionActive = true;

  /// The [List] of search results that is displayed when searching.
  List<TimelineEntry> _searchResults = [];

  /// [MenuData] is a wrapper object for the data of each Card section.
  /// This data is loaded from the asset bundle during [initState()]
  final MenuData _menu = MenuData();

  /// This is passed to the SearchWidget so we can handle text edits and display the search results on the main menu.
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer _searchTimer;

  cancelSearch() {
    if (_searchTimer != null && _searchTimer.isActive) {
      /// Remove old timer.
      _searchTimer.cancel();
      _searchTimer = null;
    }
  }

  /// Helper function which sets the [MenuItemData] for the [TimelineWidget].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [Navigator], and by providing the [item] as
  /// a parameter to the [TimelineWidget] constructor, this widget will know
  /// where to scroll to.
  navigateToTimeline(MenuItemData item) {
    _pauseSection();
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (BuildContext context) =>
          TimelineWidget(item, BlocProvider.getTimeline(context)),
    ))
        .then(_restoreSection);
  }

  _restoreSection(v) => setState(() => _isSectionActive = true);
  _pauseSection() => setState(() => _isSectionActive = false);

  /// Used by the [_searchTextController] to properly update the state of this widget,
  /// and consequently the layout of the current view.
  updateSearch() {
    cancelSearch();
    if (!_isSearching) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    String txt = _searchTextController.text.trim();

  }

  @override
  initState() {
    super.initState();

    /// The [_menu] loads a JSON file that's stored in the assets folder.
    /// This asset provides all the necessary information for the cards,
    /// such as labels, background colors, the background Flare animation asset,
    /// and for each element in the expanded card, the relative position on the [Timeline].
    _menu.loadFromBundle("assets/menu.json").then((bool success) {
      if (success) setState(() {}); // Load the menu.
    });

    _searchTextController.addListener(() {
      updateSearch();
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
        updateSearch();
      });
    });
  }

  /// A [WillPopScope] widget wraps the menu, so that before dismissing the whole app,
  /// search will be popped first. Otherwise the app will proceed as usual.
  Future<bool> _popSearch() {
    if (_isSearching) {
      setState(() {
        _searchFocusNode.unfocus();
        _searchTextController.clear();
        _isSearching = false;
      });
      return Future(() => false);
    } else {
      Navigator.of(context).pop(true);
      return Future(() => true);
    }
  }

/*  void _tapSearchResult(TimelineEntry entry) {
    navigateToTimeline(MenuItemData.fromEntry(entry));
  }*/

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;

    List<Widget> tail = [];

    tail
      ..addAll(_menu.sections
          .map<Widget>((MenuSectionData section) => Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: MenuSection(
            section.label,
            section.backgroundColor,
            section.textColor,
            section.items,
            navigateToTimeline,
            _isSectionActive,
            //assetId: section.assetId,
          )))
          .toList(growable: false))
      ..add(Container(
        margin: const EdgeInsets.only(top: 40.0, bottom: 22),
        height: 1.0,
        color: const Color.fromRGBO(151, 151, 151, 0.29),
      ));


    /// Wrap the menu in a [WillPopScope] to properly handle a pop event while searching.
    /// A [SingleChildScrollView] is used to create a scrollable view for the main menu.
    /// This will contain a [Column] with a [Collapsible] header on top, and a [tail]
    /// that's built according with the state of this widget.
    return WillPopScope(
      onWillPop: _popSearch,
      child: Container(
          color: background,
          child: Padding(
            padding: EdgeInsets.only(top: devicePadding.top),
            child: SingleChildScrollView(
                padding:
                const EdgeInsets.only(top: 20.0, left: 20, right: 20, bottom: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                    ] +
                        tail)),
          )),
    );
  }
}
