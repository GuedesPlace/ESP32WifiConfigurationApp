import './config_element.dart';

class PublicName extends ConfigElement {
  PublicName({required this.publicName});
  String publicName;
  DateTime timeStamp = DateTime.now();

  factory PublicName.fromError(Object e) {
    final pn = PublicName(publicName: '');
    pn.error(e);
    return pn;
  }
}
