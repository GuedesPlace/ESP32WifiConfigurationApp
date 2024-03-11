import 'package:esp32_managewifi_flutter/models/device_handler.dart';
import 'package:esp32_managewifi_flutter/models/device_scan_status.dart';
import 'package:esp32_managewifi_flutter/models/device_scanner.dart';
import 'package:esp32_managewifi_flutter/models/espdevice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'device_detail_screen.dart';

//d01c3000-eb86-4576-a46d-3239440100da
class Esp32DeviceListScreen extends StatefulWidget {
  @override
  State<Esp32DeviceListScreen> createState() => _Esp32DeviceListScreenState();
}

class _Esp32DeviceListScreenState extends State<Esp32DeviceListScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool determinate = false;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.stop();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggleScan(DeviceScanStatus scanStatus, DeviceScanner scanner) {
    if (scanStatus.scanIsInProgress) {
      scanner.stopScan();
      controller
        ..value = 0
        ..stop();
    } else {
      scanner.startScan([Uuid.parse('d01c3000-eb86-4576-a46d-3239440100da')]);
      controller.repeat();
    }
  }

  void openDevice(
      BuildContext context, EspDevice device, DeviceScanner scanner, DeviceHandler handler) async {
    scanner.stopScan();
    handler.connect(device.id);
    controller
      ..value = 0
      ..stop();
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => Esp32DeviceDetailScreen(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      Consumer3<DeviceScanner, DeviceScanStatus, DeviceHandler>(
          builder: (_, scanner, scanStatus, deviceHandler, __) => Scaffold(
              appBar: AppBar(
                title: const Text('ESP32 Devices'),
                automaticallyImplyLeading: false,
                actions: [
                  ElevatedButton(
                    onPressed: () => toggleScan(scanStatus, scanner),
                    child: Text(scanStatus.scanIsInProgress ? "STOP" : "SCAN"),
                  )
                ],
              ),
              body: Column(children: [
                LinearProgressIndicator(
                  value: controller.value,
                  semanticsLabel: 'Device scanning',
                ),
                Text("${scanStatus.discoveredDevices.length} devices found."),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      ...scanStatus.discoveredDevices.map((device) => Card(
                          child: ListTile(
                              title: Text(device.title),
                              subtitle: Text(device.id),
                              leading: Icon(Icons.bluetooth_outlined),
                              onTap: () => openDevice(context, device, scanner, deviceHandler))))
                    ],
                  ),
                ))
              ])));
}
