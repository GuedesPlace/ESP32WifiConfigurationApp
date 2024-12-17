import 'package:esp32_managewifi_flutter/models/esp32_properties.dart';

import 'app.dart';
import 'handlers/device_handler.dart';
import 'handlers/device_scanner.dart';
import 'models/ble_status_monitor.dart';
import 'models/device_scan_status.dart';
import 'models/public_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'models/device_data_status.dart';
import 'models/wifi_credential.dart';
import 'models/wifi_status.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ble = FlutterReactiveBle();
  final monitor = BleStatusMonitor(ble);
  final scanner = DeviceScanner(ble: ble);
  final handler = DeviceHandler(ble: ble);
  runApp(MultiProvider(providers: [
    Provider.value(value: scanner),
    Provider.value(value: handler),
    StreamProvider(
      create: (_) => monitor.state,
      initialData: BleStatus.unknown,
    ),
    StreamProvider(
        create: (_) => scanner.state,
        initialData:
            DeviceScanStatus(discoveredDevices: [], scanIsInProgress: false)),
    StreamProvider(
        create: (_) => handler.state,
        initialData: DeviceDataStatus(bleConnected: false)),
    StreamProvider(
        create: (_) => handler.wifiState,
        initialData: WifiStatus(connected: false, statusName: 'not initalized', )),
    StreamProvider(
        create: (_) => handler.wifiConfig,
        initialData: WifiCredential(ssid: "",password: "")),
    StreamProvider(
        create: (_) => handler.publicName,
        initialData: PublicName(publicName: '')),
    StreamProvider(
        create: (_) => handler.espProperties,
        initialData: Esp32Properties(properties: []))
  ], child: ESP32WifConfiguationApp()));
}
