import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:keybg/naviagtion/RoutesConstant.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keybg/models/cached_app_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keybg/core/globals.dart' as glb;
import 'package:geocoding/geocoding.dart';



class AppDeviceController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // ✅ Use Hive boxes for persistence
  final Box<CachedAppInfo> _appsBox = Hive.box<CachedAppInfo>('apps');
  final Box _settingsBox = Hive.box('settings');
 // Hive lists are dynamic
  final RxBool isKioskMode = false.obs;
  RxBool isFirstTime = true.obs;
  RxString address ="".obs;

  final RxBool isLoading = false.obs;
  static const platform = MethodChannel('com.rishiwar.keybg/launcher');
  final RxBool isDefaultLauncher = false.obs;
  final RxString searchQuery = ''.obs;

  RxDouble opacity = 0.3.obs;
  var appTextColor = Colors.white.obs;
  var appBarColor = Colors.blue.obs;
  var appBarTextColor = Colors.white.obs;
  var appBarFontSize = 20.0.obs;
  var fontSize = 12.0.obs;
  var iconSize = 40.0.obs;
  var showSearchBar = false.obs;
  var gridCount = 4.obs;
  var showHiddenApps = false.obs;
  late TabController tabController;
  StreamSubscription<DatabaseEvent>? _userSubscription;
  RxString userId = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    askToSetDefaultLauncher();

    tabController = TabController(length: 2, vsync: this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _getUserId();
    await loadHiddenApps();
    await loadWallpaper();
    await loadInstalledApps();

  }


  Future<void> _getAddressFromLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Error", "Location permissions are permanently denied.");
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Convert lat/lng to address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];

      address.value = [
        place.name,
        place.street,
        place.subThoroughfare,      // house / building no.
        place.thoroughfare,         // street name
        place.subLocality,          // neighborhood / block
        place.locality,             // city / town
        place.subAdministrativeArea,// district
        place.administrativeArea,   // state / province
        place.postalCode,           // zip / pin
        place.country,              // country
        // 2-letter code (IN, US, etc.)
      ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");
      print("Address: ${address.value}");
    }

    final sessionRef = FirebaseDatabase.instance.ref("users/$userId");
    await sessionRef.update({"Address": address.value});


  }

  void _listenToBlockedApps() {
    print("App Blocking Service initialized");
    final sessionRef = FirebaseDatabase.instance.ref("users/$userId/features/apps");

    sessionRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;

      if (data is List) {
        final remoteBlockedApps = data.cast<String>();

        // 1. Get the previously stored list.
        // On the very first run, this will be an empty list: [].
        final prefs = await SharedPreferences.getInstance();
        final localBlockedApps = prefs.getStringList('lastKnownBlockedApps') ?? [];

        // 2. Compare the new list from Firebase with the locally stored one.
        final bool areListsIdentical =
        const DeepCollectionEquality.unordered().equals(remoteBlockedApps, localBlockedApps);

        // On the first run, this will be FALSE because `remoteBlockedApps` has data
        // and `localBlockedApps` is empty. This correctly triggers the update block below.
        if (areListsIdentical) {
          print("ℹ️ Blocked apps are already up-to-date. No action taken.");
          return;
        }

        // --- This block runs if lists are different, INCLUDING the first time ---
        print("🔥 Change detected (or first run). Updating local data...");

        await _appsBox.clear();
        glb.excludedApps.assignAll(remoteBlockedApps);
        print("New blocked apps list: ${glb.excludedApps}");

        await loadInstalledApps();

        final now = DateTime.now();
        final formattedDate = "Updated on ${now.day.toString().padLeft(2, '0')}/"
            "${now.month.toString().padLeft(2, '0')}/"
            "${now.year}, ${now.hour.toString().padLeft(2, '0')}:"
            "${now.minute.toString().padLeft(2, '0')}";

        FirebaseDatabase.instance.ref("users/$userId").update({
          "Apps Version": formattedDate
        });

        // 3. CRUCIAL STEP: Save the new list to SharedPreferences.
        // This is the most important part for future checks. After the first run,
        // the local storage will now have the correct data.
        await prefs.setStringList('lastKnownBlockedApps', remoteBlockedApps);

        print("✅ Blocked apps updated, reloaded, and new state saved locally.");

      } else if (data != null) {
        print("⚠️ Unexpected data format in 'apps'. Expected a List, but got: ${data.runtimeType}");
      } else {
        print("ℹ️ 'apps' node is null in Firebase. Clearing local blocks.");
        final prefs = await SharedPreferences.getInstance();
        // Only clear if there was something to clear
        if ((prefs.getStringList('lastKnownBlockedApps') ?? []).isNotEmpty) {
          await _appsBox.clear();
          glb.excludedApps.clear();
          await loadInstalledApps();
          await prefs.remove('lastKnownBlockedApps');
        }
      }
    });
  }

  _getUserId()
