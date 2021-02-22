import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddView extends StatefulWidget {
  AddView({Key key}) : super(key: key);

  @override
  _AddViewState createState() => _AddViewState();
}

class _AddViewState extends State<AddView>{
  @override
  Widget build(BuildContext context){
    return Material(
      child: Text("Add View"),
    );
  }
}