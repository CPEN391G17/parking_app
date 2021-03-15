import 'package:flutter/cupertino.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/home_page/home_page.dart';
import 'package:parking_app/screens/mainscreen/mainscreen.dart';
import '../login_page.dart';

class RootPage extends StatefulWidget {
  static const String idScreen = "root_page";

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {

  FirebaseProvider _firebaseProvider = FirebaseProvider();

  AuthStatus _authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    _firebaseProvider.currentUser().then((userId) {
      setState(() {
        _authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(_authStatus) {
      case AuthStatus.notSignedIn:
        return LoginPage();
      case AuthStatus.signedIn:
        return MainScreen();
        //return HomePage(); commented for testing purposes
    }
  }
}