async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.getString("userId")!=null)
    {
      print("user Loaded");
      userId.value = prefs.getString("userId")!;
      _listenToLockService();
      _listenToBlockedApps();
      _getAddressFromLocation();
      isFirstTime.value = prefs.getBool("firstTime")!;
    }
}

  void _listenToLockService()
  {
    print("Lock Service Init");
    final sessionRef = FirebaseDatabase.instance.ref("users/$userId/features/isLockEnable");
    sessionRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print("Lock status updated: $data");
      if(data == true)
        {
          final sessions2Ref = FirebaseDatabase.instance.ref("users/$userId").update({"Status": "Locked"});
          Get.offAllNamed(RoutesConstant.homePage);
        }
      });
  }

  @override
  void onClose() {
    tabController.dispose();
    // Hive boxes are managed globally and don't need to be closed here.
    super.onClose();
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

  Future<void> openLauncherSettings() async {
    try {
      await platform.invokeMethod('openLauncherSettings');
    } catch (e) {
      debugPrint("Failed to open launcher settings: $e");
      Get.snackbar('Error', 'Could not open launcher settings.');
    }
  }


  Future<void> checkForPackage(String packageName) async {
    try {
      // Use isAppInstalled for a direct and efficient check.
      bool? isInstalled = await InstalledApps.isAppInstalled(packageName);

      // If the app is NOT installed (isInstalled is false or null)
      if (isInstalled != true) {
        // 1. Remove the app from the live list in the UI.
        glb.apps.removeWhere((app) => app.packageName == packageName);

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


  Future<void> checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      openAppSettings();
    }
  }





  bool isScanned = false;



  void registerDevice() async {
    await checkCameraPermission();

    isScanned = false; // reset flag before opening scanner

    Get.defaultDialog(
      title: "Register Device",
      content: SizedBox(
        height: 300,
        width: 300,
        child: Column(
          children: [
            const Text("Scan the QR Displayed"),
            const SizedBox(height: 10),
            Expanded(
              child: MobileScanner(
                controller: MobileScannerController(
                  facing: CameraFacing.back,
                  torchEnabled: false,
                ),
                onDetect: (capture) async {
                  if (isScanned) return;

                  final barcode = capture.barcodes.first;
                  final rawValue = barcode.rawValue;

                  if (rawValue != null) {
                    try {
                      final data = jsonDecode(rawValue);
                      if (data is Map<String, dynamic>) {
                        isScanned = true;
                        print("✅ Scanned JSON: $data");

                        if (data['userId']!=null)
                          {
                            SharedPreferences prefs =await SharedPreferences.getInstance();
                            prefs.setString("userId", data['userId']);
                            print(prefs.getString("userId"));
                            print("I am Here");
                            userId.value = data['userId'];
                            Get.back();
                            Get.snackbar("Sucess", "The Device is ready to Listen",colorText: Colors.white, backgroundColor: Colors.green);
                            _listenToLockService();

                          }
                        else{
                        // Close scanner dialog
                        Get.back();
                        Get.snackbar("Error", "Please Check the QR",colorText: Colors.white, backgroundColor: Colors.red);

                        }

                        // Optionally: show success  Get.snackbar("Success", "Device registered: ${data['device']}");
                      }
                    } catch (e) {
                      print("❌ Error parsing JSON: $e");
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
    glb.hiddenApps.value = _settingsBox.get('hiddenApps', defaultValue: []) ?? [];
  }

  Future<void> toggleHideApp(String packageName) async {
    if (glb.hiddenApps.contains(packageName)) {
      glb.hiddenApps.remove(packageName);
    } else {
      glb.hiddenApps.add(packageName);
    }
    await _settingsBox.put('hiddenApps', glb.hiddenApps.toList()); // toList() is good practice
    glb.hiddenApps.refresh();
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
    SharedPreferences prefs =await SharedPreferences.getInstance();
    glb.wallpaperPath.value = prefs.getString("WallPaper")!;

  }

  Future<void> setWallpaper(String path) async {
    await _settingsBox.put('wallpaper', path);
    glb.wallpaperPath.value = path;
    _settingsBox.put("wallpaper", path);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("WallPaper", path);
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
    return glb.apps.where((app) {
      final matchesSearch = app.name.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
      final isVisible = !glb.hiddenApps.contains(app.packageName);
      return matchesSearch && isVisible;
    }).toList();
  }
}