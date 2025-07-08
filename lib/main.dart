import 'package:flutter/material.dart';
import 'package:keybg/features/home_page/home_page_binidings.dart';
import 'package:keybg/features/home_page/home_page_view.dart';
import 'package:keybg/features/splash_screen/splash_screen_bindings.dart';
import 'package:keybg/features/splash_screen/splash_screen_view.dart';
import 'package:keybg/naviagtion/getPages.dart';
import 'package:keybg/services/dpc_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:keybg/firebase_options.dart';
import 'package:get/get.dart';
import 'features/home_page/home_page_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
