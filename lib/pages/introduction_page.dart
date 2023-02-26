import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notebook_app/pages/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  late PageController _pageController;
  late SharedPreferences prefs;
  bool newUser = true;

  int _page = 0;

  void navigationForward(int page) {
    _pageController.animateToPage(page + 1,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void navigationBackward(int page) {
    _pageController.animateToPage(page - 1,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  getPref() async {
    prefs = await SharedPreferences.getInstance();
    newUser = prefs.getBool('newUser') ?? true;
  }

  @override
  void initState() {
    super.initState();
    getPref();
    _pageController = new PageController();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF173F6B),
            FlexColor.jungleLightTertiaryContainer,
          ],
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: FlexColorScheme.themedSystemNavigationBar(
          context,
          systemNavBarStyle: FlexSystemNavBarStyle.background,
          useDivider: false,
          opacity: 0,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: PageView(
            controller: _pageController,
            onPageChanged: onPageChanged,
            physics: BouncingScrollPhysics(),
            children: const [
              ScreenOne(),
              ScreenTwo(),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_page != 0)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () {
                          navigationBackward(_page);
                        },
                        child: Row(
                          children: const [
                            Icon(CupertinoIcons.back),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Back'),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                      ),
                      onPressed: () {
                        navigationForward(_page);
                        if (_page == 1) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const DashBoardScreen()),
                              (Route<dynamic> route) => false);
                          newUser = false;
                          prefs.setBool('newUser', false);
                        }
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Text('Next', style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w700)),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(CupertinoIcons.forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScreenOne extends StatefulWidget {
  const ScreenOne({Key? key}) : super(key: key);

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(80),
          child: Image.asset(
            'assets/images/app_icon.png',
            height: 100,
            width: 100,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Text('Welcome to',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        Text(
          'Note Book App',
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({Key? key}) : super(key: key);

  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.note,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 30),
              Text(
                'Take Notes Easily',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w600),
              ),
              const SizedBox(height: 30),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              const SizedBox(height: 30),
              const Icon(
                Iconsax.add_circle,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                'Create notes',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w600)
              ),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.white,
                thickness: 1,
                indent: 40,
                endIndent: 40,
              ),
              const SizedBox(height: 10),
              const Icon(
                Iconsax.document_download,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                'Backup them',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w600)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
