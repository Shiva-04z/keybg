// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_app_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedAppInfoAdapter extends TypeAdapter<CachedAppInfo> {
  @override
  final int typeId = 0;

  @override
  CachedAppInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedAppInfo()
      ..name = fields[0] as String
      ..packageName = fields[1] as String
      ..versionName = fields[2] as String?
      ..versionCode = fields[3] as int?
      ..icon = fields[4] as Uint8List?
      ..builtWith = fields[5] as int
      ..installedTimestamp = fields[6] as int?;
  }

  @override
  void write(BinaryWriter writer, CachedAppInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.packageName)
      ..writeByte(2)
      ..write(obj.versionName)
      ..writeByte(3)
      ..write(obj.versionCode)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.builtWith)
      ..writeByte(6)
      ..write(obj.installedTimestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedAppInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
