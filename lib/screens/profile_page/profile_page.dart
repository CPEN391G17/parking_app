import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/coin_page/coin_page.dart';
import 'package:parking_app/screens/profile_page/edit_profile.dart';
import 'package:parking_app/widgets/progress.dart';
import 'package:parking_app/models/parking_user.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  ParkingUser parkingUser;
  String uid;

  var _isInit = true;
  var _isLoading = false;
  var _height;
  bool forceReload = false;

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setProfileData(context);
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  void setProfileData(BuildContext context) {
    setState(() {
      _isLoading = true;
      _height = MediaQuery.of(context).size.height;
      _firebaseProvider
          .getAndSetCurrentUser(forceRetrieve: true)
          .then((currUser) => setState(() {
        parkingUser = currUser;
        _isLoading = false;
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ?
      circularProgress()
      : Stack(
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
                                child: Text(parkingUser.displayName,//user.displayName,
                                  style: TextStyle(
                                      fontSize: 18
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Text("LPN: " + parkingUser.lpn,
                                  style: TextStyle(
                                      fontSize: 14
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text("Balance = " + "5" + " coins",
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
                                      image: AssetImage("assets/images/profilepic.jpg"),
                                      fit: BoxFit.fill
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => EditProfileScreen()));
                                  },
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


