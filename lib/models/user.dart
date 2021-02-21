// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
//
// /*This abstract class defines the user type, and manages some JSON to User
// * conversions and visa versa*/
//
// class User {
//   String uid;
//   String email;
//   String displayName;
//   String phone;
//   String photoUrl;
//   String bio;
//   GeoPoint lastLocation;
//   Timestamp lastTime;
//   String friends;
//   String meetups;
//   double rating;
//   int points;
//   String referralUid;
//
//   // Interest data type required
//   // added notification token
//   String androidNotificationToken;
//   // added university fields
//   String university;
//   String faculty;
//   String year;
//   // added type of user
//   bool premium;
//
//   User({
//     @required this.uid,
//     @required this.email,
//     this.photoUrl,
//     @required this.displayName,
//     this.bio,
//     this.lastLocation,
//     this.lastTime,
//     this.friends,
//     this.phone,
//     this.meetups,
//     this.points = 0,
//     this.rating = 5.0,
//     this.referralUid = "",
//
//     // added fields
//     // this.androidNotificationToken,
//     this.faculty,
//     this.university,
//     this.year,
//     // this.premium,
//   });
//
//   factory User.fromDocument(DocumentSnapshot doc) {
//     return User(
//       uid: doc.get('uid'),
//       email: doc.get('email'),
//       photoUrl: doc.get('photoUrl'),
//       displayName: doc.get('displayName'),
//       bio: doc.get('bio'),
//       lastLocation: doc.get('lastLocation'),
//       lastTime: doc.get('lastTime'),
//       friends: doc.get('friends'),
//       meetups: doc.get('meetups'),
//       phone: doc.get('phone'),
//       points: doc.get('points'),
//       referralUid: doc.get('referralUid'),
//
//       // added fields
//       // androidNotificationToken:
//       university: doc.get('university'),
//       faculty: doc.get('faculty'),
//       year: doc.get('year'),
//       // premium:
//     );
//   }
//
//   Map<String, dynamic> toMap(User user) {
//     return {
//       'uid': user.uid,
//       'email': user.email,
//       'photoUrl': user.photoUrl,
//       'displayName': user.displayName,
//       'bio': user.bio,
//       'lastLocation': user.lastLocation,
//       'lastTime': user.lastTime,
//       'friends': user.friends,
//       'phone': user.phone,
//       'meetups': user.meetups,
//       'points': user.points,
//       'referralUid': user.referralUid,
//
//       // added fields
//       // androidNotificationToken:
//       university: user.university,
//       faculty: user.faculty,
//       year: user.year,
//       // premium:
//     };
//   }
//
//   User.fromMap(Map<String, dynamic> mapData) {
//     uid = mapData['uid'];
//     email = mapData['email'];
//     photoUrl = mapData['photoUrl'];
//     displayName = mapData['displayName'];
//     bio = mapData['bio'];
//     lastTime = mapData['lastTime'];
//     friends = mapData['friends'];
//     lastLocation = mapData['lastLocation'];
//     phone = mapData['phone'];
//     meetups = mapData['meetups'];
//     points = mapData['points'];
//     referralUid = mapData['referralUid'];
//     // added fields
//     // androidNotificationToken = ;
//     university = mapData['university'];
//     faculty = mapData['faculty'];
//     year = mapData['year'];
//     // premium = ;
//   }
// }
