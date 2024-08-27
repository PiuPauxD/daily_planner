import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contactsDBWorker.dart';
import 'package:flutter_book/contacts/contactsModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_book/utils.dart' as utils;

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactModel,
      child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext context, Widget? child, ContactsModel model) {
        return Scaffold(
          body: ListView.builder(
              itemCount: contactModel.entityList.length,
              itemBuilder: (BuildContext buildContext, int index) {
                Contact contact = contactModel.entityList[index];
                File avatarFile =
                    File(utils.docsDir.path + contact.id.toString());
                bool avatarFileExists = avatarFile.existsSync();
                return Column(
                  children: [
                    Slidable(
                      startActionPane:
                          ActionPane(motion: const ScrollMotion(), children: [
                        SlidableAction(
                            borderRadius: BorderRadius.circular(20),
                            label: 'delete',
                            backgroundColor: Colors.redAccent,
                            icon: Icons.delete_outline,
                            onPressed: (BuildContext context) {
                              deleteContact(context, contact);
                            })
                      ]),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage:
                              avatarFileExists ? FileImage(avatarFile) : null,
                          child: avatarFileExists
                              ? null
                              : Text(
                                  contact.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(contact.name),
                        subtitle:
                            // ignore: unnecessary_null_comparison
                            contact.phone == null ? null : Text(contact.phone),
                        onTap: () async {
                          File avatarFile = File("${utils.docsDir.path}avatar");
                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }
                          contactModel.entityBeingEdited =
                              await ContactsDBWorker.db.get(contact.id!);
                          if (contactModel.entityBeingEdited.birthday == null) {
                            contactModel.setChosenDate('');
                          } else {
                            contactModel.setChosenDate(contact.birthday!);
                          }
                          contactModel.setStackIndex(1);
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                );
              }),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              File avatarFile = File("${utils.docsDir.path}avatar");
              if (avatarFile.existsSync()) {
                avatarFile.deleteSync();
              }
              contactModel.entityBeingEdited = Contact();
              contactModel.setChosenDate('');
              contactModel.setStackIndex(1);
            },
          ),
        );
      }),
    );
  }

  Future deleteContact(BuildContext context, Contact contact) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text('Delete contact'),
            content: Text('Are you sure you want to delete ${contact.name}?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(alertContext).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      File avatarFile =
                          File(utils.docsDir.path + contact.id!.toString());
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      await ContactsDBWorker.db.delete(contact.id!);
                      Navigator.of(alertContext).pop();

                      contactModel.loadData("contacts", ContactsDBWorker.db);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
