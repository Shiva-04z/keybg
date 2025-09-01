import 'package:get/get.dart';
import 'package:keybg/features/my_home_screen/my_home_screen_controller.dart';

class MyHomeScreenBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>MyHomeScreenController());
  }


}