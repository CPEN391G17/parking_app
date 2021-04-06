import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:parking_app/resources/firebase_provider.dart';
import 'package:parking_app/models/bt_key.dart';

class UIPage extends StatefulWidget {
  final BluetoothDevice server;
  final bool start = true;

  const UIPage({this.server});

  @override
  _UIPage createState() => new _UIPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _UIPage extends State<UIPage> {
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;


  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = <_Message>[];
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  bool keyExchangeSuccessful = false;
  String onScreenMessage = "-";


  // _________________ ↓ DiscoveryPage.dart ______________________

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];
  bool isDiscovering;
  bool _autoAcceptPairingRequests = false;


  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            results.add(r);
          });
        });

    _streamSubscription.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }
  // _________________ ↑ DiscoveryPage.dart ______________________




  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });



    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }

    // ABOVE is code from DiscoveryPage.dart
    // BELOW is code from BT_settings_page.dart

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                    (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting to ' + widget.server.name + '...')
              : isConnected
              ? Text('User Identification with' + widget.server.name)
              : Text('User Identification log with ' + widget.server.name))),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            Container(
              margin: const EdgeInsets.only(left: 0.0),
              child: Text(onScreenMessage),
            ),
            Container(
              margin: const EdgeInsets.only(left: 0.0),
              child: Text("Press the button to send a key"),
            ),
            Container(
              margin: const EdgeInsets.only(left: 0.0),
              child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isConnected
                      ? () =>
                      //_sendKey()
                      _BackgroundUI()
                      : null),
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);

    // Added for filtering received data
    dataString.replaceAll(new RegExp(r"[^\s\w\r\n]"),'');
    dataString = dataString.trim();

    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }



  void _sendKey() async {

    // _________________ ↓ Chat Page.dart ______________________
    String key_str = "GeeXoX9Td2";
    BT_key key = BT_key();
    key.key = key_str.trim();
    key.initial_access_time = DateTime.now();

    bool wait = true;
    _firebaseProvider.SetKey(key.key);
    _firebaseProvider.SetKeyTime();
    //######################

    textEditingController.clear();

    if (key.key.length > 0) {
      try {
        connection.output.add(utf8.encode(";" + key.key + ";" + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, key.key));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });

        //#############################
        String uid = _firebaseProvider.getUID() as String;
        String pid = "ChIJDfytRslyhlQRjB7JJRA9fSo";
        String lastTenUID = uid.substring(uid.length - 10);

        String response = messages.last.text;
        int ans = _hash(lastTenUID, pid);
        print("hash = $ans , last message = $response \n");
        onScreenMessage = "hash = $ans , last message = $response \n";

        if(response == ";$ans;") {
          show("KEY EXCHANGE SUCCEEDED \n");
        } else {
          show("KEY EXCHANGE FAILED \n");
        }
        // _________________ ↑ Chat Page.dart ______________________


      } catch (e) {
        // Ignore error, but notify state
      }
    }
  }

  void _BackgroundUI() async {
    print("Started _BackgroundUI\n");
    List<BluetoothDiscoveryResult> candidates = <BluetoothDiscoveryResult>[];

    setState(() {
      _autoAcceptPairingRequests = true;
    });
    FlutterBluetoothSerial.instance.setPairingRequestHandler(
            (BluetoothPairingRequest request) {
          print("Trying to auto-pair with Pin 1234");
          if (request.pairingVariant == PairingVariant.Pin) {
            return Future.value("1234");
          }
          return null;
        });

    results.forEach((result) async {
      try {
        bool bonded = false;
        if (!result.device.isBonded && (result.device.name.contains("hc05") || result.device.name.contains("HC05"))) {
          print('Bonding with ${result.device.address}...');
          bonded = await FlutterBluetoothSerial.instance
              .bondDeviceAtAddress(result.device.address);
          print(
              'Bonding with ${result.device.address} has ${bonded ? 'succed' : 'failed'}.');
        }
        setState(() {
          results[results.indexOf(result)] = BluetoothDiscoveryResult(
              device: BluetoothDevice(
                name: result.device.name ?? '',
                address: result.device.address,
                type: result.device.type,
                bondState: bonded
                    ? BluetoothBondState.bonded
                    : BluetoothBondState.none,
              ),
              rssi: result.rssi);
        });

        // Add to successful candidates
        candidates.add(result);
      } catch (ex) {
        print('Error while connecting to discovered devices');
      }
    });

    for(int i=0; i<candidates.length; i++) {
      Navigator.of(context).pop(candidates[i].device);


      // _________________ ↓ UIPage.dart ______________________
      String keyStr = "GeeXoX9Td2";
      BT_key key = BT_key();
      key.key = keyStr.trim();
      key.initial_access_time = DateTime.now();

      bool wait = true;
      _firebaseProvider.SetKey(key.key);
      _firebaseProvider.SetKeyTime();
      //######################

      textEditingController.clear();

      if (key.key.length > 0) {
        try {
          connection.output.add(utf8.encode(";" + key.key + ";" + "\r\n"));
          await connection.output.allSent;

          setState(() {
            messages.add(_Message(clientID, key.key));
          });

          Future.delayed(Duration(milliseconds: 333)).then((_) {
            listScrollController.animateTo(
                listScrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 333),
                curve: Curves.easeOut);
          });

          //#############################
          String uid = _firebaseProvider.getUID() as String;
          String pid = "ChIJDfytRslyhlQRjB7JJRA9fSo";
          String lastTenUID = uid.substring(uid.length - 10);

          String response = messages.last.text;
          int ans = _hash(lastTenUID, pid);
          print("hash = $ans , last message = $response \n");

          if(response == (";" + ans.toString() + ";") ) {
            show("KEY EXCHANGE SUCCEEDED \n");
            // Break out of the loop to finish UI process
            break;
          } else {
            show("KEY EXCHANGE FAILED \n");
          }
          // _________________ ↑ UIPage.dart ______________________


        } catch (e) {
          // Ignore error, but notify state
          print('Failed to send the key to the paired device');
        }
      }
    }

  }

  int _hash(String key, String pid) {
    print("_hash : key = $key\n");
    print("_hash : pid = $key\n");

    var str = key + pid;
    ///*
    int hash = 0, i, chr, len;
    len = str.length;
    if (len == 0) return hash;

    for(int i = 0; i < len; i++) {
      chr   = str.codeUnitAt(i);
      hash  = ((hash << 5) - hash) + chr;
      hash |= 0; // Convert to 32bit integer
    }
    return hash;
    //*/
  }

  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  /*

  // Method to send message,
  // for turning the Bluetooth device on
  void _ConnectAndSendKey(String key) async {
    String key = "ThisIsBluetoothKey SET";

    bool wait = true;
    while (wait) {
      for (var device in _devicesList) {
        if(device.name.contains("HC-05")) {
          _device = device;
          wait = false;
        }
      }
    }

    while(!_connected) {
      _connect();
    }

    _firebaseProvider.SetKey(key);
    _firebaseProvider.SetKeyTime();

    wait = true;
    while(wait) {
      connection.output.add(utf8.encode(";" + key + ";"));
      await connection.output.allSent;
      show('Sent a key \'${key}\'');
      setState(() {
        _deviceState = 15; // device on
      });

      connection.output.add(utf8.encode(";" + key + ";"));
      await connection.output.allSent;
      show('Sent a key \'${key}\'');
      setState(() {
        _deviceState = 15; // device on
      });
    }

    /*
     * We need the app to pass the key to the RFS module
     * Then the RFS module needs to upload the received key to Firestore
     * Then the code below will check if the key on the cloud matches the key we sent.
     */

    BT_key bt_key = _firebaseProvider.GetKey() as BT_key;
    if(bt_key.key == key) {
      print("KEY EXCHANGE SUCCEEDED \n");
    } else {
      print("KEY EXCHANGE FAILED \n");
    }

  }
   */
}
