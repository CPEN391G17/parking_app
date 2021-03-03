import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/*This class allows the user to edit their photo, display name, bio, email and
* phone #*/
// ignore: must_be_immutable
class EditProfileScreen extends StatefulWidget {
  String photoUrl, email, name, lpr;

  EditProfileScreen(
      {this.photoUrl,
        this.email,
        this.name,
        this.lpr,});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lprController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email;
    _lprController.text = widget.lpr;
  }

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
      super.didChangeDependencies();
    }
  File imageFile;

  Future<File> _pickImage(String action) async {
    PickedFile selectedImage;
    final picker = ImagePicker();
    action == 'Gallery'
        ? selectedImage = await picker.getImage(source: ImageSource.gallery)
        : await picker.getImage(source: ImageSource.camera);

    return File(selectedImage.path);
  }

  void updateProfileData(BuildContext context) {
    setState(() {
      _nameController.text.trim().length < 3 || _nameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actions: <Widget>[
        GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(Icons.done, color: Colors.red[900]),
              ),
              onTap: () => updateProfileData(context),
            )
        ],
      ),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : Container(
          color: Colors.white,
          child: Column(
          children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Container(
            color: Colors.white,
            child: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Update Display Name",
                  labelText: 'Display name',
                  errorText: _displayNameValid ? null : "Display Name too short",
                  labelStyle: GoogleFonts.josefinSans(
                      textStyle:
                      TextStyle(color: Colors.red[900], fontSize: 25)),
                ),
              ),
              TextField(
                controller: _lprController,
                decoration: InputDecoration(
                  hintText: "Update license plate number",
                  labelText: 'License plate number',
                  errorText: _displayNameValid ? null : "Display Name too short",
                  labelStyle: GoogleFonts.josefinSans(
                      textStyle:
                      TextStyle(color: Colors.red[900], fontSize: 25)),
                ),
              ),
            ],
          ),
          ),
        ),
      ])),
    );
  }
}