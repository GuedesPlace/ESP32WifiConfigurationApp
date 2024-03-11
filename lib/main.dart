import 'package:esp32_managewifi_flutter/app.dart';
import 'package:esp32_managewifi_flutter/models/device_handler.dart';
import 'package:esp32_managewifi_flutter/models/device_scan_status.dart';
import 'package:esp32_managewifi_flutter/models/device_scanner.dart';
import 'package:esp32_managewifi_flutter/models/status_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

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
        initialData: PublicName(publicName: ''))
  ], child: ESP32WifConfiguationApp()));
}
