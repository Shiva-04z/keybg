import 'package:flutter/services.dart';

class DpcBridge {
  static const MethodChannel _channel = MethodChannel('com.rishiwar.keybg/dpc');

  static Future<void> lockDevice() async {
    try {
      await _channel.invokeMethod('lockDevice');
    } catch (e) {
      print('Error locking device: $e');
    }
  }

  static Future<void> disableFactoryReset() async {
    try {
      await _channel.invokeMethod('disableFactoryReset');
    } catch (e) {
      print('Error disabling factory reset: $e');
    }
  }

// Add more methods as needed...
}
