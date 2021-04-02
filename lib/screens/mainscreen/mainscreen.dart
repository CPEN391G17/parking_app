import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/DataHandler/appData.dart';
import 'package:parking_app/assistant/assistantMethods.dart';
import 'package:parking_app/models/directionDetails.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/login_page/login_page.dart';
import 'package:parking_app/screens/profile_page/profile_page.dart';
import 'package:parking_app/screens/qrscanner_page/qrscanner_page.dart';
import 'package:parking_app/screens/searchScreen/searhScreen.dart';
import 'package:parking_app/screens/timer_page/timer_page.dart';
import 'package:parking_app/widgets/Divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parking_app/widgets/custom_tile.dart';
import 'package:provider/provider.dart';

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

  double refundCost = 0.0;

  @override
  void initState() {
    super.initState();
    getUid();
  }

  void getUid() async {
    uid = await _firebaseProvider.currentUser();
  }

  void displayTimerContainer() {
    setState(() {
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
      resetApp();
    });
  }

  _button({String title, VoidCallback onPressed}) {
    return Expanded(
        child: ElevatedButton(
          child: Text(
            title,
            style: TextStyle(color: Colors.white),
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
      verifyRideContainerHeight = 250.0;
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
      rideDetailsContainerHeight = 240.0;
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
      // appBar: AppBar(
      //   title: Text("Map"),
      // ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: <Color>[
                        Colors.blue,
                        Colors.lightBlueAccent,
                      ])
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/profilepic.jpg", height: 65.0, width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name", style: TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Visit Profile"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              DividerWidget(),

              SizedBox(height: 12.0,),

              CustomListTile(Icons.person, "Profile", ()=>{
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())),
              }),
              CustomListTile(Icons.qr_code_scanner, "QR Scanner", ()=>{ Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRPage()),
              )}),
              // CustomListTile(Icons.timer, "Timer", ()=>{ Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => TimerPage()),
              // )}),
              CustomListTile(Icons.history, "Booking History", ()=>{}),
              CustomListTile(Icons.help, "Help", ()=>{}),
              CustomListTile(Icons.settings, "Settings", ()=>{}),
              CustomListTile(Icons.logout, "Log Out", () {
                _firebaseProvider.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              ),

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
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    SizedBox(
                      width: double.infinity,
                      child: Center(
                          child: CircularCountDownTimer(
                            // Countdown duration in Seconds.
                            duration: 3600,

                            // Countdown initial elapsed Duration in Seconds.
                            initialDuration: 0,

                            // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                            controller: _controller,

                            // Width of the Countdown Widget.
                            width: MediaQuery.of(context).size.width / 2,

                            // Height of the Countdown Widget.
                            height: 1.1*MediaQuery.of(context).size.height,

                            // Ring Color for Countdown Widget.
                            ringColor: Colors.grey[300],

                            // Ring Gradient for Countdown Widget.
                            ringGradient: null,

                            // Filling Color for Countdown Widget.
                            fillColor: Colors.blueAccent[100],

                            // Filling Gradient for Countdown Widget.
                            fillGradient: null,

                            // Background Color for Countdown Widget.
                            backgroundColor: Colors.blue[500],

                            // Background Gradient for Countdown Widget.
                            backgroundGradient: null,

                            // Border Thickness of the Countdown Ring.
                            strokeWidth: 20.0,

                            // Begin and end contours with a flat edge and no extension.
                            strokeCap: StrokeCap.round,

                            // Text Style for Countdown Text.
                            textStyle: TextStyle(
                                fontSize: 33.0, color: Colors.white, fontWeight: FontWeight.bold),

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
                                started = true;
                              });
                            },

                            onComplete: (){
                              setState(() {
                                started = false;
                              });
                            },



                          ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        _button(title: "Pay Parkoin $timerCost to extend parking?", onPressed: started==false ? ()=>  _controller.restart(duration: _timerduration.toInt()*3600) : null),
                        SizedBox(
                          width: 10,
                        ),
                        _button(title: "Leave Parking?", onPressed: () => cancelParking()), //_controller.pause()
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
                      color: Colors.black54,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,0.7
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon( (drawerOpen) ? Icons.menu : Icons.close, color: Colors.black,),
                  radius: 20.0,

                ),
              ),
            ),
          ),

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
                  color: Colors.white,
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
                      Text("Hi there,", style: TextStyle(fontSize: 12.0, fontFamily: "Brand-Bold"),),
                      Text("Where to?", style: TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),),
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
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent,),
                                SizedBox(width: 10.0,),
                                Text("Search parking location"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.grey,),
                          SizedBox(width: 9.0), //12.0 orig 9.0 works
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).startLocation != null ? Provider.of<AppData>(context).startLocation.placeName : "Add Home"
                              ),
                              SizedBox(height: 4.0,),
                              Text("Your home address", style: TextStyle(color: Colors.black54, fontSize: 12.0),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey,),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(height: 4.0,),
                              Text("Your office address", style: TextStyle(color: Colors.black54, fontSize: 12.0),),
                            ],
                          ),
                        ],
                      ),
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
                  color: Colors.white,
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
                        color: Color.fromRGBO(54, 79, 107, 1),
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
                                    "Parking", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold", color: Colors.grey),
                                  ),
                                  Text(
                                    ((tripdirectiondetails != null) ? tripdirectiondetails.distanceText : ""), style: TextStyle(fontSize: 18.0, color: Colors.grey,),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripdirectiondetails != null) ? '\ Parkoin ${AssistantMethods.calculateFares(tripdirectiondetails, duration)}' : ''), style: TextStyle(fontSize: 18.0, color: Colors.grey, fontFamily: "Brand-Bold",),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 15.0,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            IconButton(
                              hoverColor: Colors.blue,
                              icon: Icon(Icons.access_time, size: 24.0, color: Colors.black54,),
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
                            Text("duration: ${duration.toStringAsFixed(2)} hours", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.0,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            print("Parking Requested");
                            displayRequestContainer();
                            var loc = Provider.of<AppData>(context, listen: false).endLocation;
                            var pid = loc.placeId;
                            var lat = loc.latitude;
                            var lng = loc.longitude;
                            var timeOfBooking = DateTime.now();
                            var timeOfCreation = DateTime.now();
                            var prid = 'r_${pid}h_${uid}d_t_${DateTime.now()}${new Random().nextInt(100)}';
                            createdRequest = await _firebaseProvider.createParkingRequest(prid, uid, pid, lat, lng,
                                timeOfBooking, timeOfCreation, duration);
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
                                Text("Request", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                Icon(FontAwesomeIcons.parking, color: Colors.white, size: 26.0,)
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
                color: Colors.white,
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
                    fontSize: 35.0,
                    fontFamily: "Helvetica Neue",
                    ),
                    colors: [
                      Colors.blueGrey,
                      Colors.blueAccent,
                      Colors.lightBlueAccent,
                      Colors.lightBlue,
                      Colors.blue,
                      Colors.cyanAccent,
                      Colors.cyan,
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
                        child: Icon(Icons.close, size: 26.0,),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Container(
                      width: double.infinity,
                      child: Text("Cancel booking", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0, fontFamily: "Brand-Bold" ,fontWeight: FontWeight.bold),),
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
                color: Colors.white,
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
                          "LPR failed! Please use QR to verify",
                        ],
                        textStyle: TextStyle(
                          fontSize: 35.0,
                          fontFamily: "Helvetica Neue",
                        ),
                        colors: [
                          Colors.blueGrey,
                          Colors.blueAccent,
                          Colors.lightBlueAccent,
                          Colors.lightBlue,
                          Colors.blue,
                          Colors.cyanAccent,
                          Colors.cyan,
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
                          fontSize: 35.0,
                          fontFamily: "Helvetica Neue",
                        ),
                        colors: [
                          Colors.blueGrey,
                          Colors.blueAccent,
                          Colors.lightBlueAccent,
                          Colors.lightBlue,
                          Colors.blue,
                          Colors.cyanAccent,
                          Colors.cyan,
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
                          fontSize: 35.0,
                          fontFamily: "Helvetica Neue",
                        ),
                        colors: [
                          Colors.blueGrey,
                          Colors.blueAccent,
                          Colors.lightBlueAccent,
                          Colors.lightBlue,
                          Colors.blue,
                          Colors.cyanAccent,
                          Colors.cyan,
                        ],
                        textAlign: TextAlign.center,
                        isRepeatingAnimation: true,
                        repeatForever: true,
                      ),
                    ),
                    SizedBox(height: 22.0,),
                    GestureDetector(
                      onTap: isButtonEnabled == true ? () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QRPage()),
                        );
                      } : null,
                      child: isButtonEnabled ? Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.grey[300]),
                        ),
                        child: Icon(Icons.payment , size: 26.0,),
                      ) : Container(),
                    ),
                    SizedBox(height: 10.0,),
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
        color: Colors.pink,
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      // icon: await BitmapDescriptor.fromAssetImage(
      //     ImageConfiguration(size: Size(5, 5)), 'assets/images/start.png'),
      infoWindow: InfoWindow(title: initPos.placeName, snippet: "My location"),
      position: startLatLng,
      markerId: MarkerId("startId"),
    );

    Marker endLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Parking Location"),
      position: endLatLng,
      markerId: MarkerId("endId"),
    );

    setState(() {
      markersSet.add(startLocationMarker);
      markersSet.add(endLocationMarker);
    });


    Circle startCircle = Circle(
      fillColor: Colors.lightGreen,
      center: startLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.lightGreenAccent,
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
        color: Colors.pink,
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      // icon: await BitmapDescriptor.fromAssetImage(
      //     ImageConfiguration(size: Size(5, 5)), 'assets/images/start.png'),
      infoWindow: InfoWindow(title: initPos.placeName, snippet: "My location"),
      position: startLatLng,
      markerId: MarkerId("startId"),
    );

    Marker endLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Parking Location"),
      position: endLatLng,
      markerId: MarkerId("endId"),
    );

    setState(() {
      markersSet.add(startLocationMarker);
      markersSet.add(endLocationMarker);
    });


    Circle startCircle = Circle(
      fillColor: Colors.lightGreen,
      center: startLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.lightGreenAccent,
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

}