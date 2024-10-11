import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as fbs;
import 'dart:typed_data';

class BluetoothDevicePage extends StatefulWidget {
  final fb.BluetoothDevice device;

  BluetoothDevicePage({required this.device});

  @override
  _BluetoothDevicePageState createState() => _BluetoothDevicePageState();
}

class _BluetoothDevicePageState extends State<BluetoothDevicePage> {
  fbs.BluetoothConnection? connection;
  bool isConnecting = true;
  bool isConnected = false;
  String receivedData = '';

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  Future<void> connectToDevice() async {
    try {
      await widget.device.connect();
      setState(() {
        isConnected = true;
        isConnecting = false;
      });

      // Menghubungkan menggunakan BluetoothSerial
      fbs.BluetoothConnection.toAddress(widget.device.id.toString()).then((conn) {
        connection = conn;
        connection!.input!.listen((Uint8List data) {
          setState(() {
            receivedData = String.fromCharCodes(data);
          });
        });
      });
    } catch (e) {
      print("Connection failed: $e");
      setState(() {
        isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name.isNotEmpty
            ? widget.device.name
            : 'Unknown Device'),
      ),
      body: Center(
        child: isConnecting
            ? CircularProgressIndicator()
            : isConnected
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Connected to ${widget.device.name}"),
                      SizedBox(height: 20),
                      Text("Received Data: $receivedData"),
                      ElevatedButton(
                        onPressed: () {
                          connection?.close();
                          setState(() {
                            isConnected = false;
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Disconnect"),
                      )
                    ],
                  )
                : Text("Failed to connect"),
      ),
    );
  }
}
