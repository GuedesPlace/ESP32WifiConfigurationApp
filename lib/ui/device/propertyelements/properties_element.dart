import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PropertiesElement extends StatefulWidget {
  final String title;
  final String currentText;
  final Function(String) onTextChanged;
  const PropertiesElement(
      {super.key,
      required this.title,
      required this.currentText,
      required this.onTextChanged});
  @override
  State<StatefulWidget> createState() => _PropertiesElementState();
}

class _PropertiesElementState extends State<PropertiesElement> {
  final textController = TextEditingController();

  @override
  void initState() {
    textController.addListener(() => widget.onTextChanged(textController.text));
    textController.text = widget.currentText;
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PropertiesElement oldWidget) {
    if (widget.currentText != textController.text) {
      textController.text = widget.currentText;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        TextField(
          controller: textController,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: widget.title,
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ]);
}
