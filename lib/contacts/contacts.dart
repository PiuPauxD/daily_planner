import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contactsDBWorker.dart';
import 'package:flutter_book/contacts/contactsList.dart';
import 'package:flutter_book/contacts/contactsModel.dart';
import 'package:flutter_book/contacts/contctsEntry.dart';
import 'package:scoped_model/scoped_model.dart';

class Contacts extends StatelessWidget {
  Contacts({super.key}) {
    contactModel.loadData('contacts', ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactModel,
      child: ScopedModelDescendant(
          builder: (BuildContext context, Widget? child, ContactsModel model) {
        return IndexedStack(
          index: model.stackIndex,
          children: [
            const ContactsList(),
            ContactEntry(),
          ],
        );
      }),
    );
  }
}
