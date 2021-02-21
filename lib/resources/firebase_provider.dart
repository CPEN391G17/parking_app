// import 'dart:async';
// import 'dart:io';
//
// import 'package:apple_sign_in/apple_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../models/meetup.dart';
// import '../models/message.dart';
// import '../models/user.dart' as appuser;
// import 'package:google_sign_in/google_sign_in.dart';
//
// /*This class defines the provider that manages most of the app's backend, from
// * user auth to managing friends and messages, to updating profiles, to managing
// * meet-ups */
// class FirebaseProvider with ChangeNotifier {
//   // FirebaseProvider({firebaseinitialize()});
//   // void firebaseinitialize() async {
//   //   await Firebase.initializeApp();
//   // }
//
//   FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
//   final usersRef = FirebaseFirestore.instance.collection('users');
//   final friendsRef = FirebaseFirestore.instance.collection('friends');
//   final activityFeedRef = FirebaseFirestore.instance.collection('feed');
//   final timelineRef = FirebaseFirestore.instance.collection('Timeline');
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   appuser.User user;
//   Message _message;
//   final DateTime timestamp = DateTime.now();
//
//   //SharedPreferences ptrToMem;
//
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   StorageReference _storageReference;
//
//   FirebaseFirestore get fireStore {
//     return _fireStore;
//   }
//
//   Future<dynamic> get appleSignInAvailable => AppleSignIn.isAvailable();
//
//   Future<void> addDataToDb(User currentUser) async {
//     print("Inside addDataToDb Method");
//     user = appuser.User(
//       uid: currentUser.uid,
//       email: currentUser.email,
//       displayName: "",
//       photoUrl: "https://firebasestorage.googleapis.com/v0/b/foodbuddy-93b55.appspot.com/o/1601108084438?alt=media&token=74c80b0a-c050-4b85-897f-7e8fab4e81d7",
//       friends: '0',
//       phone: '',
//       bio: "Hey! I'm new to this app! Let's Dyne!",
//       meetups: '0',
//       points: 0,
//       lastTime: Timestamp.now(),
//       referralUid: "",
//       university: "",
//       year: "",
//       faculty: "",
//     );
//     await _fireStore
//         .collection("users")
//         .doc(currentUser.uid)
//         .set(user.toMap(user));
//   }
//
//   Future<bool> authenticateUser(User user) async {
//     print("Inside authenticateUser");
//     return await _fireStore
//         .collection("users")
//         .where("email", isEqualTo: user.email)
//         .get()
//         .then((result) => result.docs.length == 0);
//   }
//
//   configurePushNotifications() async {
//     User user = _auth.currentUser;
//     if (Platform.isIOS) getiOSPermission();
//
//     _firebaseMessaging.getToken().then((token) {
//       usersRef.doc(user.uid).update({"androidNotificationToken": token});
//     });
//
//     _firebaseMessaging.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         final String recipientId = message['data']['recipient'];
//         final String body = message['notification']['body'];
//         if (recipientId == user.uid) {
//           SnackBar snackbar = SnackBar(
//               content: Text(
//                 body,
//                 overflow: TextOverflow.ellipsis,
//               ));
//           _scaffoldKey.currentState.showSnackBar(snackbar);
//         }
//       },
//     );
//   }
//
//   Future<void> getiOSPermission() async {
//     _firebaseMessaging.requestNotificationPermissions(
//         IosNotificationSettings(alert: true, badge: true, sound: true));
//     _firebaseMessaging.onIosSettingsRegistered.listen((settings) {});
//   }
//
//   Future<User> getCurrentUser() async {
//     return _auth.currentUser;
//   }
//
//   Future<appuser.User> getAndSetCurrentUser(
//       {bool forceRetrieve = false}) async {
//     if (user == null || forceRetrieve) {
//       User authUser = _auth.currentUser;
//       print("EMAIL ID : ${authUser.email}");
//       return await _fireStore.collection('users').doc(authUser.uid).get().then(
//             (_documentSnapshot) {
//           appuser.User currUser =
//           appuser.User.fromMap(_documentSnapshot.data());
//           print("user pulled from server");
//           user = currUser;
//           return currUser;
//         },
//       );
//     } else {
//       print('user already loaded');
//       return user;
//     }
//   }
//
//   Future<void> signOut() async {
//     await _googleSignIn.disconnect().whenComplete(() async {
//       await _googleSignIn.signOut();
//       return await _auth.signOut();
//     });
//   }
//
//   Future<User> signIn() async {
//     return await _googleSignIn.signIn().then((_signInAccount) {
//       return _signInAccount.authentication.then((_signInAuthentication) {
//         final AuthCredential credential = GoogleAuthProvider.credential(
//           accessToken: _signInAuthentication.accessToken,
//           idToken: _signInAuthentication.idToken,
//         );
//         return _auth
//             .signInWithCredential(credential)
//             .then((value) => value.user);
//       });
//     });
//   }
//
//   Future<User> signInWithApple() async {
//     // 1. perform the sign-in request
//     final result = await AppleSignIn.performRequests([
//       AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
//     ]);
//     // 2. check the result
//     switch (result.status) {
//       case AuthorizationStatus.authorized:
//         final AppleIdCredential appleIdCredential = result.credential;
//         final OAuthProvider oAuthProvider = new OAuthProvider("apple.com");
//         final AuthCredential credential = oAuthProvider.credential(
//           idToken: String.fromCharCodes(appleIdCredential.identityToken),
//           accessToken:
//           String.fromCharCodes(appleIdCredential.authorizationCode),
//         );
//         final authResult = await _auth.signInWithCredential(credential);
//         final firebaseUser = authResult.user;
//         if (appleIdCredential.fullName != null) {
//           await _auth.currentUser.updateProfile(
//               displayName:
//               "${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}");
//         }
//         return firebaseUser;
//
//       case AuthorizationStatus.error:
//         print(result.error.toString());
//         throw PlatformException(
//           code: 'ERROR_AUTHORIZATION_DENIED',
//           message: result.error.toString(),
//         );
//
//       case AuthorizationStatus.cancelled:
//         throw PlatformException(
//           code: 'ERROR_ABORTED_BY_USER',
//           message: 'Sign in aborted by user',
//         );
//     }
//     return null;
//   }
//
//   Future<String> uploadImageToStorage(File imageFile) async {
//     _storageReference = FirebaseStorage.instance
//         .ref()
//         .child('${DateTime.now().millisecondsSinceEpoch}');
//     StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
//     var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
//     return url;
//   }
//
//   Future<appuser.User> retrieveUserDetails(User user) async {
//     DocumentSnapshot _documentSnapshot =
//     await _fireStore.collection("users").doc(user.uid).get();
//     return appuser.User.fromMap(_documentSnapshot.data());
//   }
//
//   Future<appuser.User> fetchUserDetailsById(String uid) async {
//     return await _fireStore.collection("users").doc(uid).get().then(
//           (documentSnapshot) {
//         return appuser.User.fromMap(documentSnapshot.data());
//       },
//     );
//   }
//
//   Future<String> fetchUidBySearchedName(String name) async {
//     //TODO: Since friends is not a param of the user, but instead an adjacent collection, this method retrieves the wrong location and causes document errors
//     List<DocumentSnapshot> uidList = List<DocumentSnapshot>();
//     return await _fireStore.collection("users").get().then(
//           (querySnapshot) {
//         for (var i = 0; i < querySnapshot.docs.length; i++) {
//           uidList.add(querySnapshot.docs[i]);
//         }
//         print("UID LIST : ${uidList.length}");
//         for (var i = 0; i < uidList.length; i++) {
//           if (uidList[i].data()['displayName'] == name) {
//             return uidList[i].id;
//           }
//         }
// //        print("UID DOC ID: ${uid}");
//         return '';
//       },
//     );
//   }
//
//   Future<void> friendUser(
//       {String currentUserId,
//         String friendUserId,
//         String currentUserImg,
//         String currentUserName}) async {
//     var friendMap = Map<String, String>();
//     friendMap['uid'] = friendUserId;
//
//     activityFeedRef
//         .doc(friendUserId)
//         .collection('feedItems')
//         .doc(currentUserId)
//         .set({
//       "type": "friend",
//       "hostId": friendUserId,
//       "displayName": currentUserName,
//       "userId": currentUserId,
//       "userProfileImg": currentUserImg,
//       "timestamp": timestamp,
//     });
//
//     await friendsRef
//         .doc(friendUserId)
//         .collection('userFriends')
//         .doc(currentUserId)
//         .set({});
//
//     await friendsRef
//         .doc(currentUserId)
//         .collection('userFriends')
//         .doc(friendUserId)
//         .set({});
//
//     await _fireStore
//         .collection("users")
//         .doc(currentUserId)
//         .collection("friends")
//         .doc(friendUserId)
//         .set(friendMap);
//
//     var friendsMap = Map<String, String>();
//     friendsMap['uid'] = currentUserId;
//
//     return _fireStore
//         .collection("users")
//         .doc(friendUserId)
//         .collection("friends")
//         .doc(currentUserId)
//         .set(friendMap);
//   }
//
//   Future<void> unFriendUser(
//       {String currentUserId,
//         String friendUserId,
//         String currentUserImg,
//         String currentUserName}) async {
//     activityFeedRef
//         .doc(friendUserId)
//         .collection('feedItems')
//         .doc(currentUserId)
//         .get()
//         .then((doc) {
//       if (doc.exists) {
//         doc.reference.delete();
//       }
//     });
//
//     await friendsRef
//         .doc(friendUserId)
//         .collection('userFriends')
//         .doc(currentUserId)
//         .get()
//         .then((doc) {
//       if (doc.exists) {
//         doc.reference.delete();
//       }
//     });
//
//     await friendsRef
//         .doc(currentUserId)
//         .collection('userFriends')
//         .doc(friendUserId)
//         .get()
//         .then((doc) {
//       if (doc.exists) {
//         doc.reference.delete();
//       }
//     });
//
//     await _fireStore
//         .collection("users")
//         .doc(currentUserId)
//         .collection("friends")
//         .doc(friendUserId)
//         .delete();
//
//     return _fireStore
//         .collection("users")
//         .doc(friendUserId)
//         .collection("friends")
//         .doc(currentUserId)
//         .delete();
//   }
//
//   Future<bool> checkIsFriend(String name, String currentUserId) async {
//     bool isFriend = false;
//     String uid = await fetchUidBySearchedName(name);
//     QuerySnapshot querySnapshot = await _fireStore
//         .collection("users")
//         .doc(currentUserId)
//         .collection("friends")
//         .get();
//
//     for (var i = 0; i < querySnapshot.docs.length; i++) {
//       if (querySnapshot.docs[i].id == uid) {
//         isFriend = true;
//       }
//     }
//     return isFriend;
//   }
//
//   Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) async {
//     return await _fireStore
//         .collection("users")
//         .doc(uid)
//         .collection(label)
//         .get()
//         .then((querySnapshot) {
// //      _updateLocalUser(uid, label, querySnapshot.documents);
//       return querySnapshot.docs;
//     });
//   }
//
// //   Future<DocumentSnapshot> fetchPoints({String uid}) async {
// //     return await _fireStore
// //         .collection("users")
// //         .document(uid)
// //         .get()
// //         .then((querySnapshot) {
// // //      _updateLocalUser(uid, label, querySnapshot.documents);
// //       return querySnapshot.data["points"];
// //     });
// //   }
//
//   Future<List<DocumentSnapshot>> fetchMeetups(
//       {String uid, String label}) async {
//     return await _fireStore
//         .collection("timeline")
//         .doc(uid)
//         .collection(label)
//         .get()
//         .then((querySnapshot) {
// //      _updateLocalUser(uid, label, querySnapshot.documents);
//       return querySnapshot.docs;
//     });
//   }
//
// //  void _updateLocalUser(String uid, String label, dynamic documents) {
// //    if (uid == user?.uid) {
// //      Map<String, dynamic> currUser = user.toMap(user);
// //      currUser[label] = documents;
// //      user = User.fromMap(currUser);
// ////      ptrToMem.setString('userData', user.toMap(user).toString());
// //    }
// //  }
// //
// //  void _updateLocalUserList(
// //      String uid, List<String> labels, List<String> documents) {
// //    if (uid == user?.uid) {
// //      Map<String, dynamic> currUser = user.toMap(user);
// //      labels.asMap().forEach((index, label) {
// //        currUser[label] = documents[index];
// //      });
// //      user = User.fromMap(currUser);
// ////      ptrToMem.setString('userData', user.toMap(user).toString());
// //    }
// //  }
//
//   Future<void> updatePhoto(String photoUrl, String uid) async {
//     Map<String, dynamic> map = Map();
//     map['photoUrl'] = photoUrl;
// //    _updateLocalUser(uid, 'photoUrl', photoUrl);
//     return await _fireStore.collection("users").doc(uid).update(map);
//   }
//
//   Future<void> updateDetails(
//       String uid, String name, String bio, String email, String phone, String faculty, String year, String university) async {
//     Map<String, dynamic> map = Map();
//     map['displayName'] = name;
//     map['bio'] = bio;
//     map['email'] = email;
//     map['phone'] = phone;
//     map['university'] = university;
//     map['year'] = year;
//     map['faculty'] = faculty;
// //    _updateLocalUserList(uid, ['displayName', 'bio', 'email', 'phone'],
// //        [name, bio, email, phone]);
//     return await _fireStore.collection("users").doc(uid).update(map);
//   }
//
//   Future<void> updateReferral(String uid, String referralUid) async {
//     Map<String, dynamic> map = Map();
//     map['referralUid'] = referralUid;
//     return await _fireStore.collection("users").doc(uid).update(map);
//   }
//
//   Future<List<String>> fetchUserNames(User user) async {
//     DocumentReference documentReference =
//     _fireStore.collection("messages").doc(user.uid);
//     List<String> userNameList = List<String>();
//     List<String> chatUsersList = List<String>();
//     return await _fireStore.collection("users").get().then((querySnapshot) {
//       for (var i = 0; i < querySnapshot.docs.length; i++) {
//         if (querySnapshot.docs[i].id != user.uid) {
//           print("USERNAMES : ${querySnapshot.docs[i].id}");
//           userNameList.add(querySnapshot.docs[i].id);
//         }
//       }
//       for (var i = 0; i < userNameList.length; i++) {
//         if (documentReference.collection(userNameList[i]) != null) {
//           if (documentReference.collection(userNameList[i]).get() != null) {
//             print("CHAT USERS : ${userNameList[i]}");
//             chatUsersList.add(userNameList[i]);
//           }
//         }
//       }
//       print("CHAT USERS LIST : ${chatUsersList.length}");
//       return chatUsersList;
//     });
//   }
//
//   Future<List<appuser.User>> fetchAllUsers(User user) async {
//     return _fetchAllUsersHelper(uid: user.uid);
//   }
//
//   Future<List<appuser.User>> fetchAllUsersWithUser(appuser.User user) async {
//     return _fetchAllUsersHelper(uid: user.uid);
//   }
//
//   Future<List<appuser.User>> fetchAllUsersInFriends(
//       List<String> friendUids) async {
//     return _fetchAllUsersHelper(friendUids: friendUids);
//   }
//
//   Future<List<appuser.User>> _fetchAllUsersHelper(
//       {String uid, List<String> friendUids}) async {
//     return await _fireStore.collection("users").get().then((querySnapshot) {
//       List<appuser.User> userList = List<appuser.User>();
//       for (var i = 0; i < querySnapshot.docs.length; i++) {
//         if (uid != null) {
//           if (querySnapshot.docs[i].id != uid) {
//             userList.add(appuser.User.fromMap(querySnapshot.docs[i].data()));
//           }
//         } else if (friendUids != null) {
//           if (friendUids.contains(querySnapshot.docs[i].id)) {
//             userList.add(appuser.User.fromMap(querySnapshot.docs[i].data()));
//           }
//         } else {
//           print('missing the optional parameter');
//         }
//       }
//       print("USERSLIST : ${userList.length}");
//       return userList;
//     });
//   }
//
//   Future<List<String>> fetchAllUserNames(User user) async {
//     return await _fireStore.collection("users").get().then((querySnapshot) {
//       List<String> userNameList = List<String>();
//       for (var i = 0; i < querySnapshot.docs.length; i++) {
//         if (querySnapshot.docs[i].id != user.uid) {
//           userNameList.add(querySnapshot.docs[i].data()['displayName']);
//         }
//       }
//       print("USERNAMES LIST : ${userNameList.length}");
//       return userNameList;
//     });
//   }
//
//   Future<void> uploadImageMsgToDb(
//       String url, String receiverUid, String senderuid, String senderName) async {
//     _message = Message.withoutMessage(
//         receiverUid: receiverUid,
//         senderUid: senderuid,
//         senderName: senderName,
//         photoUrl: url,
//         timestamp: FieldValue.serverTimestamp(),
//         type: 'image');
//     var map = Map<String, dynamic>();
//     map['senderUid'] = _message.senderUid;
//     map['senderName'] = _message.senderName;
//     map['receiverUid'] = _message.receiverUid;
//     map['type'] = _message.type;
//     map['timestamp'] = _message.timestamp;
//     map['photoUrl'] = _message.photoUrl;
//
//     print("Map : ${map}");
//     await _fireStore
//         .collection("messages")
//         .doc(_message.senderUid)
//         .collection(receiverUid)
//         .add(map)
//         .then((_) {
//       print("Messages added to db");
//     }).catchError((onError) => print('error adding message to db'));
//
//     await _fireStore
//         .collection("messages")
//         .doc(receiverUid)
//         .collection(_message.senderUid)
//         .add(map)
//         .then((_) {
//       print("Messages added to db");
//     }).catchError((onError) => print('error adding message to db'));
//   }
//
//   Future<void> addMessageToDb(Message message, String receiverUid) async {
//     print("Message : ${message.message}");
//     var map = message.toMap();
//     print("Map : $map");
//     await _fireStore
//         .collection("messages")
//         .doc(message.senderUid)
//         .collection(receiverUid)
//         .add(map);
//     await _fireStore
//         .collection("messages")
//         .doc(receiverUid)
//         .collection(message.senderUid)
//         .add(map);
//   }
//
//   Future<int> fetchNumMeetUpToday(appuser.User user) async {
//     int count = 0;
//     DateTime now = DateTime.now();
//     return await FirebaseFirestore.instance
//         .collection('timeline')
//         .doc(user.uid)
//         .collection('timelineMeetups')
//         .orderBy('timeOfCreation', descending: true)
//         .get()
//         .then((snapshot) {
//       snapshot.docs.forEach((doc) {
//         MeetUp meetUp = MeetUp.fromDocument(doc);
//         if (meetUp.timeOfCreation.add(Duration(days: 1)).isAfter(now)) {
//           count++;
//         }
//       });
//       return count;
//     });
//   }
//
//   Future<List<String>> fetchFriendsUids(User user) async {
//     return _fetchFriendsUidsHelper(user.uid);
//   }
//
//   Future<List<String>> fetchFriendsUidsWithUser(appuser.User user) async {
//     return _fetchFriendsUidsHelper(user.uid);
//   }
//
//   Future<List<String>> _fetchFriendsUidsHelper(String uid) async {
//     return await _fireStore
//         .collection("users")
//         .doc(uid)
//         .collection("friends")
//         .get()
//         .then((querySnapshot) {
//       List<String> friendsUIDs = List<String>();
//       for (var i = 0; i < querySnapshot.docs.length; i++) {
//         friendsUIDs.add(querySnapshot.docs[i].id);
//       }
//       // for (var i = 0; i < friendsUIDs.length; i++) {
// //        print("DDDD : ${friendsUIDs[i]}");
// //       }
//       return friendsUIDs;
//     });
//   }
// }
