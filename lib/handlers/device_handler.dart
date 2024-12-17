import 'dart:async';
import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../models/device_data_status.dart';
import '../models/esp32_properties.dart';
import '../models/public_name.dart';
import '../models/wifi_credential.dart';
import '../models/wifi_status.dart';

const serviceUUID = "d01c3000-eb86-4576-a46d-3239440100da";
const wifiStatusCharacteristicUUID = "d01c3001-eb86-4576-a46d-3239440100da";
const wifiDefinitionCharacteristicUUID = "d01c3002-eb86-4576-a46d-3239440100da";
const publicNameCharacteristicUUID = "d01c3003-eb86-4576-a46d-3239440100da";
const propertiesCharacteristicUUID = "d01c3004-eb86-4576-a46d-3239440100da";

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
  final StreamController<Esp32Properties> _propertiesStreamController =
      StreamController();

  Stream<DeviceDataStatus> get state => _stateStreamController.stream;
  Stream<WifiStatus> get wifiState => _wifiStateStreamController.stream;
  Stream<WifiCredential> get wifiConfig => _wifiConfigStreamController.stream;
  Stream<PublicName> get publicName => _publicNameStreamController.stream;
  Stream<Esp32Properties> get espProperties =>
      _propertiesStreamController.stream;
  QualifiedCharacteristic? _wifiStatusCharacteristic;
  QualifiedCharacteristic? _wifiConfigCharacteristic;
  QualifiedCharacteristic? _publicNameCharacteristic;
  QualifiedCharacteristic? _propertiesCharacteristic;

  late StreamSubscription<ConnectionStateUpdate> _connection;
  late StreamSubscription<List<int>> _characteristic;

  void connect(String deviceId) {
    _wifiStatusCharacteristic = null;
    _wifiConfigCharacteristic = null;
    _publicNameCharacteristic = null;
    _propertiesCharacteristic = null;
    _connection = _ble
        .connectToDevice(id: deviceId, servicesWithCharacteristicsToDiscover: {
      Uuid.parse(serviceUUID): [
        Uuid.parse(wifiStatusCharacteristicUUID),
        Uuid.parse(wifiDefinitionCharacteristicUUID),
        Uuid.parse(publicNameCharacteristicUUID),
        Uuid.parse(propertiesCharacteristicUUID)
      ]
    }).listen((event) async {
      if (event.connectionState == DeviceConnectionState.connected) {
        print("Status: ${event.connectionState}");
        print(event);
        _stateStreamController.add(DeviceDataStatus(bleConnected: true));
        _wifiStatusCharacteristic =
            createCharacteristic(deviceId, wifiStatusCharacteristicUUID);
        _wifiConfigCharacteristic =
            createCharacteristic(deviceId, wifiDefinitionCharacteristicUUID);
        _publicNameCharacteristic =
            createCharacteristic(deviceId, publicNameCharacteristicUUID);
        _propertiesCharacteristic =
            createCharacteristic(deviceId, propertiesCharacteristicUUID);
        await registerWifiStatusListener();
        await readAndProcessWifiConfigCharacteristic();
        await readAndProcessPublicNameCharacteristic();
        await readAndProcessPropertiesCharacteristic();
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

  QualifiedCharacteristic createCharacteristic(
      String deviceId, String characteristicUID) {
    return QualifiedCharacteristic(
        characteristicId: Uuid.parse(characteristicUID),
        serviceId: Uuid.parse(serviceUUID),
        deviceId: deviceId);
  }

  Future<void> registerWifiStatusListener() async {
    if (_wifiStatusCharacteristic != null) {
      _ble.subscribeToCharacteristic(_wifiStatusCharacteristic!).listen((data) {
        var wifiStatus = String.fromCharCodes(data);
        var wifiStatusObject = WifiStatus(
            connected: "connected" == wifiStatus, statusName: wifiStatus);
        wifiStatusObject.available = true;
        _wifiStateStreamController.add(wifiStatusObject);
      }, onError: (dynamic error) {
        print("error during listening");
        print(error);
      });
      try {
        final value = await _ble.readCharacteristic(_wifiStatusCharacteristic!);
        var wifiStatus = String.fromCharCodes(value);
        var wifiStatusObject = WifiStatus(
            connected: "connected" == wifiStatus, statusName: wifiStatus);
        wifiStatusObject.success();
        _wifiStateStreamController.add(wifiStatusObject);
      } catch (e) {
        _wifiStateStreamController.add(WifiStatus.fromError(e));
      }
    }
  }

  Future<void> readAndProcessWifiConfigCharacteristic() async {
    if (_wifiConfigCharacteristic != null) {
      try {
        final value = await _ble.readCharacteristic(_wifiConfigCharacteristic!);
        final wifiConfig = String.fromCharCodes(value);
        final credentials = WifiCredential.fromJson(jsonDecode(wifiConfig));
        credentials.success();
        _wifiConfigStreamController.add(credentials);
      } catch (e) {
        _wifiConfigStreamController.add(WifiCredential.fromError(e));
      }
    }
  }

  Future<void> readAndProcessPublicNameCharacteristic() async {
    if (_publicNameCharacteristic != null) {
      try {
      final value = await _ble.readCharacteristic(_publicNameCharacteristic!);
      var publicName = String.fromCharCodes(value);
      var pnObject = PublicName(publicName: publicName);
      pnObject.success();
      _publicNameStreamController.add(pnObject);
      } catch(e) {
        _publicNameStreamController.add(PublicName.fromError(e)); 
      }
    }
  }

  Future<void> readAndProcessPropertiesCharacteristic() async {
    if (_propertiesCharacteristic != null) {
      try {
      final value = await _ble.readCharacteristic(_propertiesCharacteristic!);
      var propertiesFromDevice = String.fromCharCodes(value);
      var propertiesObject =
          Esp32Properties.fromJsonString(propertiesFromDevice);
      propertiesObject.available = false;
      _propertiesStreamController.add(propertiesObject);
      } catch(e) {
        _propertiesStreamController.add(Esp32Properties.fromError(e));
        
      }
    }
  }

  Future<void> updatePublicName(String publicName) async {
    if (_publicNameCharacteristic != null) {
      await _ble.writeCharacteristicWithResponse(_publicNameCharacteristic!,
          value: publicName.codeUnits);
      await readAndProcessPublicNameCharacteristic();
    }
  }

  Future<void> updateWifiCredentials(String ssid, String password) async {
    if (_wifiConfigCharacteristic != null) {
      final credentials =
          jsonEncode(WifiCredential(ssid: ssid, password: password).toJson());
      await _ble.writeCharacteristicWithResponse(_wifiConfigCharacteristic!,
          value: credentials.codeUnits);
      await readAndProcessWifiConfigCharacteristic();
    }
  }

  Future<void> updateProperies(Esp32Properties espProperties) async {
    if (_propertiesCharacteristic != null) {
      final props = jsonEncode(espProperties.toJson());
      await _ble.writeCharacteristicWithResponse(_propertiesCharacteristic!,
          value: props.codeUnits);
      await readAndProcessPropertiesCharacteristic();
    }
  }
}
