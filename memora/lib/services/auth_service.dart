import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiClient _api = ApiClient.instance;
  final StorageService _storage = StorageService.instance;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      ApiConstants.register,
      body: {'name': name, 'email': email, 'password': password},
    );
    return _saveSession(data);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );
    return _saveSession(data);
  }

  Future<UserModel?> restoreSession() async {
    final token = await _storage.getToken();
    final user = await _storage.getUser();
    if (token == null || token.isEmpty || user == null) return null;
    _api.setToken(token);
    return user;
  }

  Future<void> logout() async {
    _api.setToken(null);
    await _storage.clear();
  }

  Future<UserModel> _saveSession(dynamic data) async {
    final token = data is Map ? data['token']?.toString() : null;
    if (token == null || token.isEmpty || data['user'] is! Map) {
      throw ApiException('Login failed. Try again.');
    }
    final user = UserModel.fromJson(
      Map<String, dynamic>.from(data['user'] as Map),
    );
    _api.setToken(token);
    await _storage.saveSession(token, user);
    return user;
  }
}