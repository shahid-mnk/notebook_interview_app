import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notebook_app/common/constants.dart';
import 'package:notebook_app/widgets/small_appbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:notebook_app/helpers/globals.dart' as globals;

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    getAppInfo();
    _initPackageInfo();
    super.initState();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: SAppBar(
          title: 'About',
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: kGlobalOuterPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/app_icon.png',
                    height: 50,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        'NoteBook App',
                        style: GoogleFonts.poppins(
                            fontSize: 25, fontWeight: FontWeight.w600),
                      )),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(15.0),
              onTap: () {},
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Iconsax.cpu),
                ),
                title: const Text('App Version'),
                subtitle: Text(_packageInfo.version),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
