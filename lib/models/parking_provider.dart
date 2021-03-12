import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:parking_app/models/parking.dart';

class ParkingProvider {
  String ppid;
  String email;
  String displayName;
  String phone;
  String photoUrl;
  List<Parking> parking;
  String androidNotificationToken;

  ParkingProvider({
    @required this.ppid,
    @required this.email,
    @required this.displayName,
    @required this.parking,
    this.photoUrl,
    this.phone,
    this.androidNotificationToken,
  });

  factory ParkingProvider.fromDocument(DocumentSnapshot doc) {
    return ParkingProvider(
      ppid: doc.get('uid'),
      email: doc.get('email'),
      parking: doc.get('parking'),
      photoUrl: doc.get('photoUrl'),
      displayName: doc.get('displayName'),
      phone: doc.get('phone'),
    );
  }

  Map<String, dynamic> toMap(ParkingProvider provider) {
    return {
      'ppid': provider.ppid,
      'email': provider.email,
      'parking': provider.parking,
      'photoUrl': provider.photoUrl,
      'displayName': provider.displayName,
      'phone': provider.phone,
    };
  }

  ParkingProvider.fromMap(Map<String, dynamic> mapData) {
    ppid = mapData['ppid'];
    email = mapData['email'];
    parking = mapData['parking'];
    photoUrl = mapData['photoUrl'];
    displayName = mapData['displayName'];
    phone = mapData['phone'];
    androidNotificationToken = mapData['androidNotificationToken'];
  }
}