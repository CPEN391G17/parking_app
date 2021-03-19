import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ParkingRequest {
  String prid;
  String uid;
  String pid;
  String ppid;
  DateTime timeOfBooking;
  DateTime timeOfCreation;
  double duration;
  String qrInput;
  String qrEntryValue;
  String progress;

  ParkingRequest({
    @required this.prid,
    @required this.uid,
    @required this.pid,
    @required this.ppid,
    @required this.timeOfBooking,
    @required this.timeOfCreation,
    this.duration,
    @required this.progress,
    this.qrInput,
  });

  factory ParkingRequest.fromDocument(DocumentSnapshot doc) {
    return ParkingRequest(
      prid: doc.get('prid'),
      uid: doc.get('uid'),
      pid: doc.get('pid'),
      ppid: doc.get('ppid'),
      timeOfBooking: DateTime.tryParse(doc.get('timeOfBooking')),
      timeOfCreation: DateTime.tryParse(doc.get('timeOfCreation')),
      duration: doc.get('duration'),
      qrInput: doc.get('qrInput'),
      progress: doc.get('progress'),
    );
  }

  Map<String, dynamic> toMap(ParkingRequest parkingRequest) {
    return {
      'prid': parkingRequest.prid,
      'uid': parkingRequest.uid,
      'pid': parkingRequest.pid,
      'ppid': parkingRequest.ppid,
      'timeOfBooking': parkingRequest.timeOfBooking,
      'timeOfCreation': parkingRequest.timeOfCreation,
      'duration': parkingRequest.duration,
      'qrInput': parkingRequest.qrInput,
      'progress': parkingRequest.progress,
    };
  }

  ParkingRequest.fromMap(Map<String, dynamic> mapData) {
    prid = mapData['prid'];
    uid = mapData['uid'];
    pid = mapData['pid'];
    ppid = mapData['ppid'];
    timeOfBooking = mapData['timeOfBooking'];
    timeOfCreation = mapData['timeOfCreation'];
    duration = mapData['duration'];
    qrInput = mapData['qrInput'];
    progress = mapData['progress'];
  }
}