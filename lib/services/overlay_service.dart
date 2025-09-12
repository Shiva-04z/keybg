// In your controller or a separate service class
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static Future<void> showOverlay() async {
    try {
      // Check if permission is granted
      final hasPermission = await FlutterOverlayWindow.isPermissionGranted();

      if (!hasPermission) {
        // Request permission if not granted
        await FlutterOverlayWindow.requestPermission();
        return;
      }

      // Create and show the overlay
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true, // Allow the overlay to be dragged
        overlayTitle: "My App Overlay",
        overlayContent: "Your overlay is running",
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
     alignment: OverlayAlignment.center
      );
    } catch (e) {
      print("Error showing overlay: $e");
    }
  }

  static Future<void> closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  static Future<bool> isOverlayActive() async {
    return await FlutterOverlayWindow.isActive();
  }
}