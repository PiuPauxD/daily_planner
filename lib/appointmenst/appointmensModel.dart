import 'package:flutter_book/baseModel.dart';

class Appointment {
  int? id;
  String title = '';
  String description = '';
  //дата встречи
  String? apptDate;
  //время встречи
  String? apptTime;
}

//метод работы со временем на экране
class AppointmentsModel extends BaseModel {
  String? apptTime;
  void setApptTime(String inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }
}

class AppointmensModel extends BaseModel {}

AppointmentsModel appointmentsModel = AppointmentsModel();
