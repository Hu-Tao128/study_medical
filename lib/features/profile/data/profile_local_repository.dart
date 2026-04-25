import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_medical/features/profile/data/user_profile_model.dart';

class ProfileLocalRepository {
  static const String _boxName = 'profile_cache';
  static const String _profileKey = 'current_user';

  Box<UserProfile>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<UserProfile>(_boxName);
  }

  Box<UserProfile> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'ProfileLocalRepository not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  Future<UserProfile?> getProfile() async {
    try {
      return box.get(_profileKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await box.put(_profileKey, profile);
  }

  Future<void> clearProfile() async {
    await box.delete(_profileKey);
  }

  Future<bool> hasProfile() async {
    return box.containsKey(_profileKey);
  }
}
