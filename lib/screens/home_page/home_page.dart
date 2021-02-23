import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../coin_page/coin_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  Position currentPosition;

  static LatLng _initialPosition;
  
  static final CameraPosition _kGooglePlex = CameraPosition(target: LatLng(49.246292, -123.116226), zoom: 14);



  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    locatePosition();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _initialPosition == null ? Container(
        child: Center(
          child:Text(
            'loading map..',
            style: TextStyle(
                fontFamily: 'Avenir-Medium',
                color: Colors.grey[400]),
            ),
          ),
        )
          :Stack(
        children: <Widget>[
          GoogleMap(
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
          ),
        ],
      ),
    );
  }
}