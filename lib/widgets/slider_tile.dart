import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SliderTile extends StatelessWidget {
  String imageAssetPath, title, description;
  SliderTile({this.imageAssetPath, this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imageAssetPath),
          SizedBox(height: 20,),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12,),
          Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
          ),
        ],
      ),
    );
  }
}