import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/swing_api_client.dart';

class SessionController extends ChangeNotifier {
  SessionController({required SwingApiClient apiClient}) : _api = apiClient {
    _api.setTokenProvider(getValidAccessToken);
  }

  final SwingApiClient _api;

  bool _initializing = true;
  bool _setupComplete = false;
  String? _setupMessage;

  String? _baseUrl;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _accessTokenExpiry;

  Map<String, dynamic> _user = const {};
  String? _error;

  String _streamingQuality = '320';
  String _downloadQuality = '320';
  bool _adaptiveStreaming = true;
  bool _wifiOnlyDownloads = false;
  String? _downloadDirectory;
  String? _mobileDeviceId;

  Timer? _refreshTimer;

  bool get initializing => _initializing;
  bool get setupComplete => _setupComplete;
  String? get setupMessage => _setupMessage;

  bool get hasServer => _baseUrl != null && _baseUrl!.isNotEmpty;
  String? get baseUrl => _baseUrl;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  Map<String, dynamic> get user => _user;
  String? get username => _user['username']?.toString();
  String? get error => _error;

  String get streamingQuality => _streamingQuality;
  String get downloadQuality => _downloadQuality;
  bool get adaptiveStreaming => _adaptiveStreaming;
  bool get wifiOnlyDownloads => _wifiOnlyDownloads;
  String? get downloadDirectory => _downloadDirectory;
  String? get mobileDeviceId => _mobileDeviceId;

  Future<void> initialize() async {
    _initializing = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    _baseUrl = prefs.getString(_kBaseUrl);
    _accessToken = prefs.getString(_kAccessToken);
    _refreshToken = prefs.getString(_kRefreshToken);

    final expiryRaw = prefs.getString(_kAccessTokenExpiry);
    _accessTokenExpiry = expiryRaw == null
        ? null
        : DateTime.tryParse(expiryRaw);

    _streamingQuality = prefs.getString(_kStreamingQuality) ?? '320';
    _downloadQuality = prefs.getString(_kDownloadQuality) ?? '320';
    _adaptiveStreaming = prefs.getBool(_kAdaptiveStreaming) ?? true;
    _wifiOnlyDownloads = prefs.getBool(_kWifiOnlyDownloads) ?? false;
    _downloadDirectory = prefs.getString(_kDownloadDirectory);
    _mobileDeviceId = prefs.getString(_kMobileDeviceId);

    if (_baseUrl != null && _baseUrl!.isNotEmpty) {
      _api.setBaseUrl(_baseUrl!);
      await _refreshSetupStatus();

      if (_setupComplete && _accessToken != null && _accessToken!.isNotEmpty) {
        try {
          await _loadCurrentUser();
          _scheduleRefresh();
        } catch (_) {
          await _clearAuth(keepServer: true);
        }
      }
    }

    _initializing = false;
    notifyListeners();
  }

  Future<void> setServerUrl(String value) async {
    final normalized = _normalizeUrl(value);
    final previousBaseUrl = _baseUrl;

    final result = await _api.getSetupStatus(serverBaseUrl: normalized);
    final status = (result['status'] as num?)?.toInt() ?? 0;
    if (status < 200 || status >= 400) {
      throw ApiError('Unable to reach server', statusCode: status);
    }

    final data = result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    _setupComplete = data['setup_completed'] == true;
    _setupMessage = _setupComplete
        ? null
        : 'Server setup is not completed yet. Finish setup in web UI first.';

    _baseUrl = normalized;
    _api.setBaseUrl(normalized);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, normalized);
    if (previousBaseUrl != normalized) {
      _mobileDeviceId = null;
      await prefs.remove(_kMobileDeviceId);
    }

    if (!_setupComplete) {
      await _clearAuth(keepServer: true);
    }

