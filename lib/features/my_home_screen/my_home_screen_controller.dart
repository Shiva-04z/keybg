import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:keybg/services/dpc_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/globals.dart' as glb;
import '../../models/cached_app_info.dart';
import '../../naviagtion/RoutesConstant.dart';


class QuickAccessItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  QuickAccessItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class MyHomeScreenController extends GetxController with GetSingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.rishiwar.keybg/launcher');
  final Box _settingsBox = Hive.box('settings');
  final Box<CachedAppInfo> _appsBox = Hive.box<CachedAppInfo>('apps');
  // Existing properties
  RxString userId = "".obs;

  // New home screen properties
  final wallpaperPath = ''.obs;
  final currentTime = ''.obs;
  final currentDate = ''.obs;
  final quickAccessItems = <QuickAccessItem>[].obs;
  Timer? _clockTimer;

  @override
  void onInit() async {
    super.onInit();
    // askForDeviceAdmin();
    askToSetDefaultLauncher();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _getUserId();
    await loadWallpaper();
    _initializeHomeScreen();
  }

  Future<int> _loadAppsFromHive() async {
    final cachedApps = _appsBox.values.toList();
    glb.apps.assignAll(
      cachedApps.map((cachedApp) {
        return AppInfo(
          name: cachedApp.name,
          icon: cachedApp.icon,
          packageName: cachedApp.packageName,
          versionName: cachedApp.versionName ?? '',
          versionCode: cachedApp.versionCode?? 0,
          builtWith: BuiltWith.values[cachedApp.builtWith],
          installedTimestamp: cachedApp.installedTimestamp?? 0,
        );
      }).toList(),
    );
    return cachedApps.length;
  }


  Future<void> loadInstalledApps() async {
    final dbCount = await _loadAppsFromHive();
    if (dbCount == 0) {
    }

    try {
      final installedApps = await InstalledApps.getInstalledApps(false, true, '');

      final essentialPackages = {
        'com.android.chrome',
        'com.google.android.googlequicksearchbox',
        'com.google.android.gm',
        'com.google.android.apps.maps',
        'com.google.android.youtube',
        'com.android.settings',
        'com.android.vending',
        'com.google.android.gms',
        'com.android.phone',
        'com.mi.android.globalFileexplorer',
        'com.google.android.dialer',
        'com.miui.gallery'
            'com.android.mms',
        'com.google.android.apps.messaging',
        'com.google.android.contacts',
      };

      final Map<String, CachedAppInfo> appsToCache = {};
      for (var app in installedApps) {
        if (glb.excludedApps.contains(app.packageName)) continue;

        final isSystem = await InstalledApps.isSystemApp(app.packageName) ?? true;
        if (!isSystem || essentialPackages.contains(app.packageName)) {
          appsToCache[app.packageName] = CachedAppInfo()
            ..name = app.name
            ..packageName = app.packageName
            ..versionName = app.versionName
            ..versionCode = app.versionCode
            ..icon = app.icon
            ..builtWith = app.builtWith.index
            ..installedTimestamp = app.installedTimestamp;
        }
      }

      // ✅ Use Hive's clear and putAll for batch writing
      await _appsBox.clear();
      await _appsBox.putAll(appsToCache);

      await _loadAppsFromHive();
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh app list: $e');
    } finally {

    }
  }
  @override
  Future<void> onReady() async {
    // TODO: implement onReady
    super.onReady();
    await loadWallpaper();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }

  Future<void> askToSetDefaultLauncher() async {
    try {
      final isDefault = await platform.invokeMethod('checkDefaultLauncher');
      final prefs = await SharedPreferences.getInstance();
      final alreadyAsked = prefs.getBool('askedLauncher') ?? false;
      if (!alreadyAsked) {
        if (!isDefault) {
          Get.defaultDialog(
            title: "Set as Default Launcher",
            content: Text("For best experience, set KeyBG as your default launcher"),
            confirm: TextButton(
              child: Text("Set Now"),
              onPressed: () async {
                await platform.invokeMethod('openLauncherSettings');
                Get.back();
              },
            ),
            cancel: TextButton(
              child: Text("Later"),
              onPressed: () => Get.back(),
            ),
          );
        }
        await prefs.setBool('askedLauncher', true);
      }
    } catch (e) {
      debugPrint("Launcher check error: $e");
    }
  }


  Future<void> askForDeviceAdmin() async {
    print("something Happend");
    try {

        final isActive = await DpcBridge.isAdminActive();

        if (!isActive) {
          Get.defaultDialog(
            title: "Enable Device Admin",
            content: Text("KeyBG needs Device Admin permission to function properly."),
            confirm: TextButton(
              child: Text("Enable Now"),
              onPressed: () async {
                await DpcBridge.activateAdmin();
                Get.back();
              },
            ),
            cancel: TextButton(
              child: Text("Later"),
              onPressed: () => Get.back(),
            ),
          );

      }
    } catch (e) {
      debugPrint("Device Admin request error: $e");
    }
  }


  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      print("user Loaded");
      userId.value = prefs.getString("userId")!;
      _listenToLockService();
    }
  }

  void _listenToLockService() {
    print("Lock Service Init");
    final sessionRef = FirebaseDatabase.instance.ref("users/$userId/features/isLockEnable");
    sessionRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print("Lock status updated: $data");
      if (data == true) {
        final sessions2Ref = FirebaseDatabase.instance.ref("users/$userId").update({"Status": "Locked"});
        Get.offAllNamed(RoutesConstant.homePage);
      }
    });
  }

  Future<void> loadWallpaper() async {
    SharedPreferences prefs =await SharedPreferences.getInstance();
    glb.wallpaperPath.value = prefs.getString("WallPaper")!;

  }

  // New home screen methods
  void _initializeHomeScreen() {
    _startClock();
    _initializeQuickAccessItems();
  }

  void _startClock() {
    _updateTime();
    _clockTimer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('hh:mm a').format(now);
    currentDate.value = DateFormat('EEEE, MMMM d').format(now);
  }

  void _initializeQuickAccessItems() {
    quickAccessItems.assignAll([
      QuickAccessItem(
        icon: Icons.phone,
        label: "Phone",
        onTap: openPhone,
      ),
      QuickAccessItem(
        icon: Icons.message,
        label: "Messages",
        onTap: openMessages,
      ),
      QuickAccessItem(
        icon: Icons.email,
        label: "Email",
        onTap: openEmail,
      ),
      QuickAccessItem(
        icon: Icons.camera_alt,
        label: "Camera",
        onTap: openCamera,
      ),
    ]);
  }

  // Action methods
  void openMenu() {
    // Implement menu opening logic
  }

  void openSearch() {

  }

  void openSettings() {

  }

  void openPhone() {
    // Implement phone opening logic
  }

  void openMessages() {
    // Implement messages opening logic
  }

  void openEmail() {
    // Implement email opening logic
  }

  void openCamera() {
    // Implement camera opening logic
  }
}