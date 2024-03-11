import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../models/device_handler.dart';

class WifiStatusWidget extends StatelessWidget {
  const WifiStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<WifiStatus>(
      builder: (context, wifiStatus, __) => Row(
            children: [Text("WIFI Status: ${wifiStatus.statusName}")],
          ));
}
