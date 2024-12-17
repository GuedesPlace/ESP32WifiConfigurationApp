import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'ble_status_screen.dart';
import 'listview.dart';

class ESPConfigHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
        builder: (_, status, __) {
          if (status == BleStatus.ready) {
            return Esp32DeviceListScreen();
          } else {
            return StatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
