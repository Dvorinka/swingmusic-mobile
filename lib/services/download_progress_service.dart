import 'package:dio/dio.dart';

/// Download progress information
class DownloadProgress {
  final String downloadId;
  final String trackhash;
  final String title;
  final String artist;
  final String status; // queued, downloading, completed, failed, cancelled
  final double progressPercent;
  final int bytesDownloaded;
  final int totalBytes;
  final int speedBps;
  final int etaSeconds;
  final int startedAt;
  final int updatedAt;
  final String? errorMessage;

  DownloadProgress({
    required this.downloadId,
    required this.trackhash,
    required this.title,
    required this.artist,
    required this.status,
    required this.progressPercent,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.speedBps,
    required this.etaSeconds,
    required this.startedAt,
    required this.updatedAt,
    this.errorMessage,
  });

  factory DownloadProgress.fromJson(Map<String, dynamic> json) {
    return DownloadProgress(
      downloadId: json['download_id'] ?? '',
      trackhash: json['trackhash'] ?? '',
      title: json['title'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown Artist',
      status: json['status'] ?? 'queued',
      progressPercent: (json['progress_percent'] ?? 0).toDouble(),
      bytesDownloaded: json['bytes_downloaded'] ?? 0,
      totalBytes: json['total_bytes'] ?? 0,
      speedBps: json['speed_bps'] ?? 0,
      etaSeconds: json['eta_seconds'] ?? 0,
      startedAt: json['started_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
      errorMessage: json['error_message'],
    );
  }

  String get formattedProgress => '${progressPercent.toStringAsFixed(0)}%';

  String get formattedSize {
    if (totalBytes == 0) return _formatBytes(bytesDownloaded);
    return '${_formatBytes(bytesDownloaded)} / ${_formatBytes(totalBytes)}';
  }

  String get formattedSpeed =>
      speedBps > 0 ? '${_formatBytes(speedBps)}/s' : '';

  String get formattedETA {
    if (etaSeconds <= 0) return '';
    if (etaSeconds < 60) return '${etaSeconds}s';
    if (etaSeconds < 3600) return '${etaSeconds ~/ 60}m ${etaSeconds % 60}s';
    return '${etaSeconds ~/ 3600}h ${(etaSeconds % 3600) ~/ 60}m';
  }

  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${sizes[i]}';
  }

  bool get isActive => status == 'downloading' || status == 'queued';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

/// Service for tracking download progress via DragonflyDB
class DownloadProgressService {
  final Dio _dio;
  final String baseUrl;

  DownloadProgressService({
    required this.baseUrl,
    required String authToken,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Update auth token
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get all active downloads for the current user
  Future<List<DownloadProgress>> getActiveDownloads() async {
    try {
      final response = await _dio.get('/api/downloads/active');
      final downloads = response.data['downloads'] as List?;
      return downloads?.map((d) => DownloadProgress.fromJson(d)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Cancel a download
  Future<bool> cancelDownload(String downloadId) async {
    try {
      await _dio.post('/api/downloads/$downloadId/cancel');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add a track to download queue
  Future<String?> addToQueue(String trackhash, {String quality = '320'}) async {
    try {
      final response = await _dio.post('/api/downloads/queue', data: {
        'trackhash': trackhash,
        'quality': quality,
      });
      return response.data['queue_id'];
    } catch (e) {
      return null;
    }
  }

  /// Get download history
  Future<List<DownloadProgress>> getHistory({int limit = 50}) async {
    try {
      final response = await _dio
          .get('/api/downloads/history', queryParameters: {'limit': limit});
      final history = response.data['history'] as List?;
      return history?.map((h) => DownloadProgress.fromJson(h)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }
}
