// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/tasksDBWorker.dart';
import 'package:flutter_book/tasks/tasksModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TaskModel>(
      model: taskModel,
      child: ScopedModelDescendant(
          builder: (BuildContext context, Widget? child, TaskModel model) {
        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            itemCount: taskModel.entityList.length,
            itemBuilder: (BuildContext buildContext, int index) {
              Task task = taskModel.entityList[index];

              return Slidable(
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      borderRadius: BorderRadius.circular(20),
                      label: 'delete',
                      backgroundColor: Colors.red,
                      icon: Icons.delete_outline,
                      onPressed: (BuildContext context) {
                        deleteTask(context, task);
                      },
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: task.completed == 'true' ? true : false,
                    onChanged: (value) async {
                      task.completed = value.toString();
                      await TasksDBWorker.db.update(task);
                      taskModel.loadData("tasks", TasksDBWorker.db);
                    },
                  ),
                  title: Text(
                    task.description,
                    style: task.completed == 'true'
                        ? TextStyle(
                            color: Theme.of(context).disabledColor,
                            decoration: TextDecoration.lineThrough,
                          )
                        : const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    task.dueDate = task.dueDate.toString(),
                    style: task.completed == 'true'
                        ? TextStyle(
                            color: Theme.of(context).disabledColor,
                            decoration: TextDecoration.lineThrough,
                          )
                        : const TextStyle(color: Colors.black),
                  ),
                  onTap: () async {
                    if (task.completed == "true") {
                      return;
                    }
                    taskModel.entityBeingEdited =
                        await TasksDBWorker.db.get(task.id!);
                    taskModel.setChosenDate(task.dueDate!);
                    taskModel.setStackIndex(1);
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: () {
                taskModel.entityBeingEdited = Task();
                taskModel.setStackIndex(1);
              }),
        );
      }),
    );
  }

  Future deleteTask(BuildContext context, Task task) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text('Delete Note'),
            content:
                Text('Are you sure you want to delete ${task.description}?'),
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
                      TasksDBWorker.db.delete(task.id!);
                      Navigator.of(alertContext).pop();

                      taskModel.loadData('tasks', TasksDBWorker.db);
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
