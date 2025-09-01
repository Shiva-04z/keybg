import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:keybg/models/features.dart';
import 'package:keybg/models/emi.dart';
import 'package:keybg/models/retailer.dart';
import 'package:keybg/naviagtion/RoutesConstant.dart';
import 'package:keybg/services/dpc_service.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageController extends GetxController {
  Rx<Features?> features = Rx<Features?>(null);
  Rx<EMI?> emi = Rx<EMI?>(null);
  Rx<Retailer?> retailer = Rx<Retailer?>(null);
  RxBool isKiosk =true.obs;
  late final DatabaseReference _userRef;
  StreamSubscription<DatabaseEvent>? _userSubscription;
  RxString userId = "pranav/1BsF11LTiaPu8jQIzDHa".obs;
  RxString unlockCode = "ABC123".obs;

  @override
  void onInit() {
    super.onInit();
    _getUserId();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  _getUserId()
  async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString("userId")!=null)
    {
      userId.value = prefs.getString("userId")!;
      print("User Loaded ${prefs.getString("userId")!}");
      loadData();
      _listenToLockService();

    }
  }

void hideSystemUI()
{ SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);}



  void _listenToLockService()
  {
    print("Lock Service Init");
    final sessionRef = FirebaseDatabase.instance.ref("users/${userId.value}/features/isLockEnable");
    sessionRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;
      print("Lock status updated: $data");
      if(data == false)
      {
        final sessions2Ref = FirebaseDatabase.instance.ref("users/${userId.value}").update({"Status": "UnLocked"});
        Get.offAllNamed(RoutesConstant.myHomePage);
        await stopKioskMode();
      }
    });
  }


  Future<void> pushUnlockMode()
  async {


    Get.offAllNamed(RoutesConstant.myHomePage);
    final sessionRef = FirebaseDatabase.instance.ref("users/$userId/features");
    sessionRef.update({"isLockEnable":false});
    final sessions2Ref = FirebaseDatabase.instance.ref("users/$userId").update({"Status": "UnLocked"});
    await stopKioskMode();

  }


  Future<void> toggleKiosk()
  async {
    isKiosk.value=!(isKiosk.value);
    if(isKiosk.value){
      await startKioskMode();
    }
    else{
      await stopKioskMode();
      Get.offAllNamed(RoutesConstant.appPage);
    }

  }



  void loadData() {

    _userRef = FirebaseDatabase.instance.ref('users/$userId');
    print(userId.value);

    _userSubscription = _userRef.onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map?;
          print(data);
          if (data != null) {
            if (data['features'] != null) {
              features.value = Features.fromJson(
                Map<String, dynamic>.from(data['features']),
              );
              print(features.value);
              applyRestrictions();
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
    if(f.isLockEnable)
      {await startKioskMode();
      hideSystemUI();}
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
