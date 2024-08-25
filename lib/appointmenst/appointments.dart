import 'package:flutter/material.dart';
import 'package:flutter_book/appointmenst/appointmensModel.dart';
import 'package:flutter_book/appointmenst/appointmentsDBWorker.dart';
import 'package:flutter_book/appointmenst/appointmentsEntry.dart';
import 'package:flutter_book/appointmenst/appointmentsList.dart';
import 'package:scoped_model/scoped_model.dart';

class Appointments extends StatelessWidget {
  Appointments({super.key}) {
    appointmentsModel.loadData('appointments', AppointmentsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: appointmentsModel,
        child: ScopedModelDescendant(builder:
            (BuildContext context, Widget? child, AppointmentsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [
              const AppointmentsList(),
              AppointmentsEntry(),
            ],
          );
        }));
  }
}
