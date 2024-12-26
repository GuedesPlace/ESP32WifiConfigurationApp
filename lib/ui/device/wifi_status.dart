import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../handlers/device_handler.dart';
import '../../models/wifi_status.dart';

class WifiStatusWidget extends StatelessWidget {
  const WifiStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<WifiStatus>(
      builder: (context, wifiStatus, __) => Column(
            children: [Text("WIFI Status: ${wifiStatus.statusName}")],
          ));
}
