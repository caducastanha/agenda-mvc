import 'dart:io';

import 'package:agenda/controllers/contact_controller.dart';
import 'package:agenda/models/contact_helper.dart';
import 'package:agenda/views/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum orderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactController controller = ContactController();

  List _contactsList = [];

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  void _getAllContacts() async {
    List list = await controller.getContactList();
    setState(
      () {
        _contactsList = list;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.grey[850],
      floatingActionButton: buildFloatingActionButton(),
      body: buildBody(),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Contatos"),
      backgroundColor: Colors.grey[900],
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton<orderOptions>(
            color: Colors.grey[900],
            onSelected: _orderList,
            itemBuilder: (context) => <PopupMenuEntry<orderOptions>>[
                  const PopupMenuItem<orderOptions>(
                    child: Text(
                      "Ordenar de A-Z",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    value: orderOptions.orderaz,
                  ),
                  const PopupMenuItem<orderOptions>(
                    child: Text(
                      "Ordenar de Z-A",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    value: orderOptions.orderza,
                  )
                ])
      ],
    );
  }

  Widget buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showContactPage();
      },
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget buildBody() {
    return buildContactsList();
  }

  Widget buildContactsList() {
    return ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _contactsList.length,
        itemBuilder: buildContact);
  }

  Widget buildContact(context, index) {
    return GestureDetector(
      onTap: () {
        _showContactOptions(context, index);
      },
      child: Card(
        color: Colors.grey[850],
        margin: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: _contactsList[index].image != null
                        ? FileImage(File(_contactsList[index].image))
                        : AssetImage("images/person.png"),
                    fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _contactsList[index].name ?? "Sem nome",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _contactsList[index].email ?? "Sem email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _contactsList[index].phone ?? "Sem telefone",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactPage({Contact contact}) async {
    final receivedContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
        ),
      ),
    );
    if (receivedContact != null) {
      if (contact != null) {
        await controller.update(receivedContact);
      } else {
        await controller.create(receivedContact);
      }
      _getAllContacts();
    }
  }

  void _showContactOptions(context, index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildOptionsRow(index);
      },
    );
  }

  Widget _buildOptionsRow(int index) {
    return BottomSheet(
      backgroundColor: Colors.grey[900],
      onClosing: () {}, /////////////////////////
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextButton("Ligar", Icons.call, () {
                Navigator.pop(context);
                launch("tel:${_contactsList[index].phone}");
              }),
              _buildTextButton("Editar", Icons.edit, () {
                Navigator.pop(context);
                _showContactPage(contact: _contactsList[index]);
              }),
              _buildTextButton("Excluir", Icons.delete, () {
                Navigator.pop(context);
                setState(() {
                  controller.delete(_contactsList[index].id);
                  _contactsList.removeAt(index);
                });
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextButton(String label, IconData icon, Function function) {
    return GestureDetector(
      onTap: function,
      child: Container(
        height: 103,
        color: Colors.grey[900],
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            Text(
              " $label",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _orderList(orderOptions result) {
    switch (result) {
      case orderOptions.orderaz:
        _contactsList.sort(
          (a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          },
        );
        break;
      case orderOptions.orderza:
        _contactsList.sort(
          (a, b) {
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          },
        );
        break;
    }
    setState(() {});
  }
}
