import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/models/slider_model.dart';
import 'package:parking_app/screens/home_page/home_page.dart';
import 'package:parking_app/screens/onboarding/slider_tile.dart';

class Onboarding extends StatefulWidget {
  @override
  _Onboarding createState() => _Onboarding();
}

class _Onboarding extends State<Onboarding>{

  List<SliderModel> slides = new List<SliderModel>();
  int currentIndex = 0;
  PageController pageController = new PageController();

  @override
  void initState() {
    super.initState();
    slides = getSlides();
  }

  Widget pageIndexIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.grey : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: pageController,
        itemCount: slides.length,
        onPageChanged: (val) {
          setState(() {
            currentIndex = val;
          });
        },
        itemBuilder: (context, index) {
          return SliderTile(
            imageAssetPath: slides[index].imagePath,
            title: slides[index].title,
            description: slides[index].description,
          );
        },
      ),
      bottomSheet: currentIndex != slides.length - 1 ? Container(
        height: Platform.isIOS ? 70 : 60,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: (){
                pageController.animateToPage(
                    slides.length - 1,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.linear
                );
              },
              child: Text("Skip"),
            ),
            Row(
              children: <Widget>[
                for(int i = 0; i < slides.length; i++) currentIndex == i ? pageIndexIndicator(true) : pageIndexIndicator(false),
              ],
            ),
            GestureDetector(
              onTap: (){
                pageController.animateToPage(
                    currentIndex + 1,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.linear
                );
              },
              child: Text("Next"),
            ),
          ],
        ),
      ): Container(
        width: MediaQuery.of(context).size.width,
        height: Platform.isIOS ? 70 : 60,
        color: Colors.blue,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()));
          },
          child: Text(
            "Get started now!",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}