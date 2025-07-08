import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:keybg/models/features.dart';
import 'package:keybg/models/emi.dart';
import 'package:keybg/models/retailer.dart';
import 'package:keybg/services/dpc_service.dart';

class HomePageController extends GetxController {
  Rx<Features?> features = Rx<Features?>(null);
  Rx<EMI?> emi = Rx<EMI?>(null);
  Rx<Retailer?> retailer = Rx<Retailer?>(null);
  late final DatabaseReference _userRef;
  StreamSubscription<DatabaseEvent>? _userSubscription;
  final userId = '-OTC7uPVN_8n5tqJY_5b';

  @override
  void onInit() {
    super.onInit();
    loadData();
  }


  void _sendAcknowledgement()
  {    _userRef.child("users/$userId").update(
      {"Acknowledgement" : DateTime.now()}
    );
  }

  void loadData() {

    _userRef = FirebaseDatabase.instance.ref('users/$userId');

    _userSubscription = _userRef.onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map?;
          if (data != null) {
            if (data['features'] != null) {
              features.value = Features.fromJson(
                Map<String, dynamic>.from(data['features']),
              );
              print(features.value);
              applyRestrictions();
              _sendAcknowledgement();
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
    if(f.warningWallpaper){
    await DpcBridge.setWallpaper(f.wallpaperUrl);}
    // Play warning audio if enabled
    if (f.warningAudio) {
      await DpcBridge.playWarningAudio();
    }
    // Password change
    if (f.passwordChange.isNotEmpty) {
      await DpcBridge.setPassword(f.passwordChange);
    }
    (f.isIncomingCalls)? await DpcBridge.enableIncomingCalls():DpcBridge.disableIncomingCalls();
    (f.isOutgoingCalls)? await DpcBridge.enableOutgoingCalls(): DpcBridge.enableOutgoingCalls();

  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }
}
