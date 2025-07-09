import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:keybg/models/features.dart';
import 'package:keybg/models/emi.dart';
import 'package:keybg/models/retailer.dart';
import 'package:keybg/services/dpc_service.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class HomePageController extends GetxController {
  Rx<Features?> features = Rx<Features?>(null);
  Rx<EMI?> emi = Rx<EMI?>(null);
  Rx<Retailer?> retailer = Rx<Retailer?>(null);
  StreamSubscription<DatabaseEvent>? _userSubscription;
  RxString userId = '-OTC7uPVN_8n5tqJY_5b'.obs;
  late DatabaseReference _userRef;
  var isKioskMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _userRef = FirebaseDatabase.instance.ref('users/${userId.value}');
    _sendAcknowledgement("Instance Created");
    loadData();
  }

  Future<void> _sendAcknowledgement(String status) async {
    await _userRef.update({"Status": status});
    print("Done");
  }

  void loadData() {
    _userSubscription = _userRef.onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map?;
          if (data != null) {
            if (data['changed']) {
              _sendAcknowledgement("Request Received");
              if (data['features'] != null) {
                features.value = Features.fromJson(
                  Map<String, dynamic>.from(data['features']),
                );
                applyRestrictions();
                _sendAcknowledgement("Request Fulfilled");
                _userRef.update({"changed": false});
              }
            }
            if (data['emi'] != null) {
              print(data['emi']);
              emi.value = EMI.fromJson(Map<String, dynamic>.from(data['emi']));
              print(emi.value);
            }
            if (data['retailer'] != null) {
              print(data['retailer']);
              retailer.value = Retailer.fromJson(
                Map<String, dynamic>.from(data['retailer']),
              );
            }
          }
        }
      },
      onError: (error) {
        print('Error loading user data: $error');
      },
    );
  }

  void applyRestrictions() async {
    final f = features.value;
    if (f == null) return;
    // Apply restrictions using DpcBridge
    await DpcBridge.setUSBDebugging(f.isUSBDebug);
    await DpcBridge.setCamera(f.isCamera);
    await DpcBridge.setAppInstallation(f.isAppInstallation);
    await DpcBridge.setDeveloperOptions(f.isDeveloperOptions);
    await DpcBridge.setHardReset(f.isHardReset);
    await DpcBridge.setSoftBoot(f.isSoftBoot);
    // Block apps
    await DpcBridge.blockApps(f.apps);
    // Set wallpaper
    if (f.warningWallpaper) {
      await DpcBridge.setWallpaper(f.wallpaperUrl);
    }
    // Play warning audio if enabled
    if (f.warningAudio) {
      await DpcBridge.playWarningAudio();
    }
    // Password change
    if (f.passwordChange.isNotEmpty) {
      await DpcBridge.setPassword(f.passwordChange);
    }
    (f.isIncomingCalls)
        ? await DpcBridge.enableIncomingCalls()
        : DpcBridge.disableIncomingCalls();
    (f.isOutgoingCalls)
        ? await DpcBridge.enableOutgoingCalls()
        : DpcBridge.enableOutgoingCalls();
  }

  void launchKioskMode() async {
    isKioskMode.value = true;
    try {
      await startKioskMode();
    } catch (e) {
      print('Failed to start kiosk mode: $e');
    }
  }

  void exitKioskMode() async {
    isKioskMode.value = false;
    try {
      await stopKioskMode();
    } catch (e) {
      print('Failed to exit kiosk mode: $e');
    }
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }
}
