import 'package:flutter/material.dart';
import 'package:flutter_book/notes/notesDBWorker.dart';
import 'package:flutter_book/notes/notesEntry.dart';
import 'package:flutter_book/notes/notesList.dart';
import 'package:flutter_book/notes/notesModel.dart';
import 'package:scoped_model/scoped_model.dart';

class Notes extends StatelessWidget {
  Notes({super.key}) {
    notesModel.loadData("notes", NotesDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget? child, NotesModel model) {
        //Хранение экранов
        return IndexedStack(
          index: model.stackIndex,
          children: [const NotesList(), NotesEntry()],
        );
      }),
    );
  }
}
