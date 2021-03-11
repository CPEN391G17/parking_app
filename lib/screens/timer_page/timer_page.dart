import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:parking_app/resources/firebase_provider.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  CountDownController _controller = CountDownController();
  int _duration = 3600;
  bool started = false;
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  String id = 'parKoin';


  // void delete_coins(){
  //   _firebaseProvider.addCoin(id, "-200");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Time"),
      ),
      body: Center(
          child: CircularCountDownTimer(
            // Countdown duration in Seconds.
            duration: _duration,

            // Countdown initial elapsed Duration in Seconds.
            initialDuration: 0,

            // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
            controller: _controller,

            // Width of the Countdown Widget.
            width: MediaQuery.of(context).size.width / 2,

            // Height of the Countdown Widget.
            height: MediaQuery.of(context).size.height / 2,

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
            textFormat: CountdownTextFormat.MM_SS,

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
                _firebaseProvider.addCoin(id, "-200");
                started = true;
              });
            },

            onComplete: (){
              setState(() {
                started = false;
              });
            },

          )),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
          ),

          // ElevatedButton(
          //   onPressed:  !started ? ()=> _controller.start() : null , // ? null : () =>_controller.start()
          //   child: Text('Pay 200 parKoins'),
          // ),
          _button(title: "Pay 200 Parkoin to Start", onPressed: !started ? ()=> _controller.start() : null), //() => _controller.start()

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
      ),
    );
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

}