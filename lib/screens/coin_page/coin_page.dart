import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_app/models/coin.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/utilities/constants.dart';

class AddCoinPage extends StatefulWidget {
  double amount;
  AddCoinPage({this.amount});

  @override
  _AddCoinPageState createState() => _AddCoinPageState();
}

class _AddCoinPageState extends State<AddCoinPage>{

  String id = 'parKoin';
  TextEditingController _amountController = TextEditingController();
  FirebaseProvider _firebaseProvider = FirebaseProvider();

  Widget _buildCoinTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              hintText: 'Enter Amount',
              hintStyle: kHintTextStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:Icon(Icons.arrow_back_ios, color: Colors.white,),
        ),
        backgroundColor: Color(0xFF73AEF5),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(icon: Icon(Icons.done, color: Colors.white,),
              onPressed: () {Navigator.of(context).pop(true);}
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF73AEF5),
                  Color(0xFF61A4F1),
                  Color(0xFF478DE0),
                  Color(0xFF398AE5),
                ],
                stops: [0.1, 0.4, 0.7, 0.9],
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                    "Previous Balance = " + widget.amount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 20.0,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: _buildCoinTF()
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width / 1.4,
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white
                ),
                child: MaterialButton(
                  onPressed: () async{
                    if(double.parse(_amountController.text) > 0) {
                      await _firebaseProvider.addCoin(id, _amountController.text);
                    }
                    else {
                      Fluttertoast.showToast(msg: "Amount must be greater than 0");
                    }
                  },
                  child: Text(
                    "Add ParKoins",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      letterSpacing: 1.5,
                      fontSize: 20.0,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
      ],
      ),
    );
  }
}