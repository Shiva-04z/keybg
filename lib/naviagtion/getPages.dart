import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:keybg/features/app_page/app_page_binidings.dart';
import 'package:keybg/features/app_page/app_page_view.dart';
import 'package:keybg/features/home_page/home_page_binidings.dart';
import 'package:keybg/features/home_page/home_page_view.dart';
import 'package:keybg/features/splash_screen/splash_screen_bindings.dart';
import 'package:keybg/features/splash_screen/splash_screen_view.dart';
import 'package:keybg/naviagtion/RoutesConstant.dart';

List <GetPage> getPages = [
  GetPage(name: RoutesConstant.homePage, page: ()=>HomePageView(),binding: HomePageBindings()),
  GetPage(name: RoutesConstant.splashPage, page: ()=>SplashScreenView(),binding: SplashScreenBindings()),
  GetPage(name: RoutesConstant.appPage, page: ()=>AppPageView(),binding: AppPageBindings(),transition: Transition.downToUp,  transitionDuration: Duration(microseconds: 30)),
];