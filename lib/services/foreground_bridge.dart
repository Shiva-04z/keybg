import 'package:flutter/services.dart';

class ForegroundServiceBridge {
  static const MethodChannel _channel = MethodChannel('com.rishiwar.keybg/foreground');

  static Future<void> startService() async {
    try {
      await _channel.invokeMethod('startService');
    } catch (e) {
      print('Error starting service: $e');
    }
  }

  static Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
    } catch (e) {
      print('Error stopping service: $e');
    }
  }
}
