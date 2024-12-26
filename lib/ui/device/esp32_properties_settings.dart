import 'package:esp32_managewifi_flutter/ui/device/propertyelements/properties_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../handlers/device_handler.dart';
import '../../models/esp32_properties.dart';

class Esp32PropertiesSettings extends StatelessWidget {
  const Esp32PropertiesSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      Consumer2<DeviceHandler, Esp32Properties>(
          builder: (context, handler, esp32Properties, __) =>
              Esp32PropertiesSettingsInputWidget(
                  deviceHandler: handler, esp32Properties: esp32Properties));
}

class Esp32PropertiesSettingsInputWidget extends StatefulWidget {
  const Esp32PropertiesSettingsInputWidget(
      {required this.deviceHandler, required this.esp32Properties, Key? key})
      : super(key: key);
  final DeviceHandler deviceHandler;
  final Esp32Properties esp32Properties;
  @override
  State<Esp32PropertiesSettingsInputWidget> createState() =>
      _Esp32PropertiesSettingsInputWidgetState();
}

class _Esp32PropertiesSettingsInputWidgetState
    extends State<Esp32PropertiesSettingsInputWidget> {
  bool waitForAsyncCall = true;
  DateTime updateMustBeEarlier = DateTime.now();
  bool showCard = false;

  @override
  void initState() {
    updateMustBeEarlier = DateTime.now();
    super.initState();
  }

  @override
  void didUpdateWidget(Esp32PropertiesSettingsInputWidget oldWidget) {
    if (widget.esp32Properties.timeStamp.isAfter(updateMustBeEarlier)) {
      updateMustBeEarlier = widget.esp32Properties.timeStamp;
      showCard = widget.esp32Properties.available;
      waitForAsyncCall = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  void onUpdate() {
    updateMustBeEarlier = DateTime.now();
    waitForAsyncCall = true;
    widget.deviceHandler.updateProperies(widget.esp32Properties);
  }

  void onCancel() {
    updateMustBeEarlier = DateTime.now();
    waitForAsyncCall = true;
    widget.deviceHandler.readAndProcessPropertiesCharacteristic();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Visibility(
        visible: showCard,
        child: Card(
          child: Column(children: [
            ListTile(
              leading: Icon(Icons.wifi),
              title: Text("Custom Properties"),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: waitForAsyncCall
                    ? Column(
                        children: [
                          SizedBox(
                              child: LinearProgressIndicator(
                            backgroundColor: Colors.grey,
                            color: color,
                            minHeight: 10,
                          )),
                        ],
                      )
                    : PropertiesContainerWidget(
                        properties: widget.esp32Properties.properties,
                      )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => onCancel(), child: Text("Cancel")),
                SizedBox(
                  width: 8,
                ),
                TextButton(onPressed: () => onUpdate(), child: Text("Update")),
                SizedBox(
                  width: 8,
                )
              ],
            )
          ]),
        ));
  }
}
