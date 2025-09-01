import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_analog_clock/animated_analog_clock.dart';
import '../../core/globals.dart' as glb;
import '../../naviagtion/RoutesConstant.dart';
import 'my_home_screen_controller.dart';

class MyHomeScreenView extends GetView<MyHomeScreenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // 1. Add GestureDetector to detect the swipe up
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // A negative velocity indicates an upward swipe.
          // The threshold (-500) prevents accidental swipes.
          if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
            Get.toNamed(RoutesConstant.appPage);
          }
        },
        child: Stack(
          children: [
            // Background Wallpaper
            Obx(() => glb.wallpaperPath.isNotEmpty
                ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(glb.wallpaperPath.value)),
                  fit: BoxFit.cover,
                ),
              ),
            )
                : Container(color: Colors.grey[900])),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Main Content
            Column(
              children: [
                // Clock and Date Section
                Expanded(
                  // 2. Adjusted flex to give clock more space
                  flex: 5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedAnalogClock(
                          backgroundGradient: RadialGradient(
                            colors: [
                              Color(0xff152238),
                              Color(0xff3c649f),
                            ],
                          ),
                          hourHandColor: Colors.white,
                          minuteHandColor: Colors.white,
                          secondHandColor: Colors.lightBlueAccent,
                          centerDotColor: Colors.lightBlueAccent,
                          hourDashColor: Colors.lightBlueAccent,
                          dialType: DialType.numberAndDashes,
                        ),
                        SizedBox(height: 20),
                        // Digital Time and Date
                        Obx(() => Column(
                          children: [
                            Text(
                              controller.currentTime.value,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              controller.currentDate.value,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),

                // 3. Removed the Quick Access Icons GridView

                // 4. Removed the FloatingActionButton

                // Add a flexible spacer at the bottom with an indicator
                Spacer(flex: 1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Icon(Icons.keyboard_arrow_up, color: Colors.white.withOpacity(0.7), size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
