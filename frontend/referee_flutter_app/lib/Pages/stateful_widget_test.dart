import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    // Set the colors of the status bar and navigation bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue, // Change the color as needed
      systemNavigationBarColor: Colors.green, // Change the color as needed
      statusBarIconBrightness: Brightness.light, // Set the color of the status bar icons
      systemNavigationBarIconBrightness: Brightness.light, // Set the color of the navigation bar icons
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stateful Widget'),
      ),
      body: const Center(
        child: Text('This is a stateful widget.'),
      ),
    );
  }
}