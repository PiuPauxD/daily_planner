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
  initialDate = DateTime.now();
  //вызывает всплывающий календарь
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    model.setChosenDate(DateFormat.yMMMd("en_US").format(picked.toLocal()));
    return '${picked.day}.${picked.month}.${picked.year}';
  }
}
