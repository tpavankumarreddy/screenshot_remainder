import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OverlayScreen extends StatefulWidget {
  @override
  _OverlayScreenState createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      screenshotController.capture().then((image) {
        if (image != null) {
          setState(() {});
        }
      });
    });
  }

  void saveScreenshot(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('screenshots') ?? [];
    savedData.add(jsonEncode({'text': text, 'timestamp': DateTime.now().toString()}));
    prefs.setStringList('screenshots', savedData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Screenshot(
                controller: screenshotController,
                child: Image.asset(
                  'assets/sample_screenshot.png',
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              TextField(
                controller: textController,
                decoration: InputDecoration(labelText: 'Add Notes'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => saveScreenshot(textController.text),
                    child: Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}