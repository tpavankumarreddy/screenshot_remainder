import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot_remainder/viewer_screen.dart';
import 'ScreenShotManager.dart';
import 'screenshot_watcher.dart';
import 'overlay_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final _noScreenshot = NoScreenshot.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(MyApp());
}

Future<void> _initializeApp() async {
  await _requestPermissions();
  _startScreenshotWatcher();
  _listenForScreenshot();
}

Future<void> _requestPermissions() async {
  // Request overlay permission
  if (!await FlutterOverlayWindow.isPermissionGranted()) {
    await FlutterOverlayWindow.requestPermission();
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      print("❌ Overlay permission denied!");
      exit(0);
    }
  }

  // Request storage permissions
  if (!await Permission.manageExternalStorage.request().isGranted &&
      !await Permission.storage.request().isGranted) {
    print("❌ Storage permission denied!");
    exit(0);
  }

  print("✅ All permissions granted!");
}

void _listenForScreenshot() {
  _noScreenshot.screenshotStream.listen((value) {
    print("📸 Screenshot detected via no_screenshot");
    _openOverlay(value.screenshotPath);
  });
}

void _startScreenshotWatcher() {
  final watcher = ScreenshotWatcher();
  watcher.startWatching((String screenshotPath) async {
    if (screenshotPath.contains(".pending")) return;

    await Future.delayed(Duration(seconds: 1));

    if (await File(screenshotPath).exists()) {
      print("🖼️ Screenshot Detected: $screenshotPath");

      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }

      _openOverlay(screenshotPath);
    }
  });
}

// Future<void> _openOverlay(String imagePath) async {
//   print("🪟 Opening overlay with image: $imagePath");
//   print("df");
//   // OverlayDataHolder.imagePath = imagePath;
//   // await FlutterOverlayWindow.showOverlay(
//   //   enableDrag: true,
//   //   overlayTitle: "X-SLAYER",
//   //   overlayContent: 'Overlay Enabled',
//   //   flag: OverlayFlag.defaultFlag,
//   //   visibility: NotificationVisibility.visibilityPublic,
//   //   positionGravity: PositionGravity.auto,
//   //   height: WindowSize.matchParent,
//   //   width: WindowSize.matchParent,
//   //   startPosition: const OverlayPosition(0, -259),
//   // );
//
//
//
// }

Future<void> _openOverlay(String imagePath) async {
  print("🪟 Opening in-app overlay screen");
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => const OverlayScreen(imagePath: ""),
    ),
  );
}

class OverlayDataHolder {
  static String? imagePath;
}

@pragma('vm:entry-point')
void overlayEntryPoint() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayScreen(imagePath: '',),
    ),
  );
}


class MyApp extends StatelessWidget {
  final ScreenshotManager screenshotManager = ScreenshotManager();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      screenshotManager.startWatching();
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: OverlayScreen(imagePath: ""), // You can replace with a HomeScreen if needed
    );
  }
}
