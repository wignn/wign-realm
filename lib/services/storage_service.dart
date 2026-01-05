import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _readerFontSizeKey = 'reader_font_size';
  static const String _readerThemeKey = 'reader_theme';

  // Token Management
  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // User Data (SharedPreferences for non-sensitive data)
  Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userData);
  }

  Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Reader Settings
  Future<void> saveReaderFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_readerFontSizeKey, size);
  }

  Future<double> getReaderFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_readerFontSizeKey) ?? 18.0;
  }

  Future<void> saveReaderTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readerThemeKey, theme);
  }

  Future<String> getReaderTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_readerThemeKey) ?? 'dark';
  }

  // Clear All
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
