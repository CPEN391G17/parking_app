import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/resources/repository.dart';

class AddCoinPage extends StatefulWidget {
  AddCoinPage({Key key}) : super(key: key);

  @override
  _AddCoinPageState createState() => _AddCoinPageState();
}

class _AddCoinPageState extends State<AddCoinPage>{

  String coin = "ParKoin";

  TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width / 1.3,
            child: TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Coin Amount"
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width / 1.4,
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white
            ),
            child: MaterialButton(
              onPressed: () async{
                await addCoin(coin, _amountController.text);
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ),
        ],
      ),
      ),
    );
  }
}