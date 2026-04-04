import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/command_types_page.dart';

void main() {
  runApp(const ProviderScope(child: CommandStrategiesApp()));
}

class CommandStrategiesApp extends StatelessWidget {
  const CommandStrategiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Command Types',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const CommandTypesPage(),
    );
  }
}
