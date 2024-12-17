import 'esp_device.dart';

class DeviceScanStatus {
  DeviceScanStatus(
      {required this.discoveredDevices, required this.scanIsInProgress});
  final List<EspDevice> discoveredDevices;
  final bool scanIsInProgress;
}
