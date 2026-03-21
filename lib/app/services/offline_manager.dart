import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/music_models.dart';
import '../models/offline_models.dart';
import '../state/session_controller.dart';
import 'local_cache_service.dart';
import 'swing_api_client.dart';

class OfflineManager {
  OfflineManager({
    required SwingApiClient api,
    required SessionController session,
    required LocalCacheService cache,
  }) : _api = api,
       _session = session,
       _cache = cache;

  final SwingApiClient _api;
  final SessionController _session;
  final LocalCacheService _cache;
  final Uuid _uuid = const Uuid();

  Future<List<OfflineTrack>> loadOfflineTracks() {
    return _cache.getOfflineTracks();
  }

  Future<String> resolveDownloadDirectory() async {
    final configured = _session.downloadDirectory;
    if (configured != null && configured.isNotEmpty) {
      final dir = Directory(configured);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    }

    final docs = await getApplicationDocumentsDirectory();
    final fallback = Directory('${docs.path}/offline_tracks');
    if (!fallback.existsSync()) {
      await fallback.create(recursive: true);
    }
    return fallback.path;
  }

  Future<DownloadTask> downloadTrackToDevice(
    MusicTrack track, {
    required void Function(DownloadTask task) onProgress,
    String? collectionLabel,
  }) async {
    if (track.trackhash.isEmpty || track.filepath.isEmpty) {
      throw ApiError('Track is not available for local download');
    }

    if (_session.wifiOnlyDownloads) {
      final isWifi = await _isOnWifiLikeNetwork();
      if (!isWifi) {
        throw ApiError(
          'Wi-Fi only downloads are enabled. Connect to Wi-Fi to continue.',
        );
      }
    }

    final directory = await resolveDownloadDirectory();
    final quality = _session.downloadQuality;
    final container = _containerForQuality(quality);
    final extension = _extensionForContainer(container);
    final targetDirectory = await _resolveTargetDirectory(
      directory,
      track,
      collectionLabel,
    );
    final normalizedHash = track.trackhash.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final safeHash = normalizedHash.length > 8
        ? normalizedHash.substring(0, 8)
        : normalizedHash;
    final titleBase = _sanitizeFilePart(track.title, fallback: 'track');
    final fileName = '${titleBase}_$safeHash.$extension';
    final outputPath = '$targetDirectory/$fileName';

    final existingEntries = await _cache.getOfflineTracks();
    var hadDifferentQuality = false;
    for (final entry in existingEntries) {
      if (entry.trackhash != track.trackhash) continue;
      final sameQuality =
          entry.quality == quality || entry.quality.startsWith('$quality/');
      if (!sameQuality) {
        hadDifferentQuality = true;
        final oldFile = File(entry.localPath);
        if (oldFile.existsSync()) {
          try {
            await oldFile.delete();
          } catch (_) {
            // Keep going; stale files are best-effort cleanup.
          }
        }
        continue;
      }
      final existingFile = File(entry.localPath);
      if (!existingFile.existsSync()) continue;

      await _syncOfflineTrackAdded(entry, collectionLabel: collectionLabel);

      final completedTask = DownloadTask(
        id: _uuid.v4(),
        trackhash: track.trackhash,
        title: track.title,
        progress: 1,
        state: 'completed',
      );
      onProgress(completedTask);
      return completedTask;
    }

    if (hadDifferentQuality) {
      await _cache.removeOfflineTrack(track.trackhash);
    }

    var task = DownloadTask(
      id: _uuid.v4(),
      trackhash: track.trackhash,
      title: track.title,
      progress: 0,
      state: 'downloading',
    );
    onProgress(task);

    try {
      final url = _api.buildStreamUrl(
        trackhash: track.trackhash,
        filepath: track.filepath,
        quality: quality,
        container: container,
      );

      await _api.downloadFile(
        url,
        outputPath,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final progress = (received / total).clamp(0.0, 1.0);
          task = task.copyWith(progress: progress);
          onProgress(task);
        },
      );

      final offlineTrack = OfflineTrack(
        trackhash: track.trackhash,
        title: track.title,
        artist: track.artist,
        album: track.album,
        remoteFilepath: track.filepath,
        localPath: outputPath,
        downloadedAt: DateTime.now(),
        quality: '$quality/$container',
      );
      await _cache.upsertOfflineTrack(offlineTrack);

      await _syncOfflineTrackAdded(offlineTrack, collectionLabel: collectionLabel);

      task = task.copyWith(progress: 1, state: 'completed');
      onProgress(task);
      return task;
    } catch (error) {
      task = task.copyWith(state: 'failed', error: error.toString());
      onProgress(task);
      return task;
    }
  }

  Future<void> removeOfflineTrack(String trackhash) async {
    final tracks = await _cache.getOfflineTracks();
    final target = tracks
        .where((entry) => entry.trackhash == trackhash)
        .toList();

    for (final track in target) {
      final file = File(track.localPath);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {
          // Keep cache cleanup even when file removal fails.
        }
      }
    }

    await _cache.removeOfflineTrack(trackhash);
    await _syncOfflineTrackRemoved(trackhash);
  }

  Future<void> queuePendingScrobble({
    required String trackhash,
    required int timestamp,
    required int durationSeconds,
    required String source,
  }) {
    return _cache.addPendingScrobble(
      PendingScrobble(
        id: _uuid.v4(),
        trackhash: trackhash,
        timestamp: timestamp,
        durationSeconds: durationSeconds,
        source: source,
      ),
    );
  }

  Future<void> queuePendingFavorite({
    required String action,
    required String hash,
    required String type,
  }) {
    return _cache.addPendingAction(
      PendingAction(
        id: _uuid.v4(),
        type: action,
        payload: {'hash': hash, 'favorite_type': type},
      ),
    );
  }

  Future<void> syncPendingData() async {
    final hasNetwork = await _hasUsableNetwork();
    if (!hasNetwork) {
      return;
    }

    final healthy = await _api.checkHealth();
    if (!healthy || !_session.isAuthenticated) {
      return;
    }

    final deviceId = await _ensureRemoteDeviceRegistered();

    final actions = await _cache.getPendingActions();
    for (final action in actions) {
      try {
        final hash = action.payload['hash']?.toString() ?? '';
        final type = action.payload['favorite_type']?.toString() ?? 'track';
        if (hash.isEmpty) {
          if (action.type != 'offline.track.add' &&
              action.type != 'offline.track.remove') {
            await _cache.removePendingAction(action.id);
            continue;
          }
        }

        if (action.type == 'favorite.add') {
          final status = await _api.addFavorite(hash: hash, type: type);
          if (_api.isSuccessStatus(status)) {
            await _cache.removePendingAction(action.id);
          }
        } else if (action.type == 'favorite.remove') {
          final status = await _api.removeFavorite(hash: hash, type: type);
          if (_api.isSuccessStatus(status)) {
            await _cache.removePendingAction(action.id);
          }
        } else if (action.type == 'offline.track.add') {
          if (deviceId == null || deviceId.isEmpty) {
            break;
          }
          final rawTrack = action.payload['track'];
          if (rawTrack is! Map) {
            await _cache.removePendingAction(action.id);
            continue;
          }

          final track = Map<String, dynamic>.from(rawTrack);
          final response = await _api.addTracksToMobileOffline(
            deviceId: deviceId,
            tracks: [track],
            quality: track['quality']?.toString(),
            collection: track['collection']?.toString(),
          );
          if (response['success'] == true) {
            await _cache.removePendingAction(action.id);
          }
        } else if (action.type == 'offline.track.remove') {
          if (deviceId == null || deviceId.isEmpty) {
            break;
          }
          final trackhash = action.payload['trackhash']?.toString() ?? '';
          if (trackhash.isEmpty) {
            await _cache.removePendingAction(action.id);
            continue;
          }
          final response = await _api.removeTracksFromMobileOffline(
            deviceId: deviceId,
            trackhashes: [trackhash],
          );
          if (response['success'] == true) {
            await _cache.removePendingAction(action.id);
          }
        } else {
          await _cache.removePendingAction(action.id);
        }
      } catch (_) {
        break;
      }
    }

    final scrobbles = await _cache.getPendingScrobbles();
    for (final scrobble in scrobbles) {
      try {
        final status = await _api.logTrackPlay(
          trackhash: scrobble.trackhash,
          timestamp: scrobble.timestamp,
          duration: scrobble.durationSeconds,
          source: scrobble.source,
        );

        if (_api.isSuccessStatus(status)) {
          await _cache.removePendingScrobble(scrobble.id);
        }
      } catch (_) {
        break;
      }
    }
  }

  Future<void> _syncOfflineTrackAdded(
    OfflineTrack track, {
    String? collectionLabel,
  }) async {
    final payload = <String, dynamic>{
      'trackhash': track.trackhash,
      'title': track.title,
      'artist': track.artist,
      'album': track.album,
      'filepath': track.remoteFilepath,
      'local_path': track.localPath,
      'quality': track.quality,
      'collection': collectionLabel ?? _inferCollection(track),
      'downloaded_at': track.downloadedAt.toUtc().toIso8601String(),
      'is_available': true,
    };

    try {
      final hasNetwork = await _hasUsableNetwork();
      if (!hasNetwork) {
        throw Exception('offline');
      }
      final healthy = await _api.checkHealth();
      if (!healthy || !_session.isAuthenticated) {
        throw Exception('server unavailable');
      }
      final deviceId = await _ensureRemoteDeviceRegistered();
      if (deviceId == null || deviceId.isEmpty) {
        throw Exception('missing device');
      }
      final response = await _api.addTracksToMobileOffline(
        deviceId: deviceId,
        tracks: [payload],
        quality: track.quality,
        collection: payload['collection']?.toString(),
      );
      if (response['success'] != true) {
        throw Exception('remote sync failed');
      }
    } catch (_) {
      await _cache.addPendingAction(
        PendingAction(
          id: _uuid.v4(),
          type: 'offline.track.add',
          payload: {'track': payload},
        ),
      );
    }
  }

  Future<void> _syncOfflineTrackRemoved(String trackhash) async {
    try {
      final hasNetwork = await _hasUsableNetwork();
      if (!hasNetwork) {
        throw Exception('offline');
      }
      final healthy = await _api.checkHealth();
      if (!healthy || !_session.isAuthenticated) {
        throw Exception('server unavailable');
      }
      final deviceId = await _ensureRemoteDeviceRegistered();
      if (deviceId == null || deviceId.isEmpty) {
        throw Exception('missing device');
      }
      final response = await _api.removeTracksFromMobileOffline(
        deviceId: deviceId,
        trackhashes: [trackhash],
      );
      if (response['success'] != true) {
        throw Exception('remote removal failed');
      }
    } catch (_) {
      await _cache.addPendingAction(
        PendingAction(
          id: _uuid.v4(),
          type: 'offline.track.remove',
          payload: {'trackhash': trackhash},
        ),
      );
    }
  }

  Future<String?> _ensureRemoteDeviceRegistered() async {
    final existing = _session.mobileDeviceId;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    if (!_session.hasServer || !_session.isAuthenticated) {
      return null;
    }

    final quality = _session.downloadQuality;
    final type = Platform.operatingSystem.toLowerCase();
    final name = _friendlyDeviceName(type);
    final fingerprint = _buildDeviceFingerprint(type, name);

    final response = await _api.registerMobileDevice(
      name: name,
      type: type,
      preferences: {
        'auto_sync': true,
        'wifi_only': _session.wifiOnlyDownloads,
        'quality': quality,
      },
      fingerprint: fingerprint,
    );

    final device = response['device'];
    if (device is! Map) {
      return null;
    }

    final deviceId = device['device_id']?.toString();
    if (deviceId == null || deviceId.isEmpty) {
      return null;
    }

    await _session.saveMobileDeviceId(deviceId);
    return deviceId;
  }

  String _friendlyDeviceName(String type) {
    final hostname = Platform.localHostname.trim();
    if (hostname.isNotEmpty) {
      return hostname;
    }
    switch (type) {
      case 'android':
        return 'Android Phone';
      case 'ios':
        return 'iPhone';
      default:
        return 'SwingMusic Mobile';
    }
  }

  String _buildDeviceFingerprint(String type, String name) {
    return '$type|$name|${Platform.operatingSystemVersion}';
  }

  String _inferCollection(OfflineTrack track) {
    final album = track.album.trim();
    if (album.isEmpty) {
      return 'tracks';
    }
    return 'album:$album';
  }

  Future<bool> _isOnWifiLikeNetwork() async {
    final values = await _connectivityValues();
    return values.contains(ConnectivityResult.wifi) ||
        values.contains(ConnectivityResult.ethernet) ||
        values.contains(ConnectivityResult.vpn);
  }

  Future<bool> _hasUsableNetwork() async {
    final values = await _connectivityValues();
    if (values.isEmpty) {
      return true;
    }

    return values.any((value) => value != ConnectivityResult.none);
  }

  Future<List<ConnectivityResult>> _connectivityValues() async {
    return Connectivity().checkConnectivity();
  }

  Future<String> _resolveTargetDirectory(
    String baseDirectory,
    MusicTrack track,
    String? collectionLabel,
  ) async {
    final base = Directory(baseDirectory);
    if (!base.existsSync()) {
      await base.create(recursive: true);
    }

    final label = collectionLabel?.trim() ?? '';
    final parent = label.isNotEmpty
        ? _sanitizeFilePart(label, fallback: 'collection')
        : _sanitizeFilePart(track.artist, fallback: 'Unknown Artist');
    final child = label.isNotEmpty
        ? null
        : _sanitizeFilePart(track.album, fallback: 'Unknown Album');

    final targetPath = child == null
        ? '${base.path}/$parent'
        : '${base.path}/$parent/$child';
    final target = Directory(targetPath);
    if (!target.existsSync()) {
      await target.create(recursive: true);
    }
    return target.path;
  }

  String _containerForQuality(String quality) {
    final normalized = quality.trim().toLowerCase();
    if (normalized == 'original') {
      return 'flac';
    }
    final bitrate = int.tryParse(normalized);
    if (bitrate != null && bitrate > 320) {
      return 'flac';
    }
    return 'mp3';
  }

  String _extensionForContainer(String container) {
    switch (container) {
      case 'flac':
        return 'flac';
      case 'aac':
        return 'm4a';
      case 'ogg':
        return 'ogg';
      case 'webm':
        return 'webm';
      default:
        return 'mp3';
    }
  }

  String _sanitizeFilePart(String value, {required String fallback}) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return fallback;
    return cleaned;
  }
}
