import 'dart:async';
import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const serviceUUID = "d01c3000-eb86-4576-a46d-3239440100da";
const wifiStatusCharacteristicUUID = "d01c3001-eb86-4576-a46d-3239440100da";
const wifiDefinitionCharacteristicUUID = "d01c3002-eb86-4576-a46d-3239440100da";
const publicNameCharacteristicUUID = "d01c3003-eb86-4576-a46d-3239440100da";

class DeviceHandler {
  DeviceHandler({
    required FlutterReactiveBle ble,
  }) : _ble = ble;
  final FlutterReactiveBle _ble;
  final StreamController<DeviceDataStatus> _stateStreamController =
      StreamController();
  final StreamController<WifiStatus> _wifiStateStreamController =
      StreamController();
  final StreamController<WifiCredential> _wifiConfigStreamController =
      StreamController();
  final StreamController<PublicName> _publicNameStreamController =
      StreamController();

  Stream<DeviceDataStatus> get state => _stateStreamController.stream;
  Stream<WifiStatus> get wifiState => _wifiStateStreamController.stream;
  Stream<WifiCredential> get wifiConfig => _wifiConfigStreamController.stream;
  Stream<PublicName> get publicName => _publicNameStreamController.stream;
  QualifiedCharacteristic? _wifiStatusCharacteristic;
  QualifiedCharacteristic? _wifiConfigCharacteristic;
  QualifiedCharacteristic? _publicNameCharacteristic;

  late StreamSubscription<ConnectionStateUpdate> _connection;
  late StreamSubscription<List<int>> _characteristic;

  void connect(String deviceId) {
    _wifiStatusCharacteristic = null;
    _wifiConfigCharacteristic = null;
    _publicNameCharacteristic = null;
    _connection = _ble
        .connectToDevice(id: deviceId, servicesWithCharacteristicsToDiscover: {
      Uuid.parse(serviceUUID): [
        Uuid.parse(wifiStatusCharacteristicUUID),
        Uuid.parse(wifiDefinitionCharacteristicUUID),
        Uuid.parse(publicNameCharacteristicUUID),
      ]
    }).listen((event) {
      if (event.connectionState == DeviceConnectionState.connected) {
        print("Status: ${event.connectionState}");
        print(event);
        _stateStreamController.add(DeviceDataStatus(bleConnected: true));
        _wifiStatusCharacteristic = createWifiStatusCharacteristic(deviceId);
        _wifiConfigCharacteristic = createWifiConfigCharacteristic(deviceId);
        _publicNameCharacteristic = createPublicNameCharacteristic(deviceId);
      }
    });
    _connection.onError((e) => print('Error in Connection: ${e}'));
  }

  Future<void> disconnect(String deviceId) async {
    try {
      await _characteristic.cancel();
      print("CHAR UNSUB DONE");
      await _connection.cancel();
    } on Exception catch (e, _) {
      print("IN D EXEC");
      print(e);
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _stateStreamController.add(DeviceDataStatus(bleConnected: false));
    }
  }

  QualifiedCharacteristic createWifiStatusCharacteristic(String deviceId) {
    final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUUID),
        characteristicId: Uuid.parse(wifiStatusCharacteristicUUID),
        deviceId: deviceId);
    _characteristic =
        _ble.subscribeToCharacteristic(characteristic).listen((data) {
      var wifiStatus = String.fromCharCodes(data);
      _wifiStateStreamController.add(WifiStatus(
          connected: "connected" == wifiStatus, statusName: wifiStatus));
    }, onError: (dynamic error) {
      print("error during listening");
      print(characteristic);
      print(error);
    });
    _ble.readCharacteristic(characteristic).then((value) {
      var wifiStatus = String.fromCharCodes(value);
      _wifiStateStreamController.add(WifiStatus(
          connected: "connected" == wifiStatus, statusName: wifiStatus));
    });
    return characteristic;
  }

  QualifiedCharacteristic createWifiConfigCharacteristic(String deviceId) {
    final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUUID),
        characteristicId: Uuid.parse(wifiDefinitionCharacteristicUUID),
        deviceId: deviceId);
    _ble.readCharacteristic(characteristic).then((value) {
      var wifiConfig = String.fromCharCodes(value);
      var credentials = WifiCredential.fromJson(jsonDecode(wifiConfig));
      _wifiConfigStreamController.add(credentials);
    });
    return characteristic;
  }

  QualifiedCharacteristic createPublicNameCharacteristic(String deviceId) {
    final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUUID),
        characteristicId: Uuid.parse(publicNameCharacteristicUUID),
        deviceId: deviceId);
    _ble.readCharacteristic(characteristic).then((value) {
      var publicName = String.fromCharCodes(value);
      _publicNameStreamController.add(PublicName(publicName: publicName));
    });
    return characteristic;
  }

  void updatePublicName(String publicName) {
    if (_publicNameCharacteristic != null) {
      _ble
          .writeCharacteristicWithResponse(_publicNameCharacteristic!,
              value: publicName.codeUnits)
          .then((value) => {
                _ble
                    .readCharacteristic(_publicNameCharacteristic!)
                    .then((value) {
                  var publicName = String.fromCharCodes(value);
                  _publicNameStreamController
                      .add(PublicName(publicName: publicName));
                })
              });
    }
  }

  void updateWifiCredentials(String ssid, String password) {
    if (_wifiConfigCharacteristic != null) {
      var credentials =
          jsonEncode(WifiCredential(ssid: ssid, password: password).toJson());
      _ble
          .writeCharacteristicWithResponse(_wifiConfigCharacteristic!,
              value: credentials.codeUnits)
          .then((value) => {
                _ble
                    .readCharacteristic(_wifiConfigCharacteristic!)
                    .then((value) {
                  var wifiConfig = String.fromCharCodes(value);
                  var credentials =
                      WifiCredential.fromJson(jsonDecode(wifiConfig));
                  _wifiConfigStreamController.add(credentials);
                })
              });
    }
  }
}

class DeviceDataStatus {
  DeviceDataStatus({required this.bleConnected});

  final bool bleConnected;
}

class WifiCredential {
  WifiCredential({required this.ssid, required this.password});

  String ssid;
  String password;
  DateTime timeStamp = DateTime.now();
  WifiCredential.fromJson(Map<String, dynamic> json)
      : ssid = json['ssid'],
        password = json['pw'];
  Map<String, dynamic> toJson() => {
        'ssid': ssid,
        'pw': password,
      };
}

class WifiStatus {
  WifiStatus({required this.connected, required this.statusName});
  bool connected;
  String statusName;
  DateTime timeStamp = DateTime.now();
}

class PublicName {
  PublicName({required this.publicName});
  String publicName;
  DateTime timeStamp = DateTime.now();
}
