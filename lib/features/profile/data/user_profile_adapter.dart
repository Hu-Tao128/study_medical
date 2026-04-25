import 'package:hive/hive.dart';
import 'package:study_medical/features/profile/data/user_profile_model.dart';

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      authId: fields[1] as String,
      email: fields[2] as String,
      displayName: fields[3] as String?,
      role: fields[4] as String?,
      lastLoginAt: fields[5] as DateTime?,
      photoUrl: fields[6] as String?,
      preferredLanguage: fields[7] as String?,
      theme: fields[8] as String?,
      level: fields[9] as String?,
      semester: fields[10] as int?,
      career: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.authId)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.displayName)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.lastLoginAt)
      ..writeByte(6)
      ..write(obj.photoUrl)
      ..writeByte(7)
      ..write(obj.preferredLanguage)
      ..writeByte(8)
      ..write(obj.theme)
      ..writeByte(9)
      ..write(obj.level)
      ..writeByte(10)
      ..write(obj.semester)
      ..writeByte(11)
      ..write(obj.career);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
