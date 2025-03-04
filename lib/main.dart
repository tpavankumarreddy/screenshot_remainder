// main.dart (Handles both Server & Viewer Modes)
import 'package:flutter/material.dart';
import 'overlay_screen.dart'; // Overlay UI for adding screenshots
import 'viewer_screen.dart'; // UI for viewing saved screenshots

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ViewerScreen(), // Default opens saved screenshots
    );
  }
}
