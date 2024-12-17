import 'dart:convert';
import './config_element.dart';
class Esp32Properties extends ConfigElement {
  Esp32Properties({required this.properties});
  DateTime timeStamp = DateTime.now();
  List<Esp32PropertyElement> properties;
  
  factory Esp32Properties.fromJsonString(String propertiesString) {
    Iterable l = json.decode(propertiesString);
    var res = l.map((e)=>Esp32PropertyElement.fromJson(e));
    return Esp32Properties(properties:List<Esp32PropertyElement>.from(res));
  }
  List<Map<String,dynamic>> toJson() {
    return List.from(properties.map((e)=>e.toJson()));
  }

  factory Esp32Properties.fromError(Object e) {
    final prop = Esp32Properties(properties: []);
    prop.error(e);
    return prop;
  }
}

class Esp32PropertyElement {
  Esp32PropertyElement({required this.key, required this.label, required this.value});
  String key;
  String label;
  String value;
  Esp32PropertyElement.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        label = json['label'],
        value = json['value'];
  Map<String, dynamic> toJson() => {
        'key': key,
        'label':label,
        'value':value,
      };
}