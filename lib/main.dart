import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/screens/home_page/home_page.dart';
import 'package:parking_app/screens/login_page/login_page.dart';
import 'package:parking_app/screens/login_page/register_page.dart';
import 'package:parking_app/screens/login_page/root/root.dart';
import 'package:parking_app/screens/onboarding/onboarding.dart';
import 'package:parking_app/screens/profile_page/edit_profile.dart';
import 'package:parking_app/screens/profile_page/profile_page.dart';
import 'package:parking_app/screens/qrscanner_page/qrscanner_page.dart';
import 'package:parking_app/screens/timer_page/timer_page.dart';
import 'package:provider/provider.dart';

import 'DataHandler/appData.dart';

///*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ParKing',
        home: RootPage(),
      ),
    );
  }
}
//*/

