
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keybg/features/splash_screen/spalsh_screen_controller.dart';


class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return GetBuilder(init: SplashScreenController(),
        builder: (GetxController Controller) {
          return Scaffold(
            backgroundColor: Colors.white,
            body:Container(),

          );
        });
  }
}
