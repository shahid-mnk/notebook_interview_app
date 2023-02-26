import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notebook_app/common/constants.dart';
import 'package:notebook_app/common/theme.dart';
import 'package:notebook_app/helpers/utility.dart';
import 'package:notebook_app/pages/app.dart';
import 'package:notebook_app/pages/app_lock_page.dart';
import 'package:notebook_app/pages/introduction_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/biometric_page.dart';
import 'helpers/globals.dart' as globals;

late SharedPreferences prefs;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Phoenix(
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;
  int themeID = 3;

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getInt('themeMode') != null) {
        switch (prefs.getInt('themeMode')) {
          case 0:
            themeMode = ThemeMode.light;
            break;
          case 1:
            themeMode = ThemeMode.dark;
            break;
          case 2:
            themeMode = ThemeMode.system;
            break;
          default:
            themeMode = ThemeMode.system;
            break;
        }
      } else {
        themeMode = ThemeMode.system;
        prefs.setInt('themeMode', 2);
      }
      globals.themeMode = themeMode;
      prefs.setBool('use_biometric', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: theme(),
      darkTheme: themeDark(),
      home: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool isAppUnlocked = false;
  bool isPinRequired = false;
  bool useBiometric = false;
  bool newUser = true;

  getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isAppUnlocked = prefs.getBool("is_app_unlocked") ?? false;
      isPinRequired = prefs.getBool("is_pin_required") ?? false;
      useBiometric = prefs.getBool('use_biometric') ?? true;
      newUser = prefs.getBool('newUser') ?? true;

      if (isPinRequired) {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new AppLockPage(appLockState: AppLockState.CONFIRM),
            ),
            (Route<dynamic> route) => false);
      } else if (useBiometric) {
        confirmBiometrics();
      } else {
        if (newUser) {
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(
                builder: (BuildContext context) => new IntroductionPage(),
              ),
              (Route<dynamic> route) => false);
        } else
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(
                  builder: (BuildContext context) => new DashBoardScreen()),
              (Route<dynamic> route) => false);
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  void confirmBiometrics() async {
    bool res = await Navigator.of(context).push(new CupertinoPageRoute(
        builder: (BuildContext context) => new BiometricPage()));
    if (res)
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(
            builder: (BuildContext context) => new DashBoardScreen(),
          ),
          (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
