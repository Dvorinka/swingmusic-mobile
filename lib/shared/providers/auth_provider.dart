import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _authState = AuthState.loggedOut;
  String? _errorMessage;
  String? _baseUrl;
  String? _accessToken;
  String? _refreshToken;

  // Getters
  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  String? get baseUrl => _baseUrl;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _authState.isLoggedIn;
  bool get isLoggedOut => _authState.isLoggedOut;
  bool get isAuthenticating => _authState.isAuthenticating;
  bool get hasError => _authState.hasError;

  Future<void> initialize() async {
    await _loadStoredCredentials();
    _checkLoginStatus();
  }

  Future<void> loginWithUsernameAndPassword(
    String baseUrl,
    String username,
    String password,
  ) async {
    try {
      _setAuthenticating();
      
      // Validate URL
      if (!_isValidUrl(baseUrl)) {
        _setError('Please enter a valid server URL');
        return;
      }

      if (username.isEmpty || password.isEmpty) {
        _setError('Username and password are required');
        return;
      }

      // Make API call to login
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _baseUrl = baseUrl;

        // Store credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('base_url', _baseUrl);

        _setAuthenticated();
        _clearError();
      } else {
        _setError('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Login error: $e');
    }
  }

  Future<void> loginWithQrCode(String qrCode) async {
    try {
      _setAuthenticating();
      
      // TODO: Implement QR code login logic
      // For now, simulate successful login
      await Future.delayed(const Duration(seconds: 1));
      
      _accessToken = 'mock_token_from_qr';
      _refreshToken = 'mock_refresh_from_qr';

      // Store credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);
      await prefs.setString('refresh_token', _refreshToken!);

      _setAuthenticated();
      _clearError();
    } catch (e) {
      _setError('QR code login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('base_url');

      _accessToken = null;
      _refreshToken = null;
      _setLoggedOut();
      _clearError();
    } catch (e) {
      // Continue with logout even if storage fails
      _accessToken = null;
      _refreshToken = null;
      _setLoggedOut();
      _clearError();
    }
  }

  Future<void> refreshTokens() async {
    try {
      if (_refreshToken == null) return;

      // TODO: Implement token refresh logic
      // For now, just check if current token is still valid
    } catch (e) {
      _setError('Token refresh failed: $e');
    }
  }

  void _setAuthenticating() {
    _authState = AuthState.authenticating;
    _clearError();
    notifyListeners();
  }

  void _setAuthenticated() {
    _authState = AuthState.authenticated;
    _clearError();
    notifyListeners();
  }

  void _setLoggedOut() {
    _authState = AuthState.loggedOut;
    _clearError();
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _authState = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_authState == AuthState.error) {
      _authState = AuthState.loggedOut;
    }
    notifyListeners();
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      _baseUrl = prefs.getString('base_url');
      
      if (_accessToken != null) {
        _setAuthenticated();
      }
    } catch (e) {
      // Continue without stored credentials
      debugPrint('Error loading stored credentials: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    // TODO: Implement token validation
    // For now, assume stored token is valid
    if (_accessToken != null) {
      _setAuthenticated();
    }
  }

  // HTTP client with auth headers
  http.BaseClient get authenticatedHttpClient {
    return http.BaseClient(
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );
  }
}
