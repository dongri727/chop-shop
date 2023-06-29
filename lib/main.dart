import 'package:chop_shop/timeline/timeline.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bloc_provider.dart';
import 'menu/main_menu.dart';


/// The app is wrapped by a [BlocProvider]. This allows the child widgets
/// to access other components throughout the hierarchy without the need
/// to pass those references around.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return BlocProvider(
      platform: Theme.of(context).platform,
      t: Timeline(Theme.of(context).platform),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CHOP SHOP',
        theme: ThemeData(
           useMaterial3: true),
        home: const MenuPage(),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null, body: MainMenuWidget());
  }
}

//TODO Set up your firebase environment
void main() /*async*/{
  WidgetsFlutterBinding.ensureInitialized();
/*  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/

  runApp(const MyApp());
}






