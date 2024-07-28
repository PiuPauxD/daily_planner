import "package:scoped_model/scoped_model.dart";

class BaseModel extends Model {
  //отвечает за текущий экран
  int stackIndex = 0;
  //списки с данными экранов
  List entityList = [];
  //позвояет редактировать существующие элементы
  // ignore: prefer_typing_uninitialized_variables
  var entityBeingEdited;
  //хранит дату, выбранную при редактировании
  late String chosenDate;

//возвращает выбранную дату в модель
  void setChosenDate(String date) {
    chosenDate = date;
    //обновляет экран, чтобы показать выбранную дату
    notifyListeners();
  }

  //вызывается когдаа добавляется или удаляется элемент
  void loadData(String entityType, dynamic dataBase) async {
    //get.All() заменяет entityList
    entityList = await dataBase.getAll();
    //обновляет экран
    notifyListeners();
  }

//вызывается при перемещении м/у экрана списка и вывода
  void setStackIndex(int stacIndex) {
    stacIndex = stacIndex;
    notifyListeners();
  }
}
