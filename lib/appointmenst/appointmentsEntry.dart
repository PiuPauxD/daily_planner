// ignore_for_file: file_names, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_book/appointmenst/appointmentsDBWorker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'appointmensModel.dart' show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry({super.key}) {
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = appointmentsModel.entityBeingEdited != null
        ? appointmentsModel.entityBeingEdited.title
        : '';
    _descriptionEditingController.text =
        appointmentsModel.entityBeingEdited != null
            ? appointmentsModel.entityBeingEdited.description
            : '';
    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(builder:
          (BuildContext context, Widget? child, AppointmentsModel model) {
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    //устанавливает область видимости
                    FocusScope.of(context).requestFocus(FocusNode());
                    model.setStackIndex(0);
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _save(context, appointmentsModel);
                    model.setStackIndex(0);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                //Назване
                ListTile(
                  leading: const Icon(Icons.notes_outlined),
                  title: TextFormField(
                    decoration: const InputDecoration(hintText: 'Title'),
                    controller: _titleEditingController,
                  ),
                ),
                //Описание
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: TextFormField(
                    decoration: const InputDecoration(hintText: "Description"),
                    controller: _descriptionEditingController,
                  ),
                ),
                //дата встречи
                ListTile(
                  leading: const Icon(Icons.today_outlined),
                  title: const Text("Due Date"),
                  subtitle: Text(appointmentsModel.chosenDate.toString()),
                  trailing: IconButton(
                      onPressed: () async {
                        // ignore: unused_local_variable
                        String? chosenDate = await utils.selectDate(
                            context,
                            appointmentsModel,
                            appointmentsModel.entityBeingEdited.apptDate
                                .toString());
                        appointmentsModel.entityBeingEdited.apptDate =
                            chosenDate;
                      },
                      icon: const Icon(Icons.edit_outlined)),
                ),
                //Время встречи
                ListTile(
                  leading: const Icon(Icons.alarm_outlined),
                  title: const Text('Time'),
                  subtitle: Text('${appointmentsModel.apptTime}'),
                  trailing: IconButton(
                    onPressed: () => selectTime,
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: initialTime);
  }

  void _save(BuildContext context, AppointmentsModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (appointmentsModel.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Appointment saved'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }
}
