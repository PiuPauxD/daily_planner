// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter_book/appointmenst/appointmensModel.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;

class AppointmentsDBWorker {
  //Убеждаемся, что существует только 1 экземпляр класса

  //Создание закрытого конструктора
  AppointmentsDBWorker._();
  //вызов конструктора
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

//проверяем есть ли что-то в БД
  Database? _db;
  Future get database async {
    //Если БД пустая вызывается метод init()
    _db ??= await init();
    return _db;
  }

//Убеждаемся, что БД существует
  Future<Database> init() async {
    //Объединяем путь к катологу документов с именем файла appointments
    String path = join(utils.docsDir.path, "appointments.db");
    //Создание объекта Database из сформированного пути
    Database? db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database DB, int version) async {
      //выполнение SQL-запроса для создания таблицы tasks, если такая не создана
      await DB.execute("CREATE TABLE IF NOT EXISTS appointments ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "description TEXT,"
          "apptDate TEXT,"
          "apptTime TEXT"
          ")");
    });
    return db;
  }

//преобразование объекта в appointment из map
  Appointment appointmentFromMap(Map<String, dynamic> map) {
    Appointment appointment = Appointment();
    appointment.id = map["id"];
    appointment.title = map["title"];
    appointment.description = map["description"];
    appointment.apptDate = map["apptDate"];
    appointment.apptTime = map["apptTime"];
    return appointment;
  }

//преобразование объекта из appointment в map
  Map<String, dynamic> appointmentToMap(Appointment appointment) {
    Map<String, dynamic> map = {};
    map["id"] = appointment.id;
    map["title"] = appointment.title;
    map["description"] = appointment.description;
    map["apptDate"] = appointment.apptDate;
    map["apptTime"] = appointment.apptTime;
    return map;
  }

//создание заметки  в бд
  Future create(Appointment appointment) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    Object? id = val.first["id"];
    id ??= 1;
    return await db.rawInsert(
        "INSERT INTO tasks (id, title, description, apptDate, apptTime) "
        "VALUES (?, ?, ?, ?, ?)",
        [
          id,
          appointment.title,
          appointment.description,
          appointment.apptDate,
          appointment.apptTime
        ]);
  }

  //получение указанной задач
  Future<Appointment> get(int id) async {
    Database db = await database;
    var rec = await db.query("tasks", where: "id = ?", whereArgs: [id]);
    return appointmentFromMap(rec.first);
  }

  //извлечение всех задач за 1 вызов
  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("tasks");
    var list =
        recs.isNotEmpty ? recs.map((m) => appointmentFromMap(m)).toList() : [];
    return list;
  }

  //обновление задач
  Future update(Appointment appointment) async {
    Database db = await database;
    return await db.update("tasks", appointmentToMap(appointment),
        where: "id = ?", whereArgs: [appointment.id]);
  }

  //удаление заметки
  Future delete(int id) async {
    Database db = await database;
    return await db.delete("appointments", where: "id = ?", whereArgs: [id]);
  }
}
