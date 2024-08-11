import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/tasksDBWorker.dart';
import 'package:flutter_book/tasks/tasksModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'tasksModel.dart' show TaskModel, taskModel;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry({super.key}) {
    _descriptionEditingController.addListener(() {
      taskModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _descriptionEditingController.text = taskModel.entityBeingEdited != null
        ? taskModel.entityBeingEdited.description
        : '';
    return ScopedModel(
      model: taskModel,
      child: ScopedModelDescendant<TaskModel>(
          builder: (BuildContext context, Widget? child, TaskModel model) {
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
                    _save(context, taskModel);
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
                  leading: const Icon(Icons.description_outlined),
                  title: TextFormField(
                    decoration: const InputDecoration(hintText: "Description"),
                    controller: _descriptionEditingController,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.today_outlined),
                  title: const Text("Due Date"),
                  subtitle: Text('${DateTime.now()}'),
                  trailing: IconButton(
                      onPressed: () async {
                        // ignore: unused_local_variable
                        String chosenDate = await utils.selectDate(
                            context,
                            taskModel,
                            taskModel.entityBeingEdited.dueDate ??
                                '11.8.2024'.toString());
                        taskModel.entityBeingEdited.dueDate = chosenDate;
                      },
                      icon: const Icon(Icons.edit_outlined)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _save(BuildContext context, TaskModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (taskModel.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(taskModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(taskModel.entityBeingEdited);
    }

    taskModel.loadData("notes", TasksDBWorker.db);
    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Note saved'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }
}
