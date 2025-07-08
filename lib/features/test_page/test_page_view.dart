import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:keybg/features/test_page/test_page_controller.dart';

class TestPageView extends GetView<TestPageController>
{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Test Page"),),
    );
  }
  
}