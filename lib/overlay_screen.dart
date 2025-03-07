import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'viewer_screen.dart';
import 'package:path/path.dart' as path;

class OverlayScreen extends StatefulWidget {
  final String imagePath;

  const OverlayScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _OverlayScreenState createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController textController = TextEditingController();
  TextEditingController linkController = TextEditingController();

  bool isSaving = false;
  String latestScreenshotPath = "";

  @override
  void initState() {
    super.initState();
    _loadLatestScreenshot();
  }

  /// Load latest screenshot from the Screenshots folder
  Future<void> _loadLatestScreenshot() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Pictures/Screenshots');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null && await directory.exists()) {
        List<FileSystemEntity> files = directory.listSync();
        files.sort((a, b) =>
            b.statSync().modified.compareTo(a.statSync().modified));

        final latestFile = files.firstWhere(
                (file) => file.path.endsWith(".png") || file.path.endsWith(".jpg"),
            orElse: () => File(""));

        if (latestFile is File && await latestFile.exists()) {
          setState(() {
            latestScreenshotPath = latestFile.path;
          });
          print("✅ Latest screenshot loaded: $latestScreenshotPath");
        } else {
          print("⚠️ No screenshots found.");
        }
      }
    } catch (e) {
      print("❌ Error loading latest screenshot: $e");
    }
  }

  Future<void> saveScreenshot(String text, String link) async {
    if (isSaving) return;
    setState(() => isSaving = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('screenshots') ?? [];

    String imageToSave = widget.imagePath.isNotEmpty
        ? widget.imagePath
        : latestScreenshotPath;

    if (imageToSave.isEmpty || !File(imageToSave).existsSync()) {
      print("⚠️ ERROR: Invalid image path!");
      setState(() => isSaving = false);
      return;
    }

    Map<String, String> screenshotData = {
      'text': text.isNotEmpty ? text : "No Notes",
      'link': link.isNotEmpty ? link : "No Link",
      'imagePath': imageToSave,
      'timestamp': DateTime.now().toString(),
    };

    savedData.add(jsonEncode(screenshotData));
    await prefs.setStringList('screenshots', savedData);

    print("✅ Screenshot saved successfully!");
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    String displayImagePath =
    widget.imagePath.isNotEmpty ? widget.imagePath : latestScreenshotPath;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Material(
      color: Colors.black54, // Semi-transparent background
      child: Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20), // Moves content up when keyboard appears
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Screenshot Box
              Container(
                width: 220,
                height: 470,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: displayImagePath.isNotEmpty &&
                  File(displayImagePath).existsSync()
                  ? Image.file(File(displayImagePath), fit: BoxFit.contain)
                  : Center(
                child: Text(
                  "No Screenshot Available",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

              SizedBox(height: 16),

              // Notes & Actions Box
              Container(
                width: 280,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: textController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Add Notes',
                        labelStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: linkController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Add Link',
                        labelStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => exit(0),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => saveScreenshot(textController.text, linkController.text),
                          child: Text("Save"),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewerScreen()),
                        );
                      },
                      child: Text("View Saved Screenshots",
                          style:
                          TextStyle(color: Colors.blueAccent, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
