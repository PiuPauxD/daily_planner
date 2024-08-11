import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'notesDBWorker.dart';
import 'notesModel.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget? child, NotesModel model) {
          return Scaffold(
            body: ListView.builder(
              itemCount: notesModel.entityList.length,
              itemBuilder: (BuildContext buildContext, int index) {
                Note note = notesModel.entityList[index];
                //определение цвета заметки
                Color color = Colors.white;
                switch (note.color) {
                  case "red":
                    color = Colors.red;
                    break;
                  case "green":
                    color = Colors.green;
                    break;
                  case "blue":
                    color = Colors.blue;
                    break;
                  case "yellow":
                    color = Colors.yellow;
                    break;
                  case "grey":
                    color = Colors.grey;
                    break;
                  case "purple":
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
                          borderRadius: BorderRadius.circular(20),
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
                        title: Text(note.title),
                        subtitle: Text(note.content),
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
              onPressed: () {
                //сохраняет заметку
                notesModel.entityBeingEdited = Note();
                //устанавливает начальный цвет
                notesModel.setColor('');
                //перемещает пользователя на экран создания заметки
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

  Future deleteNote(BuildContext context, Note note) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text('Delete Note'),
            content: Text('Are you sure you want to delete ${note.title}?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(alertContext).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      NotesDBWorker.db.delete(note.id!);
                      Navigator.of(alertContext).pop();

                      notesModel.loadData('notes', NotesDBWorker.db);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
