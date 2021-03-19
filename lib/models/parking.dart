import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Parking {

  String pid;
  String ppid;
  String qrValue;
  double lat;
  double lng;
  int count;

  Parking({
    @required this.pid,
    @required this.ppid,
    @required this.count,
    @required this.lat,
    @required this.lng,
    @required this.qrValue,
  });

  factory Parking.fromDocument(DocumentSnapshot doc) {
    return Parking(
      pid: doc.get('pid'),
      ppid: doc.get('ppid'),
      count: doc.get('count'),
      qrValue: doc.get('qrValue'),
      lat: doc.get('lat'),
      lng: doc.get('lng'),
    );
  }

  Map<String, dynamic> toMap(Parking parking) {
    return {
      'pid': parking.pid,
      'ppid': parking.ppid,
      'count': parking.count,
      'qrValue': parking.qrValue,
      'lat': parking.lat,
      'lng': parking.lng,
    };
  }

  Parking.fromMap(Map<String, dynamic> mapData) {
    pid = mapData['pid'];
    ppid = mapData['ppid'];
    count = mapData['count'];
    qrValue = mapData['qrValue'];
    lat = mapData['lat'];
    lng = mapData['lng'];
  }
}