import '../handlers/device_handler.dart';
import '../models/esp_device.dart';
import 'device/esp32_publicname_settings.dart';
import 'device/esp32_wlan_settings.dart';
import 'device/wifi_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device_data_status.dart';

class Esp32DeviceDetailScreen extends StatelessWidget {
  final EspDevice device;

  const Esp32DeviceDetailScreen({required this.device, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Consumer2<DeviceHandler, DeviceDataStatus>(
          builder: (context, handler, dataStatus, __) => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    handler.disconnect(device.id);
                    Navigator.pop(context);
                  },
                ),
                title: const Text('ESP32 Device'),
                automaticallyImplyLeading: false,
                actions: [],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                    child: Column(children: [
                  Text(
                      "${device.title}: ${dataStatus.bleConnected ? "BLE connected" : "BLE not connected"}"),
                  WifiStatusWidget(),
                  Esp32WLANSettings(),
                  Esp32PublicNameSettings()
                ])),
              )));
}
