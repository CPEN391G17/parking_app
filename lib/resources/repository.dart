// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import '../models/message.dart';
// import '../models/user.dart' as appuser;
// import '../resources/firebase_provider.dart';
//
// /*This is a wrapper class for firebase provider, with descriptive function names*/
// class Repository with ChangeNotifier {
//   final _firebaseProvider = FirebaseProvider();
//
//   FirebaseFirestore firestore() => _firebaseProvider.fireStore;
//
//   Future<bool> appleSignInAvailable() =>
//       _firebaseProvider.appleSignInAvailable;
//
//   appuser.User user() => _firebaseProvider.user;
//
//   Future<void> addDataToDb(User user) => _firebaseProvider.addDataToDb(user);
//
//   Future<User> signIn() => _firebaseProvider.signIn();
//
//   Future<User> signInWithApple() => _firebaseProvider.signInWithApple();
//
//   Future<bool> authenticateUser(User user) =>
//       _firebaseProvider.authenticateUser(user);
//
//   Future<User> getCurrentUser() => _firebaseProvider.getCurrentUser();
//
//   Future<appuser.User> getAndSetCurrentUser({forceRetrieve = false}) =>
//       _firebaseProvider.getAndSetCurrentUser(forceRetrieve: forceRetrieve);
//
//   Future<void> signOut() => _firebaseProvider.signOut();
//
//   Future<void> configurePushNotifications() =>
//       _firebaseProvider.configurePushNotifications();
//
//   Future<String> uploadImageToStorage(File imageFile) =>
//       _firebaseProvider.uploadImageToStorage(imageFile);
//
//   Future<appuser.User> retrieveUserDetails(User user) =>
//       _firebaseProvider.retrieveUserDetails(user);
//
//   Future<List<String>> fetchAllUserNames(User user) =>
//       _firebaseProvider.fetchAllUserNames(user);
//
//   Future<String> fetchUidBySearchedName(String name) =>
//       _firebaseProvider.fetchUidBySearchedName(name);
//
//   Future<appuser.User> fetchUserDetailsById(String uid) =>
//       _firebaseProvider.fetchUserDetailsById(uid);
//
//   Future<void> friendUser(
//       {String currentUserId,
//         String friendUserId,
//         String currentUserImg,
//         String currentUserName}) =>
//       _firebaseProvider.friendUser(
//           currentUserId: currentUserId,
//           friendUserId: friendUserId,
//           currentUserImg: currentUserImg,
//           currentUserName: currentUserName);
//
//   Future<void> unFriendUser(
//       {String currentUserId,
//         String friendUserId,
//         String currentUserImg,
//         String currentUserName}) =>
//       _firebaseProvider.unFriendUser(
//           currentUserId: currentUserId,
//           friendUserId: friendUserId,
//           currentUserImg: currentUserImg,
//           currentUserName: currentUserName);
//
//   Future<bool> checkIsFriend(String name, String currentUserId) =>
//       _firebaseProvider.checkIsFriend(name, currentUserId);
//
//   Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) =>
//       _firebaseProvider.fetchStats(uid: uid, label: label);
//
//   // Future<DocumentSnapshot> fetchPoints({String uid}) =>
//   //     _firebaseProvider.fetchPoints(uid: uid);
//
//   Future<List<DocumentSnapshot>> fetchMeetups({String uid, String label}) =>
//       _firebaseProvider.fetchMeetups(uid: uid, label: label);
//
//   Future<void> updatePhoto(String photoUrl, String uid) =>
//       _firebaseProvider.updatePhoto(photoUrl, uid);
//
//   Future<void> updateDetails(
//       String uid, String name, String bio, String email, String phone, String faculty, String year, String university) =>
//       _firebaseProvider.updateDetails(uid, name, bio, email, phone, faculty, year, university);
//
//   Future<void> updateReferral(
//       String uid, String referralUid) =>
//       _firebaseProvider.updateReferral(uid, referralUid);
//
//   Future<List<String>> fetchUserNames(User user) =>
//       _firebaseProvider.fetchUserNames(user);
//
//   Future<List<appuser.User>> fetchAllUsers(User user) =>
//       _firebaseProvider.fetchAllUsers(user);
//
//   Future<List<appuser.User>> fetchAllUsersWithUser(appuser.User user) =>
//       _firebaseProvider.fetchAllUsersWithUser(user);
//
//   Future<List<appuser.User>> fetchAllUsersInFriends(List<String> friendUids) =>
//       _firebaseProvider.fetchAllUsersInFriends(friendUids);
//
//   void uploadImageMsgToDb(String url, String receiverUid, String senderuid, String senderName) =>
//       _firebaseProvider.uploadImageMsgToDb(url, receiverUid, senderuid, senderName);
//
//   Future<void> addMessageToDb(Message message, String receiverUid) =>
//       _firebaseProvider.addMessageToDb(message, receiverUid);
//
//   Future<int> fetchNumMeetUpToday(appuser.User user) =>
//       _firebaseProvider.fetchNumMeetUpToday(user);
//
// //  Future<List<DocumentSnapshot>> fetchMeetUpAcceptDetails(
// //          DocumentReference reference) =>
// //      _firebaseProvider.fetchMeetUpAcceptDetails(reference);
// //
// //  Future<bool> checkIfUserAcceptedOrNot(
// //          String userId, DocumentReference reference) =>
// //      _firebaseProvider.checkIfUserAcceptedOrNot(userId, reference);
//
// //  Future<List<DocumentSnapshot>> fetchMeetUpFeed(FirebaseUser user) =>
// //      _firebaseProvider.fetchMeetUpFeed(user);
//
//   Future<List<String>> fetchFriendsUids(User user) =>
//       _firebaseProvider.fetchFriendsUids(user);
//
//   Future<List<String>> fetchFriendsUidsWithUser(appuser.User user) =>
//       _firebaseProvider.fetchFriendsUidsWithUser(user);
// }
