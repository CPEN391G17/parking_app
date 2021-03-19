import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:parking_app/resources/firebase_provider.dart';

//parking app billing needs to enabled once it has been verified to enable Geocoding
class MainScreen extends StatefulWidget{
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{

  FirebaseProvider _firebaseProvider = FirebaseProvider();

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

  bool drawerOpen = true;
  bool createdRequest = false;

  @override
  void initState() {
    super.initState();
    getUid();
  }

  void getUid() async {
    uid = await _firebaseProvider.currentUser();
  }

  void displayRequestContainer(){
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingofMap = 230.0;
      drawerOpen = true;
    });
  }

  resetApp(){
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingofMap = 230.0;
      requestRideContainerHeight = 0.0;
      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async{
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0.0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingofMap = 230.0;
      drawerOpen = false;
    });
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
              CustomListTile(Icons.timer, "Timer", ()=>{ Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimerPage()),
              )}),
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
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Color.fromRGBO(54, 79, 107, 1),
                        // color: Colors.lightBlueAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("assets/images/parking_logo.png", height: 40.0, width: 40.0),
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
                                ((tripdirectiondetails != null) ? '\ Parkoin ${AssistantMethods.calculateFares(tripdirectiondetails)}' : ''), style: TextStyle(fontSize: 18.0, color: Colors.grey, fontFamily: "Brand-Bold",),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt, size: 18.0, color: Colors.black54,),
                            SizedBox(width: 16.0,),
                            Text("Payment Method"),
                            SizedBox(width: 6.0,),
                            Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16.0,),
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
                            var duration = 1.0;
                            var prid = 'r_${pid}h_${uid}d_t_${DateTime.now()}${new Random().nextInt(100)}';
                            createdRequest = await _firebaseProvider.createParkingRequest(prid,
                                uid, pid, lat, lng, timeOfBooking, timeOfCreation, duration);
                            if(createdRequest)
                              setState(() {
                                createdRequest = false;
                                requestRideContainerHeight = 0.0;
                              });
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


        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async{
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