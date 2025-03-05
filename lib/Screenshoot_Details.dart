import 'dart:io';
import 'package:flutter/material.dart';

class ScreenshotDetailScreen extends StatefulWidget {
  final String imagePath;
  final String text;
  final Function(String) onTextUpdated;

  ScreenshotDetailScreen({
    required this.imagePath,
    required this.text,
    required this.onTextUpdated,
  });

  @override
  _ScreenshotDetailScreenState createState() => _ScreenshotDetailScreenState();
}

class _ScreenshotDetailScreenState extends State<ScreenshotDetailScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void saveUpdatedText() {
    widget.onTextUpdated(_textController.text);
    Navigator.pop(context); // Return to ViewerScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screenshot Details")),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Full-Screen Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: widget.imagePath.isNotEmpty && File(widget.imagePath).existsSync()
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain, // Ensures full image is visible
                  ),
                )
                    : Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
              ),
            ),
            SizedBox(height: 20),

            // Editable Text Field
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: "Edit Text",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: saveUpdatedText,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
