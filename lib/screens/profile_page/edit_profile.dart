import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_app/models/parking_user.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/utilities/constants.dart';
import 'package:parking_app/widgets/progress.dart';
import 'package:parking_app/widgets/text_formatter.dart';
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

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Name',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: kHintTextStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: kHintTextStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLpnTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'License plate number',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: TextFormField(
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
            controller: _lpnController,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              hintText: 'Enter your LPN',
              hintStyle: kHintTextStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.directions_car,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Phone',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: TextFormField(
            inputFormatters: [
              MaskedInputFormatter("##########"),
            ],
            controller: _phoneController,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
              hintStyle: kHintTextStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? circularProgress()
    : Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Color(0xFF73AEF5),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actions: <Widget>[
        GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(Icons.done, color: Colors.black, size: 25),
              ),
              onTap: () => updateProfileData(context),
            )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
          height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF73AEF5),
                  Color(0xFF61A4F1),
                  Color(0xFF478DE0),
                  Color(0xFF398AE5),
                ],
                stops: [0.1, 0.4, 0.7, 0.9],
              ),
            ),
          ),
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 10.0,
              ),
              child: Column(children: <Widget>[
                editImage(),
                SizedBox(height: 30.0,),
                _buildNameTF(),
                SizedBox(height: 30.0,),
                _buildEmailTF(),
                SizedBox(height: 30.0,),
                _buildLpnTF(),
                SizedBox(height: 30.0,),
                _buildPhoneTF(),
              ],
              ),
            ),
          ),
        ],
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
            new TextButton(
              child: new Text(isComplex ? "Yes" : "Ok",
                style: TextStyle(fontFamily: 'OpenSans'),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              },
            ),
            isComplex
                ? new TextButton(
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
                      border: Border.all(color: Colors.white, width: 2),
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
                color: Colors.white,
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
                  style: TextStyle(fontFamily: 'OpenSans'),
                ),
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
                    style: TextStyle(fontFamily: 'OpenSans'),
                ),
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
                  style: TextStyle(fontFamily: 'OpenSans'),
                ),
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