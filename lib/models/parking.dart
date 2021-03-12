import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Parking {

  String pid;
  String ppid;
  String parkingPhotoUrl;
  String qrValue;
  String lat;
  String lng;
  String openTime;
  String closeTime;
  bool status;

  Parking({
    @required this.pid,
    @required this.ppid,
    @required this.parkingPhotoUrl,
    @required this.status,
    @required this.lat,
    @required this.lng,
    @required this.openTime,
    @required this.closeTime,
    @required this.qrValue,
  });

  factory Parking.fromDocument(DocumentSnapshot doc) {
    return Parking(
      pid: doc.get('pid'),
      ppid: doc.get('ppid'),
      parkingPhotoUrl: doc.get('parkingPhotoUrl'),
      status: doc.get('status'),
      qrValue: doc.get('qrValue'),
      lat: doc.get('lat'),
      lng: doc.get('lng'),
      openTime: doc.get('openTime'),
      closeTime: doc.get('closeTime'),
    );
  }

  Map<String, dynamic> toMap(Parking parking) {
    return {
      'pid': parking.pid,
      'ppid': parking.ppid,
      'parkingPhotoUrl': parking.parkingPhotoUrl,
      'status': parking.status,
      'qrValue': parking.qrValue,
      'lat': parking.lat,
      'lng': parking.lng,
      'openTime': parking.openTime,
      'closeTime': parking.closeTime,
    };
  }

  Parking.fromMap(Map<String, dynamic> mapData) {
    pid = mapData['pid'];
    ppid = mapData['ppid'];
    parkingPhotoUrl = mapData['parkingPhotoUrl'];
    status = mapData['status'];
    qrValue = mapData['qrValue'];
    lat = mapData['lat'];
    lng = mapData['lng'];
    openTime = mapData['openTime'];
    closeTime = mapData['closeTime'];
  }
}