import 'package:flutter/cupertino.dart';
import 'package:parking_app/models/address.dart';
import 'package:provider/provider.dart';

class AppData extends ChangeNotifier{

  Address startLocation, endLocation;

  void updateStartLocationAddress(Address startPoint){
    startLocation = startPoint;
    notifyListeners(); //handle changes
  }

  void updatEndLocationAddress(Address endPoint){
    endLocation = endPoint;
    notifyListeners(); //handle changes
  }

}