// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_book/baseModel.dart';

class Appointment {
  int? id;
  String title = ' ';
  String description = ' ';
  //дата встречи
  DateTime? apptDate = DateTime.now();
  //время встречи
  TimeOfDay? apptTime = TimeOfDay.now();

  @override
  String toString() {
    return '{id = $id, title = $title, description = $description, apptDate = $apptDate, apptTime = $apptTime}';
  }
}

//метод работы со временем на экране
class AppointmentsModel extends BaseModel {
  String? apptDate;
  void setApptDate(String inApptDate) {
    apptDate = inApptDate;
    notifyListeners();
  }

  String? apptTime;
  void setApptTime(String inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();
