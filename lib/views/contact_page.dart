import 'dart:io';

import 'package:agenda/models/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _userEdited = false;

  Contact _editedContact;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: buildAppBar(),
        backgroundColor: Colors.grey[850],
        floatingActionButton: buildFloatingActionButton(),
        body: buildBody(),
      ),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[900],
      title: Text(
        _editedContact.name ?? "Novo contato",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
    );
  }

  Widget buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
          Navigator.pop(context, _editedContact);
        } else {
          FocusScope.of(context).requestFocus(_nameFocus);
        }
      },
      child: Icon(
        Icons.save,
        color: Colors.white,
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          buildAvatar(),
          buildTextField("Nome", _editedContact.setName, _nameController,
              focusNode: _nameFocus),
          buildTextField("Email", _editedContact.setEmail, _emailController,
              textInputType: TextInputType.emailAddress),
          buildTextField("Telefone", _editedContact.setPhone, _phoneController,
              textInputType: TextInputType.phone),
          TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered))
                      return Colors.blue.withOpacity(0.04);
                    if (states.contains(MaterialState.focused) ||
                        states.contains(MaterialState.pressed))
                      return Colors.blue.withOpacity(0.12);
                    return null; // Defer to the widget's default.
                  },
                ),
              ),
              onPressed: () {},
              child: Text('Adicionar outro telefone'))
        ],
      ),
    );
  }

  Widget buildAvatar() {
    return GestureDetector(
      onTap: () {
        _showImageOptions();
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: _editedContact.image != null
                  ? FileImage(File(_editedContact.image))
                  : AssetImage("images/person.png"),
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, Function function, TextEditingController _controller,
      {TextInputType textInputType, FocusNode focusNode}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: TextField(
        controller: _controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        onChanged: (text) {
          _userEdited = true;
          setState(
            () {
              function(text);
            },
          );
        },
        keyboardType: textInputType,
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              "Descartar alterações?",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: Text(
              "Se sair as alterações serão perdidas",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Permanecer",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  "Sair assim mesmo",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildOptionsRow();
      },
    );
  }

  Widget _buildOptionsRow() {
    return BottomSheet(
      backgroundColor: Colors.grey[900],
      onClosing: () {}, /////////////////////////
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextButton("Câmera", Icons.camera_alt, ImageSource.camera),
              _buildTextButton("Galeria", Icons.camera, ImageSource.gallery),
              _buildTextButton("Excluir", Icons.delete, null)
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextButton(String label, IconData icon, ImageSource imageEntry) {
    return GestureDetector(
      onTap: () {
        if (imageEntry != null) {
          ImagePicker imagePicker = ImagePicker();
          imagePicker.getImage(source: imageEntry).then((file) {
            if (file == null) {
              return;
            } else {
              setState(() {
                _userEdited = true;
                _editedContact.image = file.path;
              });
            }
          });
        } else {
          setState(() {
            _editedContact.image = null;
            _userEdited = true;
          });
        }
        Navigator.pop(context);
      },
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
}
