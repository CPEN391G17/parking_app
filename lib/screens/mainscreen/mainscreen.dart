import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/DataHandler/appData.dart';
import 'package:parking_app/assistant/assistantMethods.dart';
import 'package:parking_app/models/directionDetails.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/booking_history_page/booking_history_page.dart';
import 'package:parking_app/screens/login_page/login_page.dart';
import 'package:parking_app/screens/profile_page/profile_page.dart';
import 'package:parking_app/screens/searchScreen/searhScreen.dart';
import 'package:parking_app/widgets/Divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parking_app/widgets/custom_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:confetti/confetti.dart';

//parking app billing needs to enabled once it has been verified to enable Geocoding
class MainScreen extends StatefulWidget{
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{

  FirebaseProvider _firebaseProvider = FirebaseProvider();

  CountDownController _controller = CountDownController();
  double _timerduration = 3600;
  bool started = false;
  String id = 'parKoin';
  bool startTimer = false;
  double timerCost = 0;

  String uid;
  String pid;
  String userName;

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  DirectionDetails tripdirectiondetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  Position currentPosition;
  double bottomPaddingofMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double searchContainerHeight = 300.0;
  double requestRideContainerHeight = 0;
  double verifyRideContainerHeight = 0.0;
  double timerContainerHeight = 0.0;
  double duration = 1.0;

  bool drawerOpen = true;
  bool createdRequest = false;
  bool isButtonEnabled = false;
  bool startingLpr = false;

  bool myLocationIconVisible = true;

  double refundCost = 0.0;

  String qrCodeResult = "Not Yet Scanned";

  String _mapStyle;

  ConfettiController _controllerCenterRight;
  ConfettiController _controllerCenterLeft;
  // ConfettiController _controllerTopCenter;
  @override
  void initState() {
    super.initState();
    getUid();
    getName();
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 3));
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 3));
    // _controllerTopCenter =
    //     ConfettiController(duration: const Duration(seconds: 10));
  }

  void getUid() async {
    uid = await _firebaseProvider.currentUser();
    print("uid is ::");
    print(uid);
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1).toLowerCase();

  void getName() async {
    userName = await _firebaseProvider.currentUserName();
    print("UserName is ::");
    print(userName);
  }

  void displayTimerContainer() {
    setState(() {
      myLocationIconVisible = false;
      timerContainerHeight = 1000.0;
      verifyRideContainerHeight = 0;
      requestRideContainerHeight = 0.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingofMap = 230.0;
      drawerOpen = true;
      startTimer = true;
      print("...................Sign of the times...................");
      print(_timerduration);
      print( (_timerduration*3600).toInt());
      _controller.restart(duration: (_timerduration*3600).toInt());
      _controllerCenterRight.play();
      _controllerCenterLeft.play();
    });
  }

  void cancelParking(){
    setState(() {
      _controller.pause();
      // String chars  =_controller.getTime();
      //
      // if(_controller.getTime().isNotEmpty) {
      //   double currTime = double.parse("${_controller.getTime()}");
      //   print("curr time :: ");
      //   print(currTime);
      //
      //   double difference = _timerduration - currTime;
      //   refundCost = timerCost - 200 * difference;
      //   if (refundCost > 0) {
      //     _firebaseProvider.addCoin(
      //         id, "$refundCost"); //refund coins if cancelled early
      //   }
      // }
      print(_controller.getTime());
      resetApp();
    });
  }

  _button({String title, VoidCallback onPressed}) {
    return Expanded(
        child: RaisedButton(
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.white,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
            textAlign: TextAlign.center,
          ),
          onPressed: onPressed,//onPressed,

          //color: Colors.blue,
        ));
  }

  verifyLpr() async {
    var loc = Provider.of<AppData>(context, listen: false).endLocation;
    String progress = await _firebaseProvider.getParkingRequestProgress(uid, loc.placeId);
    while(progress == "AwaitingConfirmation") {
      progress = await _firebaseProvider.getParkingRequestProgress(uid, loc.placeId);
    }
    if(progress == 'LprFailed') {
      setState(() {
        startingLpr = false;
        isButtonEnabled = true;
      });
    }
    else if(progress == 'Confirmed') {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => TimerPage()));
      displayTimerContainer();
    }
  }

  reRoute() async {
    var initPos = Provider.of<AppData>(context, listen: false).startLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).endLocation;
    var startLatLng = LatLng(initPos.latitude, initPos.longitude);
    var endLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    while(Geolocator.distanceBetween(
        endLatLng.latitude, endLatLng.longitude,
        startLatLng.latitude, startLatLng.longitude) > 15) {
        print("Reroute called");
        locateRoutePosition();
        await getRoutePlaceDirection();
        initPos = Provider.of<AppData>(context, listen: false).startLocation;
        startLatLng = LatLng(initPos.latitude, initPos.longitude);
    }
    print("exited reroute");
    locateRoutePosition();
    await getRoutePlaceDirection();
    var loc = Provider.of<AppData>(context, listen: false).endLocation;
    _firebaseProvider.updateParkingRequestInParking(uid, loc.placeId, true);
    setState(() {
      startingLpr = true;
    });
    verifyLpr();
    print("reached destination");
  }

  void displayVerifyRequestContainer() {
    setState(() {
      timerContainerHeight = 0.0;
      verifyRideContainerHeight = 300.0;
      requestRideContainerHeight = 0.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingofMap = 230.0;
      drawerOpen = true;
    });
  }

  void displayRequestContainer(){
    setState(() {
      verifyRideContainerHeight = 0;
      timerContainerHeight = 0.0;
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingofMap = 230.0;
      drawerOpen = true;
    });
  }

  resetApp(){
    setState(() {
      myLocationIconVisible = true;
      timerContainerHeight = 0;
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingofMap = 230.0;
      requestRideContainerHeight = 0.0;
      verifyRideContainerHeight = 0;
      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
      startTimer = false;
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async{
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0.0;
      timerContainerHeight = 0.0;
      rideDetailsContainerHeight = 315.0;
      bottomPaddingofMap = 230.0;
      drawerOpen = false;
    });
  }

  void locateRoutePosition() async{
    Position _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = _position;

    LatLng latlanPosition = LatLng(_position.latitude, _position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latlanPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(_position, context);
    print("This is your Address :: " + address);
  }

  void locatePosition() async{
    Position _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = _position;

    LatLng latlanPosition = LatLng(_position.latitude, _position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latlanPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(_position, context);
    print("This is your Address :: " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 200.0,
                // color: Colors.blueAccent,
                child: DrawerHeader(
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
                  // child: Row(
                  //   // children: [
                  //   //   Image.asset("assets/images/profilepic.jpg", height: 65.0, width: 65.0,),
                  //   //   SizedBox(width: 16.0,),
                  //   //   Column(
                  //   //     mainAxisAlignment: MainAxisAlignment.center,
                  //   //     // children: [
                  //   //     //   Text("Profile Name", style: TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),),
                  //   //     //   SizedBox(height: 6.0,),
                  //   //     //   Text("Visit Profile"),
                  //   //     // ],
                  //   //   ),
                  //   // ],
                  // ),
                ),
              ),

              //DividerWidget(),

              //SizedBox(height: 12.0,),

              CustomListTile(Icons.person, "Profile", ()=>{
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())),
              }),
              // CustomListTile(Icons.qr_code_scanner, "QR Scanner", ()=>{ Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => QRPage()),
              // )}),
              // CustomListTile(Icons.timer, "Timer", ()=>{ Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => TimerPage()),
              // )}),
              CustomListTile(Icons.history, "Booking History", ()=>{
                Navigator.push(context, MaterialPageRoute(builder: (context) => BookingHistoryPage())),
              }),
              CustomListTile(Icons.help, "Help", ()=>{}),
              // CustomListTile(Icons.settings, "Settings", ()=>{}),
              CustomListTile(Icons.logout, "Log Out", () {
                _firebaseProvider.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              ),
              // Container(
              //   child: DrawerHeader(
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         begin: Alignment.topCenter,
              //         end: Alignment.bottomCenter,
              //         colors: [
              //           Color(0xFF73AEF5),
              //           Color(0xFF61A4F1),
              //           Color(0xFF478DE0),
              //           Color(0xFF398AE5),
              //         ],
              //         stops: [0.1, 0.4, 0.7, 0.9],
              //       ),
              //     ),
              //   ),
              // ),
              //Drawer Body Controls
              // ListTile(
              //  leading: Icon(Icons.history),
              //  title: Text("Parking History", style: TextStyle(fontSize: 16.0,),),
              // ),
              // ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text("Vist Profile", style: TextStyle(fontSize: 16.0,),),
              // ),
              // ListTile(
              //   leading: Icon(Icons.info),
              //   title: Text("About", style: TextStyle(fontSize: 16.0,),),
              // ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingofMap),
            //mapType: MapType.normal,
            myLocationButtonEnabled: false,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              newGoogleMapController.setMapStyle(_mapStyle);
              setState(() {
                bottomPaddingofMap = 300.0;
              });

              locatePosition();
            },
          ),


          ///////////

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                color: Colors.white,
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
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: timerContainerHeight,
              child: Column(
                children: [
                  SizedBox(height: 300.0,),
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                        child: Stack(
                          children: <Widget>[

                            CircularCountDownTimer(
                              // Countdown duration in Seconds.
                              duration: 3600,

                              // Countdown initial elapsed Duration in Seconds.
                              initialDuration: 0,

                              // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                              controller: _controller,

                              // Width of the Countdown Widget.
                              width: MediaQuery.of(context).size.width / 2,

                              // Height of the Countdown Widget.
                              height: 0.7*MediaQuery.of(context).size.height,

                              // Ring Color for Countdown Widget.
                              ringColor: Colors.lightBlueAccent,

                              // Ring Gradient for Countdown Widget.
                              ringGradient: null,

                              // Filling Color for Countdown Widget.
                              fillColor: Colors.white,

                              // Filling Gradient for Countdown Widget.
                              fillGradient: null,
                              // fillGradient: LinearGradient(
                              //   begin: Alignment.topCenter,
                              //   end: Alignment.bottomCenter,
                              //   colors: [
                              //   Color(0xFF73AEF5),
                              //   Color(0xFF61A4F1),
                              //   Color(0xFF478DE0),
                              //   Color(0xFF398AE5),
                              //   ],
                              //   stops: [0.1, 0.4, 0.7, 0.9],
                              //   ),

                              // Background Color for Countdown Widget.
                              backgroundColor: Colors.transparent,

                              // Background Gradient for Countdown Widget.
                              backgroundGradient: null,

                              // Border Thickness of the Countdown Ring.
                              strokeWidth: 20.0,

                              // Begin and end contours with a flat edge and no extension.
                              strokeCap: StrokeCap.round,

                              // Text Style for Countdown Text.
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 35.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',),

                              // Format for the Countdown Text.
                              textFormat: CountdownTextFormat.HH_MM_SS,

                              // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                              isReverse: true,

                              // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                              isReverseAnimation: false,

                              // Handles visibility of the Countdown Text.
                              isTimerTextShown: true,

                              // Handles the timer start.
                              autoStart: false,

                              onStart: (){
                                setState(() {
                                  //delete_coins();
                                  _firebaseProvider.addCoin(id, "-$timerCost"); //dynamically delte required coins on starting timer
                                  // _controllerCenterRight.play();
                                  // _controllerCenterLeft.play();
                                  started = true;
                                });
                              },

                              onComplete: (){
                                setState(() {
                                  started = false;
                                });
                              },
                            ),
                          ],
                        ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //CENTER LEFT - Emit right
                      ConfettiWidget(
                        confettiController: _controllerCenterLeft,
                        blastDirection: 0, // radial value - RIGHT
                        particleDrag: 0.05, // apply drag to the confetti
                        emissionFrequency: 0.5, // how often it should emit
                        numberOfParticles: 20, // number of particles to emit
                        gravity: 0.05, // gravity - or fall speed
                        shouldLoop: false,
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink
                        ],
                      ),
                      //CENTER RIGHT -- Emit left
                      ConfettiWidget(
                        confettiController: _controllerCenterRight,
                        blastDirection: pi, // radial value - LEFT
                        particleDrag: 0.05, // apply drag to the confetti
                        emissionFrequency: 0.5, // how often it should emit
                        numberOfParticles: 20, // number of particles to emit
                        gravity: 0.05, // gravity - or fall speed
                        shouldLoop: false,
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink
                        ], // manually specify the colors to be used
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      _button(title: "Extend parking", onPressed: started==false ? ()=>  _controller.restart(duration: _timerduration.toInt()*3600) : null),
                      SizedBox(
                        width: 10
                      ),
                      _button(title: "Leave Parking", onPressed: () => cancelParking()), //_controller.pause()
                      SizedBox(
                          width: 10
                      ),
                      //_button(title: "Pay 200 to extend", onPressed: started==false ? ()=>  _controller.restart(duration: _duration) : null), //() => _controller.start()
                      // MaterialButton(
                      //   onPressed: () {
                      //     if(started == false) {
                      //       delete_coins();
                      //       _controller.start();
                      //     }
                      //     else {
                      //       null;
                      //     }
                      //   },
                      //   child: Text("Pay 200 parKoins"),
                      // ),

                      // SizedBox(
                      //   width: 10,
                      // ),
                      // _button(title: "Pause", onPressed: () => _controller.pause()),
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // _button(title: "Resume", onPressed: () => _controller.resume()),
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // _button(
                      //     title: "Restart",
                      //     onPressed: () => _controller.restart(duration: _duration))
                    ],
                    // _button(title: "Pay 200 to extend", onPressed: started==false ? ()=>  _controller.restart(duration: _timerduration) : null),
                    // _button(title: "Want to leave?", onPressed: () => _controller.pause()),
                  ),



                ],
              ),
            ),
          ),



          ///////////



          //HamburgerButton for Drawer
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: (){
                if(drawerOpen) {
                  scaffoldKey.currentState.openDrawer();
                }
                else{
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white70,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,0.7
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon( (drawerOpen) ? Icons.menu : Icons.close, color: Colors.white,),
                  radius: 20.0,

                ),
              ),
            ),
          ),


          //MyLocation
          myLocationIconVisible? Positioned(
            bottom: 325.0,
            right: 22.0,
            child: GestureDetector(
              onTap: (){
                locatePosition();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white70,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                          0.7,0.7
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.my_location, color: Colors.white,),
                  radius: 20.0,

                ),
              ),
            ),
          ):Container(),


          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  // color: Colors.white,
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text(userName != null ? "Hi ${capitalize(userName)}," : "Hi There,", style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                      ),
                      ),
                  Text("Where to?", style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                  ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () async{

                          var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));

                          if (res == "obtainDirection"){
                            // await getPlaceDirection();
                            displayRideDetailsContainer();
                          }

                          },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 3.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent, size: 30.0,),
                                SizedBox(width: 10.0,),
                                Text("Search Parking Location", style:
                                TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.white, size: 30.0,),
                          SizedBox(width: 9.0), //12.0 orig 9.0 works
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AppData>(context).startLocation != null ? Provider.of<AppData>(context).startLocation.placeName : "Add Home",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',),
                                ),
                                SizedBox(height: 4.0,),
                                Text("Your current location", style:
                                  TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      // SizedBox(height: 16.0),
                      // Row(
                      //   children: [
                      //     Icon(Icons.work, color: Colors.grey,),
                      //     SizedBox(width: 12.0),
                      //     Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text("Add Work"),
                      //         SizedBox(height: 4.0,),
                      //         Text("Your office address", style: TextStyle(color: Colors.black54, fontSize: 12.0),),
                      //       ],
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                )
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  // color: Colors.white,
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight:Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        //color: Colors.blueAccent,
                        // color: Colors.lightBlueAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            children: [
                              Image.asset("assets/images/parking_logo.png", height: 60.0, width: 60.0),
                              // Icon(FontAwesomeIcons.car, size: 70.0, color: Colors.grey,),
                              SizedBox(width: 16.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Distance", style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',),
                                  ),
                                  Text(
                                    ((tripdirectiondetails != null) ? tripdirectiondetails.distanceText : ""),
                                    style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripdirectiondetails != null) ? '${AssistantMethods.calculateFares(tripdirectiondetails, duration)}\ ParKoin  ' : ''), style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      // SizedBox(height: 10.0,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            IconButton(
                              splashColor: Colors.pink,
                              splashRadius: 15.0,
                              icon: Icon(Icons.location_on, size: 25.0, color: Colors.white,),
                              onPressed: (){

                              },
                            ),
                            SizedBox(width: 16.0,),
                            Expanded(
                              child: Column(
                                children: [
                                  Text( Provider.of<AppData>(context, listen: false).endLocation != null?
                                    "Parking Name: ${Provider.of<AppData>(context, listen: false).endLocation.placeName}" : "Parking Name: N/A", style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SizedBox(height: 5.0,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            IconButton(
                              splashColor: Colors.pink,
                              splashRadius: 15.0,
                              icon: Icon(Icons.star_rate, size: 25.0, color: Colors.white,),
                              onPressed: (){

                              },
                            ),
                            SizedBox(width: 16.0,),
                            Text( Provider.of<AppData>(context, listen: false).endLocation != null ?
                              "Parking Rating: ${Provider.of<AppData>(context, listen: false).endLocation.rating}" : "Parking Rating: N/A", style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',),),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            IconButton(
                              splashColor: Colors.pink,
                              splashRadius: 15.0,
                              icon: Icon(Icons.access_time, size: 25.0, color: Colors.white,),
                              onPressed: () async {
                                var resultingDuration = await showDurationPicker(
                                  context: context,
                                  initialTime: Duration(minutes: (duration * 60).toInt()),
                                );
                                setState(() {
                                  duration = (resultingDuration.inMinutes / 60);
                                  print(duration);
                                });
                              },
                            ),
                            SizedBox(width: 16.0,),
                            Text("Duration: ${duration.toStringAsFixed(2)} hours", style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',),),
                          ],
                        ),
                      ),
                      // SizedBox(height: 10.0,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          onPressed: () async {
                            print("Parking Requested");
                            displayRequestContainer();
                            var loc = Provider.of<AppData>(context, listen: false).endLocation;
                            print("Final Location ::");
                            print(loc.placeName);
                            pid = loc.placeId;
                            var lat = loc.latitude;
                            var lng = loc.longitude;
                            var timeOfBooking = DateTime.now();
                            var timeOfCreation = DateTime.now();
                            var prid = 'r_${pid}h_${uid}d_t_${DateTime.now()}${new Random().nextInt(100)}';
                            createdRequest = await _firebaseProvider.createParkingRequest(prid, uid, pid, lat, lng,
                                timeOfBooking, timeOfCreation, duration, loc.placeName);
                            if(createdRequest) {
                              setState(() {
                                createdRequest = false;
                                requestRideContainerHeight = 0.0;
                                verifyRideContainerHeight = 250;
                                _timerduration = duration;
                                timerCost = AssistantMethods.calculateFares(tripdirectiondetails, duration);
                                print("time duration ::");
                                print(_timerduration);
                                print("duration ::");
                                print(duration);
                                //here I have to call checker that updates user start point
                              });
                            }
                            reRoute();
                          },
                          // color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            // padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Request", style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',),),
                                Icon(FontAwesomeIcons.parking, color: Colors.blueAccent, size: 27.0,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                //color: Colors.white,
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
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    SizedBox(
                    width: double.infinity,
                    child: ColorizeAnimatedTextKit(
                    onTap: () {
                      print("Tap Event");
                    },
                    text: [
                      "Requesting Parking",
                      "Please Wait",
                      "Finding Parking",
                    ],
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                    colors: [
                      Colors.white,
                      Colors.white60,
                      Colors.white70,
                      Colors.grey,
                      Colors.blueGrey,
                      Colors.black26,
                      Colors.black54,
                    ],
                    textAlign: TextAlign.center,
                    isRepeatingAnimation: true,
                    repeatForever: true,
                    ),
                    ),
                    SizedBox(height: 22.0,),

                    GestureDetector(
                      onTap: (){
                        //cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.grey[300]),
                        ),
                        child: Icon(Icons.close, size: 26.0, color: Colors.blueAccent,),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Container(
                      width: double.infinity,
                      child: Text("Cancel booking", textAlign: TextAlign.center, style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',),),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                // color: Colors.white,
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
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: verifyRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    SizedBox(
                      width: double.infinity,
                      child:
                      isButtonEnabled ? // check if qrButton enabled
                      ColorizeAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "LPR failed! Please use QR or BT to verify",
                        ],
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                        colors: [
                          Colors.white,
                          Colors.white60,
                          Colors.white70,
                          Colors.grey,
                          Colors.blueGrey,
                          Colors.black26,
                          Colors.black54,
                        ],
                        textAlign: TextAlign.center,
                        isRepeatingAnimation: true,
                        repeatForever: true,
                      )
                          : startingLpr ? // check if lpr began
                        ColorizeAnimatedTextKit(
                        onTap: () {
                          // resetApp();
                          print("Tap Event");
                        },
                        text: [
                          "Reached parking, performing lpr",
                        ],
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                        colors: [
                          Colors.white,
                          Colors.white60,
                          Colors.white70,
                          Colors.grey,
                          Colors.blueGrey,
                          Colors.black26,
                          Colors.black54,
                        ],
                          textAlign: TextAlign.center,
                        isRepeatingAnimation: true,
                        repeatForever: true,
                        )
                          : ColorizeAnimatedTextKit( // still not reached parking
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "Please reach parking to verify booking",
                        ],
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                        colors: [
                          Colors.white,
                          Colors.white60,
                          Colors.white70,
                          Colors.grey,
                          Colors.blueGrey,
                          Colors.black26,
                          Colors.black54,
                        ],
                        textAlign: TextAlign.center,
                        isRepeatingAnimation: true,
                        repeatForever: true,
                      ),
                    ),
                    // SizedBox(height: 18.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: isButtonEnabled == true ? () async {
                            String codeSanner = await BarcodeScanner.scan();
                            setState(() {
                              qrCodeResult = codeSanner;
                            });

                            if(qrCodeResult == Provider.of<AppData>(context, listen: false).endLocation.placeId){
                              displayTimerContainer();
                              print("QR verification successful");
                            }
                            else{
                              print("QR verification failed");
                            }
                            // Navigator.push(
                            // context,
                            // MaterialPageRoute(builder: (context) => QRPage()),
                            // );
                          } : null,
                          child: isButtonEnabled ? Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(width: 2.0, color: Colors.grey[300]),
                            ),
                            child: Icon(Icons.qr_code_scanner , size: 25.0, color: Colors.blueAccent,),
                          ) : Container(),
                        ),
                        GestureDetector(
                          onTap: isButtonEnabled == true ? () {
                            _blueToothVerification(uid, pid);
                          } : null,
                          child: isButtonEnabled ? Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(width: 2.0, color: Colors.grey[300]),
                            ),
                            child: Icon(Icons.bluetooth , size: 25.0, color: Colors.blueAccent,),
                          ) : Container(),
                        ),
                      ],
                    ),

                    SizedBox(height: 5.0,),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async{ //bool started added
    var initPos = Provider.of<AppData>(context, listen: false).startLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).endLocation;

    var startLatLng = LatLng(initPos.latitude, initPos.longitude);
    var endLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => Center(child: CircularProgressIndicator(),)//ProgressDialog(message: "Setting Destination, Please Wait...",),
    );

    var details = await AssistantMethods.obtainPlaceDirectionsDetails(startLatLng, endLatLng);

    setState(() {
      tripdirectiondetails = details;
    });


    Navigator.pop(context);

    print("This is encoded points ::");
    print(details.encodedPoints);

    PolylinePoints polylinepoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinepoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if(decodedPolyLinePointsResult.isNotEmpty){
      decodedPolyLinePointsResult.forEach((PointLatLng pointlatlng) {
        pLineCoordinates.add(LatLng(pointlatlng.latitude, pointlatlng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pinkAccent,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyline); //added in here
    });

    LatLngBounds latlngbounds;
    if(startLatLng.latitude > endLatLng.latitude && startLatLng.longitude > endLatLng.longitude){
      latlngbounds = LatLngBounds(southwest: endLatLng, northeast: startLatLng);
    }
    else if(startLatLng.longitude > endLatLng.longitude){
      latlngbounds = LatLngBounds(southwest: LatLng(startLatLng.latitude, endLatLng.longitude), northeast: LatLng(endLatLng.latitude, startLatLng.longitude));
    }
    else if(startLatLng.latitude > endLatLng.latitude){
      latlngbounds = LatLngBounds(southwest: LatLng(endLatLng.latitude, startLatLng.longitude), northeast: LatLng(startLatLng.latitude, endLatLng.longitude));
    }
    else{
      latlngbounds = LatLngBounds(southwest: startLatLng, northeast: endLatLng);
    }

    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latlngbounds, 70));

    Marker startLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      // icon: await BitmapDescriptor.fromAssetImage(
      //     ImageConfiguration(size: Size(5, 5)), 'assets/images/start.png'),
      infoWindow: InfoWindow(title: initPos.placeName, snippet: "My location"),
      position: startLatLng,
      markerId: MarkerId("startId"),
    );

    Marker endLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Parking Location"),
      position: endLatLng,
      markerId: MarkerId("endId"),
    );

    setState(() {
      markersSet.add(startLocationMarker);
      markersSet.add(endLocationMarker);
    });


    Circle startCircle = Circle(
      fillColor: Colors.red,
      center: startLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
      circleId: CircleId("startId"),
    );

    Circle endCircle = Circle(
      fillColor: Colors.lightBlue,
      center: endLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.lightBlueAccent,
      circleId: CircleId("endId"),
    );

    setState(() {
      circlesSet.add(startCircle);
      circlesSet.add(endCircle);
    });

  }


  Future<void> getRoutePlaceDirection() async{ //bool started added
    var initPos = Provider.of<AppData>(context, listen: false).startLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).endLocation;

    var startLatLng = LatLng(initPos.latitude, initPos.longitude);
    var endLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) => Center(child: CircularProgressIndicator(),)//ProgressDialog(message: "Setting Destination, Please Wait...",),
    // );

    var details = await AssistantMethods.obtainPlaceDirectionsDetails(startLatLng, endLatLng);

    setState(() {
      tripdirectiondetails = details;
    });


    // Navigator.pop(context);

    print("This is encoded points ::");
    print(details.encodedPoints);

    PolylinePoints polylinepoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinepoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if(decodedPolyLinePointsResult.isNotEmpty){
      decodedPolyLinePointsResult.forEach((PointLatLng pointlatlng) {
        pLineCoordinates.add(LatLng(pointlatlng.latitude, pointlatlng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pinkAccent,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyline); //added in here
    });

    // LatLngBounds latlngbounds;
    // if(startLatLng.latitude > endLatLng.latitude && startLatLng.longitude > endLatLng.longitude){
    //   latlngbounds = LatLngBounds(southwest: endLatLng, northeast: startLatLng);
    // }
    // else if(startLatLng.longitude > endLatLng.longitude){
    //   latlngbounds = LatLngBounds(southwest: LatLng(startLatLng.latitude, endLatLng.longitude), northeast: LatLng(endLatLng.latitude, startLatLng.longitude));
    // }
    // else if(startLatLng.latitude > endLatLng.latitude){
    //   latlngbounds = LatLngBounds(southwest: LatLng(endLatLng.latitude, startLatLng.longitude), northeast: LatLng(startLatLng.latitude, endLatLng.longitude));
    // }
    // else{
    //   latlngbounds = LatLngBounds(southwest: startLatLng, northeast: endLatLng);
    // }

    // newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latlngbounds, 70));

    Marker startLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      // icon: await BitmapDescriptor.fromAssetImage(
      //     ImageConfiguration(size: Size(5, 5)), 'assets/images/start.png'),
      infoWindow: InfoWindow(title: initPos.placeName, snippet: "My location"),
      position: startLatLng,
      markerId: MarkerId("startId"),
    );

    Marker endLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Parking Location"),
      position: endLatLng,
      markerId: MarkerId("endId"),
    );

    setState(() {
      markersSet.add(startLocationMarker);
      markersSet.add(endLocationMarker);
    });


    Circle startCircle = Circle(
      fillColor: Colors.red,
      center: startLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
      circleId: CircleId("startId"),
    );

    Circle endCircle = Circle(
      fillColor: Colors.lightBlue,
      center: endLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.lightBlueAccent,
      circleId: CircleId("endId"),
    );

    setState(() {
      circlesSet.add(startCircle);
      circlesSet.add(endCircle);
    });

  }

  String _hash(String key, String pid) {
    print("_hash : key = $key\n");
    print("_hash : pid = $key\n");

    var str = key + pid;
    int hash = 0, i, chr, len;
    len = str.length;
    if (len == 0) return hash.toString();

    for(int i = 0; i < len; i++) {
      chr   = str.codeUnitAt(i);
      hash  = ((hash << 5) - hash) + chr;
      hash |= 0; // Convert to 32bit integer
    }
    return hash.toString();
  }

  void _blueToothVerification(String uid, String pid) async {
    String result = "";
    String address = "20:18:11:21:23:23";
    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(address);
      print('Connected to the device');

      String lastTenUID = uid.substring(uid.length - 10);
      print("Lets send the key over the connection\n");
      connection.output.add(utf8.encode(";" + lastTenUID + ";" + "\r\n"));
      await connection.output.allSent;
      connection.input.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        //connection.output.add(data); // Sending data
        result += ascii.decode(data);
        if (ascii.decode(data).contains("@")) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
        result = result.replaceAll(RegExp(r'[@;]'), '');
        String ans = _hash(lastTenUID, pid);
        if(ans == result) {
            displayTimerContainer();
        }
        else {
          Fluttertoast.showToast(msg: "BlueTooth Auth failed, Try QR");
        }
      });
    } catch (exception) {
      Fluttertoast.showToast(msg: 'Cannot connect, try again or use QR');
    }
  }

}