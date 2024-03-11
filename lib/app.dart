import 'package:flutter/material.dart';

import 'ui/home.dart';

class ESP32WifConfiguationApp extends StatelessWidget {
  //const ESP32WifConfiguationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Configuration App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 48, 123, 50)),
      ),
      home: ESPConfigHomePage(),
    );
  }
}
