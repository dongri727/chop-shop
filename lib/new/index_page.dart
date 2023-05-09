import 'package:flutter/material.dart';

import '../bloc_provider.dart';
import '../timeline_widget.dart';

class IndexPage extends StatefulWidget {

  //final NavigateTo navigateTo;

  IndexPage(
      //this.navigateTo,
      {Key key}) : super(key: key);


  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  int eraStart = 0;
  int eraEnd = 0;

  navigateToTimeline(eraStart, eraEnd) async {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (BuildContext context) =>
          TimelineWidget(eraStart, eraEnd),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {
                navigateToTimeline;

              },
              child: Text("Billion Years"),
            )
              ),
          Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {

                },
                child: Text("Million Years"),
              )
          ),
          Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {

                },
                child: Text("Historical Years"),
              )
          ),
          Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {

                },
                child: Text("21 Century"),
              )
          ),
        ],
      )
    );
  }
}