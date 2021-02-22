import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/resources/repository.dart';
import 'package:parking_app/screens/home_page/home_page.dart';

//authentication
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controller to capture input of user
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passwordField =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Container(
         width: MediaQuery.of(context).size.width, //fill entire width of screen
         height: MediaQuery.of(context).size.height, //fill entire height of screen
         decoration: BoxDecoration(
           color: Colors.blueAccent,
         ),
         child: Column( //place everything positioned vertically
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width / 1.3,
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: _emailField,
                decoration: InputDecoration(
                  hintText: "something@email.com",
                  hintStyle: TextStyle(
                    color: Colors.white,
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
                    color: Colors.white,
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
              width: MediaQuery.of(context).size.width / 1.4, //give me a width based on size of device
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white
              ),
              child: MaterialButton(
                onPressed: () async {
                  bool shouldNavigate = await register(_emailField.text, _passwordField.text);
                  if(shouldNavigate){
                    //Navigate
                    Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );

                  }
                  },
                child: Text("Register"),
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
                  bool shouldNavigate = await signIn(_emailField.text, _passwordField.text);
                  if(shouldNavigate){
                    //Navigate
                    Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  }
                },
                child: Text("Login"),
              ),
            ),
           ],
          ),
       ),
    );
  }
}