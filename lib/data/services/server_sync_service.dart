import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:swingmusic_mobile/app/services/swing_api_client.dart';

/// Server-side sync service using SwingMusic backend.
/// Uses existing /api/mobile-offline/* endpoints for cross-platform sync.
class ServerSyncService {
  static const String _lastSyncKey = 'last_cross_platform_sync';
  static const String _deviceIdKey = 'sync_device_id';

  late final SharedPreferences _prefs;
  late final SwingApiClient _apiClient;

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();
  Timer? _syncTimer;
  bool _isSyncing = false;
  String? _deviceId;

  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  ServerSyncService({SwingApiClient? apiClient})
      : _apiClient = apiClient ?? SwingApiClient();

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _deviceId = _prefs.getString(_deviceIdKey) ?? const Uuid().v4();
      await _prefs.setString(_deviceIdKey, _deviceId!);

      await _registerDevice();
      await _setupSyncTimer();
      await _checkAndPerformSync();

      debugPrint('Server sync service initialized (device: $_deviceId)');
    } catch (e) {
      debugPrint('Error initializing server sync: $e');
    }
  }

  Future<void> _registerDevice() async {
    try {
      await _apiClient.registerMobileDevice(
        name: 'SwingMusic Mobile',
        type: 'mobile',
        deviceId: _deviceId,
      );
    } catch (e) {
      debugPrint('Error registering device: $e');
    }
  }

  Future<void> _setupSyncTimer() async {
    final syncInterval = _prefs.getInt('sync_interval_minutes') ?? 30;
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(minutes: syncInterval), (timer) {
      _performScheduledSync();
    });
  }

  Future<void> _checkAndPerformSync() async {
    final lastSync = _prefs.getInt(_lastSyncKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncInterval = _prefs.getInt('sync_interval_minutes') ?? 30;

    if (now - lastSync > syncInterval * 60 * 1000) {
      await performSync();
    }
  }

  Future<void> _performScheduledSync() async {
    if (!_isSyncing) {
      await performSync();
    }
  }

  Future<void> performSync() async {
    if (_isSyncing || _deviceId == null) return;

    try {
      _isSyncing = true;
      _syncStatusController.add(SyncStatus(status: SyncStatusType.syncing));

      debugPrint('Starting server sync...');

      // Sync offline library metadata
      await _syncOfflineLibrary();

      // Push pending events (listening history, etc.)
      await _pushPendingEvents();

      // Update last sync time
      await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

      _syncStatusController.add(SyncStatus(
        status: SyncStatusType.completed,
        message: 'Server sync completed',
      ));

      debugPrint('Server sync completed');
    } catch (e) {
      debugPrint('Error during server sync: $e');
      _syncStatusController.add(SyncStatus(
        status: SyncStatusType.error,
        message: 'Sync failed: $e',
      ));
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncOfflineLibrary() async {
    try {
      final response = await _apiClient.getMobileOfflineLibrary(_deviceId!);
      debugPrint('Offline library synced: ${response.keys}');
    } catch (e) {
      debugPrint('Error syncing offline library: $e');
    }
  }

  Future<void> _pushPendingEvents() async {
    try {
      // Get pending events from local storage
      final pendingEvents = _prefs.getStringList('pending_events') ?? [];
      if (pendingEvents.isEmpty) return;

      final events = pendingEvents
          .map((e) => _parseEvent(e))
          .whereType<Map<String, dynamic>>()
          .toList();

      if (events.isNotEmpty) {
        await _apiClient.pushMobileEvents(
          deviceId: _deviceId!,
          events: events,
        );
        await _prefs.remove('pending_events');
        debugPrint('Pushed ${events.length} events to server');
      }
    } catch (e) {
      debugPrint('Error pushing pending events: $e');
    }
  }

  Map<String, dynamic>? _parseEvent(String eventStr) {
    try {
      // Simple JSON parse - in production use proper serialization
      return {
        'raw': eventStr,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      };
    } catch (e) {
      return null;
    }
  }

  // Public API methods
  Future<void> setSyncInterval(int minutes) async {
    await _prefs.setInt('sync_interval_minutes', minutes);
    await _setupSyncTimer();
  }

  Future<void> enableAutoSync(bool enabled) async {
    await _prefs.setBool('auto_sync_enabled', enabled);

    if (enabled) {
      await _checkAndPerformSync();
    } else {
      _syncTimer?.cancel();
    }
  }

  Future<SyncInfo> getSyncInfo() async {
    final lastSync = _prefs.getInt(_lastSyncKey) ?? 0;
    final autoSyncEnabled = _prefs.getBool('auto_sync_enabled') ?? true;
    final syncInterval = _prefs.getInt('sync_interval_minutes') ?? 30;

    return SyncInfo(
      lastSyncTime: DateTime.fromMillisecondsSinceEpoch(lastSync),
      autoSyncEnabled: autoSyncEnabled,
      syncInterval: Duration(minutes: syncInterval),
      isSyncing: _isSyncing,
      nextSyncTime: DateTime.now().add(Duration(minutes: syncInterval)),
    );
  }

  Future<void> forceSync() async {
    await performSync();
  }

  Future<void> clearSyncData() async {
    try {
      await _prefs.remove(_lastSyncKey);
      await _prefs.remove('pending_events');
      debugPrint('Server sync data cleared');
    } catch (e) {
      debugPrint('Error clearing sync data: $e');
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

// Models
enum SyncStatusType { idle, syncing, completed, error }

class SyncStatus {
  final SyncStatusType status;
  final String? message;
  final int? progress;

  SyncStatus({
    required this.status,
    this.message,
    this.progress,
  });
}

class SyncInfo {
  final DateTime lastSyncTime;
  final bool autoSyncEnabled;
  final Duration syncInterval;
  final bool isSyncing;
  final DateTime nextSyncTime;

  SyncInfo({
    required this.lastSyncTime,
    required this.autoSyncEnabled,
    required this.syncInterval,
    required this.isSyncing,
    required this.nextSyncTime,
  });
}
