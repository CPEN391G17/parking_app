import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:parking_app/Bluetooth/DiscoveryPage.dart';
import 'package:parking_app/Bluetooth/SelectBondedDevicePage.dart';
import 'package:parking_app/Bluetooth/ChatPage.dart';
import 'package:parking_app/Bluetooth/UIPage.dart';
import 'package:parking_app/Bluetooth/BackgroundCollectingTask.dart';
import 'package:parking_app/Bluetooth/BackgroundCollectedPage.dart';

import 'package:parking_app/models/bt_key.dart';
import 'package:parking_app/resources/firebase_provider.dart';

// import './helpers/LineChart.dart';

class BluetoothPage extends StatefulWidget {
  final bool start = true;


  @override
  _BluetoothPageState createState() => new _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;


  // _________________ ↓ UIPage.dart ______________________
    FirebaseProvider _firebaseProvider = FirebaseProvider();
    // Initializing a global key, as it would help us in showing a SnackBar later
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


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
  // _________________ ↑ Chat UIPage.dart ______________________

  // _________________ ↓ DiscoveryPage.dart ______________________

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];
  bool isDiscovering;

  @override
  void initState() {
    super.initState();



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
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();

    //For UIPage code
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            ListTile(title: const Text('General')),
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Bluetooth status'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Local adapter address'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Local adapter name'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            ListTile(
              title: _discoverableTimeoutSecondsLeft == 0
                  ? const Text("Discoverable")
                  : Text(
                  "Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
              subtitle: const Text("PsychoX-Luna"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _discoverableTimeoutSecondsLeft != 0,
                    onChanged: null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      print('Discoverable requested');
                      final int timeout = await FlutterBluetoothSerial.instance
                          .requestDiscoverable(60);
                      if (timeout < 0) {
                        print('Discoverable mode denied');
                      } else {
                        print(
                            'Discoverable mode acquired for $timeout seconds');
                      }
                      setState(() {
                        _discoverableTimeoutTimer?.cancel();
                        _discoverableTimeoutSecondsLeft = timeout;
                        _discoverableTimeoutTimer =
                            Timer.periodic(Duration(seconds: 1), (Timer timer) {
                              setState(() {
                                if (_discoverableTimeoutSecondsLeft < 0) {
                                  FlutterBluetoothSerial.instance.isDiscoverable
                                      .then((isDiscoverable) {
                                    if (isDiscoverable) {
                                      print(
                                          "Discoverable after timeout... might be infinity timeout :F");
                                      _discoverableTimeoutSecondsLeft += 1;
                                    }
                                  });
                                  timer.cancel();
                                  _discoverableTimeoutSecondsLeft = 0;
                                } else {
                                  _discoverableTimeoutSecondsLeft -= 1;
                                }
                              });
                            });
                      });
                    },
                  )
                ],
              ),
            ),
            Divider(),
            ListTile(title: const Text('Devices discovery and connection')),
            SwitchListTile(
              title: const Text('Auto-try specific pin when pairing'),
              subtitle: const Text('Pin 1234'),
              value: _autoAcceptPairingRequests,
              onChanged: (bool value) {
                setState(() {
                  _autoAcceptPairingRequests = value;
                });
                if (value) {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler(
                          (BluetoothPairingRequest request) {
                        print("Trying to auto-pair with Pin 1234");
                        if (request.pairingVariant == PairingVariant.Pin) {
                          return Future.value("1234");
                        }
                        return null;
                      });
                } else {
                  FlutterBluetoothSerial.instance
                      .setPairingRequestHandler(null);
                }
              },
            ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Explore discovered devices'),
                  onPressed: () async {
                    final BluetoothDevice selectedDevice =
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DiscoveryPage();
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Discovery -> selected ' + selectedDevice.address);
                    } else {
                      print('Discovery -> no device selected');
                    }
                  }),
            ),
            ListTile(
              title: ElevatedButton(
                child: const Text('Connect to paired device to chat'),
                onPressed: () async {
                  final BluetoothDevice selectedDevice =
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    print('Connect -> selected ' + selectedDevice.address);
                    _startChat(context, selectedDevice);
                  } else {
                    print('Connect -> no device selected');
                  }
                },
              ),
            ),



            ListTile(
              title: ElevatedButton(
                child: const Text('Send a key for user identification'),
                onPressed: () async {
                  _BackgroundUI();
                },
              ),
            ),


            Divider(),
            ListTile(title: const Text('Multiple connections example')),
            ListTile(
              title: ElevatedButton(
                child: ((_collectingTask != null && _collectingTask.inProgress)
                    ? const Text('Disconnect and stop background collecting')
                    : const Text('Connect to start background collecting')),
                onPressed: () async {
                  if (_collectingTask != null && _collectingTask.inProgress) {
                    await _collectingTask.cancel();
                    setState(() {
                      /* Update for `_collectingTask.inProgress` */
                    });
                  } else {
                    final BluetoothDevice selectedDevice =
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      await _startBackgroundTask(context, selectedDevice);
                      setState(() {
                        /* Update for `_collectingTask.inProgress` */
                      });
                    }
                  }
                },
              ),
            ),
            ListTile(
              title: ElevatedButton(
                child: const Text('View background collected data'),
                onPressed: (_collectingTask != null)
                    ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ScopedModel<BackgroundCollectingTask>(
                          model: _collectingTask,
                          child: BackgroundCollectedPage(),
                        );
                      },
                    ),
                  );
                }
                    : null,
              ),
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

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }

  void _startUI(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return UIPage(server: server);
        },
      ),
    );
  }

  Future<void> _startBackgroundTask(
      BuildContext context,
      BluetoothDevice server,
      ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask.start();
    } catch (ex) {
      if (_collectingTask != null) {
        _collectingTask.cancel();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }


  void _BackgroundUI() async {
    print("Started _BackgroundUI\n");
    List<BluetoothDiscoveryResult> candidates = <BluetoothDiscoveryResult>[];
    candidates.clear();

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
      print("result = " + result.toString() + "\n");
      if(result.device.name != null) {
        try {
          bool bonded = false;
          if (!result.device.isBonded && (result.device.name.contains("hc05") || result.device.name.contains("HC05"))) {
            print("Found device with name : " + result.device.name + "\n");

            print('Bonding with ${result.device.address}...');
            bonded = await FlutterBluetoothSerial.instance
                .bondDeviceAtAddress(result.device.address);
            print(
                'Bonding with ${result.device.address} has ${bonded ? 'succeeded' : 'failed'}.');

            // Add to successful candidates
            print("Add to Candidates list\n");
            candidates.add(result);
          } else if ((result.device.name.contains("hc05") || result.device.name.contains("HC05"))) {
            print("Add to Candidates list\n");
            candidates.add(result);
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
        } catch (ex) {
          print("Error while connecting to discovered devices\n");
          print("ex = " + ex.toString() + "\n");
        }


      }
    });

    for(int i=0; i<candidates.length; i++) {
      print("Connect to the list of candidates\n");
      print(candidates.toString());

      // _________________ ↓ UIPage.dart initState() ______________________
      BluetoothConnection.toAddress(candidates[i].device.address).then((_connection) {
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

      // _________________ ↑ UIPage.dart initState()______________________

      // I need a way to safely disconnect and reconnect with other devices in the candidates list.

      //This is wrong
      //Navigator.of(context).pop(candidates[i].device);
      //print("is connected  = " + connection.isConnected.toString() + " \n");

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
          print("Lets send the key over the connection\n");
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
          print("hash = " + ans.toString() + "last message = " + response + "\n");

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
          print("Failed to send the key to the paired device\n");
          print("ex = " + e.toString() + "\n");
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
}


class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
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