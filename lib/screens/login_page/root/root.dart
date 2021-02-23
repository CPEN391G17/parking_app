import 'package:flutter/cupertino.dart';
import 'package:parking_app/resources/repository.dart';
import 'package:parking_app/screens/home_page/home_page.dart';
import '../login_page.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {

  AuthStatus _authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        _authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(_authStatus) {
      case AuthStatus.notSignedIn:
        return LoginPage(auth: widget.auth, onSignedIn: _signedIn,);
      case AuthStatus.signedIn:
        return HomePage(auth: widget.auth, onSignedOut: _signedOut,);
    }
  }
}