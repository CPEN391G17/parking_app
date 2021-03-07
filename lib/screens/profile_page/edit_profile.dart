import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_app/models/parking_user.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

/*This class allows the user to edit their photo, display name, bio, email and
* phone #*/
// ignore: must_be_immutable
class EditProfileScreen extends StatefulWidget {
  String photoUrl, email, name, lpn, phone;

  EditProfileScreen(
      {this.photoUrl,
        this.email,
        this.name,
        this.lpn,
        this.phone,
      });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  FirebaseProvider _firebaseProvider = FirebaseProvider();

  ParkingUser parkingUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lpnController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _displayNameValid = true;
  bool _emailValid = true;
  bool _lpnValid = true;
  bool _phoneValid = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email;
    _lpnController.text = widget.lpn;
    _phoneController.text = widget.phone;
  }

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
      super.didChangeDependencies();
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        _firebaseProvider.getAndSetCurrentUser().then((currUser) {
          setState(() {
            _nameController.text.trim().length < 2 || _nameController.text.isEmpty
                ? _displayNameValid = false
                : _displayNameValid = true;
            parkingUser = currUser;
            _isLoading = false;
          });
        });
        _isInit = false;
        super.didChangeDependencies();
      }
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

      !_emailController.text.trim().contains("@") || _emailController.text.isEmpty
          ? _emailValid = false
          : _emailValid = true;

      _phoneController.text.trim().length < 10 || _phoneController.text.isEmpty
        ? _phoneValid = false
        : _phoneValid = true;

      _lpnController.text.isEmpty
      ? _lpnValid = false
      : _lpnValid = true;
    });
    bool valid = _displayNameValid && _emailValid && _phoneValid && _lpnValid;
    if(valid) {
      _firebaseProvider.updateDetails(
          parkingUser.uid,
          _nameController.text,
          _emailController.text,
          _lpnController.text,
          _phoneController.text).then((value) {
         widget.name = _nameController.text;
         widget.email = _emailController.text;
         widget.phone = _phoneController.text;
         widget.lpn = _lpnController.text;
         _firebaseProvider.getAndSetCurrentUser().then((currUser) {
           parkingUser = currUser;
           _showPopUpDialog(context, "Are Your Changes Finalized?",
               "This will save all changes");
         });
      });
    }
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
                child: Icon(Icons.done, color: Colors.blue),
              ),
              onTap: () => updateProfileData(context),
            )
        ],
      ),
      body: // _isLoading
          //? Center(child: circularProgress())
      Container(
          color: Colors.white,
          child: ListView(children: <Widget>[
            Column(
              children: <Widget>[
                editImage(),
              ],
            ),
            Column(
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
                    labelText: 'Display name',
                    errorText: _displayNameValid ? null : "Display Name too short",
                    errorStyle: TextStyle(
                      color: Colors.red,
                    ),
                    labelStyle: GoogleFonts.josefinSans(
                        textStyle:
                        TextStyle(color: Colors.blue, fontSize: 20)),
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.josefinSans(
                        textStyle:
                        TextStyle(color: Colors.blue, fontSize: 20)),
                  ),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    labelStyle: GoogleFonts.josefinSans(
                        textStyle:
                        TextStyle(color: Colors.blue, fontSize: 20)),
                  ),
                ),
                TextField(
                  controller: _lpnController,
                  decoration: InputDecoration(
                    labelText: 'License plate number',
                    labelStyle: GoogleFonts.josefinSans(
                        textStyle:
                        TextStyle(color: Colors.blue, fontSize: 20)),
                  ),
                ),
              ],
            ),
            ),
          ),
          ],
          ),
        ],
        ),
      ),
    );
  }

  void _showPopUpDialog(BuildContext context, String title, String body,
      {isComplex = true}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            new FlatButton(
              child: new Text(isComplex ? "Yes" : "Ok"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
            ),
            isComplex
                ? new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
                : null,
          ],
        );
      },
    );
  }


  Widget editImage() {
    return Center(
      child: Stack(
        children: <Widget>[
          GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(80.0),
                      image: new DecorationImage(
                          image: widget.photoUrl == null
                              ? AssetImage('assets/images/profilepic.png')
                              : NetworkImage(widget.photoUrl),
                          fit: BoxFit.cover),
                    )),
              ),
              onTap: _showImageDialog),
          Positioned(
            bottom: 0.0,
            right: 10.0,
            child: InkWell(
              onTap: _showImageDialog,
              child: Icon(
                Icons.camera_alt,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showImageDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Choose from Gallery',
                    style: GoogleFonts.josefinSans(textStyle: TextStyle())),
                onPressed: () {
                  _pickImage('Gallery').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _firebaseProvider.uploadImageToStorage(imageFile).then((url) {
                      widget.photoUrl = url;
                      _firebaseProvider.updatePhoto(url, parkingUser.uid).then((v) {
                        _firebaseProvider
                            .getAndSetCurrentUser(forceRetrieve: true)
                            .then((currUser) {
                          parkingUser = currUser;
                        });

//                        Navigator.pop(context);
                      });
                    });
                    _showPopUpDialog(context, "Image updated from Gallery",
                        "Changes may take a minute to show...",
                        isComplex: false);
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Take Photo',
                    style: GoogleFonts.josefinSans(textStyle: TextStyle())),
                onPressed: () {
                  _pickImage('Camera').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _firebaseProvider.uploadImageToStorage(imageFile).then((url) {
                      _firebaseProvider.updatePhoto(url, parkingUser.uid).then((v) {
                        _firebaseProvider
                            .getAndSetCurrentUser(forceRetrieve: true)
                            .then((currUser) {
                          parkingUser = currUser;
                        });
//                        Navigator.pop(context);
                      });
                    });
                    _showPopUpDialog(context, "Image updated from Camera",
                        "Changes may take a minute to show...",
                        isComplex: false);
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel',
                    style: GoogleFonts.josefinSans(textStyle: TextStyle())),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

  void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.copyResize(image, width: 25, height: 25);
    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = newim2;
    });
    print('done');
  }

}