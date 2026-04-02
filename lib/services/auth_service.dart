import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _baseUrlKey = 'base_url';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';

  String? _baseUrl;
  String? _accessToken;
  String? _refreshToken;
  String? _username;
  String? _userId;

  // Stream controllers for authentication state
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();
  final StreamController<String?> _tokenController =
      StreamController<String?>.broadcast();

  Stream<bool> get authStateStream => _authStateController.stream;
  Stream<String?> get tokenStream => _tokenController.stream;

  // Getters
  String? get baseUrl => _baseUrl;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  String? get userId => _userId;
  bool get isLoggedIn => _accessToken != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_baseUrlKey);
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _username = prefs.getString(_usernameKey);
    _userId = prefs.getString(_userIdKey);

    _authStateController.add(isLoggedIn);
    _tokenController.add(_accessToken);
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  Future<bool> loginWithUsername(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> loginWithQRCode(String qrData) async {
    try {
      // Parse QR code data (assuming it contains auth token or session info)
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/qr-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qr_data': qrData}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('QR login error: $e');
      return false;
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    _accessToken = data['access_token'];
    _refreshToken = data['refresh_token'];
    _username = data['username'];
    _userId = data['user_id']?.toString();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, _accessToken ?? '');
    await prefs.setString(_refreshTokenKey, _refreshToken ?? '');
    await prefs.setString(_usernameKey, _username ?? '');
    await prefs.setString(_userIdKey, _userId ?? '');

    _authStateController.add(true);
    _tokenController.add(_accessToken);
  }

  Future<bool> refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _accessToken ?? '');
        await prefs.setString(_refreshTokenKey, _refreshToken ?? '');

        _tokenController.add(_accessToken);
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }

    return false;
  }

  Future<void> logout() async {
    try {
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$_baseUrl/api/auth/logout'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    await _clearTokens();
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _username = null;
    _userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);

    _authStateController.add(false);
    _tokenController.add(null);
  }

  // Get authorization header for API requests
  Map<String, String> get authHeaders => {
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  void dispose() {
    _authStateController.close();
    _tokenController.close();
  }
}
