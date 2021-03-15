import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/DataHandler/appData.dart';
import 'package:parking_app/assistant/requestAssistant.dart';
import 'package:parking_app/configMaps.dart';
import 'package:parking_app/models/address.dart';
import 'package:parking_app/models/directionDetails.dart';
import 'package:provider/provider.dart';

class AssistantMethods{

  //perform Geocoding req
  static Future<String> searchCoordinateAddress(Position position, context) async{
    String placeAddress = "";
    String st1,st2,st3,st4;
    String url  = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey"; //&sensor=true

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed"){

      placeAddress = response["results"][0]["formatted_address"];
      // st1 = response["results"][0]["address_components"][3]["long_name"]; //[0]house num
      // st2 = response["results"][0]["address_components"][4]["long_name"];
      // st3 = response["results"][0]["address_components"][5]["long_name"];
      // st4 = response["results"][0]["address_components"][6]["long_name"];
      // placeAddress = st1+ ", " + st2 + ", " + st3 + ", " + st4;

      Address userStartPoint = new Address();
      userStartPoint.longitude = position.longitude;
      userStartPoint.latitude= position.latitude;
      userStartPoint.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updateStartLocationAddress(userStartPoint);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionsDetails(LatLng initialPosition, LatLng finalPosition) async {
    String directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(directionURL);

    if (response == "failed"){
      return null;
    }

    DirectionDetails directiondetails = DirectionDetails();

    directiondetails.encodedPoints = response["routes"][0]["overview_polyline"]["points"];
    directiondetails.distanceText = response["routes"][0]["legs"][0]["distance"]["text"];
    directiondetails.distanceValue = response["routes"][0]["legs"][0]["distance"]["value"];
    directiondetails.durationText = response["routes"][0]["legs"][0]["duration"]["text"];
    directiondetails.durationValue = response["routes"][0]["legs"][0]["duration"]["value"];

    return directiondetails;
  }

  static double calculateFares(DirectionDetails directiondetails){
    //USD
    double parkingFare = (directiondetails.durationValue/60)*0.20;
    double distanceFare = (directiondetails.distanceValue/1000)*0.20;
    double totalFare = parkingFare + distanceFare; //can be changed later on right now just testing
    //$1 = $1.25
    double total  = (totalFare*1.25);
    return 200+total;
  }

}