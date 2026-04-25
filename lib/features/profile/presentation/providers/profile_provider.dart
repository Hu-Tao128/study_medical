import 'package:flutter/foundation.dart';
import 'package:study_medical/core/network/backend_api.dart';
import 'package:study_medical/features/profile/data/profile_local_repository.dart';
import 'package:study_medical/features/profile/data/user_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileLocalRepository _localRepo;
  final BackendApi _backendApi;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  ProfileProvider({
    required ProfileLocalRepository localRepo,
    required BackendApi backendApi,
  }) : _localRepo = localRepo,
       _backendApi = backendApi;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  Future<void> initFromCache() async {
    final cached = await _localRepo.getProfile();
    if (cached != null) {
      _profile = cached;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    final hasExisting = _profile != null;
    if (!hasExisting || !_isRefreshing) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _profile = await _backendApi.getProfile();
      if (_profile != null) {
        await _localRepo.saveProfile(_profile!);
      }
      _error = null;
    } catch (e) {
      if (_profile == null) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _backendApi.updateProfile(request);
      _profile = updated;
      await _localRepo.saveProfile(updated);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    _localRepo.clearProfile();
    notifyListeners();
  }
}
