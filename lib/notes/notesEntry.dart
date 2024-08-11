// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notesDBWorker.dart';
import 'notesModel.dart' show NotesModel, notesModel;

class NotesEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//изменяет значение TextFormField
  NotesEntry({super.key}) {
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = notesModel.entityBeingEdited != null
        ? notesModel.entityBeingEdited.title
        : '';
    _contentEditingController.text = notesModel.entityBeingEdited != null
        ? notesModel.entityBeingEdited.content
        : '';
    return ScopedModel(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget? child, NotesModel model) {
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    //устанавливает область видимости
                    FocusScope.of(context).requestFocus(FocusNode());
                    model.setStackIndex(0);
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _save(context, notesModel);
                    model.setStackIndex(0);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.title),
                  title: TextFormField(
                    decoration: const InputDecoration(hintText: "Title"),
                    controller: _titleEditingController,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.content_paste),
                  title: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    decoration: const InputDecoration(hintText: 'Content'),
                    controller: _contentEditingController,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: Row(
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: Border.all(width: 18, color: Colors.red) +
                                Border.all(
                                    width: 6,
                                    color: notesModel.color == "red"
                                        ? Colors.red
                                        : Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () {
                          notesModel.entityBeingEdited.color = "red";
                          notesModel.setColor('red');
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: Border.all(width: 18, color: Colors.green) +
                                Border.all(
                                    width: 6,
                                    color: notesModel.color == "green"
                                        ? Colors.green
                                        : Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () {
                          notesModel.entityBeingEdited.color = "green";
                          notesModel.setColor("green");
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: Border.all(width: 18, color: Colors.blue) +
                                Border.all(
                                    width: 6,
                                    color: notesModel.color == "blue"
                                        ? Colors.blue
                                        : Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () {
                          notesModel.entityBeingEdited.color = "blue";
                          notesModel.setColor("blue");
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: Border.all(width: 18, color: Colors.yellow) +
                                Border.all(
                                    width: 6,
                                    color: notesModel.color == "yellow"
                                        ? Colors.yellow
                                        : Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () {
                          notesModel.entityBeingEdited.color = "yellow";
                          notesModel.setColor("yellow");
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: Border.all(width: 18, color: Colors.grey) +
                                Border.all(
                                    width: 6,
                                    color: notesModel.color == "grey"
                                        ? Colors.grey
                                        : Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () {
                          notesModel.entityBeingEdited.color = "grey";
                          notesModel.setColor("grey");
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: Border.all(width: 18, color: Colors.purple) +
                                Border.all(
                                    width: 6,
                                    color: notesModel.color == "purple"
                                        ? Colors.purple
                                        : Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () {
                          notesModel.entityBeingEdited.color = "purple";
                          notesModel.setColor("purple");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _save(BuildContext context, NotesModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (notesModel.entityBeingEdited.id == null) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    } else {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }

    notesModel.loadData("notes", NotesDBWorker.db);
    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Note saved'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }
}
