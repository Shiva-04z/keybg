import 'package:get/get.dart';
import 'package:keybg/features/splash_screen/spalsh_screen_controller.dart';


class SplashScreenBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>SplashScreenController());
  }

}