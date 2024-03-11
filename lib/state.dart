
import 'package:esp32_managewifi_flutter/models/espdevice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ESPAppState extends ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();
  var devices = <EspDevice>[];
  var status = "Loading";
  ESPAppState() {
    print("GUGUS");
    flutterReactiveBle.statusStream.listen((bleStatus) {
      status = bleStatus.toString();
      print(bleStatus.toString());
      notifyListeners();
    });
    status = flutterReactiveBle.status.name;
  }
}