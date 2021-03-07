import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/login_page/login_page.dart';
import 'package:parking_app/screens/onboarding/onboarding.dart';
import 'package:parking_app/widgets/text_formatter.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  FirebaseProvider _firebaseProvider = FirebaseProvider();

  //controller to capture input of user
  TextEditingController _nameField = TextEditingController();
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passwordField = TextEditingController();
  TextEditingController _lpnField = TextEditingController();
  TextEditingController _phoneField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width, //fill entire width of screen
          height: MediaQuery.of(context).size.height, //fill entire height of screen
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: SingleChildScrollView(
            child:Column( //place everything positioned vertically
                    children: <Widget>[
                      SizedBox(height: 25.0,),
                      Image(
                        image: AssetImage("assets/images/logo.png"),
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          controller: _nameField,
                          decoration: InputDecoration(
                            hintText: "John Doe",
                            hintStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w300,
                            ),
                            labelText: "Name",
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
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          controller: _passwordField,
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
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: TextFormField(
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                          style: TextStyle(color: Colors.white),
                          controller: _lpnField,
                          decoration: InputDecoration(
                            hintText: "XXXXXX",
                            hintStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w300,
                            ),
                            labelText: "Licence Plate Number",
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
                          inputFormatters: [
                            MaskedInputFormater('##########')
                          ],
                          style: TextStyle(color: Colors.white),
                          controller: _phoneField,
                          decoration: InputDecoration(
                            hintText: "7783259322",
                            hintStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w300,
                            ),
                            labelText: "Phone Number",
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
                              if(_nameField.text.length < 2) {
                                Fluttertoast.showToast(msg: "Name must be at least 2 characters");
                              }
                              else if(!_emailField.text.contains("@")) {
                                Fluttertoast.showToast(msg: "Invalid email");
                              }
                              else if(_lpnField.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Please enter Licence plate number");
                              }
                              else if(_passwordField.text.length < 6) {
                                Fluttertoast.showToast(msg: "Password must be at least 6 characters");
                              }
                              else if(_phoneField.text.length < 10) {
                                Fluttertoast.showToast(msg: "Invalid phone number");
                              }
                              else {
                                bool auth = await _firebaseProvider.register(_nameField.text,
                                    _emailField.text,
                                    _passwordField.text,
                                    _lpnField.text,
                                    _phoneField.text,
                                );
                                if(auth) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Onboarding()));
                                }
                              }
                            },
                          child: Text("Create Account"),
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                          child: Text(
                            "Already have an Account? Login here!",
                            style: TextStyle(
                                color: Colors.black
                            ),
                          )
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
