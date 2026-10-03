import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService.instance;

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<void> init() async {
    try {
      _user = await _service.restoreSession();
    } catch (_) {
      _user = null;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) {
    return _run(() async {
      _user = await _service.login(email: email, password: password);
    });
  }

  Future<bool> register(String name, String email, String password) {
    return _run(() async {
      _user = await _service.register(
        name: name,
        email: email,
        password: password,
      );
    });
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Something went wrong. Try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}