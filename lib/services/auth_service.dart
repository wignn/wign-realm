import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  // Login
  Future<AuthResponse> login(String email, String password) async {
    final response = await _api.post(
      ApiConfig.login,
      data: {'email': email, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(response.data);

    // Save tokens
    if (authResponse.accessToken != null) {
      await _storage.saveTokens(
        authResponse.accessToken!,
        authResponse.refreshToken,
      );
    }

    return authResponse;
  }

  // Register
  Future<AuthResponse> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await _api.post(
      ApiConfig.register,
      data: {'username': username, 'email': email, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(response.data);

    // Save tokens
    if (authResponse.accessToken != null) {
      await _storage.saveTokens(
        authResponse.accessToken!,
        authResponse.refreshToken,
      );
    }

    return authResponse;
  }

  // Get current user
  Future<User> getMe() async {
    final response = await _api.get(ApiConfig.me);
    final data = response.data['data'] ?? response.data;
    return User.fromJson(data);
  }

  // Logout
  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout);
    } catch (e) {
      // Ignore errors
    }
    await _storage.clearTokens();
    await _storage.clearUserData();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  // Auto login - returns user if valid token exists
  Future<User?> tryAutoLogin() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) return null;

    try {
      return await getMe();
    } catch (e) {
      await _storage.clearTokens();
      return null;
    }
  }
}
