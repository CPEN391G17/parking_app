import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Coin {
  String id;
  String amount;

  Coin({
    @required this.id,
    @required this.amount,
  });

  factory Coin.fromDocument(DocumentSnapshot doc) {
    return Coin(
      amount: doc.get('amount'),
    );
  }

  Map<String, dynamic> toMap(Coin coin) {
    return {
      'amount': coin.amount,
    };
  }

  Coin.fromMap(Map<String, dynamic> mapData) {
    amount = mapData['amount'];
  }
}