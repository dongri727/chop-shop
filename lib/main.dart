import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bloc_provider.dart';
import 'color.dart';
import 'main_menu.dart';

/// The app is wrapped by a [BlocProvider]. This allows the child widgets
/// to access other components throughout the hierarchy without the need
/// to pass those references around.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return BlocProvider(
      platform: Theme.of(context).platform,
      child: MaterialApp(
        title: 'History & Future of Everything',
        theme: ThemeData(
            backgroundColor: background, scaffoldBackgroundColor: background),
        home: const MenuPage(),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null, body: MainMenuWidget());
  }
}

void main() => runApp(MyApp());





