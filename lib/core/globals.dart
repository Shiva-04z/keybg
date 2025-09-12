import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:installed_apps/app_info.dart';
import 'package:keybg/models/features.dart';

Rx<Features?> features = Rx<Features?>(null);
 RxString wallpaperPath = ''.obs;
 RxBool isLockEnabled = false.obs;
final RxList<AppInfo> apps = <AppInfo>[].obs;
final RxList<dynamic> hiddenApps = <dynamic>[].obs;
final RxList<String> excludedApps = <String>[].obs;