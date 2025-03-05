import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screenshoot_Details.dart';

class ViewerScreen extends StatefulWidget {
  @override
  _ViewerScreenState createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  List<Map<String, String>> savedScreenshots = [];
  List<Map<String, String>> filteredScreenshots = [];
  Set<String> appNames = {};
  String selectedApp = "All";

  @override
  void initState() {
    super.initState();
    loadScreenshots();
  }

  /// Load Saved Screenshots from SharedPreferences
  void loadScreenshots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('screenshots') ?? [];

    List<Map<String, String>> tempScreenshots = [];
    Set<String> detectedAppNames = {};

    for (String item in savedData) {
      try {
        Map<String, dynamic> decoded = jsonDecode(item);
        String imagePath = decoded['imagePath']?.toString() ?? "";
        String appName = extractAppName(imagePath);

        if (appName.isNotEmpty) {
          detectedAppNames.add(appName);
        }

        tempScreenshots.add({
          'text': decoded['text']?.toString() ?? "No Note",
          'imagePath': imagePath,
          'timestamp': decoded['timestamp']?.toString() ?? "",
          'appName': appName,
        });
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }

    setState(() {
      savedScreenshots = tempScreenshots;
      filteredScreenshots = tempScreenshots;
      appNames = detectedAppNames;
    });
  }

  /// Extract app name from file name (e.g., Screenshot_20250305-194824.Instagram.png)
  String extractAppName(String imagePath) {
    try {
      String fileName = imagePath.split('/').last;
      if (fileName.contains('.')) {
        List<String> parts = fileName.split('.');
        if (parts.length >= 2) {
          return parts[1]; // Instagram in this example
        }
      }
    } catch (e) {
      print("Error extracting app name: $e");
    }
    return "Unknown";
  }

  /// Delete a screenshot
  void deleteScreenshot(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove from the saved list
    savedScreenshots.removeWhere((screenshot) => screenshot['imagePath'] == imagePath);

    // Update shared preferences
    List<String> updatedData = savedScreenshots.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('screenshots', updatedData);

    // Refresh filtered list
    filterScreenshots(selectedApp);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🗑️ Screenshot deleted!')),
    );
  }


  /// Filter screenshots by selected app
  void filterScreenshots(String appName) {
    setState(() {
      selectedApp = appName;
      if (appName == "All") {
        filteredScreenshots = List.from(savedScreenshots);
      } else {
        filteredScreenshots = savedScreenshots
            .where((screenshot) => screenshot['appName'] == appName)
            .toList();
      }
    });
  }

  /// Update notes
  void updateScreenshot(int index, String newText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedScreenshots[index]['text'] = newText;
    List<String> updatedData =
    savedScreenshots.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('screenshots', updatedData);

    filterScreenshots(selectedApp); // Refresh filtered list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Screenshots')),
      body: savedScreenshots.isEmpty
          ? Center(child: Text("No saved screenshots found!"))
          : Column(
        children: [
          // 🔹 App Name Chips
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: Text("All"),
                  selected: selectedApp == "All",
                  onSelected: (_) => filterScreenshots("All"),
                ),
                ...appNames.map((appName) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(appName),
                    selected: selectedApp == appName,
                    onSelected: (_) => filterScreenshots(appName),
                  ),
                )),
              ],
            ),
          ),

          // 🔹 Screenshots List
          Expanded(
            child: ListView.builder(
              itemCount: filteredScreenshots.length,
              itemBuilder: (context, index) {
                String imagePath =
                    filteredScreenshots[index]['imagePath'] ?? "";
                String text =
                    filteredScreenshots[index]['text'] ?? "No Note";
                String timestamp =
                    filteredScreenshots[index]['timestamp'] ?? "";

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenshotDetailScreen(
                            imagePath: imagePath,
                            text: text,
                            onTextUpdated: (newText) {
                              int originalIndex = savedScreenshots.indexWhere(
                                      (s) => s['imagePath'] == imagePath);
                              if (originalIndex != -1) {
                                updateScreenshot(originalIndex, newText);
                              }
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image Preview
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: imagePath.isNotEmpty &&
                                File(imagePath).existsSync()
                                ? ClipRRect(
                              borderRadius:
                              BorderRadius.circular(8.0),
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.contain,
                              ),
                            )
                                : Icon(Icons.image,
                                size: 40, color: Colors.grey),
                          ),
                          SizedBox(width: 10),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  timestamp,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Screenshot'),
                                  content: Text('Are you sure you want to delete this screenshot?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        deleteScreenshot(imagePath);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
