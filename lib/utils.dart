import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "baseModel.dart";

//каталог документов приложения
late Directory docsDir;

//выбор даты на экранах добавления
Future selectDate(
    //Base model объект, для которого будет выбрана дата
    BuildContext context,
    BaseModel model,
    String dateString) async {
  //Устанавливает текущий день
  DateTime initialDate = DateTime.now();
  //разделет дату на части точкой
  List dateParts = dateString.split(".");
  initialDate = DateTime(
    int.parse(dateParts[0]),
    int.parse(dateParts[1]),
    int.parse(dateParts[2]),
  );
  //вызывает всплывающий календарь
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  //сохранение выбранной даты
  if (picked != null) {
    model.setChosenDate(
      DateFormat.yMMMMd("en_US").format(picked.toLocal()),
    );
    return "${picked.day}. ${picked.month}. ${picked.year}";
  }
}
