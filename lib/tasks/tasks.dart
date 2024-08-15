import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/taskList.dart';
import 'package:flutter_book/tasks/tasksDBWorker.dart';
import 'package:flutter_book/tasks/tasksEntry.dart';
import 'package:flutter_book/tasks/tasksModel.dart';
import 'package:scoped_model/scoped_model.dart';

class Tasks extends StatelessWidget {
  Tasks({super.key}) {
    taskModel.loadData("tasks", TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TaskModel>(
      model: taskModel,
      child: ScopedModelDescendant<TaskModel>(
          builder: (BuildContext context, Widget? child, TaskModel model) {
        //Хранение экранов
        return IndexedStack(
          index: model.stackIndex,
          children: [const TasksList(), TasksEntry()],
        );
      }),
    );
  }
}
