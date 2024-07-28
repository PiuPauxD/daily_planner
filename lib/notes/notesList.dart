import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'notesDBWorker.dart';
import 'notesModel.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    Future deleteNote(BuildContext context, Note note) {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext alertContext) {
            return AlertDialog(
              title: const Text('Delete Note'),
              content: Text('Are you sure you want to delete ${note.title}?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    NotesDBWorker.db.delete(note.id!);
                    Navigator.of(alertContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note deleted'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    notesModel.loadData('notes', NotesDBWorker.db);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });
    }

    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget? child, NotesModel model) {
          return Scaffold(
            body: ListView.builder(
              itemCount: notesModel.entityList.length,
              itemBuilder: (BuildContext buildContext, int index) {
                Note note = notesModel.entityList[index];
                Color color = Colors.white;
                switch (note.color) {
                  case 'red':
                    color = Colors.red;
                    break;
                  case 'green':
                    color = Colors.green;
                    break;
                  case 'blue':
                    color = Colors.blue;
                    break;
                  case 'yellow':
                    Colors.yellow;
                    break;
                  case 'grey':
                    color = Colors.grey;
                    break;
                  case 'purple':
                    color = Colors.purple;
                    break;
                }
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          label: 'delete',
                          backgroundColor: Colors.red,
                          icon: Icons.delete_outline,
                          onPressed: (BuildContext context) {
                            deleteNote(context, note);
                          },
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 8,
                      color: color,
                      child: ListTile(
                        title: Text("${note.content}"),
                        onTap: () async {
                          notesModel.entityBeingEdited =
                              await NotesDBWorker.db.get(note.id!);
                          notesModel
                              .setColor(notesModel.entityBeingEdited.color);
                          notesModel.setStackIndex(1);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              focusColor: Colors.yellow,
              onPressed: () {
                notesModel.entityBeingEdited = Note();
                // notesModel.setColor(Colors.purple);
                notesModel.setStackIndex(1);
              },
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}
