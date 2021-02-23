import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<bool> signIn(String email, String password);
  Future<bool> register(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
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
    User user = _firebaseAuth.currentUser;
    return user.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

}

// ignore: missing_return
Future<bool> addCoin(String id, String amount) async {
  try{
    String uid = FirebaseAuth.instance.currentUser.uid;
    var value = double.parse(amount);
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Coins')
        .doc(id);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot documentSnapshot = await transaction.get(documentReference);
      if(!documentSnapshot.exists) {
        documentReference.set({'Amount': value});
        return true;
      }
      double newAmount = documentSnapshot.data()['Amount'] + value;
      transaction.update(documentReference, {'Amount': newAmount});
      return true;
    });
  } catch (e) {
    return false;
  }
}
