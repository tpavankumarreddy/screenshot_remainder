import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ViewerScreen extends StatefulWidget {
  @override
  _ViewerScreenState createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  List<Map<String, String>> savedScreenshots = [];

  @override
  void initState() {
    super.initState();
    loadScreenshots();
  }

  void loadScreenshots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('screenshots') ?? [];
    setState(() {
      savedScreenshots = savedData.map((item) => jsonDecode(item)).cast<Map<String, String>>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Screenshots')),
      body: ListView.builder(
        itemCount: savedScreenshots.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(savedScreenshots[index]['text'] ?? "No Note"),
              subtitle: Text(savedScreenshots[index]['timestamp'] ?? ""),
            ),
          );
        },
      ),
    );
  }
}