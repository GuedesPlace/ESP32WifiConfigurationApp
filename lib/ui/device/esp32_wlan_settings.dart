import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/device_handler.dart';

class Esp32WLANSettings extends StatelessWidget {
  const Esp32WLANSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      Consumer2<DeviceHandler, WifiCredential>(
          builder: (context, handler, wifiCredential, __) =>
              WifiCredentialInputWidget(
                  deviceHandler: handler, credentials: wifiCredential));
}

class WifiCredentialInputWidget extends StatefulWidget {
  const WifiCredentialInputWidget(
      {required this.deviceHandler, required this.credentials, Key? key})
      : super(key: key);
  final DeviceHandler deviceHandler;
  final WifiCredential credentials;
  @override
  State<WifiCredentialInputWidget> createState() =>
      _WifiCredentialInputWidgetState();
}

class _WifiCredentialInputWidgetState extends State<WifiCredentialInputWidget> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController ssidController = TextEditingController();
  DateTime updateMustBeEarlier = DateTime.now();
  bool waitForAsyncCall = true;

  @override
  void initState() {
    updateMustBeEarlier = DateTime.now();
    passwordController.text = "";
    ssidController.text = "";
    super.initState();
  }

  @override
  void didUpdateWidget(WifiCredentialInputWidget oldWidget) {
    if (widget.credentials.timeStamp.isAfter(updateMustBeEarlier)) {
      updateMustBeEarlier = widget.credentials.timeStamp;
      waitForAsyncCall = false;
      passwordController.text = widget.credentials.password;
      ssidController.text = widget.credentials.ssid;
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    passwordController.text = "";
    ssidController.text = "";
    super.dispose();
  }

  void onUpdate() {
    print("OnUpdate");
    updateMustBeEarlier = DateTime.now();
    waitForAsyncCall = true;
    widget.deviceHandler
        .updateWifiCredentials(ssidController.text, passwordController.text);
  }

  void onCancel() {
    passwordController.text = widget.credentials.password;
    ssidController.text = widget.credentials.ssid;
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Card(
      child: Column(children: [
        ListTile(
          leading: Icon(Icons.wifi),
          title: Text("WLAN Settings"),
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
                      controller: ssidController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'SSID',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
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