    _error = null;
    notifyListeners();
  }

  Future<void> refreshSetupStatus() async {
    if (!hasServer) return;
    await _refreshSetupStatus();
    notifyListeners();
  }

  Future<void> loginWithCredentials({
    required String username,
    required String password,
  }) async {
    if (!hasServer) {
      throw ApiError('Server URL is not configured');
    }

    final result = await _api.login(
      serverBaseUrl: _baseUrl!,
      username: username,
      password: password,
    );

    final status = (result['status'] as num?)?.toInt() ?? 0;
    if (status != 200) {
      throw ApiError('Login failed', statusCode: status);
    }

    final payload =
        result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    await _applyAuthPayload(payload);
    await _loadCurrentUser();
    _error = null;
    notifyListeners();
  }

  Future<void> loginWithPairCode({
    required String serverUrl,
    required String code,
  }) async {
    final normalized = _normalizeUrl(serverUrl);
    final normalizedCode = _normalizePairCode(code);
    if (normalizedCode.isEmpty) {
      throw const FormatException('Pair code cannot be empty');
    }
    final result = await _api.pairWithCode(
      serverBaseUrl: normalized,
      code: normalizedCode,
    );

    final status = (result['status'] as num?)?.toInt() ?? 0;
    if (status != 200) {
      throw ApiError('Pair login failed', statusCode: status);
    }

    _baseUrl = normalized;
    _api.setBaseUrl(normalized);

    final payload =
        result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    await _applyAuthPayload(payload);
    await _loadCurrentUser();
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearAuth(keepServer: true);
    notifyListeners();
  }

  Future<void> clearServerConnection() async {
    await _clearAuth(keepServer: false);
    notifyListeners();
  }

  Future<String?> getValidAccessToken() async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return null;
    }

    final expiresAt = _accessTokenExpiry;
    final needsRefresh =
        expiresAt == null ||
        DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 2)));
    if (!needsRefresh) {
      return _accessToken;
    }

    final refresh = _refreshToken;
    if (refresh == null || refresh.isEmpty || !hasServer) {
      return _accessToken;
    }

    try {
      final result = await _api.refreshToken(refreshToken: refresh);
      final status = (result['status'] as num?)?.toInt() ?? 0;
      if (status == 200) {
        final data =
            result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
        await _applyAuthPayload(data, keepExistingRefresh: true, notify: false);
      }
    } catch (_) {
      return _accessToken;
    }

    return _accessToken;
  }

  Future<void> saveQualitySettings({
    required String streamingQuality,
    required String downloadQuality,
    required bool adaptiveStreaming,
    required bool wifiOnlyDownloads,
  }) async {
    _streamingQuality = streamingQuality;
    _downloadQuality = downloadQuality;
    _adaptiveStreaming = adaptiveStreaming;
    _wifiOnlyDownloads = wifiOnlyDownloads;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStreamingQuality, _streamingQuality);
    await prefs.setString(_kDownloadQuality, _downloadQuality);
    await prefs.setBool(_kAdaptiveStreaming, _adaptiveStreaming);
    await prefs.setBool(_kWifiOnlyDownloads, _wifiOnlyDownloads);

    notifyListeners();
  }

  Future<void> saveDownloadDirectory(String? path) async {
    _downloadDirectory = path;
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_kDownloadDirectory);
    } else {
      await prefs.setString(_kDownloadDirectory, path);
    }
    notifyListeners();
  }

  Future<void> saveMobileDeviceId(String? value) async {
    _mobileDeviceId = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove(_kMobileDeviceId);
    } else {
      await prefs.setString(_kMobileDeviceId, value);
    }
    notifyListeners();
  }

  Future<String> resolveStreamingQuality() async {
    final preferred = _streamingQuality;
    if (!_adaptiveStreaming) {
      return preferred;
    }

    try {
      final values = await _connectivityValues();
      final hasWifiLikeNetwork =
          values.contains(ConnectivityResult.wifi) ||
          values.contains(ConnectivityResult.ethernet) ||
          values.contains(ConnectivityResult.vpn);

      if (hasWifiLikeNetwork) {
        return preferred;
      }

      final hasMobileNetwork = values.contains(ConnectivityResult.mobile);
      if (hasMobileNetwork || values.contains(ConnectivityResult.none)) {
        return _dataSaverQuality(preferred);
      }
    } catch (_) {
      // Keep preferred quality when connectivity APIs are unavailable.
    }

    return preferred;
  }

  ({String serverUrl, String code}) parseQrPayload(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw const FormatException('Empty QR payload');
    }

    if (value.startsWith('{') && value.endsWith('}')) {
      try {
        final parsed = jsonDecode(value);
        if (parsed is Map) {
          final server =
              parsed['server_url']?.toString() ??
              parsed['server']?.toString() ??
              parsed['url']?.toString() ??
              '';
          final code =
              parsed['code']?.toString() ??
              parsed['pair_code']?.toString() ??
              '';

          if (server.isNotEmpty && code.isNotEmpty) {
            return (
              serverUrl: _normalizeUrl(server),
              code: _normalizePairCode(code),
            );
          }
        }
      } catch (_) {
        // Continue to other payload formats.
      }
    }

    try {
      final uri = Uri.parse(value);
      final uriCode =
          uri.queryParameters['code'] ?? uri.queryParameters['pair_code'] ?? '';
      final uriServer =
          uri.queryParameters['server'] ??
          uri.queryParameters['server_url'] ??
          uri.queryParameters['url'] ??
          '';

      if (uriCode.isNotEmpty && uriServer.isNotEmpty) {
        return (
          serverUrl: _normalizeUrl(uriServer),
          code: _normalizePairCode(uriCode),
        );
      }

      if (uriCode.isNotEmpty &&
          (uri.scheme == 'http' || uri.scheme == 'https')) {
        final server = Uri(
          scheme: uri.scheme,
          userInfo: uri.userInfo,
          host: uri.host,
          port: uri.hasPort ? uri.port : null,
        ).toString().replaceAll(RegExp(r'/+$'), '');
        return (
          serverUrl: _normalizeUrl(server),
          code: _normalizePairCode(uriCode),
        );
      }
    } catch (_) {
      // Continue to legacy payload formats.
    }

    final pipeParts = value.split('|');
    if (pipeParts.length == 2) {
      return (
        serverUrl: _normalizeUrl(pipeParts.first),
        code: _normalizePairCode(pipeParts.last),
      );
    }

    final tokens = value
        .split(RegExp(r'\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (tokens.length >= 2) {
      final server = tokens.sublist(0, tokens.length - 1).join(' ');
      final code = tokens.last;
      return (serverUrl: _normalizeUrl(server), code: _normalizePairCode(code));
    }

    throw const FormatException('Unsupported QR payload format');
  }

  Future<void> _refreshSetupStatus() async {
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _setupComplete = false;
      _setupMessage = null;
      return;
    }

    final result = await _api.getSetupStatus(serverBaseUrl: _baseUrl);
    final status = (result['status'] as num?)?.toInt() ?? 0;

    if (status < 200 || status >= 400) {
      _setupComplete = false;
      _setupMessage = 'Could not load setup status from server.';
      return;
    }

    final data = result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    _setupComplete = data['setup_completed'] == true;
    _setupMessage = _setupComplete
        ? null
        : 'Server setup is not completed yet. Finish setup in web UI first.';
  }

  Future<void> _loadCurrentUser() async {
    final user = await _api.getCurrentUser();
    _user = user;
  }

  Future<void> _applyAuthPayload(
    Map<String, dynamic> payload, {
    bool keepExistingRefresh = false,
    bool notify = true,
  }) async {
    final access =
        payload['accesstoken']?.toString() ??
        payload['access_token']?.toString();
    final refresh =
        payload['refreshtoken']?.toString() ??
        payload['refresh_token']?.toString();
    final maxAge =
        (payload['maxage'] as num?)?.toInt() ??
        (payload['expires_in'] as num?)?.toInt() ??
        3600;

    if (access == null || access.isEmpty) {
      throw const FormatException('Missing access token in auth payload');
    }

    _accessToken = access;
    _refreshToken = keepExistingRefresh
        ? (_refreshToken ?? refresh ?? '')
        : (refresh ?? '');
    _accessTokenExpiry = DateTime.now().add(Duration(seconds: maxAge));

    final prefs = await SharedPreferences.getInstance();
    if (_baseUrl != null && _baseUrl!.isNotEmpty) {
      await prefs.setString(_kBaseUrl, _baseUrl!);
    }
    await prefs.setString(_kAccessToken, _accessToken!);
    await prefs.setString(_kRefreshToken, _refreshToken ?? '');
    await prefs.setString(
      _kAccessTokenExpiry,
      _accessTokenExpiry!.toIso8601String(),
    );

    _scheduleRefresh();

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _clearAuth({required bool keepServer}) async {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiry = null;
    _user = const {};
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
    await prefs.remove(_kAccessTokenExpiry);

    if (!keepServer) {
      _baseUrl = null;
      _setupComplete = false;
      _setupMessage = null;
      _mobileDeviceId = null;
      await prefs.remove(_kBaseUrl);
      await prefs.remove(_kMobileDeviceId);
    }
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    final expiry = _accessTokenExpiry;
    if (expiry == null) return;

    final refreshAt = expiry.subtract(const Duration(minutes: 2));
    final delay = refreshAt.difference(DateTime.now());
    if (delay.isNegative) {
      return;
    }

    _refreshTimer = Timer(delay, () async {
      await getValidAccessToken();
    });
  }

  String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Server URL cannot be empty');
    }

    final uri = Uri.parse(trimmed);
    if (!uri.hasScheme) {
      throw const FormatException(
        'Server URL must include http:// or https://',
      );
    }

    if (uri.host.isEmpty) {
      throw const FormatException('Server URL host is invalid');
    }

    final normalized = Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '',
    );

    return normalized.toString().replaceAll(RegExp(r'/+$'), '');
  }

  String _normalizePairCode(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  Future<List<ConnectivityResult>> _connectivityValues() async {
    return Connectivity().checkConnectivity();
  }

  String _dataSaverQuality(String quality) {
    final parsed = int.tryParse(quality);
    if (parsed == null) {
      return '128';
    }

    if (parsed <= 128) {
      return quality;
    }

    if (parsed <= 192) {
      return '128';
    }

    if (parsed <= 320) {
      return '192';
    }

    return '256';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

const _kBaseUrl = 'session.base_url';
const _kAccessToken = 'session.access_token';
const _kRefreshToken = 'session.refresh_token';
const _kAccessTokenExpiry = 'session.access_token_expiry';
const _kStreamingQuality = 'settings.streaming_quality';
const _kDownloadQuality = 'settings.download_quality';
const _kAdaptiveStreaming = 'settings.adaptive_streaming';
const _kWifiOnlyDownloads = 'settings.wifi_only_downloads';
const _kDownloadDirectory = 'settings.download_directory';
const _kMobileDeviceId = 'session.mobile_device_id';
