import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class EspDevice {
  String id;
  String title;
  EspDevice(this.id,this.title);
  factory EspDevice.fromDiscovery(DiscoveredDevice device) {
    var id = device.id;
    var title = device.name;
    return EspDevice(id, title);
  }
}