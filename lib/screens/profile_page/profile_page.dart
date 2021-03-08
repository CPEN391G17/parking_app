import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/coin_page/coin_page.dart';
import 'package:parking_app/screens/profile_page/edit_profile.dart';
import 'package:parking_app/widgets/progress.dart';
import 'package:parking_app/models/parking_user.dart';
import 'package:parking_app/models/coin.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  String uid;
  bool forceReload = false;
  ParkingUser user;

  var _isInit = true;
  var _isLoading0 = false;
  var _isLoading1 = false;

  String defaultUrl;

  @override
  initState() {
    getDefaultUrl();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading0 = true;
        _isLoading1 = true;
      });
      _firebaseProvider.getAndSetCurrentUser().then((currUser) {
        setState(() {
          user = currUser;
          _isLoading0 = false;
        });
      });
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading0 && _isLoading1 ? circularProgress()
          : FutureBuilder(
        future: Future.wait([_firebaseProvider.parkingUsers.doc(user.uid).get(),
            _firebaseProvider.parkingUsers.doc(user.uid).collection('Coins').doc('parKoin').get()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if(!snapshot.hasData) {
            return circularProgress();
          }
          ParkingUser parkingUser = ParkingUser.fromDocument(snapshot.data[0]);
          Coin coin = Coin.fromDocument(snapshot.data[1]);
          return Stack(
            children: <Widget>[
              Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  AppBar(
                    elevation: 0,
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios),
                    ),
                    backgroundColor: Colors.blue,
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                              editProfile(context, parkingUser);
                            }
                          ),
                    ],
                    iconTheme: IconThemeData(
                      color: Colors.black,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(20),
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: parkingUser.photoUrl == null
                                  ? NetworkImage(defaultUrl)
                                  : NetworkImage(parkingUser.photoUrl),
                              fit: BoxFit.fill
                          ),
                        ),
                      ),
                      Container(
                        child: Text(parkingUser.displayName,
                          style: TextStyle(
                              fontSize: 30
                          ),
                        ),
                      ),
                      Container(
                        child: Text("LPN: " + parkingUser.lpn,
                          style: TextStyle(
                              fontSize: 20
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height / 14,),
                      Container(
                        child: Text("Balance = " + coin.amount.toString() + " coins",
                          style: TextStyle(
                              fontSize: 20
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height / 8,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 1.5,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () {
                              addCoin(context, coin.amount);
                            },
                            child: Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.2,
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 9,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.account_balance_wallet),
                                  Text(
                                      'Add coins', textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }

    ),
    );
  }

  Future<void> getDefaultUrl() async {
    defaultUrl = await _firebaseProvider.getUrl();
  }

  void editProfile(context, parkingUser) async {
    final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) =>
            EditProfileScreen(
              name: parkingUser.displayName,
              photoUrl: parkingUser.photoUrl,
              email: parkingUser.email,
              lpn: parkingUser.lpn,
              phone: parkingUser.phone,
            )));
    if (result) {
      setState(() {});
    }
  }

  void addCoin(context, amount) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddCoinPage(amount: amount,)));
    if(result) {
      setState(() {});
    }
  }

}


