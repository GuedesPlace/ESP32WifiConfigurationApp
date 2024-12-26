import 'package:esp32_managewifi_flutter/ui/device/propertyelements/properties_element.dart';
import 'package:flutter/material.dart';

import '../../../models/esp32_properties.dart';

class PropertiesContainerWidget extends StatelessWidget {
  final List<Esp32PropertyElement> properties;
  const PropertiesContainerWidget({super.key, required this.properties});
  @override
  Widget build(BuildContext context) => Column(
        children: List.from(this.properties.map((propertyElement) =>
            PropertiesElement(
                title: propertyElement.label,
                currentText: propertyElement.value,
                onTextChanged: (text) => propertyElement.value = text))),
      );
}
