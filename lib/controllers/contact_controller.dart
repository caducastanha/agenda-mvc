import 'dart:developer';

import 'package:agenda/models/contact_helper.dart';

class ContactController {
  ContactHelper helper = ContactHelper();

  Future<Contact> create(Contact contact) async {
    return await helper.saveContact(contact);
  }

  Future<List<Contact>> getContactList() async {
    return await this.helper.getAllContacts();
  }

  Future<int> update(Contact contact) async {
    return await helper.updateContact(contact);
  }

  Future<int> delete(int id) async {
    return await helper.deleteContact(id);
  }
}
