import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notebook_app/common/constants.dart';
import 'package:notebook_app/helpers/database_helper.dart';
import 'package:notebook_app/models/note_list_model.dart';
import 'package:notebook_app/models/notes_model.dart';
import 'package:notebook_app/widgets/note_edit_list_textfield.dart';
import 'package:notebook_app/widgets/small_appbar.dart';
import 'package:uuid/uuid.dart';
import 'package:notebook_app/helpers/globals.dart' as globals;

class EditNotePage extends StatefulWidget {
  final Notes note;

  const EditNotePage({Key? key, required this.note}) : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();
  TextEditingController _noteTitleController = new TextEditingController();
  TextEditingController _noteTextController = new TextEditingController();
  TextEditingController _noteListTextController = new TextEditingController();
  bool _noteListCheckValue = false;
  String currentEditingNoteId = "";
  String _noteListJsonString = "";
  final dbHelper = DatabaseHelper.instance;
  var uuid = Uuid();
  late Notes note;
  bool isCheckList = false;
  List<NoteListItem> _noteListItems = [];

  void _saveNote() async {
    if (currentEditingNoteId.isEmpty) {
      setState(() {
        note = Notes(
            uuid.v1(),
            DateTime.now().toString(),
            _noteTitleController.text,
            _noteTextController.text,
            '',
            0,
            0,
            _noteListJsonString);
      });
      await dbHelper.insertNotes(note).then((value) {
        // loadNotes();
      });
    } else {
      setState(() {
        note =  Notes(
            currentEditingNoteId,
            DateTime.now().toString(),
            _noteTitleController.text,
            _noteTextController.text,
            '',
            0,
            0,
            _noteListJsonString);
      });
      await dbHelper.updateNotes(note).then((value) {
        // loadNotes();
      });
    }
  }

  void onSubmitListItem() async {
    _noteListItems.add(new NoteListItem(_noteListTextController.text, 'false'));
    _noteListTextController.text = "";
    print(_noteListCheckValue);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      note = widget.note;
      _noteTextController.text = note.noteText;
      _noteTitleController.text = note.noteTitle;
      currentEditingNoteId = note.noteId;
      isCheckList = note.noteList.contains('{');
    });
    titleFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Builder(builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: SAppBar(
              title: '',
              onTap: _onBackPressed,
              action: [
                Visibility(
                  visible: true,
                  child: IconButton(
                    icon: const Icon(Iconsax.tick_square, color: Colors.green),
                    onPressed: () {
                      if (_noteTextController.text.isNotEmpty) {
                        _saveNote();
                        Navigator.pop(context, note);
                      } else {
                        Fluttertoast.showToast(
                            gravity: ToastGravity.CENTER,
                            msg:
                            "\u26A0  Empty Note!! Add Something",
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          body: GestureDetector(
            onTap: () {
              contentFocusNode.requestFocus();
            },
            child: Padding(
              padding: kGlobalOuterPadding,
              child: ListView(
                children: [
                  TextField(
                    controller: _noteTitleController,
                    focusNode: titleFocusNode,
                    onSubmitted: (value) {
                      contentFocusNode.requestFocus();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      // label: Text('Title'),
                      // isCollapsed: true,
                      fillColor: Colors.transparent,
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    thickness: 1.2,
                    endIndent: 10,
                    indent: 10,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: _noteTextController,
                    focusNode: contentFocusNode,
                    maxLines: null,
                    onSubmitted: (value) {
                      contentFocusNode.requestFocus();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Content',
                      fillColor: Colors.transparent,
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  if (isCheckList)
                    ...List.generate(
                        _noteListItems.length, generatenoteListItems),
                  Visibility(
                    visible: isCheckList,
                    child: NoteEditListTextField(
                      checkValue: _noteListCheckValue,
                      controller: _noteListTextController,
                      onSubmit: () => onSubmitListItem(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget generatenoteListItems(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      child: Row(
        children: [
          const Icon(Icons.check_box),
          const SizedBox(
            width: 5.0,
          ),
          Expanded(
            child: Text(_noteListItems[index].value),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if (_noteTextController.text.isNotEmpty) {
      _saveNote();
      Navigator.pop(context, note);
    } else {
      Navigator.pop(context, false);
    }
    return false;
  }
}
