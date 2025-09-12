import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:keybg/services/dpc_service.dart' as dpc;

class PermissionPageController extends GetxController {
  // Observable permission statuses
  var adminPermission = false.obs;
  var usageAccessPermission = false.obs;
  var batteryRestrictionBypass = false.obs;
  var displayOverOtherApps = false.obs;
  var notificationPermission = false.obs;
  var isCheckingPermissions = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    isCheckingPermissions.value = true;

    // Check each permission status
    await Future.wait([
      _checkAdminPermission(),
      _checkUsageAccessPermission(),
      _checkBatteryRestrictionBypass(),
      _checkDisplayOverOtherApps(),
      _checkNotificationPermission(),
    ]);

    isCheckingPermissions.value = false;
  }

  Future<void> _checkAdminPermission() async {
    // Device admin permissions require special handling
    // This is a placeholder - you'll need to implement device admin specifically
    bool isAdmin =   dpc.DpcBridge.isAdminActive() as bool;
    if(isAdmin)
      {
        await dpc.DpcBridge.activateAdmin();
      }
    adminPermission.value = false;
  }

  Future<void> _checkUsageAccessPermission() async {

      // Corrected request usage access
      final status = await AppUsage().getAppUsage(DateTime.now().subtract(Duration(hours: 1)), DateTime.now());





}

  Future<void> _checkBatteryRestrictionBypass() async {
    // Check if battery optimization is ignored
    final status = await Permission.ignoreBatteryOptimizations.status;
    batteryRestrictionBypass.value = status.isGranted;
  }

  Future<void> _checkDisplayOverOtherApps() async {
    // Check system alert window permission
    final status = await Permission.systemAlertWindow.status;
    displayOverOtherApps.value = status.isGranted;
  }

  Future<void> _checkNotificationPermission() async {
    // Check notification permission
    final status = await Permission.notification.status;
    notificationPermission.value = status.isGranted;
  }

  // Methods to request permissions
  Future<void> requestAdminPermission() async {
    try {
      // Device admin requires special setup with DevicePolicyManager
      // This would typically involve starting a new activity
      Get.snackbar('Info', 'Device admin permission requires manual setup in device settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to request admin permission: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> requestUsageAccess() async {
    try {
      final status = await Permission.accessMediaLocation.request();
      usageAccessPermission.value = status.isGranted;

      if (status.isGranted) {
        Get.snackbar('Success', 'Usage access granted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else if (status.isPermanentlyDenied) {
        // Open app settings
        await openAppSettings();
        Get.snackbar('Attention', 'Please enable usage access in settings',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request usage access: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> requestBatteryRestrictionBypass() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      batteryRestrictionBypass.value = status.isGranted;

      if (status.isGranted) {
        Get.snackbar('Success', 'Battery restriction bypass granted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else if (status.isPermanentlyDenied) {
        // Open app settings
        await openAppSettings();
        Get.snackbar('Attention', 'Please enable battery optimization bypass in settings',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request battery optimization: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> requestDisplayOverOtherApps() async {
    try {
      final status = await Permission.systemAlertWindow.request();
      displayOverOtherApps.value = status.isGranted;

      if (status.isGranted) {
        Get.snackbar('Success', 'Display over other apps granted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else if (status.isPermanentlyDenied) {
        // Open app settings
        await openAppSettings();
        Get.snackbar('Attention', 'Please enable display over other apps in settings',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request display permission: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      notificationPermission.value = status.isGranted;

      if (status.isGranted) {
        Get.snackbar('Success', 'Notification permission granted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else if (status.isPermanentlyDenied) {
        // Open app settings
        await openAppSettings();
        Get.snackbar('Attention', 'Please enable notifications in settings',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request notification permission: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // Helper method to open specific settings screens
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}