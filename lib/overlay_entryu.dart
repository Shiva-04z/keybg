// overlay_entry.dart
import 'package:flutter/material.dart';

import 'main.dart';

@pragma('vm:entry-point')
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Material(
      child: OverlayWidget(),
    ),
  ));
}