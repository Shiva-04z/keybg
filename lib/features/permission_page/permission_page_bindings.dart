import 'package:get/get.dart';
import 'package:keybg/features/permission_page/permission_page_controller.dart';

class PermissionPageBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>PermissionPageController());
  }

}