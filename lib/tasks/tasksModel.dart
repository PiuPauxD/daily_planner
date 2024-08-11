import '../baseModel.dart';

class Task {
  int? id;
  String description = ' ';
  String? dueDate;
  //отметка о выполнении
  String completed = 'false';

//Переопределение реализации по умолчанию, представляему классом Object
  String toString() {
    return "{id = $id, description = $description, dueDate = $dueDate, completed = $completed}";
  }
}

class TaskModel extends BaseModel {}

//Создание экземпляра
TaskModel taskModel = TaskModel();
