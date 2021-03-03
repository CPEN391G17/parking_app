import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/resources/repository.dart';
import 'package:parking_app/screens/coin_page/coin_page.dart';
import 'package:parking_app/screens/profile_page/profile_page.dart';
import 'package:parking_app/screens/qrscanner_page/qrscanner_page.dart';
import 'package:parking_app/screens/timer_page/timer_page.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut});

  BaseAuth auth;
  VoidCallback onSignedOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  Position currentPosition;
  LatLng _initialPosition;

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

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
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentLocation();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldState,
      body: Stack(
        children: <Widget>[
          map(),
          myLocationButton(),
          // qrButton(),
          // timerButton(),
        ],
      ),
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.lightBlue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[
                  Colors.blue,
                  Colors.lightBlueAccent,
                ])
              ),
            child: Container(
              child: Column(
                children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    elevation: 10,
                    child: Padding(padding: EdgeInsets.all(8.0),
                      child: Image.asset('assets/images/logo.png', width: 80, height: 80,),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Username", style: TextStyle(color: Colors.white, fontSize: 20.0)),
                  )
                ],
              ),
            ),
            ),
            CustomListTile(Icons.person, "Profile", ()=>{Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(auth: widget.auth, onSignedOut: widget.onSignedOut)),
            )}),
            CustomListTile(Icons.account_balance_wallet, "Wallet", ()=>{Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCoinPage()),
            )}),
            CustomListTile(Icons.qr_code_scanner, "QR Scanner", ()=>{Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRPage()),
            )}),
            CustomListTile(Icons.history, "Booking History", ()=>{}),
            CustomListTile(Icons.help, "Help", ()=>{}),
            CustomListTile(Icons.settings, "Settings", ()=>{}),
            CustomListTile(Icons.logout, "Log Out", ()=>{}),
          ],
        ),
      ),

    );
  }

   map() {
     return GoogleMap(
        myLocationEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        initialCameraPosition: CameraPosition(
          target: _initialPosition?? LatLng(49.2827, -123.1207),
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controllerGoogleMap.complete(controller);
        },
      );
  }

  myLocationButton() {
    return Positioned(
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
    );
  }

  qrButton() {
    return Positioned(
      left: 20,
      top: 30,
      child: Material(
        shape: CircleBorder(),
        elevation: 10,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 20,
          child: IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRPage()),
            ),
            color: Colors.black,
          ),
        ),
      ),
    );
  }


  //
  timerButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Material(
        shape: CircleBorder(),
        elevation: 10,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 20,
          child: IconButton(
            icon: Icon(Icons.timer),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimerPage()),
            ),
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  profileButton() {
    return Positioned(
      right: 20,
      top: 30,
      child: Material(
        shape: CircleBorder(),
        elevation: 10,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 20,
          child: IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(auth: widget.auth, onSignedOut: widget.onSignedOut)),
            ),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget{


  IconData icon;
  String text;
  Function onTap;

  CustomListTile(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400))
        ),
        child: InkWell(
          splashColor: Colors.lightBlueAccent,
          onTap: onTap,
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: <Widget>[
                    Icon(icon),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(text, style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}