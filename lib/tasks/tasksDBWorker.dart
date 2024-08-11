// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter_book/tasks/tasksModel.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;

class TasksDBWorker {
  //Убеждаемся, что существует только 1 экземпляр класса

  //Создание закрытого конструктора
  TasksDBWorker._();
  //вызов конструктора
  static final TasksDBWorker db = TasksDBWorker._();

//проверяем есть ли что-то в БД
  Database? _db;
  Future get database async {
    //Если БД пустая вызывается метод init()
    _db ??= await init();
    return _db;
  }

//Убеждаемся, что БД существует
  Future<Database> init() async {
    //Объединяем путь к катологу документов с именем файла tasks
    String path = join(utils.docsDir.path, "tasks.db");
    //Создание объекта Database из сформированного пути
    Database? db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database DB, int version) async {
      //выполнение SQL-запроса для создания таблицы tasks, если такая не создана
      await DB.execute("CREATE TABLE IF NOT EXISTS tasks ("
          "id INTEGER PRIMARY KEY,"
          "description TEXT,"
          "dueDate TEXT,"
          "completed TEXT"
          ")");
    });
    return db;
  }

//преобразование объекта в task из map
  Task taskFromMap(Map<String, dynamic> map) {
    Task task = Task();
    task.id = map["id"];
    task.description = map["description"];
    task.dueDate = map["dueDate"];
    task.completed = map["completed"];
    return task;
  }

//преобразование объекта из task в map
  Map<String, dynamic> taskToMap(Task task) {
    Map<String, dynamic> map = {};
    map["id"] = task.id;
    map["description"] = task.description;
    map["dueDate"] = task.dueDate;
    map["completed"] = task.completed;
    return map;
  }

//создание заметки  в бд
  Future create(Task task) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    Object? id = val.first["id"];
    id ??= 1;
    return await db.rawInsert(
        "INSERT INTO tasks (id, description, dueDate, completed) "
        "VALUES (?, ?, ?, ?)",
        [id, task.description, task.dueDate, task.completed]);
  }

  //получение указанной задач
  Future<Task> get(int id) async {
    Database db = await database;
    var rec = await db.query("tasks", where: "id = ?", whereArgs: [id]);
    return taskFromMap(rec.first);
  }

  //извлечение всех задач за 1 вызов
  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("tasks");
    var list = recs.isNotEmpty ? recs.map((m) => taskFromMap(m)).toList() : [];
    return list;
  }

  //обновление задач
  Future update(Task task) async {
    Database db = await database;
    return await db.update("tasks", taskToMap(task),
        where: "id = ?", whereArgs: [task.id]);
  }

  //удаление заметки
  Future delete(int id) async {
    Database db = await database;
    return await db.delete("tasks", where: "id = ?", whereArgs: [id]);
  }
}
