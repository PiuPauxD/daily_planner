import 'package:flutter/material.dart';
import 'package:flutter_book/appointmenst/appointmensModel.dart';
import 'package:flutter_book/appointmenst/appointmentsDBWorker.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    EventList<Event> markedDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];

      markedDateMap.add(
        appointment.apptDate as DateTime,
        Event(
          date: appointment.apptDate as DateTime,
          icon: Container(
            decoration: const BoxDecoration(color: Colors.blue),
          ),
        ),
      );
    }
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant(builder:
          (BuildContext context, Widget? child, AppointmentsModel model) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: CalendarCarousel<Event>(
                    thisMonthDayBorderColor: Colors.grey,
                    daysHaveCircularBorder: false,
                    markedDatesMap: markedDateMap,
                    onDayPressed: (DateTime date, List<Event> events) {
                      _showAppointments(date, context);
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: () {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.setApptDate(' ');
                appointmentsModel.setChosenDate(
                    DateFormat.yMMMMd('en_US').format(now.toLocal()));
                appointmentsModel.setApptTime(' ');
                appointmentsModel.setStackIndex(1);
              }),
        );
      }),
    );
  }

  void _showAppointments(DateTime date, BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ScopedModel(
            model: appointmentsModel,
            child: ScopedModelDescendant<AppointmentsModel>(builder:
                (BuildContext context, Widget? child, AppointmentsModel model) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    child: Column(
                      children: [
                        Text(
                          DateFormat.yMMMMd('en_US').format(date.toLocal()),
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 24),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                              itemCount: appointmentsModel.entityList.length,
                              itemBuilder:
                                  (BuildContext buildContext, int index) {
                                Appointment appointment =
                                    appointmentsModel.entityList[index];
                                // ignore: unrelated_type_equality_checks
                                if (appointment.apptDate !=
                                    date.day + date.month + date.year) {
                                  return const SizedBox(
                                    height: 0,
                                  );
                                }
                                TimeOfDay? apptTime;

                                return Slidable(
                                  child: ListTile(
                                    title: Text(appointment.title +
                                        apptTime.toString()),
                                    subtitle: Text(appointment.description),
                                    onTap: () async {
                                      editAppointment(context, appointment);
                                    },
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  void editAppointment(BuildContext context, Appointment appointment) async {
    appointmentsModel.entityBeingEdited =
        await AppointmentsDBWorker.db.get(appointment.id!);

    appointmentsModel.setChosenDate(
        DateFormat.yMMMMd('en_US').format(appointment.apptDate as DateTime));

    appointmentsModel.setApptTime(appointment.apptTime.toString());

    appointmentsModel.setStackIndex(1);
    Navigator.pop(context);
  }
}
