import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keybg/models/features.dart';
import 'package:keybg/services/dpc_service.dart';

class TestPageController extends GetxController {
  // Observable feature states
  final RxBool isUSBDebug = false.obs;
  final RxBool isCamera = false.obs;
  final RxBool isAppInstallation = false.obs;
  final RxBool isSoftReset = false.obs;
  final RxBool isSoftBoot = false.obs;
  final RxBool isHardReset = false.obs;
  final RxBool isOutgoingCalls = false.obs;
  final RxBool isSetting = false.obs;
  final RxBool warningAudio = false.obs;
  final RxBool warningWallpaper = false.obs;
  final RxBool isDeveloperOptions = false.obs;

  // Text controllers for input fields
  final passwordController = TextEditingController();
  final wallpaperUrlController = TextEditingController();
  final appsController = TextEditingController();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxString statusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values
    wallpaperUrlController.text = 'https://example.com/wallpaper.jpg';
    appsController.text = 'com.example.app1,com.example.app2';
  }

  @override
  void onClose() {
    passwordController.dispose();
    wallpaperUrlController.dispose();
    appsController.dispose();
    super.onClose();
  }

  // USB Debugging
  Future<void> toggleUSBDebug(bool value) async {
    isLoading.value = true;
    statusMessage.value = 'Updating USB Debugging...';

    try {
      final result = await DpcBridge.setUSBDebugging(value);
      if (result != null) {
        isUSBDebug.value = value;
        statusMessage.value =
            'USB Debugging ${value ? 'enabled' : 'disabled'} successfully';
      } else {
        statusMessage.value = 'Failed to update USB Debugging';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Camera
  Future<void> toggleCamera(bool value) async {
    isLoading.value = true;
    statusMessage.value = 'Updating Camera...';

    try {
      final result = await DpcBridge.setCamera(value);
      if (result != null) {
        isCamera.value = value;
        statusMessage.value =
            'Camera ${value ? 'enabled' : 'disabled'} successfully';
      } else {
        statusMessage.value = 'Failed to update Camera';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // App Installation
  Future<void> toggleAppInstallation(bool value) async {
    isLoading.value = true;
    statusMessage.value = 'Updating App Installation...';

    try {
      final result = await DpcBridge.setAppInstallation(value);
      if (result != null) {
        isAppInstallation.value = value;
        statusMessage.value =
            'App Installation ${value ? 'enabled' : 'disabled'} successfully';
      } else {
        statusMessage.value = 'Failed to update App Installation';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Developer Options
  Future<void> toggleDeveloperOptions(bool value) async {
    isLoading.value = true;
    statusMessage.value = 'Updating Developer Options...';

    try {
      final result = await DpcBridge.setDeveloperOptions(value);
      if (result != null) {
        isDeveloperOptions.value = value;
        statusMessage.value =
            'Developer Options ${value ? 'enabled' : 'disabled'} successfully';
      } else {
        statusMessage.value = 'Failed to update Developer Options';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Hard Reset
  Future<void> toggleHardReset(bool value) async {
    isLoading.value = true;
    statusMessage.value = 'Updating Hard Reset...';

    try {
      final result = await DpcBridge.setHardReset(value);
      if (result != null) {
        isHardReset.value = value;
        statusMessage.value =
            'Hard Reset ${value ? 'enabled' : 'disabled'} successfully';
      } else {
        statusMessage.value = 'Failed to update Hard Reset';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Soft Boot
  Future<void> toggleSoftBoot(bool value) async {
    isLoading.value = true;
    statusMessage.value = 'Updating Soft Boot...';

    try {
      final result = await DpcBridge.setSoftBoot(value);
      if (result != null) {
        isSoftBoot.value = value;
        statusMessage.value =
            'Soft Boot ${value ? 'enabled' : 'disabled'} successfully';
      } else {
        statusMessage.value = 'Failed to update Soft Boot';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Warning Audio
  Future<void> toggleWarningAudio(bool value) async {
    isLoading.value = true;
    statusMessage.value = 'Updating Warning Audio...';

    try {
      if (value) {
        final result = await DpcBridge.playWarningAudio();
        if (result != null) {
          warningAudio.value = value;
          statusMessage.value = 'Warning Audio played successfully';
        } else {
          statusMessage.value = 'Failed to play Warning Audio';
        }
      } else {
        warningAudio.value = value;
        statusMessage.value = 'Warning Audio disabled';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Set Wallpaper
  Future<void> setWallpaper() async {
    if (wallpaperUrlController.text.isEmpty) {
      statusMessage.value = 'Please enter a wallpaper URL';
      return;
    }

    isLoading.value = true;
    statusMessage.value = 'Setting Wallpaper...';

    try {
      final result = await DpcBridge.setWallpaper(wallpaperUrlController.text);
      if (result != null) {
        warningWallpaper.value = true;
        statusMessage.value = 'Wallpaper set successfully';
      } else {
        statusMessage.value = 'Failed to set Wallpaper';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Block Apps
  Future<void> blockApps() async {
    if (appsController.text.isEmpty) {
      statusMessage.value = 'Please enter app package names';
      return;
    }

    isLoading.value = true;
    statusMessage.value = 'Blocking Apps...';

    try {
      final apps = appsController.text.split(',').map((e) => e.trim()).toList();
      final result = await DpcBridge.blockApps(apps);
      if (result != null) {
        statusMessage.value = 'Apps blocked successfully';
      } else {
        statusMessage.value = 'Failed to block apps';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Set Password
  Future<void> setPassword() async {
    if (passwordController.text.isEmpty) {
      statusMessage.value = 'Please enter a password';
      return;
    }

    isLoading.value = true;
    statusMessage.value = 'Setting Password...';

    try {
      final result = await DpcBridge.setPassword(passwordController.text);
      if (result != null) {
        statusMessage.value = 'Password set successfully';
      } else {
        statusMessage.value = 'Failed to set password';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Lock Device
  Future<void> lockDevice() async {
    isLoading.value = true;
    statusMessage.value = 'Locking Device...';

    try {
      final result = await DpcBridge.lockDevice();
      if (result != null) {
        statusMessage.value = 'Device locked successfully';
      } else {
        statusMessage.value = 'Failed to lock device';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Factory Reset Controls
  Future<void> disableFactoryReset() async {
    isLoading.value = true;
    statusMessage.value = 'Disabling Factory Reset...';

    try {
      final result = await DpcBridge.disableFactoryReset();
      if (result != null) {
        statusMessage.value = 'Factory Reset disabled successfully';
      } else {
        statusMessage.value = 'Failed to disable Factory Reset';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enableFactoryReset() async {
    isLoading.value = true;
    statusMessage.value = 'Enabling Factory Reset...';

    try {
      final result = await DpcBridge.enableFactoryReset();
      if (result != null) {
        statusMessage.value = 'Factory Reset enabled successfully';
      } else {
        statusMessage.value = 'Failed to enable Factory Reset';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Clear status message
  void clearStatus() {
    statusMessage.value = '';
  }
}
