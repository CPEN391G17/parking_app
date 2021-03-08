import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/*This abstract class defines the user type, and manages some JSON to User
* conversions and visa versa*/

class ParkingUser {
  String uid;
  String email;
  String displayName;
  String phone;
  String photoUrl;
  String lpn;
  GeoPoint lastLocation;
  Timestamp lastTime;
  String androidNotificationToken;

  ParkingUser({
    @required this.uid,
    @required this.email,
    @required this.displayName,
    @required this.lpn,
    this.photoUrl,
    this.lastLocation,
    this.lastTime,
    this.phone,
    this.androidNotificationToken,
  });

  factory ParkingUser.fromDocument(DocumentSnapshot doc) {
    return ParkingUser(
      uid: doc.get('uid'),
      email: doc.get('email'),
      lpn: doc.get('lpn'),
      photoUrl: doc.get('photoUrl'),
      displayName: doc.get('displayName'),
      lastLocation: doc.get('lastLocation'),
      lastTime: doc.get('lastTime'),
      phone: doc.get('phone'),
    );
  }

  Map<String, dynamic> toMap(ParkingUser user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'lpn': user.lpn,
      'photoUrl': user.photoUrl,
      'displayName': user.displayName,
      'lastLocation': user.lastLocation,
      'lastTime': user.lastTime,
      'phone': user.phone,
    };
  }

  ParkingUser.fromMap(Map<String, dynamic> mapData) {
    uid = mapData['uid'];
    email = mapData['email'];
    lpn = mapData['lpn'];
    photoUrl = mapData['photoUrl'];
    displayName = mapData['displayName'];
    lastTime = mapData['lastTime'];
    lastLocation = mapData['lastLocation'];
    phone = mapData['phone'];
    androidNotificationToken = mapData['androidNotificationToken'];
  }
}
