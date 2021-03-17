import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_app/models/coin.dart';
import 'package:parking_app/models/parking_request.dart';
import 'package:parking_app/models/parking_user.dart';
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
  final CollectionReference parkingProviders = FirebaseFirestore.instance
      .collection('ParkingProvider');
  final CollectionReference parkingSpaces = FirebaseFirestore.instance
      .collection("ParkingSpace");
  final CollectionReference parkingRequests = FirebaseFirestore.instance
      .collection("ParkingRequest");

  ParkingUser parkingUser;
  ParkingRequest parkingRequest;
  Coin parkoin;

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


    // parking request functions
    Future<bool> createParkingRequest(String prid, String uid, String pid, String ppid,
        String parkingPhotoUrl, DateTime timeOfBooking, DateTime timeOfCreation, double duration, bool status /*, double cost*/) async {
      // prid = 'r_${args.restaurantId}h_${_repo.user().uid}d_${day.replaceAll('/', '')}t_$time${new Random().nextInt(100)}'
      try {
        parkingRequest = ParkingRequest(
            prid: prid,
            uid: uid,
            pid: pid,
            ppid: ppid,
            parkingPhotoUrl: parkingPhotoUrl,
            timeOfBooking: timeOfBooking,
            timeOfCreation: timeOfCreation,
            duration: duration,
            status: status);

        await parkingRequests.doc(uid).collection('parking').doc(prid).set(
            parkingRequest.toMap(parkingRequest));
        // var amount = -cost * duration;
        // addCoin(uid, amount.toString());
      } on Exception catch(e){
        Fluttertoast.showToast(msg: e.toString());
        return false;
      }
      return true;
    }

    Future deleteParkingRequest(String uid, String prid) async {
      parkingRequests.doc(uid).collection('parking').doc(prid).get().then((doc) {
        if(doc.exists) {
          doc.reference.delete();
        }
      });
    }





}