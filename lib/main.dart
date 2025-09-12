import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:keybg/features/home_page/home_page_binidings.dart';
import 'package:keybg/features/home_page/home_page_view.dart';
import 'package:keybg/features/splash_screen/splash_screen_bindings.dart';
import 'package:keybg/features/splash_screen/splash_screen_view.dart';
import 'package:keybg/naviagtion/getPages.dart';
import 'package:keybg/services/dpc_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:keybg/firebase_options.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'features/app_page/app_page_controller.dart';
import 'features/home_page/home_page_controller.dart';
import 'models/cached_app_info.dart';

// overlay_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({Key? key}) : super(key: key);

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              "Floating Button",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                FlutterOverlayWindow.closeOverlay();
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();


  // ✅ Register your TypeAdapter
  Hive.registerAdapter(CachedAppInfoAdapter());

  // ✅ Open boxes for apps and settings
  await Hive.openBox<CachedAppInfo>('apps');
  await Hive.openBox('settings');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, // Or match your app's BG
        systemNavigationBarIconBrightness: Brightness.dark, // or light based on contrast
        statusBarColor: Colors.transparent, // optional
        statusBarIconBrightness: Brightness.dark, // or light
      ));



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Use GetMaterialApp for Obx and GetX support
    return GetMaterialApp(
      title: 'Key BG',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreenView(),
      initialBinding:  SplashScreenBindings(),
      getPages: getPages,
    );
  }
}
