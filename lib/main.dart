import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_book/appointmenst/appointments.dart';
import 'package:flutter_book/contacts/contacts.dart';
import 'package:flutter_book/notes/notes.dart';
import 'package:flutter_book/tasks/tasks.dart';
import 'package:path_provider/path_provider.dart';
import 'utils.dart' as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startMeUp() async {
    //возвращает объект directory
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(const FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {
  const FlutterBook({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("My Book"),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.date_range_outlined),
                  text: "Appointments",
                ),
                Tab(
                  icon: Icon(Icons.contacts_outlined),
                  text: "Contacts",
                ),
                Tab(
                  icon: Icon(Icons.note_outlined),
                  text: "Notes",
                ),
                Tab(
                  icon: Icon(Icons.assignment_outlined),
                  text: "Tasks",
                ),
              ],
            ),
          ),
          body: TabBarView(
              children: [Appointments(), Contacts(), Notes(), Tasks()]),
        ),
      ),
    );
  }
}
