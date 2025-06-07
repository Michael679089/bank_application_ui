import 'package:flutter/material.dart';
import 'pages/pin_setup_or_login_page.dart';

void main() { // Driver Function
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that the binding is initialized before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const PinSetupOrLoginPage(),
    );
  }
}
