import 'dart:convert';
import 'dart:typed_data';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notebook_app/common/constants.dart';
import 'package:notebook_app/helpers/utility.dart';
import 'package:notebook_app/pages/about_page.dart';
import 'package:notebook_app/pages/app_lock_page.dart';
import 'package:notebook_app/pages/biometric_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:notebook_app/helpers/globals.dart' as globals;

import 'labels_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences sharedPreferences;
  bool isAppLogged = false;
  bool isAppUnlocked = false;
  bool usePin = false;
  bool useBiometric = false;
  late String username;
  late String useremail;
  Uint8List? avatarData;

  bool isAndroid = UniversalPlatform.isAndroid;
  bool isIOS = UniversalPlatform.isIOS;
  bool isWeb = UniversalPlatform.isWeb;
  bool _isExpanded = false;

  int themeModeState = 0;
  String themeModeStateName = '';
  ThemeMode themeMode = ThemeMode.system;
  String _themeModeName = 'System';

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isAppUnlocked = sharedPreferences.getBool("is_app_unlocked") ?? false;
      usePin = sharedPreferences.getBool("is_pin_required") ?? false;
      isAppLogged = sharedPreferences.getBool('is_logged') ?? false;
      themeModeState = sharedPreferences.getInt('themeMode') ?? 2;
      useBiometric = sharedPreferences.getBool('use_biometric') ?? true;
      username = sharedPreferences.getString('nc_userdisplayname') ?? '';
      useremail = sharedPreferences.getString('nc_useremail') ?? '';
      avatarData = base64Decode(sharedPreferences.getString('nc_avatar') ?? '');
      sharedPreferences.setBool('use_biometric', true);
    });
    getThemeModeName();
  }

  setThemeMode(BuildContext context, String value) {
    print(value);
    setState(() {
      if (value == '0') {
        themeMode = ThemeMode.light;
        sharedPreferences.setInt('themeMode', 0);
        print(sharedPreferences.getInt('themeMode'));
        Phoenix.rebirth(context);
      } else if (value == '1') {
        themeMode = ThemeMode.dark;
        sharedPreferences.setInt('themeMode', 1);
        print(sharedPreferences.getInt('themeMode'));
        Phoenix.rebirth(context);
      } else if (value == '2') {
        themeMode = ThemeMode.dark;
        sharedPreferences.setInt('themeMode', 2);
        print(sharedPreferences.getInt('themeMode'));
        Phoenix.rebirth(context);
      } else {
        themeMode = ThemeMode.system;
        sharedPreferences.setInt('themeMode', 3);
        print(sharedPreferences.getInt('themeMode'));
        Phoenix.rebirth(context);
      }
      getThemeModeName();
    });
  }

  void getThemeModeName() async {
    int _themeMode = 2;
    setState(() {
      _themeMode = sharedPreferences.getInt('themeMode') ?? 2;
      switch (_themeMode) {
        case 0:
          _themeModeName = 'Light';
          break;
        case 1:
          _themeModeName = 'Dark';
          break;
        case 2:
          _themeModeName = 'System';
          break;
        default:
          _themeModeName = 'System';
          break;
      }
    });
  }

  @override
  void initState() {
    getPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: darkModeOn ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                titlePadding: EdgeInsets.only(left: 30, bottom: 15),
              ),
            ),
          ];
        },
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: kGlobalOuterPadding,
                  child: Column(
                    children: [
                      Padding(
                        padding: kGlobalCardPadding,
                        child: ExpansionTile(
                          subtitle: const Text('Secure your notes'),
                          leading: const CircleAvatar(
                            child: Icon(Iconsax.lock),
                          ),
                          title: const Text('App Lock',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: const Icon(Iconsax.arrow_down_1),
                          children: [
                            if (!usePin && !useBiometric)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () {
                                    if (usePin) {
                                      showAppLockMenu();
                                    } else {
                                      callAppLock();
                                    }
                                  },
                                  child: const ListTile(
                                    leading: SizedBox(
                                      width: 20,
                                    ),
                                    title: Text(
                                      'Set Pin',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                            if (!usePin)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: ListTile(
                                  leading: const SizedBox(
                                    width: 20,
                                  ),
                                  title: const Text(
                                    'Use Biometric',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  trailing: Switch.adaptive(
                                    value: useBiometric,
                                    onChanged: (value) {
                                      setState(() {
                                        useBiometric = value;
                                        if (value) {
                                          confirmBiometrics();
                                        } else {
                                          sharedPreferences.setBool(
                                              'use_biometric', false);
                                        }
                                        print(useBiometric);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            if (usePin)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    callAppLock();
                                  },
                                  child: const ListTile(
                                    leading: SizedBox(
                                      width: 20,
                                    ),
                                    title: Text(
                                      'Reset Passcode',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                            if (usePin)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    unSetAppLock();
                                  },
                                  child: const ListTile(
                                    leading: SizedBox(
                                      width: 20,
                                    ),
                                    title: Text(
                                      'Remove App lock',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () {
                            themeDialog();
                          },
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Iconsax.moon),
                            ),
                            title: const Text(
                              'App Theme',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(_themeModeName),
                          ),
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => const AboutPage()));
                          },
                          child: const ListTile(
                            leading: CircleAvatar(
                              child: Icon(Iconsax.info_circle),
                            ),
                            title: Text(
                              'About',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('Know the App'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () {
                            _confirmLogOut();
                          },
                          child: const ListTile(
                            leading: CircleAvatar(
                              child: Icon(Iconsax.logout),
                            ),
                            title: Text(
                              'Log Out',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('Exit the App'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  openDialog(Widget page) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: darkModeOn ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: darkModeOn ? Colors.white24 : Colors.black12,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Container(
                decoration: BoxDecoration(
                  color: darkModeOn ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                    maxWidth: 600,
                    minWidth: 400,
                    minHeight: 600,
                    maxHeight: 600),
                padding: const EdgeInsets.all(8),
                child: page),
          );
        });
  }

  void themeDialog() {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        constraints: BoxConstraints(),
        builder: (context) {
          return Container(
            margin: EdgeInsets.only(bottom: 40.0),
            child: Padding(
              padding: kGlobalOuterPadding,
              child: Container(
                height: 200,
                child: Padding(
                  padding: kGlobalOuterPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Change theme',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: FlexColor.jungleDarkSecondary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 18),
                        child: Text(
                          _themeModeName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: FlexColor.jungleDarkSecondary),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Iconsax.sun_1,
                                    size: 30,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Light',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => setThemeMode(context, '0'),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Iconsax.moon,
                                    size: 30,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Dark',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => setThemeMode(context, '1'),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Iconsax.setting,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'System',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => setThemeMode(context, '2'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void confirmBiometrics() async {
    bool res = await Navigator.of(context).push(
        CupertinoPageRoute(builder: (BuildContext context) => BiometricPage()));
    setState(() {
      if (res) {
        sharedPreferences.setBool('use_biometric', true);
        useBiometric = true;
      } else {
        sharedPreferences.setBool('use_biometric', false);
        useBiometric = false;
      }
    });
  }

  void confirmBiometricsLogOut() async {
    bool res = await Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (BuildContext context) => const BiometricPage()));
    setState(() {
      if (res) {
        SystemNavigator.pop();
        sharedPreferences.setBool('use_biometric', true);
        useBiometric = true;
      } else {
        sharedPreferences.setBool('use_biometric', false);
        useBiometric = false;
      }
    });
  }

  void showAppLockMenu() {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        constraints: const BoxConstraints(maxWidth: 800, minWidth: 300),
        builder: (context) {
          return Padding(
            padding: kGlobalOuterPadding,
            child: SizedBox(
              height: 140,
              child: Padding(
                padding: kGlobalOuterPadding,
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        callAppLock();
                      },
                      child: const ListTile(
                        title: Text('Reset Passcode'),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        unSetAppLock();
                        Navigator.pop(context);
                      },
                      child: const ListTile(
                        title: Text('Remove App lock'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _confirmLogOut() async {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        constraints: BoxConstraints(),
        builder: (context) {
          return Container(
            margin: EdgeInsets.only(bottom: 10.0),
            child: Padding(
              padding: kGlobalOuterPadding,
              child: Container(
                height: 150,
                child: Padding(
                  padding: kGlobalOuterPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: kGlobalCardPadding,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Padding(
                        padding: kGlobalCardPadding,
                        child: Text('Are you sure you want to log out?'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('No'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: ElevatedButton(
                                onPressed: () {
                                  sharedPreferences.clear();
                                  getPref();
                                  confirmBiometricsLogOut();
                                },
                                child: Text('Yes'),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void callAppLock() async {
    final res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => const AppLockPage(
              appLockState: AppLockState.SET,
            )));
    if (res == true) getPref();
  }

  void unSetAppLock() async {
    setState(() {
      sharedPreferences.setBool("is_pin_required", false);
      sharedPreferences.setBool("is_app_unlocked", true);
      sharedPreferences.setString("app_pin", '');
      isAppUnlocked = true;
      usePin = false;
    });
  }
}
