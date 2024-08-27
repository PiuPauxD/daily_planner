// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter_book/contacts/contactsModel.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;

class ContactsDBWorker {
  //Убеждаемся, что существует только 1 экземпляр класса

  //Создание закрытого конструктора
  ContactsDBWorker._();
  //вызов конструктора
  static final ContactsDBWorker db = ContactsDBWorker._();

//проверяем есть ли что-то в БД
  Database? _db;
  Future get database async {
    //Если БД пустая вызывается метод init()
    _db ??= await init();
    return _db;
  }

//Убеждаемся, что БД существует
  Future<Database> init() async {
    //Объединяем путь к катологу документов с именем файла contacts
    String path = join(utils.docsDir.path, "contacts.db");
    //Создание объекта Database из сформированного пути
    Database? db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database DB, int version) async {
      //выполнение SQL-запроса для создания таблицы contacts, если такая не создана
      await DB.execute("CREATE TABLE IF NOT EXISTS contacts ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "email TEXT,"
          "phone TEXT,"
          "birthday TEXT"
          ")");
    });
    return db;
  }

//преобразование объекта в contact из map
  Contact contactFromMap(Map<String, dynamic> map) {
    Contact contact = Contact();
    contact.id = map["id"];
    contact.name = map["name"];
    contact.email = map["email"];
    contact.phone = map["phone"];
    contact.birthday = map["birthday"];
    return contact;
  }

//преобразование объекта из contact в map
  Map<String, dynamic> contactToMap(Contact contact) {
    Map<String, dynamic> map = {};
    map["id"] = contact.id;
    map["name"] = contact.name;
    map["email"] = contact.email;
    map["phone"] = contact.phone;
    map["birthday"] = contact.birthday;
    return map;
  }

//создание заметки  в бд
  Future create(Contact contact) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM contacts");
    Object? id = val.first["id"];
    id ??= 1;
    return await db.rawInsert(
        "INSERT INTO contacts (id, name, email, phone, birthday) "
        "VALUES (?, ?, ?, ?, ?)",
        [id, contact.name, contact.email, contact.phone, contact.birthday]);
  }

  //получение указанного контакта
  Future<Contact> get(int id) async {
    Database db = await database;
    var rec = await db.query("contacts", where: "id = ?", whereArgs: [id]);
    return contactFromMap(rec.first);
  }

  //извлечение всех контактов за 1 вызов
  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("contacts");
    var list =
        recs.isNotEmpty ? recs.map((m) => contactFromMap(m)).toList() : [];
    return list;
  }

  //обновление задач
  Future update(Contact contact) async {
    Database db = await database;
    return await db.update("contacts", contactToMap(contact),
        where: "id = ?", whereArgs: [contact.id]);
  }

  //удаление заметки
  Future delete(int id) async {
    Database db = await database;
    return await db.delete("contacts", where: "id = ?", whereArgs: [id]);
  }
}
