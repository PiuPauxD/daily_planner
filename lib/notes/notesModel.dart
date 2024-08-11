import '../baseModel.dart';

class Note {
  int? id;
  String title = ' ';
  String content = ' ';
  String? color;

//Переопределение реализации по умолчанию, представляему классом Object
  String toString() {
    return "{id = $id, title = $title, content = $content, color = $color}";
  }
}

//Задание цвета на фон заметки
class NotesModel extends BaseModel {
  String? color;
  void setColor(String color) {
    color = color;
    notifyListeners();
  }
}

//Создание экземпляра
NotesModel notesModel = NotesModel();
