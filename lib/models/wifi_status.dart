import './config_element.dart';

class WifiStatus extends ConfigElement{
  WifiStatus({required this.connected, required this.statusName});
  bool connected;
  String statusName;
  DateTime timeStamp = DateTime.now();
  factory WifiStatus.fromError(Object e) {
    final status = WifiStatus(connected: false, statusName: "system error");
    status.error(e);
    return status;
  }
}
