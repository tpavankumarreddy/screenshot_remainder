import 'dart:io';
import 'package:flutter/material.dart';

class ScreenshotDetailScreen extends StatefulWidget {
  final String imagePath;
  final String text;
  final String link;
  final Function(String) onTextUpdated;
  final Function(String) onLinkUpdated;

  ScreenshotDetailScreen({
    required this.imagePath,
    required this.text,
    required this.onTextUpdated,
    required this.onLinkUpdated,
    required  this.link,
  });

  @override
  _ScreenshotDetailScreenState createState() => _ScreenshotDetailScreenState();
}

class _ScreenshotDetailScreenState extends State<ScreenshotDetailScreen> {
  late TextEditingController _textController;
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
    _linkController = TextEditingController(text: widget.link);
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void saveUpdatedTextAndLink() {
    widget.onTextUpdated(_textController.text);
    widget.onLinkUpdated(_linkController.text);
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

            // Editable Link Field
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: "Edit Link",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: saveUpdatedTextAndLink,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
