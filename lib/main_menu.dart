import 'package:chop_shop/bloc_provider.dart';
import 'package:chop_shop/main_menu_section.dart';
import 'package:chop_shop/menu_data.dart';
import 'package:chop_shop/timeline_widget.dart';
import "package:flutter/material.dart";

/// The Main Page of the Timeline App.
/// the card-sections for accessing the main events on the Timeline,
class MainMenuWidget extends StatefulWidget {
  MainMenuWidget({Key? key}) : super(key: key);

  @override
  _MainMenuWidgetState createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {

  /// [MenuData] is a wrapper object for the data of each Card section.
  /// This data is loaded from the asset bundle during [initState()]
  final MenuData _menu = MenuData();

  /// Helper function which sets the [MenuItemData] for the [TimelineWidget].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [Navigator], and by providing the [item] as
  /// a parameter to the [TimelineWidget] constructor, this widget will know
  /// where to scroll to.
  navigateToTimeline(MenuItemData item) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (BuildContext context) =>
          TimelineWidget(item, BlocProvider.getTimeline(context)),
    ));
  }

  @override
  initState() {
    super.initState();

    /// The [_menu] loads a JSON file that's stored in the assets folder.
    /// This asset provides all the necessary information for the cards,
    /// such as labels, background colors,
    /// and for each element in the expanded card, the relative position on the [Timeline].
    _menu.loadFromBundle("assets/menu.json").then((bool success) {
      if (success) setState(() {}); // Load the menu.
    });
  }

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
          )))
          .toList(growable: false));

    /// A [SingleChildScrollView] is used to create a scrollable view for the main menu.
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHOP SHOP"),
      ),
          body: Padding(
            padding: EdgeInsets.only(top: devicePadding.top),
            child: SingleChildScrollView(
                padding:
                const EdgeInsets.only(top: 20.0, left: 20, right: 20, bottom: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[] + tail)),
          ),
    );
  }
}
