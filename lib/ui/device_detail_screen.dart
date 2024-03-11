import 'package:esp32_managewifi_flutter/models/device_handler.dart';
import 'package:esp32_managewifi_flutter/models/espdevice.dart';
import 'package:esp32_managewifi_flutter/ui/device/esp32_publicname_settings.dart';
import 'package:esp32_managewifi_flutter/ui/device/esp32_wlan_settings.dart';
import 'package:esp32_managewifi_flutter/ui/device/wifi_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
