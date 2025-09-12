import 'dart:async';
import 'dart:convert';
import 'package:app_usage/app_usage.dart';
import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:keybg/models/cached_app_info.dart';
import 'package:keybg/naviagtion/RoutesConstant.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keybg/core/globals.dart' as glb;
import '../../services/dpc_service.dart' as dpc;
import '../../services/foreground_bridge.dart';
import '../../services/app_bridge.dart';

class AppDeviceController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// -------------------------
  /// 📦 Variables & Observables
  /// -------------------------
  final Box<CachedAppInfo> _appsBox = Hive.box<CachedAppInfo>('apps');
  final RxBool isKioskMode = false.obs;
  RxBool isFirstTime = true.obs;
  RxString address = "".obs;
  final RxBool isLoading = false.obs;
  static const platform = MethodChannel('com.rishiwar.keybg/launcher');
  StreamSubscription<DatabaseEvent>? _userSubscription;
  RxString userId = ''.obs;
  Timer? appCheckTimer;
  String? lastApp;

  // Permission Observables
  var adminPermission = false.obs;
  var usageAccessPermission = false.obs;
  var batteryRestrictionBypass = false.obs;
  var displayOverOtherApps = false.obs;
  var notificationPermission = false.obs;
  var isCheckingPermissions = false.obs;
  RxInt h = 0.obs;

  bool isScanned = false;

  /// -------------------------
  /// 🔄 Lifecycle
  /// -------------------------
  @override
  void onInit() async {
    super.onInit();
    ForegroundServiceBridge.startService();
    h.value = MediaQuery.of(Get.context!).size.height.floor();
    checkPermissions();
    _getUserId();
  }

  Future<bool> launchApp() async {
    try {
      return await InstalledApps.startApp('com.rishiwar.keybg') ?? false;
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

  void showOverlay(String event) async {
    {
      await FlutterOverlayWindow.shareData(event);
      if (event == 'A') {
        await FlutterOverlayWindow.showOverlay(
          overlayContent: "System Alert",
          height: 1200,
          alignment: OverlayAlignment.center,
        );
      } else {
        await FlutterOverlayWindow.showOverlay(
          visibility: NotificationVisibility.visibilitySecret,
          overlayContent: "Monitoring your activity",
          overlayTitle: "System Alert",
          height: 100,
          width: 100,
          alignment: OverlayAlignment.centerLeft,

          enableDrag: true,
        );
      }
    }
  }

  /// -------------------------
  /// 📍 Location Handling
  /// -------------------------
  Future<void> _getAddressFromLocation() async {
    // 1. Check location service
    if (!await Geolocator.isLocationServiceEnabled()) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    // 2. Check permission
    LocationPermission permission = await Geolocator.checkPermission();
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

    // 3. Get position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4. Convert to address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      address.value = [
        place.name,
        place.street,
        place.subThoroughfare,
        place.thoroughfare,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");
      print("Address: ${address.value}");
    }

    await FirebaseDatabase.instance.ref("users/$userId").update({
      "Address": address.value,
    });
  }

  /// -------------------------
  /// 🔒 User & Lock Services
  /// -------------------------
  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      print("user Loaded ");
      userId.value = prefs.getString("userId")!;
      isFirstTime.value = prefs.getBool("firstTime") ?? false;
      _listenToLockService();
      _listenToBlockedApps();
      _getAddressFromLocation();
      showOverlay("B");
      startAppWatcher();
    }
  }

  Future<void> _getUserId2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("userId") != null) {
      print("user Loaded ");
      userId.value = prefs.getString("userId")!;
      isFirstTime.value = prefs.getBool("firstTime") ?? false;
      _listenToLockService();
      _listenToBlockedApps();
    }
  }

  void _listenToLockService() {
    print("Lock Service Init");
    final sessionRef = FirebaseDatabase.instance.ref(
      "users/$userId/features/isLockEnable",
    );

    sessionRef.onValue.listen((event) {
      final data = event.snapshot.value;
      glb.isLockEnabled.value = true;
      print("Lock status updated: $data");
      if (data == true) {
        FirebaseDatabase.instance.ref("users/$userId").update({
          "Status": "Locked",
        });
        launchApp();
        Get.offAllNamed(RoutesConstant.homePage);
      }
    });
  }

  /// -------------------------
  /// 📵 Blocked Apps Service
  /// -------------------------
  void _listenToBlockedApps() {
    print("App Blocking Service initialized");
    final sessionRef = FirebaseDatabase.instance.ref(
      "users/$userId/features/apps",
    );

    sessionRef.onValue.listen((event) async {
      final data = event.snapshot.value;

      if (data is List) {
        final remoteBlockedApps = data.cast<String>();

        // Compare with local cache
        final prefs = await SharedPreferences.getInstance();
        final localBlockedApps =
            prefs.getStringList('lastKnownBlockedApps') ?? [];

        final identical = const DeepCollectionEquality.unordered().equals(
          remoteBlockedApps,
          localBlockedApps,
        );

        if (identical) {
          glb.excludedApps.assignAll(remoteBlockedApps);
          print("ℹ️ Blocked apps already up-to-date.");
          return;
        }

        // Update local DB
        await _appsBox.clear();
        glb.excludedApps.assignAll(remoteBlockedApps);
        print("New blocked apps list: ${glb.excludedApps}");

        final now = DateTime.now();
        final formattedDate =
            "Updated on ${now.day.toString().padLeft(2, '0')}/"
            "${now.month.toString().padLeft(2, '0')}/"
            "${now.year}, ${now.hour.toString().padLeft(2, '0')}:"
            "${now.minute.toString().padLeft(2, '0')}";

        FirebaseDatabase.instance.ref("users/$userId").update({
          "Apps Version": formattedDate,
        });

        await prefs.setStringList('lastKnownBlockedApps', remoteBlockedApps);
        print("✅ Blocked apps updated and saved locally.");
      } else if (data == null) {
        print("ℹ️ 'apps' node is null. Clearing local blocks.");
        final prefs = await SharedPreferences.getInstance();
        if ((prefs.getStringList('lastKnownBlockedApps') ?? []).isNotEmpty) {
          await _appsBox.clear();
          glb.excludedApps.clear();
          await prefs.remove('lastKnownBlockedApps');
        }
      } else {
        print("⚠️ Unexpected data format: ${data.runtimeType}");
      }
    });
  }

  /// -------------------------
  /// 📷 Device Registration
  /// -------------------------
  Future<void> checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) openAppSettings();
  }

  void registerDevice() async {
    await checkCameraPermission();
    isScanned = false;

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

                        if (data['userId'] != null) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString("userId", data['userId']);
                          userId.value = data['userId'];
                          Get.back();
                          Get.snackbar(
                            "Sucess",
                            "The Device is ready",
                            colorText: Colors.white,
                            backgroundColor: Colors.green,
                          );
                          _listenToLockService();
                        } else {
                          Get.back();
                          Get.snackbar(
                            "Error",
                            "Invalid QR",
                            colorText: Colors.white,
                            backgroundColor: Colors.red,
                          );
                        }
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

  /// -------------------------
  /// ✅ Permission Handling
  /// -------------------------
  Future<void> checkPermissions() async {
    isCheckingPermissions.value = true;
    await Future.wait([
      _checkAdminPermission(),
      _checkUsageAccessPermission(),
      _checkBatteryRestrictionBypass(),
      _checkDisplayOverOtherApps(),
      _checkNotificationPermission(),
    ]);
    isCheckingPermissions.value = false;
  }

  // ---- Permission Checkers ----
  Future<void> _checkAdminPermission() async {
    bool isAdmin = await dpc.DpcBridge.isAdminActive() ?? false;
    if (isAdmin) await dpc.DpcBridge.activateAdmin();
    adminPermission.value = false;
  }

  Future<void> _checkUsageAccessPermission() async {
    await AppUsage().getAppUsage(
      DateTime.now().subtract(const Duration(hours: 1)),
      DateTime.now(),
    );
  }

  Future<void> _checkBatteryRestrictionBypass() async {
    batteryRestrictionBypass.value =
        (await Permission.ignoreBatteryOptimizations.status).isGranted;
  }

  Future<void> _checkDisplayOverOtherApps() async {
    displayOverOtherApps.value =
        (await Permission.systemAlertWindow.status).isGranted;
  }

  Future<void> _checkNotificationPermission() async {
    notificationPermission.value =
        (await Permission.notification.status).isGranted;
  }

  // ---- Permission Requesters ----
  Future<void> requestAdminPermission() async {
    Get.snackbar(
      'Info',
      'Device admin permission requires manual setup in device settings',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Future<void> requestUsageAccess() async {
    final status = await Permission.accessMediaLocation.request();
    usageAccessPermission.value = status.isGranted;
    _handlePermissionSnack(status, "Usage access");
  }

  Future<void> requestBatteryRestrictionBypass() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    batteryRestrictionBypass.value = status.isGranted;
    _handlePermissionSnack(status, "Battery optimization bypass");
  }

  Future<void> requestDisplayOverOtherApps() async {
    final status = await Permission.systemAlertWindow.request();
    displayOverOtherApps.value = status.isGranted;
    _handlePermissionSnack(status, "Display over other apps");
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    notificationPermission.value = status.isGranted;
    _handlePermissionSnack(status, "Notification");
  }

  // Helper to show snackbars for permissions
  void _handlePermissionSnack(PermissionStatus status, String name) {
    if (status.isGranted) {
      Get.snackbar(
        'Success',
        '$name granted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      Get.snackbar(
        'Attention',
        'Please enable $name in settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        '$name denied',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// -------------------------
  /// 👀 Foreground App Watcher
  /// -------------------------
  void startAppWatcher() {
    appCheckTimer?.cancel(); // ensure no duplicate timers
    appCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _getUserId2();
      try{
      List<AppUsageInfo> apps=  await AppUsage().getAppUsage(DateTime.now().subtract(Duration(seconds: 5)), DateTime.now());
      print(apps);
      }
      catch (e)
      {
        print(e);
      }
      final currentApp = await CurrentApp.getForegroundApp();
      print("📱 Foreground app: $currentApp");
      print("Excluded List : ${glb.excludedApps}");
      if (currentApp != lastApp) {
        lastApp = currentApp;
        // If the app is in excluded/blocked list
        if (glb.excludedApps.contains(currentApp)) {
          print("🚫 Blocked app detected: $currentApp");
          showOverlay("A"); // Show restricted overlay
        } else {
          showOverlay('B');
        }
      }
    });
  }

  void stopAppWatcher() {
    appCheckTimer?.cancel();
    appCheckTimer = null;
  }
}
