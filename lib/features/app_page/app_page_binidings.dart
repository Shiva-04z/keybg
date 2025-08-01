import 'package:get/get.dart';
import 'package:keybg/features/app_page/app_page_controller.dart';

class AppPageBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=> AppDeviceController());
  }

}