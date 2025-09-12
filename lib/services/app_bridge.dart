import 'package:flutter/services.dart';

class CurrentApp {
  static const MethodChannel _channel =
  MethodChannel('com.rishiwar.keybg/current_app');

  static Future<String?> getForegroundApp() async {
    try {
      final String? app = await _channel.invokeMethod('getCurrentApp');
      return app;
    } on PlatformException catch (e) {
      print("Error getting foreground app: ${e.message}");
      return null;
    }
  }
}
