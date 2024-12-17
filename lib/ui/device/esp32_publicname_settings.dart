import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../handlers/device_handler.dart';
import '../../models/public_name.dart';

class Esp32PublicNameSettings extends StatelessWidget {
  const Esp32PublicNameSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      Consumer2<DeviceHandler, PublicName>(
          builder: (context, handler, publicName, __) =>
              Esp32PublicNameInputWidget(
                  deviceHandler: handler, publicName: publicName));
}

class Esp32PublicNameInputWidget extends StatefulWidget {
  const Esp32PublicNameInputWidget(
      {required this.deviceHandler, required this.publicName, Key? key})
      : super(key: key);
  final DeviceHandler deviceHandler;
  final PublicName publicName;
  @override
  State<Esp32PublicNameInputWidget> createState() =>
      _Esp32PublicNameInputWidgetState();
}

class _Esp32PublicNameInputWidgetState extends State<Esp32PublicNameInputWidget> {
  TextEditingController publicNameController = TextEditingController();
  DateTime updateMustBeEarlier = DateTime.now();
  bool waitForAsyncCall = true;
  

  @override
  void initState() {
    updateMustBeEarlier = DateTime.now();
    publicNameController.text = "";
    super.initState();
  }

  @override
  void didUpdateWidget(Esp32PublicNameInputWidget oldWidget) {
    if (widget.publicName.timeStamp.isAfter(updateMustBeEarlier)) {
      updateMustBeEarlier = widget.publicName.timeStamp;
      waitForAsyncCall = false;
      publicNameController.text = widget.publicName.publicName;
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    publicNameController.text = "";
    super.dispose();
  }

  void onUpdate() {
    print("OnUpdate");
    updateMustBeEarlier = DateTime.now();
    waitForAsyncCall = true;
    widget.deviceHandler
        .updatePublicName(publicNameController.text);
  }

  void onCancel() {
    publicNameController.text = widget.publicName.publicName;
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Card(
      child: Column(children: [
        ListTile(
          leading: Icon(Icons.wifi),
          title: Text("Public Name for Homebridge"),
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
              : Column(
                  children: [
                    TextField(
                      controller: publicNameController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                    ),
                    
                  ],
                ),
        ),
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
    );
  }
}
