import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class BookingHistory {
  double duration;
  bool inParking;
  String pid;
  String ppid;
  String prid;
  String progress;
  String qrInput;
  dynamic timeOfBooking;
  String uid;
  String location;

  BookingHistory({
    this.duration,
    this.inParking,
    this.pid,
    this.ppid,
    this.prid,
    this.progress,
    this.qrInput,
    this.timeOfBooking,
    this.uid,
    this.location
  });

  factory BookingHistory.fromDocument(DocumentSnapshot doc) {
    return BookingHistory(
        duration: doc.get('duration'),
        inParking: doc.get('inParking'),
        pid: doc.get('pid'),
        ppid: doc.get('ppid'),
        prid: doc.get('prid'),
        progress: doc.get('progress'),
        qrInput: doc.get('qrInput'),
        timeOfBooking: doc.get('timeOfBooking'),
        uid: doc.get('uid'),
        location: doc.get('location'),
    );
  }

  Map<String, dynamic> toMap(BookingHistory history) {
    return {
      'duration': history.duration,
      'inParking': history.inParking,
      'pid': history.pid,
      'ppid': history.ppid,
      'prid': history.prid,
      'progress': history.progress,
      'qrInput': history.qrInput,
      'timeOfBooking': history.timeOfBooking,
      'uid': history.uid,
      'location': history.location,
    };
  }

  BookingHistory.fromMap(Map<String, dynamic> mapData) {
    duration = mapData['duration'];
    inParking = mapData['inParking'];
    pid = mapData['pid'];
    ppid = mapData['ppid'];
    prid = mapData['prid'];
    progress = mapData['progress'];
    qrInput = mapData['qrInput'];
    timeOfBooking = mapData['timeOfBooking'];
    uid = mapData['uid'];
    location = mapData['location'];
  }

}