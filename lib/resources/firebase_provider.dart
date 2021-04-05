import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parking_app/models/coin.dart';
import 'package:parking_app/models/bt_key.dart';
import 'package:parking_app/models/parking_user.dart';
import 'package:parking_app/models/parking.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseProvider {

  // firebase authentication
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // firestore instance
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // storage instance
  firebase_storage.Reference _storageReference;

  // firebase collections
  final CollectionReference parkingUsers = FirebaseFirestore.instance
      .collection('ParkingUsers');
  final CollectionReference parkingProvider = FirebaseFirestore.instance
      .collection('ParkingProvider');
  final CollectionReference parkingSpace = FirebaseFirestore.instance
      .collection("ParkingSpace");
  final CollectionReference parkingRequest = FirebaseFirestore.instance
      .collection("ParkingRequest");
  final CollectionReference bluetoothTest = FirebaseFirestore.instance
      .collection("BluetoothTest");


  ParkingUser parkingUser;
  Parking parking;
  Coin parkoin;
  BT_key bluetooth_key;

  //time
  final DateTime timestamp = DateTime.now();

  // global key
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseFirestore get fireStore {
    return firebaseFirestore;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      if (e.toString() ==
          '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.') {
        Fluttertoast.showToast(msg: "Please create an account");
      }
      else if (e.toString() ==
          '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.') {
        Fluttertoast.showToast(msg: "Incorrect email/password");
      }
      else {
        Fluttertoast.showToast(msg: e.toString());
      }
      return false;
    }
  }

  Future<bool> register(String name, String email, String password,
      String lpn, String phone) async {
    try {
      final User user = (await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).catchError((onError) {
        Fluttertoast.showToast(msg: "Error" + onError.toString());
      })).user;
      if (user != null) {
        parkingUser = ParkingUser(
          uid: user.uid,
          email: email,
          displayName: name,
          lpn: lpn,
          phone: phone,
          photoUrl: await getUrl(),
          lastTime: Timestamp.now(),
        );

        await parkingUsers
            .doc(user.uid)
            .set(parkingUser.toMap(parkingUser));

        addCoin('parKoin', '0');
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to create user");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email');
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<String> currentUser() async {
    User user = firebaseAuth.currentUser;
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    User user = firebaseAuth.currentUser;
    if (user != null) {
      return firebaseAuth.signOut();
    }
    return;
  }

  // ignore: missing_return
  Future<bool> addCoin(String id, String amount) async {
    try {
      String uid = firebaseAuth.currentUser.uid;
      var value = double.parse(amount);
      DocumentReference documentReference = parkingUsers
          .doc(uid)
          .collection('Coins')
          .doc(id);
      firebaseFirestore.runTransaction((transaction) async {
        DocumentSnapshot documentSnapshot = await transaction.get(
            documentReference);
        if (!documentSnapshot.exists) {
          documentReference.set({'amount': value});
          return true;
        }
        double newAmount = documentSnapshot.data()['amount'] + value;
        transaction.update(documentReference, {'amount': newAmount});
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    _storageReference = firebase_storage.FirebaseStorage.instance
        .ref().child("${DateTime
        .now()
        .millisecondsSinceEpoch}");
    await _storageReference.putFile(imageFile);
    return await _storageReference.getDownloadURL();
  }

  Future<String> getUrl() async {
    _storageReference = firebase_storage.FirebaseStorage.instance
        .ref().child("profilepic.jpg");
    String url = (await _storageReference.getDownloadURL()).toString();
    return url;
  }

  Future<ParkingUser> retrieveParkingUserDetails(ParkingUser user) async {
    DocumentSnapshot _documentSnapshot =
    await parkingUsers.doc(user.uid).get();
    return ParkingUser.fromMap(_documentSnapshot.data());
  }

  Future<ParkingUser> fetchParkingUserDetailsById(String uid) async {
    return await parkingUsers.doc(uid).get().then(
          (documentSnapshot) {
        return ParkingUser.fromMap(documentSnapshot.data());
      },
    );
  }

  Future<void> updatePhoto(String photoUrl, String uid) async {
    Map<String, dynamic> map = Map();
    map['photoUrl'] = photoUrl;
    return await parkingUsers.doc(uid).update(map);
  }

  Future<void> updateDetails(String uid, String name, String email, String lpn,
      String phone) async {
    Map<String, dynamic> map = Map();
    map['displayName'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['lpn'] = lpn;
    return await parkingUsers.doc(uid).update(map);
  }

  Future<ParkingUser> getAndSetCurrentUser(
      {bool forceRetrieve = false}) async {
    if (parkingUser == null || forceRetrieve) {
      User authUser = firebaseAuth.currentUser;
      print("EMAIL ID : ${authUser.email}");
      return await parkingUsers.doc(authUser.uid).get().then(
            (_documentSnapshot) {
          ParkingUser currUser =
          ParkingUser.fromMap(_documentSnapshot.data());
          print("user pulled from server");
          parkingUser = currUser;
          return currUser;
        },
      );
    } else {
      print('user already loaded');
      return parkingUser;
    }
  }

  Future<Coin> getAndSetCurrentBalance(
      {bool forceRetrieve = false}) async {
      User authUser = firebaseAuth.currentUser;
      return await parkingUsers.doc(authUser.uid).collection('Coins').doc('parKoin').get().then(
            (_documentSnapshot) {
          Coin coin =
          Coin.fromMap(_documentSnapshot.data());
          print("user pulled from server");
          parkoin = coin;
          return coin;
          });
    }


  Future<BT_key> SetKey(String key_str) async {
    User authUser = firebaseAuth.currentUser;
    await bluetoothTest.doc(authUser.uid).collection('Key').doc('userIdentify').update({
      "initial_access_time": 0,
      "key": key_str,
    });
    print("user updates the key");
    BT_key bt_key = BT_key();
    bt_key.initial_access_time = 0 as DateTime;
    bt_key.key = key_str;
    return bt_key;
  }

  Future<DateTime> SetKeyTime() async {
    User authUser = firebaseAuth.currentUser;
    await bluetoothTest.doc(authUser.uid).collection('Key').doc('userIdentify').update({
      "initial_access_time": timestamp,
    });
    print("user updates the key initial_access_time");
    DateTime time = timestamp;
    return time;
  }

  Future<BT_key> GetKey() async {
    User authUser = firebaseAuth.currentUser;
    var future_key = await bluetoothTest.doc(authUser.uid).collection('Key').doc('userIdentify').get().then(
            (_documentSnapshot) {
          BT_key key =
          BT_key.fromMap(_documentSnapshot.data());
          print("user get the BT_key from the server");
          bluetooth_key = key;
          return key;
        });
    SetKeyTime();
    return future_key;
  }

  Future<String> getUID() async {
    User authUser = firebaseAuth.currentUser;
    DocumentSnapshot _documentSnapshot =
    await parkingUsers.doc(authUser.uid).get();
    return ParkingUser.fromMap(_documentSnapshot.data()).uid;
  }

  Future<String> getPID() async {
    User authUser = firebaseAuth.currentUser;
    DocumentSnapshot _documentSnapshot =
    await parkingSpace.doc(
        //authUser.pid
        authUser.uid // This is not correct
    ).get();
    return Parking.fromMap(_documentSnapshot.data()).pid;
  }


}