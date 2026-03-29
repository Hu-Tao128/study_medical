import 'package:flutter/foundation.dart';
import '../../../../core/network/backend_api.dart';
import '../../data/user_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final BackendApi _backendApi;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider({required BackendApi backendApi}) : _backendApi = backendApi;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _backendApi.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _backendApi.updateProfile(request);
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
    notifyListeners();
  }
}
