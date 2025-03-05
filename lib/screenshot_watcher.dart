import 'dart:async';
import 'dart:io';

class ScreenshotWatcher {
  Directory? _screenshotsDir;
  StreamSubscription<FileSystemEvent>? _subscription;

  /// Starts watching the screenshots folder.
  Future<void> startWatching(Function(String) onScreenshot) async {
    _screenshotsDir = await _getScreenshotsDirectory();
    if (_screenshotsDir == null) {
      print("❌ Screenshots directory not found.");
      return;
    }

    _subscription = _screenshotsDir!.watch(events: FileSystemEvent.create).listen(
          (event) async {
        print("📂 Screenshot Event: ${event.path}");

        // Ignore temporary or incomplete files
        if (event.path.contains(".pending")) {
          print("⚠️ Temporary screenshot detected. Waiting for completion...");

          await Future.delayed(Duration(seconds: 2));
          String finalPath = _getFinalPath(event.path);

          if (File(finalPath).existsSync()) {
            print("🖼️ Screenshot Ready: $finalPath");
            onScreenshot(finalPath);
          } else {
            print("🚨 Finalized screenshot not found: $finalPath");
          }
          return;
        }

        // If a complete screenshot is detected
        if (File(event.path).existsSync()) {
          print("🖼️ Screenshot Detected: ${event.path}");
          onScreenshot(event.path);
        }
      },
    );

    print("✅ Screenshot watching started.");
  }

  /// Get the default Android screenshots directory.
  Future<Directory?> _getScreenshotsDirectory() async {
    if (Platform.isAndroid) {
      return Directory("/storage/emulated/0/Pictures/Screenshots/");
    }
    return null;
  }

  /// Clean up ".pending" filenames to get the final file path.
  String _getFinalPath(String pendingPath) {
    return pendingPath.replaceFirst(RegExp(r'\.pending-\d+-'), '');
  }

  /// Stops watching the screenshots folder.
  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
    print("🛑 Screenshot watching stopped.");
  }
}
