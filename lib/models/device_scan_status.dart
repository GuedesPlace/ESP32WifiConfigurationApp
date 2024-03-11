import 'package:esp32_managewifi_flutter/models/espdevice.dart';

class DeviceScanStatus {
  DeviceScanStatus(
      {required this.discoveredDevices, required this.scanIsInProgress});
  final List<EspDevice> discoveredDevices;
  final bool scanIsInProgress;
}
