import 'package:get/get.dart';
import 'package:keybg/features/home_page/home_page_controller.dart';

class HomePageBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>HomePageController());
  }

}