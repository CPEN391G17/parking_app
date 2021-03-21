import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: camel_case_types
class BT_key{
  String key;
  DateTime initial_access_time; //When was the key accessed from the Android app?

  BT_key({this.key, this.initial_access_time});

  factory BT_key.fromDocument(DocumentSnapshot doc) {
    return BT_key(
      key: doc.get('key'),
      initial_access_time: doc.get('initial_access_time'),
    );
  }

  Map<String, dynamic> toMap(BT_key user) {
    return {
      'key': user.key,
      'initial_access_time': user.initial_access_time,
    };
  }

  BT_key.fromMap(Map<String, dynamic> mapData) {
    key = mapData['key'];
    initial_access_time = mapData['initial_access_time'];
  }
}