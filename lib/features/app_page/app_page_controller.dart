import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keybg/models/cached_app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDeviceController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // ✅ Use Hive boxes for persistence
  final Box<CachedAppInfo> _appsBox = Hive.box<CachedAppInfo>('apps');
  final Box _settingsBox = Hive.box('settings');
  final RxList<AppInfo> apps = <AppInfo>[].obs;
  final RxList<dynamic> hiddenApps = <dynamic>[].obs; // Hive lists are dynamic
  final RxBool isKioskMode = false.obs;
  final RxString wallpaperPath = ''.obs;
  final RxBool isLoading = false.obs;
  static const platform = MethodChannel('com.rishiwar.keybg/launcher');
  final RxBool isDefaultLauncher = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> excludedApps = <String>["com.rishiwar.keybg"].obs;
  RxDouble opacity = 0.3.obs;
  var appTextColor = Colors.white.obs;
  var appBarColor = Colors.blue.obs;
  var appBarTextColor = Colors.white.obs;
  var appBarFontSize = 20.0.obs;
  var fontSize = 12.0.obs;
  var iconSize = 40.0.obs;
  var showSearchBar = true.obs;
  var gridCount = 4.obs;
  var showHiddenApps = false.obs;
  late TabController tabController;

  @override
  void onInit() async {
    super.onInit();
    askToSetDefaultLauncher();
    tabController = TabController(length: 2, vsync: this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await loadHiddenApps();
    await loadWallpaper();
    await loadInstalledApps();
  }

  @override
  void onClose() {
    tabController.dispose();
    // Hive boxes are managed globally and don't need to be closed here.
    super.onClose();
  }

  Future<int> _loadAppsFromHive() async {
    final cachedApps = _appsBox.values.toList();
    apps.assignAll(
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


  Future<void> checkForPackage(String packageName) async {
    try {
      // Use isAppInstalled for a direct and efficient check.
      bool? isInstalled = await InstalledApps.isAppInstalled(packageName);

      // If the app is NOT installed (isInstalled is false or null)
      if (isInstalled != true) {
        // 1. Remove the app from the live list in the UI.
        apps.removeWhere((app) => app.packageName == packageName);

        // 2. Remove the app from the Hive database for persistence.
        //    This assumes the package name is used as the key in the box.
        await _appsBox.delete(packageName);

        // Optional: Show a confirmation to the user.
      }
    } catch (e) {
      // Handle any potential errors during the check.
      Get.snackbar('Error', 'Failed to verify app status: $e');
    }
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


  Future<void> loadInstalledApps() async {
    final dbCount = await _loadAppsFromHive();
    if (dbCount == 0) {
      isLoading.value = true;
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
        'com.google.android.dialer',
        'com.android.mms',
        'com.google.android.apps.messaging',
        'com.google.android.contacts',
      };

      final Map<String, CachedAppInfo> appsToCache = {};
      for (var app in installedApps) {
        if (excludedApps.contains(app.packageName)) continue;

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
      isLoading.value = false;
    }
  }

  void resetUiSettings() {
    appTextColor.value = Colors.white;
    appBarColor.value = Colors.blue;
    appBarTextColor.value = Colors.white;
    appBarFontSize.value = 20;
    fontSize.value = 12;
    iconSize.value = 40;
    showSearchBar.value = true;
    setWallpaper(''); // Use the Hive-based function
  }

  // ✅ Switched from SharedPreferences to Hive
  Future<void> loadHiddenApps() async {
    hiddenApps.value = _settingsBox.get('hiddenApps', defaultValue: []) ?? [];
  }

  Future<void> toggleHideApp(String packageName) async {
    if (hiddenApps.contains(packageName)) {
      hiddenApps.remove(packageName);
    } else {
      hiddenApps.add(packageName);
    }
    await _settingsBox.put('hiddenApps', hiddenApps.toList()); // toList() is good practice
    hiddenApps.refresh();
  }

  Future<void> toggleKioskMode() async {
    if (isKioskMode.value) {
      await stopKioskMode();
    } else {
      await startKioskMode();
    }
    isKioskMode.toggle();
  }

  // ✅ Switched from SharedPreferences to Hive
  Future<void> loadWallpaper() async {
    wallpaperPath.value = _settingsBox.get('wallpaper', defaultValue: '') ?? '';
  }

  Future<void> setWallpaper(String path) async {
    await _settingsBox.put('wallpaper', path);
    wallpaperPath.value = path;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await setWallpaper(pickedFile.path);
    }
  }

  Future<void> downloadAndSetWallpaper(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wallpaper.jpg');
      await file.writeAsBytes(response.bodyBytes);
      await setWallpaper(file.path);
    } catch (e) {
      Get.snackbar('Error', 'Failed to download wallpaper');
    }
  }

  Future<bool> launchApp(String packageName) async {
    try {
      return await InstalledApps.startApp(packageName) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uninstallApp(String packageName) async {
    try {
      return await InstalledApps.uninstallApp(packageName) ?? false;
    } catch (e) {
      return false;
    }
  }

  List<AppInfo> get filteredApps {
    return apps.where((app) {
      final matchesSearch = app.name.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
      final isVisible = !hiddenApps.contains(app.packageName);
      return matchesSearch && isVisible;
    }).toList();
  }
}