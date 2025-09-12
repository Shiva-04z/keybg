import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keybg/features/splash_screen/splash_screen_bindings.dart';
import 'package:keybg/features/splash_screen/splash_screen_view.dart';
import 'package:keybg/naviagtion/getPages.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:keybg/firebase_options.dart';
import 'package:get/get.dart';

import 'models/cached_app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ✅ Register your TypeAdapter
  Hive.registerAdapter(CachedAppInfoAdapter());

  // ✅ Open boxes for apps and settings
  await Hive.openBox<CachedAppInfo>('apps');
  await Hive.openBox('settings');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: OverlayApp()),
    ),
  );
}

class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  String currentOverlay = "A"; // default

  @override
  void initState() {
    super.initState();
    // Listen for data sent from the main app
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String) {
        setState(() {
          currentOverlay = event;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentOverlay == "A") {
      return const OverlayA();
    } else {
      return const OverlayB();
    }
  }
}

class OverlayA extends StatelessWidget {
  const OverlayA({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        height: 250,
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              "Action Blocked",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "This action has been restricted by device administration policies.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverlayB extends StatelessWidget {
  const OverlayB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              color: Colors.white,
              child: Icon(
                Icons.monitor_heart_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
      initialBinding: SplashScreenBindings(),
      getPages: getPages,
    );
  }
}
