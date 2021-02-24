import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/resources/repository.dart';
import 'package:parking_app/screens/coin_page/coin_page.dart';
import 'package:parking_app/screens/home_page/home_page.dart';
import 'package:parking_app/screens/login_page/login_page.dart';

import '../login_page/root/root.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  ProfilePage({this.auth, this.onSignedOut});

  BaseAuth auth;
  VoidCallback onSignedOut;

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
          ),
          AppBar(
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
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await widget.auth.signOut();
                        widget.onSignedOut();
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 15, left: 10),
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
              ),
            ],
            ),
            Column(
              children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                      flex: 2,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      child: Text("UserName",
                                        style: TextStyle(
                                          fontSize: 18
                                        ),
                                      ),
                                    ),
                                ),
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      child: Text("LPN: xxxxxx",
                                        style: TextStyle(
                                            fontSize: 14
                                        ),
                                      ),
                                    ),
                                ),
                                Expanded(
                                    flex: 4,
                                    child: Container(
                                      child: Text("Balance = x Coins",
                                        style: TextStyle(
                                            fontSize: 14
                                        ),
                                      ),
                                    ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                      flex: 7,
                                      child: Container(
                                        margin: EdgeInsets.all(20),
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage('https://googleflutter.com/sample_image.jpg'),
                                              fit: BoxFit.fill
                                          ),
                                        ),
                                      ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      child: GestureDetector(
                                        onTap: (){},
                                        child: Text("Edit Profile",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ),
                        ],
                      ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddCoinPage()));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: MediaQuery.of(context).size.height / 9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.account_balance_wallet),
                              Text('Add coins', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                    ),
                  ),
                  ),
                Expanded(flex: 4,
                    child: Container(),
                )
              ],
            ),
        ],
      ),
    );
  }
}


