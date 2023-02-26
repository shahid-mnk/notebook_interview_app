import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:notebook_app/helpers/database_helper.dart';
import 'package:notebook_app/models/note_list_model.dart';
import 'package:notebook_app/pages/app.dart';
import 'package:notebook_app/pages/note_reader_page.dart';
import 'package:notebook_app/widgets/note_card_grid.dart';
import 'package:notebook_app/widgets/note_card_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notebook_app/helpers/globals.dart' as globals;

import '../models/notes_model.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({Key? key}) : super(key: key);

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  late SharedPreferences sharedPreferences;
  List<Notes> notesList = [];
  bool isLoading = false;
  bool hasData = false;
  late ViewType _viewType;

  TextEditingController _searchController = new TextEditingController();
  final dbHelper = DatabaseHelper.instance;

  int selectedPageColor = 1;

  bool isDesktop = false;

  loadArchiveNotes() async {
    setState(() {
      isLoading = true;
    });

    await dbHelper.getNotesArchived(_searchController.text).then((value) {
      setState(() {
        print(value.length);
        isLoading = false;
        hasData = value.length > 0;
        notesList = value;
      });
    });
  }

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      bool isTile = sharedPreferences.getBool("is_tile") ?? false;
      _viewType = isTile ? ViewType.Tile : ViewType.Grid;
    });
  }

  @override
  void initState() {
    getPref();
    loadArchiveNotes();
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
                  'Archive',
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
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : (hasData
                        ? (_viewType == ViewType.Grid
                            ? StaggeredGridView.countBuilder(
                                crossAxisCount: isDesktop ? 4 : 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                // shrinkWrap: true,
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemCount: notesList.length,
                                staggeredTileBuilder: (index) {
                                  return StaggeredTile.count(
                                      1, index.isOdd ? 0.9 : 1.02);
                                },
                                itemBuilder: (context, index) {
                                  var note = notesList[index];
                                  List<NoteListItem> _noteList = [];
                                  if (note.noteList.contains('{')) {
                                    final parsed = json
                                        .decode(note.noteText)
                                        .cast<Map<String, dynamic>>();
                                    _noteList = parsed
                                        .map<NoteListItem>((json) =>
                                            NoteListItem.fromJson(json))
                                        .toList();
                                  }
                                  return NoteCardGrid(
                                    note: note,
                                    onTap: () {
                                      setState(() {
                                        selectedPageColor = note.noteColor;
                                      });
                                      _showNoteReader(context, note);
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: notesList.length,
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemBuilder: (context, index) {
                                  var note = notesList[index];
                                  List<NoteListItem> _noteList = [];
                                  if (note.noteList.contains('{')) {
                                    final parsed = json
                                        .decode(note.noteText)
                                        .cast<Map<String, dynamic>>();
                                    _noteList = parsed
                                        .map<NoteListItem>((json) =>
                                            NoteListItem.fromJson(json))
                                        .toList();
                                  }
                                  return NoteCardList(
                                    note: note,
                                    onTap: () {
                                      setState(() {
                                        selectedPageColor = note.noteColor;
                                      });
                                      _showNoteReader(context, note);
                                    },
                                    onLongPress: (){
                                      print("|||||||||||||||||Long press|||||||||||||||");
                                    },
                                  );
                                },
                              ))
                        : Container(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  height: 200,
                                ),
                                Icon(
                                  Iconsax.archive_minus,
                                  size: 100,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'No Archive Data!!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getDateString() {
    var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime dt = DateTime.now();
    return formatter.format(dt);
  }

  void _showNoteReader(BuildContext context, Notes _note) async {
      bool res = await Navigator.of(context).push( CupertinoPageRoute(
          builder: (BuildContext context) => NoteReaderPage(
                note: _note,
              )));
      if (res) loadArchiveNotes();
  }
}
