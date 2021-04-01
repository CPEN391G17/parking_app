import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/home_page/home_page.dart';
import 'package:parking_app/screens/login_page/register_page.dart';
import 'package:parking_app/screens/mainscreen/mainscreen.dart';

//authentication
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseProvider _firebaseProvider = FirebaseProvider();

  //controller to capture input of user
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passwordField =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: SingleChildScrollView(
          child: Container(
           width: MediaQuery.of(context).size.width, //fill entire width of screen
           height: MediaQuery.of(context).size.height, //fill entire height of screen
           decoration: BoxDecoration(
             color: Colors.lightBlueAccent,
           ),
           child: Column( //place everything positioned vertically
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[
               SizedBox(height: 30.0,),
               Image(
                   image: AssetImage("assets/images/logo.png"),
                   width: 250.0,
                   height: 250.0,
                   alignment: Alignment.center,
               ),
              Container(
                width: MediaQuery.of(context).size.width / 1.3,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _emailField,
                  decoration: InputDecoration(
                    hintText: "something@email.com",
                    hintStyle: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w300,
                    ),
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 35,),
              Container(
                width: MediaQuery.of(context).size.width / 1.3,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _passwordField,
                  obscureText: true, //hide previously typed chars
                  decoration: InputDecoration(
                    hintText: "password",
                    hintStyle: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w300,
                    ),
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 35,),
              Container(
                width: MediaQuery.of(context).size.width / 1.4,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white
                ),
                child: MaterialButton(
                  onPressed: () async{
                    if(!_emailField.text.contains("@")) {
                      Fluttertoast.showToast(msg: "Invalid email");
                    }
                    else if(_passwordField.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Password is mandatory");
                    }
                    else {
                      bool auth = await _firebaseProvider.signIn(_emailField.text, _passwordField.text);
                      if(auth){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen())); //commented out for testing maps
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
                      }
                    }
                  },
                  child: Text("Login"),
                ),
              ),
               SizedBox(height: 10,),
               TextButton(
                   onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                     },
                   child: Text(
                     "Do not have an Account? Register here!",
                     style: TextStyle(
                       color: Colors.black
                     ),
                   )
               ),
             ],
            ),
         ),
       ),
    );
  }
}