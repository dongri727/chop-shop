import 'package:chop_shop/bloc_provider.dart';
import 'package:chop_shop/menu/main_menu_section.dart';
import 'package:chop_shop/menu/menu_data.dart';
import 'package:chop_shop/timeline/timeline_widget.dart';
import "package:flutter/material.dart";
import '../tff_format.dart';

/// The Main Page of the Timeline App.
/// the card-sections for accessing the main events on the Timeline,
class MainMenuWidget extends StatefulWidget {
  const MainMenuWidget({Key? key}) : super(key: key);

  @override
  MainMenuWidgetState createState() => MainMenuWidgetState();
}

class MainMenuWidgetState extends State<MainMenuWidget> {

  /// [MenuData] is a wrapper object for the data of each Card section.
  /// This data is loaded from the asset bundle during [initState()]
  final MenuData _menu = MenuData();

  /// Helper function which sets the [MenuItemData] for the [TimelineWidget].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [Navigator],  this widget will know where to scroll to.
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
    /// This asset provides all the necessary information
    _menu.loadFromBundle("assets/menu.json").then((bool success) {
      if (success) setState(() {}); // Load the menu.
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    final controller = TextEditingController();
    ///if you use firestore, get timeline through BlocProvider
    //final timeline = BlocProvider.getTimeline(context);

    List<Widget> tail = [];

    tail
        .addAll(_menu.sections
        .map<Widget>((MenuSectionData section) => Container(
        margin: const EdgeInsets.only(top: 20.0),
        child: MenuSection(
          section.label,
          section.backgroundColor,
          section.textColor,
          section.items,
          navigateToTimeline,
        )))
        .toList(growable: false)
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("TIMELINE"),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: devicePadding.top),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20,20,5,20),
                      child: FormatGrey(
                        controller: controller,
                        hintText: "Search Term",
                        onChanged: (text) {
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5,20,20,20),
                      child: ElevatedButton(
                        onPressed: () {
                          ///you can select data of firestore with this code
/*                         timeline.loadFromFirestore('events', country: controller.text.isNotEmpty
                              ? controller.text
                              : null);*/
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: const Text('Successfully Selected'),
                                  content: const Text('Please Choose an Era and Move On'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK')),
                                  ],
                                );
                              });
                        },
                        child: const Icon(Icons.done),
                      ),),
                  )
                ],
              ),
              Center(
                child: ElevatedButton(
                    onPressed: (){
                      controller.clear();
                      ///you can reload data from firestore with this code
                      ///events -> change to your collection path
                      ///country -> change to your field where you select
                      //timeline.loadFromFirestore('events',country: null);
                    },
                    child: Text('clear')),
              )
            ] + tail),
      ),
    );
  }
}
