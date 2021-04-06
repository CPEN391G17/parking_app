import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BlueToothProvider {

  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  List<BluetoothDiscoveryResult> _results = <BluetoothDiscoveryResult>[];
  BluetoothConnection _connection;
  Uint8List _buffer;

  bool isDiscovering = true;
  void _startDiscovery() {
    _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery()
        .listen((r) {
      _results.add(r);
    });
    _streamSubscription.onDone(() {
      isDiscovering = false;
    });
  }


  void _endDiscovery() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();
  }

  void _sendMessage(String text) async {
    text = text.trim();
    if (text.length > 0) {
      try {
        _connection.output.add(utf8.encode(";" + text + ";" + "\r\n"));
        await _connection.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        print(e);
      }
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    _buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = _buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          _buffer[--bufferIndex] = data[i];
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

  // function that authenticates bluetooth
  Future<String> verifyBluetooth(String uid, String pid) async {
    String result = "";
    String address = "20:18:11:21:23:23";
    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(address);
      print('Connected to the device');

      String lastTenUID = uid.substring(uid.length - 10);
      print("Lets send the key over the connection\n");
      connection.output.add(utf8.encode(";" + lastTenUID + ";" + "\r\n"));
      await connection.output.allSent;

      // "3250604574"
      connection.input.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        //connection.output.add(data); // Sending data
        result += ascii.decode(data);
        if (ascii.decode(data).contains("@")) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }


      }).onDone(() {
        print('Disconnected by remote request');
        result = result.replaceAll(RegExp(r'[@;]'), '');
        print(result);
        return result;
      });
    } catch (exception) {
      print('Cannot connect, exception occured');
    }
    return result;
  }
}