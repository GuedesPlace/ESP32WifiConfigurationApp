import './config_element.dart';
class WifiCredential extends ConfigElement {
  WifiCredential({required this.ssid, required this.password});

  String ssid;
  String password;
  DateTime timeStamp = DateTime.now();
  factory WifiCredential.fromError(Object e) {
    var cred = WifiCredential(ssid: "", password: "");
    cred.error(e);
    return cred;
  }
  WifiCredential.fromJson(Map<String, dynamic> json)
      : ssid = json['ssid'],
        password = json['pw'];
  Map<String, dynamic> toJson() => {
        'ssid': ssid,
        'pw': password,
      };
}