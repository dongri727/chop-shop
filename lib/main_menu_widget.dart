import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class MainMenuWidget extends StatefulWidget {
  MainMenuWidget ({Key? key}) : super(key: key);

  @override
  _MainMenuWidgetState createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {
  bool _isSearching = false;
  bool _isSectionActive = true;

  List<dynamic> _searchResults = [];
  final MenuData _menu = MenuData();

  navigateToTimeline(MenuItemData item) {
    _pauseSection();
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (BuildContext context) =>
          TimelineWidget(item, BlocProvider.getTimeline(context)),
    ))
        .then(_restoreSection);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _menu.loadFromBundle
  }
}