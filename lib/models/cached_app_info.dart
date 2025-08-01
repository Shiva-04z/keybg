// lib/models/cached_app_info.dart
import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'cached_app_info.g.dart'; // This file will be generated

@HiveType(typeId: 0)
class CachedAppInfo extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String packageName;

  @HiveField(2)
  String? versionName;

  @HiveField(3)
  int? versionCode;

  @HiveField(4)
  Uint8List? icon;

  @HiveField(5)
  late int builtWith; // Storing enum as index

  @HiveField(6)
  int? installedTimestamp;
}