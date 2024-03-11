import 'dart:async';

import 'package:esp32_managewifi_flutter/models/device_scan_status.dart';
import 'package:esp32_managewifi_flutter/models/espdevice.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceScanner {
  DeviceScanner({
    required FlutterReactiveBle ble,
  }) : _ble = ble;
  final FlutterReactiveBle _ble;
  final StreamController<DeviceScanStatus> _stateStreamController =
      StreamController();

  Stream<DeviceScanStatus> get state => _stateStreamController.stream;
  final _devices = <EspDevice>[];
  StreamSubscription? _subscription;

  void startScan(List<Uuid> serviceIds) {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
      var espDevice = EspDevice.fromDiscovery(device);
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == espDevice.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = espDevice;
      } else {
        _devices.add(espDevice);
      }
      _pushState();
    }, onError: (Object e) => print('Device scan fails with error: $e'));
    _pushState();
  }

  void _pushState() {
    _stateStreamController.add(
      DeviceScanStatus(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      ),
    );
  }

  Future<void> stopScan() async {
    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }
}
