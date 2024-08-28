// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter_book/contacts/contactsDBWorker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/contactsModel.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'contactsModel.dart' show ContactsModel, contactModel;

class ContactEntry extends StatelessWidget {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  ContactEntry({super.key}) {
    _nameEditingController.addListener(() {
      contactModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactModel.entityBeingEdited.email = _emailEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _nameEditingController.text = contactModel.entityBeingEdited != null
        ? contactModel.entityBeingEdited.name
        : '';
    _phoneEditingController.text = contactModel.entityBeingEdited != null
        ? contactModel.entityBeingEdited.phone
        : '';
    _emailEditingController.text = contactModel.entityBeingEdited != null
        ? contactModel.entityBeingEdited.email
        : '';
    return ScopedModel(
        model: contactModel,
        child: ScopedModelDescendant<ContactsModel>(builder:
            (BuildContext context, Widget? child, ContactsModel model) {
          File avatarFile = File(join(utils.docsDir.path, "avatar"));
          // if (avatarFile.existsSync() == false) {
          //   if (model.entityBeingEdited.id! != null &&
          //       model.entityBeingEdited != null) {
          //     avatarFile = File(
          //         utils.docsDir.path + model.entityBeingEdited.id!.toString());
          //   }
          // }

          return Scaffold(
            body: Form(
              key: _formkey,
              //image picker
              child: ListView(
                children: [
                  ListTile(
                    title: avatarFile.existsSync()
                        ? Image.file(avatarFile)
                        : const Text('No avatar image for this contact'),
                    trailing: IconButton(
                      onPressed: () => selectAvatar(context),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                  //name input
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      controller: _nameEditingController,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),

                  //phone input
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Phone'),
                      controller: _phoneEditingController,
                    ),
                  ),
                  //email input
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Email'),
                      controller: _emailEditingController,
                    ),
                  ),
                  //birthday picker
                  ListTile(
                    leading: const Icon(Icons.today_outlined),
                    title: const Text('Birthday'),
                    subtitle: Text(contactModel.chosenDate ?? ''),
                    trailing: IconButton(
                        onPressed: () async {
                          String chosenDate = await utils.selectDate(
                              context,
                              contactModel,
                              contactModel.entityBeingEdited.birthday
                                  .toString());
                          contactModel.entityBeingEdited.birthday = chosenDate;
                        },
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.blue)),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      File avatarFile =
                          File(join(utils.docsDir.path, "avatar"));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      model.setStackIndex(1);
                    },
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _save(context, model);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  void _save(BuildContext context, ContactsModel model) async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    contactModel.entityBeingEdited.id =
        await ContactsDBWorker.db.create(contactModel.entityBeingEdited);

    contactModel.loadData("contacts", ContactsDBWorker.db);
    model.setStackIndex(0);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Contact saved'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
    File avatarFile = File(join(utils.docsDir.path, "avatar"));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(
          utils.docsDir.path + contactModel.entityBeingEdited.id.toString());
    }
  }

  Future selectAvatar(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: const Text('Take a picture'),
                    onTap: () async {
                      XFile? cameraImage = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (cameraImage != null) {
                        cameraImage.saveTo(join(utils.docsDir.path, "avatar"));
                        contactModel.triggerRebuild();
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  GestureDetector(
                    child: const Text('Select from Gallery'),
                    onTap: () async {
                      XFile? galleryImage = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (galleryImage != null) {
                        galleryImage.saveTo(join(utils.docsDir.path, "avatar"));
                        contactModel.triggerRebuild();
                      }
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
