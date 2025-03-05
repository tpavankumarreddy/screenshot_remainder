import 'dart:async';
import 'dart:io';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/material.dart';

class ScreenshotManager {
  static final ScreenshotManager _instance = ScreenshotManager._internal();
  factory ScreenshotManager() => _instance;

  ScreenshotManager._internal();

  Directory? _screenshotsDir;
  StreamSubscription<FileSystemEvent>? _subscription;

  /// Start watching the Screenshots directory for new screenshots.
  void startWatching() async {
    _screenshotsDir = await _getScreenshotsDirectory();
    if (_screenshotsDir == null) {
      print("❌ Screenshot directory not found.");
      return;
    }

    _subscription = _screenshotsDir!.watch(events: FileSystemEvent.create).listen(
          (event) async {
        final screenshotFile = File(event.path);

        // Ignore temporary or incomplete files
        if (!screenshotFile.existsSync() || event.path.contains(".pending")) return;

        print("🖼️ Screenshot detected: ${event.path}");

        // Wait briefly to ensure file is fully saved
        await Future.delayed(Duration(seconds: 1));

        if (await screenshotFile.exists()) {
          //await _showOverlay();
        }
      },
    );
  }

  /// Get the default screenshots directory (Android only).
  Future<Directory?> _getScreenshotsDirectory() async {
    if (Platform.isAndroid) {
      return Directory("/storage/emulated/0/Pictures/Screenshots/");
    }
    return null;
  }

  /// Show the overlay window with note-taking UI.
  Future<void> _showOverlay() async {
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      print("❌ Overlay permission not granted.");
      await FlutterOverlayWindow.requestPermission();
      if (!await FlutterOverlayWindow.isPermissionGranted()) {
        print("❌ Overlay permission denied after request.");
        return;
      }
    }

    if (await FlutterOverlayWindow.isActive()) {
      print("⚠️ Overlay already active, skipping.");
      return;
    }

    // await FlutterOverlayWindow.showOverlay(
    //   height: WindowSize.matchParent,
    //   width: WindowSize.matchParent,
    //   alignment: OverlayAlignment.center,
    //   flag: OverlayFlag.defaultFlag,
    //   visibility: NotificationVisibility.visibilityPrivate,
    //   enableDrag: true,
    //   overlayTitle: "Screenshot Note",
    //   overlayContent: "Add a note for your screenshot",
    // );

    print("✅ Overlay shown.");
  }

  /// Stop watching the screenshots directory.
  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
    print("🛑 Screenshot watching stopped.");
  }
}
