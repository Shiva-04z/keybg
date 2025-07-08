import 'package:flutter/services.dart';

class DpcBridge {
  static const MethodChannel _channel = MethodChannel('com.rishiwar.keybg/dpc');

  static Future<String?> lockDevice() async {
    try {
      return await _channel.invokeMethod('lockDevice');
    } catch (e) {
      print('Error locking device: $e');
      return null;
    }
  }

  static Future<String?> disableFactoryReset() async {
    try {
      return await _channel.invokeMethod('disableFactoryReset');
    } catch (e) {
      print('Error disabling factory reset: $e');
      return null;
    }
  }

  static Future<String?> enableFactoryReset() async {
    try {
      return await _channel.invokeMethod('enableFactoryReset');
    } catch (e) {
      print('Error enabling factory reset: $e');
      return null;
    }
  }

  static Future<String?> setUSBDebugging(bool enable) async {
    try {
      return await _channel.invokeMethod('setUSBDebugging', {'enable': enable});
    } catch (e) {
      print('Error setting USB debugging: $e');
      return null;
    }
  }

  static Future<String?> setCamera(bool enable) async {
    try {
      return await _channel.invokeMethod('setCamera', {'enable': enable});
    } catch (e) {
      print('Error setting camera state: $e');
      return null;
    }
  }

  static Future<String?> setAppInstallation(bool enable) async {
    try {
      return await _channel.invokeMethod('setAppInstallation', {'enable': enable});
    } catch (e) {
      print('Error setting app installation: $e');
      return null;
    }
  }

  static Future<String?> setDeveloperOptions(bool enable) async {
    try {
      return await _channel.invokeMethod('setDeveloperOptions', {'enable': enable});
    } catch (e) {
      print('Error setting developer options: $e');
      return null;
    }
  }

  static Future<String?> setHardReset(bool enable) async {
    try {
      return await _channel.invokeMethod('setHardReset', {'enable': enable});
    } catch (e) {
      print('Error setting hard reset: $e');
      return null;
    }
  }

  static Future<String?> setSoftBoot(bool enable) async {
    try {
      return await _channel.invokeMethod('setSoftBoot', {'enable': enable});
    } catch (e) {
      print('Error setting soft boot: $e');
      return null;
    }
  }

  static Future<String?> setWallpaper(String url) async {
    try {
      return await _channel.invokeMethod('setWallpaper', {'url': url});
    } catch (e) {
      print('Error setting wallpaper: $e');
      return null;
    }
  }

  static Future<String?> playWarningAudio() async {
    try {
      return await _channel.invokeMethod('playWarningAudio');
    } catch (e) {
      print('Error playing warning audio: $e');
      return null;
    }
  }

  static Future<String?> blockApps(List<String> packageNames) async {
    try {
      return await _channel.invokeMethod('blockApps', {'apps': packageNames});
    } catch (e) {
      print('Error blocking apps: $e');
      return null;
    }
  }

  static Future<String?> setPassword(String password) async {
    try {
      return await _channel.invokeMethod('setPassword', {'password': password});
    } catch (e) {
      print('Error setting password: $e');
      return null;
    }
  }

  // --- New Methods for calls control ---

  static Future<String?> disableIncomingCalls() async {
    try {
      return await _channel.invokeMethod('disableIncomingCalls');
    } catch (e) {
      print('Error disabling incoming calls: $e');
      return null;
    }
  }

  static Future<String?> enableIncomingCalls() async {
    try {
      return await _channel.invokeMethod('enableIncomingCalls');
    } catch (e) {
      print('Error enabling incoming calls: $e');
      return null;
    }
  }

  static Future<String?> disableOutgoingCalls() async {
    try {
      return await _channel.invokeMethod('disableOutgoingCalls');
    } catch (e) {
      print('Error disabling outgoing calls: $e');
      return null;
    }
  }

  static Future<String?> enableOutgoingCalls() async {
    try {
      return await _channel.invokeMethod('enableOutgoingCalls');
    } catch (e) {
      print('Error enabling outgoing calls: $e');
      return null;
    }
  }
}
