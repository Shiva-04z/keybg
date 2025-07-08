import 'package:get/get.dart';
import 'package:keybg/features/test_page/test_page_controller.dart';

class TestPageBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>TestPageController());
  }

}