import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_state.dart';
import '../../data/services/enhanced_api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _authState = AuthState.loggedOut;
  String? _errorMessage;
  String? _baseUrl;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  Timer? _refreshTimer;
  final EnhancedApiService _apiService;

  AuthProvider({EnhancedApiService? apiService})
      : _apiService = apiService ?? EnhancedApiService();

  // Getters
  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  String? get baseUrl => _baseUrl;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _authState.isLoggedIn;
  bool get isLoggedOut => _authState.isLoggedOut;
  bool get isAuthenticating => _authState.isAuthenticating;
  bool get isTokenExpired {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!);
  }

  bool get shouldRefreshToken {
    if (_tokenExpiry == null) return true;
    // Refresh 5 minutes before expiry
    final refreshTime = _tokenExpiry!.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(refreshTime);
  }

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

        // Calculate token expiry (default 1 hour if not specified)
        final expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        // Store credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('base_url', _baseUrl!);
        await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());

        // Setup token refresh
        _setupTokenRefresh();

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

      // Parse QR code data (format: url|pairCode)
      final parts = qrCode.split('|');
      if (parts.length != 2) {
        _setError('Invalid QR code format');
        return;
      }

      final url = parts[0];
      final pairCode = parts[1];

      if (!_isValidUrl(url)) {
        _setError('Invalid server URL in QR code');
        return;
      }

      // Make API call to login with QR code
      final response = await http.post(
        Uri.parse('$url/api/auth/qr-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pair_code': pairCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _baseUrl = url;

        // Calculate token expiry
        final expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        // Store credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('base_url', _baseUrl!);
        await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());

        // Setup token refresh
        _setupTokenRefresh();

        _setAuthenticated();
        _clearError();
      } else {
        _setError('QR login failed: ${response.statusCode}');
      }
    } catch (e) {
      _setError('QR code login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _clearTokens();
      _setLoggedOut();
      _clearError();
    } catch (e) {
      // Continue with logout even if storage fails
      await _clearTokens();
      _setLoggedOut();
      _clearError();
    }
  }

  Future<void> _clearTokens() async {
    // Cancel refresh timer
    _refreshTimer?.cancel();
    _refreshTimer = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('base_url');
    await prefs.remove('token_expiry');

    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
  }

  Future<void> refreshTokens() async {
    try {
      if (_refreshToken == null || _baseUrl == null) {
        await logout();
        return;
      }

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
        _refreshToken = data['refresh_token'] ?? _refreshToken;

        // Update token expiry
        final expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        // Store updated credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());

        // Setup next refresh
        _setupTokenRefresh();
      } else {
        // Refresh failed, logout user
        await logout();
      }
    } catch (e) {
      _setError('Token refresh failed: $e');
      await logout();
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

      final expiryString = prefs.getString('token_expiry');
      if (expiryString != null) {
        _tokenExpiry = DateTime.parse(expiryString);
      }

      if (_accessToken != null && !isTokenExpired) {
        _setupTokenRefresh();
        _setAuthenticated();
      } else if (_accessToken != null && shouldRefreshToken) {
        await refreshTokens();
      }
    } catch (e) {
      // Continue without stored credentials
      debugPrint('Error loading stored credentials: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    if (_accessToken == null) return;

    try {
      // Validate token by making a lightweight API call
      final userInfo = await _apiService.getUserInfo();
      if (userInfo.isNotEmpty) {
        _setAuthenticated();
      } else {
        // Token is invalid, clear it
        await _clearTokens();
      }
    } catch (e) {
      // Token validation failed, clear it
      debugPrint('Token validation failed: $e');
      await _clearTokens();
    }
  }

  void _setupTokenRefresh() {
    _refreshTimer?.cancel();

    if (_tokenExpiry == null) return;

    // Schedule refresh 5 minutes before expiry
    final refreshTime = _tokenExpiry!.subtract(const Duration(minutes: 5));
    final durationUntilRefresh = refreshTime.difference(DateTime.now());

    if (durationUntilRefresh.inMilliseconds > 0) {
      _refreshTimer = Timer(durationUntilRefresh, () {
        refreshTokens();
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // HTTP client with auth headers
  http.Client get authenticatedHttpClient {
    return _AuthenticatedClient(this);
  }

  // Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    if (_accessToken == null) return null;

    if (shouldRefreshToken) {
      await refreshTokens();
    }

    return _accessToken;
  }
}

class _AuthenticatedClient extends http.BaseClient {
  final AuthProvider _authProvider;

  _AuthenticatedClient(this._authProvider);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer ${_authProvider._accessToken}';
    request.headers['Content-Type'] = 'application/json';
    return request.send();
  }
}
