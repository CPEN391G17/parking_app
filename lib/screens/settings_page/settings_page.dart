import 'package:flutter/material.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/screens/settings_page/pages/bluetooth_settings_page.dart';
import 'package:parking_app/widgets/Divider.dart';
import 'package:parking_app/widgets/custom_tile.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FirebaseProvider _firebaseProvider = FirebaseProvider();

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _customListView(BuildContext context) {
    return ListView(
        children: <Widget>[
          Card (
            child: ListTile(
              leading: FlutterLogo(),
              title: Text('Bluetooth'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BluetoothPage()),
                );
              },
            ),
          ),

          Card (
            child: ListTile(
              leading: FlutterLogo(),
              title: Text('Other Settings'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print('Other Settings');
              },
            ),
          ),

          Card (
            child: ListTile(
                leading: FlutterLogo(),
                title: Text('Other Settings'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  print('Other Settings');
                },
            ),
          ),
        ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   title: Text("Map"),
      // ),
      appBar: AppBar(
        title: Text("Settings"),
      ),

      body: ListView(
            children: <Widget>[
              Card (
                child: ListTile(
                  leading: FlutterLogo(),
                  title: Text('Bluetooth'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BluetoothPage()),
                    );
                  },
                ),
              ),

              Card (
                child: ListTile(
                  leading: FlutterLogo(),
                  title: Text('Other Settings'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    print('Other Settings');
                  },
                ),
              ),

              Card (
                child: ListTile(
                  leading: FlutterLogo(),
                  title: Text('Other Settings'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    print('Other Settings');
                  },
                ),
              ),
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