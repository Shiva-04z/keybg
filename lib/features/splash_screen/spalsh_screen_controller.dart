import 'dart:convert';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../naviagtion/RoutesConstant.dart';


class SplashScreenController extends GetxController {

  @override
  void onReady() async {
    // TODO: implement onReady

    Get.offNamed(RoutesConstant.homePage);
  }


}



