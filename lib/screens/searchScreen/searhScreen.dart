import 'package:flutter/material.dart';
import 'package:parking_app/assistant/requestAssistant.dart';
import 'package:parking_app/configMaps.dart';
import 'package:parking_app/models/address.dart';
import 'package:parking_app/models/placePredictions.dart';
import 'package:parking_app/widgets/Divider.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/DataHandler/appData.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController startPointTextEditingController = TextEditingController();
  TextEditingController endPointTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  bool _isLoading = false;
  bool _isInit = true;
  // String rating;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      String placeAddress = Provider.of<AppData>(context).startLocation.placeName?? "";
      startPointTextEditingController.text = placeAddress;
      setState(() {
        _isLoading = false;
      });
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return startPointTextEditingController.text == null ?
      showDialog(
          context: context,
          builder: (BuildContext context) => Center(child: CircularProgressIndicator(),)//ProgressDialog(message: "Setting Destination, Please Wait...",),
      ):Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: 215.0,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, //black, 6
                  blurRadius: 3.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7,0.7),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 5.0),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap:(){
                          Navigator.pop(context);
                        },
                        child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 25.0,
                        ),
                      ),
                      Center(
                        child: Text("Select Destination", style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',),),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),

                  Row(
                    children: [
                      Image.asset("assets/images/pin_location.png", height: 25.0, width: 25.0,),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                              controller: startPointTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Starting Point",
                                hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.0),

                  Row(
                    children: [
                      Image.asset("assets/images/destination.png", height: 25.0, width: 25.0,),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                              onChanged: (val){
                                findPlace(val);
                              },
                              controller: endPointTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Where to?",
                                hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
          //tile to display predictions
          SizedBox(height: 10.0,),

          (placePredictionList.length > 0) ? Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              // color: Colors.pink,
              child: ListView.separated(
                padding: EdgeInsets.all(0.0),
                itemBuilder: (context, index){
                  return Container(child: PredictionTile(placePredictions: placePredictionList[index],));
                },
                separatorBuilder: (BuildContext context, int index) => DividerWidget(),
                itemCount: placePredictionList.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  void findPlace(String placeName) async{
    if(placeName.length > 1){
      String autoCompleteURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890";//&components=country:ca";

      var response = await RequestAssistant.getRequest(autoCompleteURL);

      if(response == "failed"){
        return;
      }
      // print("Places Prediction Response :: ");
      // print(response);

      if(response["status"] == "OK"){
        var predictions = response["predictions"];
        var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();
        setState(() {
          placePredictionList = placesList;
        });
      }

    }
  }
}


class PredictionTile extends StatelessWidget {

  final PlacePredictions placePredictions;

  PredictionTile({Key key, this.placePredictions,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        // padding: EdgeInsets.all(0.0),
        onPressed: (){
          getPlaceAddressDetails(placePredictions.place_id, context);
        },
        child: Container(
          child: Column(
            children: [
              SizedBox(width: 10.0,),
              Row(
                children: [
                  Icon(Icons.location_on, size: 25.0, color: Colors.blueAccent,),
                  SizedBox(
                    width: 14.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0,),
                        Text(placePredictions.main_text, overflow: TextOverflow.ellipsis, style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',),),
                        SizedBox(height: 2.0,),
                        Text(placePredictions.secondary_text, overflow: TextOverflow.ellipsis, style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14.0,
                          // fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',),),
                        SizedBox(height: 8.0,),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.0,),
            ],
          ),
        ),
      );
  }
  void getPlaceAddressDetails(String placeId, context) async{

    double rating;

    showDialog(
        context: context,
        builder: (BuildContext context) => Center(child: CircularProgressIndicator(),)//ProgressDialog(message: "Setting Destination, Please Wait...",),
    );

    String placeDetailsURL = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var response = await RequestAssistant.getRequest(placeDetailsURL);

    Navigator.pop(context);

    if(response == "failed"){
      return;
    }

    if(response["status"] == "OK"){
      Address address = Address();
      address.placeName = response["result"]["name"];
      address.placeId = placeId;
      address.latitude = response["result"]["geometry"]["location"]["lat"];
      address.longitude = response["result"]["geometry"]["location"]["lng"];

      //here i need to make request to nearest parking spot and return that as address along with other details
      double lat = address.latitude;
      double lng = address.longitude;

      showDialog(
          context: context,
          builder: (BuildContext context) => Center(child: CircularProgressIndicator(),)//ProgressDialog(message: "Setting Destination, Please Wait...",),
      );

      String parkingPlaceDetailsURL = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey"; //comment if not using bt on phone
      //String parkingPlaceDetailsURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&rankby=distance&type=parking&key=$mapKey"; //uncommnet for Canadian parkings
      var parking_response = await RequestAssistant.getRequest(parkingPlaceDetailsURL);

      Navigator.pop(context);

      if(parking_response == "failed"){
        return;
      }
      if(parking_response["status"] == "OK"){
        Address parking_address = Address();
        // parking_address.placeName = parking_response["results"][1]["name"];
        // parking_address.placeId = parking_response["results"][1]["place_id"];
        // parking_address.latitude = parking_response["results"][1]["geometry"]["location"]["lat"];
        // parking_address.longitude = parking_response["results"][1]["geometry"]["location"]["lng"];
        // //
        // // rating = parking_response["results"][1]["rating"];
        // // print("rating is ::");
        // // print(rating);
        //
        // parking_address.rating = parking_response["results"][1]["rating"];

        //next 4 lines for bt demo only
        parking_address.placeName = parking_response["result"]["name"];;
        parking_address.placeId = placeId;
        parking_address.latitude = parking_response["result"]["geometry"]["location"]["lat"];
        parking_address.longitude = parking_response["result"]["geometry"]["location"]["lng"];


        Provider.of<AppData>(context, listen: false).updatEndLocationAddress(parking_address);
        print("This is Parking Location ::");
        print(parking_address.placeName);

        Navigator.pop(context, "obtainDirection");
      }

    }
  }
}
