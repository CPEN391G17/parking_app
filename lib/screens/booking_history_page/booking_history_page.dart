import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/DataHandler/appData.dart';
import 'package:parking_app/models/booking_history.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/widgets/coloredCard.dart';

class BookingHistoryPage extends StatefulWidget {
  @override
  _BookingHistoryPage createState() => _BookingHistoryPage();
}

class _BookingHistoryPage extends State<BookingHistoryPage> {

  bool _isLoading = false;
  bool _isInit = true;

  FirebaseProvider _firebaseProvider = new FirebaseProvider();
  List<BookingHistory> history;

  @override
  Future<void> didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await _firebaseProvider.getBookingHistory().then((value) {
        history = value;
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: const CircularProgressIndicator(backgroundColor: Colors.white,))
        : Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:Icon(Icons.arrow_back_ios, color: Colors.white, size: 25.0,),
          ),
          title: Text(
            "Booking History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 35.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF73AEF5),
          iconTheme: IconThemeData(
          color: Colors.black,
          ),
        ),
        body: Container(
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
                  child:ListView(
                    children: <Widget>[
                      ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: history.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          BookingHistory his = history[index];
                          return _card(his);
                         }
                        ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
      );
  }

  Widget _card(BookingHistory history) {
     return Column(
         children: [
           Container(
             child:Card(
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(15.0),
             ),
             clipBehavior: Clip.antiAlias,
             child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Text(
                 DateTime.parse(history.timeOfBooking.toString()).toString(),
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: Colors.blueAccent,
                   fontSize: 30.0,
                   fontWeight: FontWeight.bold,
                   fontFamily: 'OpenSans',
                 ),
               ),
                Text(
                     "location: " + history.location??"",
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     color: Colors.blueAccent,
                     fontSize: 20.0,
                     fontWeight: FontWeight.bold,
                     fontFamily: 'OpenSans',
                   ),
                 ),
               Text(
                 "duration: " + history.duration.toString() + " hours",
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: Colors.blueAccent,
                   fontSize: 20.0,
                   fontWeight: FontWeight.bold,
                   fontFamily: 'OpenSans',
                 ),
               ),
        ],
      ),
     ),
    ),
           SizedBox(height: 10,),
    ],
   );
  }

}