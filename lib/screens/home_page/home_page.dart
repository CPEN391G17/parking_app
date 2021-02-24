import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/resources/repository.dart';
import 'package:parking_app/screens/coin_page/coin_page.dart';
import 'package:parking_app/screens/qrscanner_page/qrscanner_page.dart';
import 'package:parking_app/widgets/side_navigation.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  Position currentPosition;
  static LatLng _initialPosition;

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _currentLocation() async {
    final GoogleMapController controller = await _controllerGoogleMap.future;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.0,
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    locatePosition();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldState,
      drawer: SideNavigationDrawer(
        onTap: ((i) {
          setState(() {
            getDialog(i);
          });
        }),
      ),
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
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
            },
          ),
          Positioned(
            left: 20,
            top: 30,
            child: Material(
              elevation: 10,
              shape: CircleBorder(),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => _scaffoldState.currentState.openDrawer(),
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Material(
              shape: CircleBorder(),
              elevation: 10,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: () => _currentLocation(),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDialog(i) async {
    switch (i) {
      case 1:
        try {
          await widget.auth.signOut();
          widget.onSignedOut();
        } catch (e) {
          print(e);
        }
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCoinPage()),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRPage()),
        );
        break;

  //timer
      case 4:
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => TimerPage()),
      // );
        break;

      case 5:
        break;

      case 6:
        break;

      case 7:
        break;

      default:
    }
  }
}