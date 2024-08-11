import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'notesModel.dart';

class NotesDBWorker {
  //Убеждаемся, что существует только 1 экземпляр класса

  //Создание закрытого конструктора
  NotesDBWorker._();
  //вызов конструктора
  static final NotesDBWorker db = NotesDBWorker._();

//проверяем есть ли что-то в БД
  Database? _db;
  Future get database async {
    //Если БД пустая вызывается метод init()
    _db ??= await init();
    return _db;
  }

//Убеждаемся, что БД существует
  Future<Database> init() async {
    //Объединяем путь к катологу документов с именем файла notes
    String path = join(utils.docsDir.path, "notes.db");
    //Создание объекта Database из сформированного пути
    Database? db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database DB, int version) async {
      //выполнение SQL-запроса для создания таблицы notes, если такая не создана
      await DB.execute("CREATE TABLE IF NOT EXISTS notes ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "content TEXT,"
          "color TEXT"
          ")");
    });
    return db;
  }

//преобразование объекта в note из map
  Note noteFromMap(Map<String, dynamic> map) {
    Note note = Note();
    note.id = map["id"];
    note.title = map["title"];
    note.content = map["content"];
    note.color = map["color"];
    return note;
  }

//преобразование объекта из note в map
  Map<String, dynamic> noteToMap(Note note) {
    Map<String, dynamic> map = {};
    map["id"] = note.id;
    map["title"] = note.title;
    map["content"] = note.content;
    map["color"] = note.color;
    return map;
  }

//создание заметки  в бд
  Future create(Note note) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
    Object? id = val.first["id"];
    id ??= 1;
    return await db.rawInsert(
        "INSERT INTO notes (id, title, content, color) "
        "VALUES (?, ?, ?, ?)",
        [id, note.title, note.content, note.color]);
  }

  //получение указанной заметки
  Future<Note> get(int id) async {
    Database db = await database;
    var rec = await db.query("notes", where: "id = ?", whereArgs: [id]);
    return noteFromMap(rec.first);
  }

  //извлечение всх заметок за 1 вызов
  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("notes");
    var list = recs.isNotEmpty ? recs.map((m) => noteFromMap(m)).toList() : [];
    return list;
  }

  //обновление заметки
  Future update(Note note) async {
    Database db = await database;
    return await db.update("notes", noteToMap(note),
        where: "id = ?", whereArgs: [note.id]);
  }

  //удаление заметки
  Future delete(int id) async {
    Database db = await database;
    return await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }
}
