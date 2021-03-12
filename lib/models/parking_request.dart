import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ParkingRequest {
  String uid;
  String pid;
  String ppid;
  String parkingPhotoUrl;
  DateTime timeOfBooking;
  DateTime timeOfCreation;
  int duration;
  String qrInput;
  String qrEntryValue;
  bool status;

  ParkingRequest({
    @required this.uid,
    @required this.pid,
    @required this.ppid,
    @required this.parkingPhotoUrl,
    @required this.timeOfBooking,
    @required this.timeOfCreation,
    @required this.duration,
    @required this.status,
    this.qrInput,
  });

  factory ParkingRequest.fromDocument(DocumentSnapshot doc) {
    return ParkingRequest(
      uid: doc.get('uid'),
      pid: doc.get('pid'),
      ppid: doc.get('ppid'),
      parkingPhotoUrl: doc.get('parkingPhotoUrl'),
      timeOfBooking: doc.get('timeOfBooking'),
      timeOfCreation: doc.get('timeOfCreation'),
      duration: doc.get('duration'),
      status: doc.get('status'),
      qrInput: doc.get('qrInput'),
    );
  }

  Map<String, dynamic> toMap(ParkingRequest parkingRequest) {
    return {
      'uid': parkingRequest.uid,
      'pid': parkingRequest.pid,
      'ppid': parkingRequest.ppid,
      'parkingPhotoUrl': parkingRequest.parkingPhotoUrl,
      'timeOfBooking': parkingRequest.timeOfBooking,
      'timeOfCreation': parkingRequest.timeOfCreation,
      'duration': parkingRequest.duration,
      'status': parkingRequest.status,
      'qrInput': parkingRequest.qrInput
    };
  }

  ParkingRequest.fromMap(Map<String, dynamic> mapData) {
    uid = mapData['uid'];
    pid = mapData['pid'];
    ppid = mapData['ppid'];
    parkingPhotoUrl = mapData['parkingPhotoUrl'];
    timeOfBooking = mapData['timeOfBooking'];
    timeOfCreation = mapData['timeOfCreation'];
    duration = mapData['duration'];
    status = mapData['status'];
    qrInput = mapData['qrInput'];
  }
}