import 'package:flutter/foundation.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../data/models/track_model.dart';

class DownloadProvider extends ChangeNotifier {
  final EnhancedApiService _apiService;

  DownloadProvider({required EnhancedApiService apiService})
      : _apiService = apiService;

  bool _isLoading = false;
  String? _errorMessage;
  List<DownloadItem> _downloads = [];
  List<DownloadItem> _completedDownloads = [];
  Map<String, dynamic> _settings = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DownloadItem> get downloads => _downloads;
  List<DownloadItem> get completedDownloads => _completedDownloads;
  List<DownloadItem> get allDownloads =>
      [..._downloads, ..._completedDownloads];
  Map<String, dynamic> get settings => _settings;

  bool get hasDownloads =>
      _downloads.isNotEmpty || _completedDownloads.isNotEmpty;
  int get activeDownloadCount =>
      _downloads.where((d) => d.status == DownloadStatus.downloading).length;

  Future<void> loadDownloads() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final downloadsData = await _apiService.getDownloads();

      final allDownloads =
          downloadsData.map((data) => _parseDownloadItem(data)).toList();

      _downloads = allDownloads
          .where((d) => d.status != DownloadStatus.completed)
          .toList();
      _completedDownloads = allDownloads
          .where((d) => d.status == DownloadStatus.completed)
          .toList();

      if (kDebugMode) {
        debugPrint(
            'Loaded ${_downloads.length} active downloads, ${_completedDownloads.length} completed');
      }
    } catch (e) {
      _setError('Failed to load downloads: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSettings() async {
    try {
      _settings = await _apiService.getDownloadSettings();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load download settings: $e');
      }
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _apiService.updateDownloadSettings(settings);
      _settings = {..._settings, ...settings};
      notifyListeners();
    } catch (e) {
      _setError('Failed to update settings: $e');
    }
  }

  Future<void> downloadTrack(TrackModel track) async {
    try {
      await _apiService.downloadTrack(track.trackhash);

      // Add to downloads list optimistically
      final download = DownloadItem(
        id: track.trackhash,
        track: track,
        status: DownloadStatus.downloading,
        progress: 0.0,
        downloadedSize: 0,
        totalSize: _estimateTrackSize(track),
        downloadDate: DateTime.now(),
      );

      _downloads.insert(0, download);
      notifyListeners();

      // Reload to get actual status
      await loadDownloads();
    } catch (e) {
      _setError('Failed to start download: $e');
    }
  }

  Future<void> pauseDownload(String downloadId) async {
    try {
      await _apiService.pauseDownload(downloadId);

      final index = _downloads.indexWhere((d) => d.id == downloadId);
      if (index != -1) {
        _downloads[index] =
            _downloads[index].copyWith(status: DownloadStatus.paused);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pause download: $e');
    }
  }

  Future<void> resumeDownload(String downloadId) async {
    try {
      await _apiService.resumeDownload(downloadId);

      final index = _downloads.indexWhere((d) => d.id == downloadId);
      if (index != -1) {
        _downloads[index] =
            _downloads[index].copyWith(status: DownloadStatus.downloading);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to resume download: $e');
    }
  }

  Future<void> cancelDownload(String downloadId) async {
    try {
      await _apiService.cancelDownload(downloadId);
      _downloads.removeWhere((d) => d.id == downloadId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to cancel download: $e');
    }
  }

  Future<void> deleteDownload(String downloadId) async {
    try {
      await _apiService.deleteDownload(downloadId);
      _downloads.removeWhere((d) => d.id == downloadId);
      _completedDownloads.removeWhere((d) => d.id == downloadId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete download: $e');
    }
  }

  Future<void> retryDownload(String downloadId) async {
    try {
      await _apiService.retryDownload(downloadId);

      final index = _downloads.indexWhere((d) => d.id == downloadId);
      if (index != -1) {
        _downloads[index] =
            _downloads[index].copyWith(status: DownloadStatus.downloading);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to retry download: $e');
    }
  }

  void clearCompletedDownloads() {
    _completedDownloads.clear();
    notifyListeners();
  }

  DownloadItem _parseDownloadItem(Map<String, dynamic> data) {
    final trackData = data['track'] as Map<String, dynamic>? ?? {};
    final statusStr = data['status'] as String? ?? 'downloading';

    return DownloadItem(
      id: data['id']?.toString() ?? data['download_id']?.toString() ?? '',
      track: TrackModel.fromJson(trackData),
      status: _parseDownloadStatus(statusStr),
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      downloadedSize: (data['downloaded_size'] as num?)?.toDouble() ?? 0.0,
      totalSize: (data['total_size'] as num?)?.toDouble() ?? 0.0,
      downloadDate: data['download_date'] != null
          ? DateTime.parse(data['download_date'])
          : DateTime.now(),
    );
  }

  DownloadStatus _parseDownloadStatus(String status) {
    switch (status.toLowerCase()) {
      case 'downloading':
        return DownloadStatus.downloading;
      case 'paused':
        return DownloadStatus.paused;
      case 'completed':
      case 'complete':
        return DownloadStatus.completed;
      case 'failed':
      case 'error':
        return DownloadStatus.failed;
      default:
        return DownloadStatus.downloading;
    }
  }

  double _estimateTrackSize(TrackModel track) {
    // Estimate based on bitrate and duration
    // bitrate in kbps, duration in seconds
    // size in MB = (bitrate * duration) / (8 * 1024)
    return (track.bitrate * track.duration) / (8 * 1024);
  }

  void _setError(String error) {
    _errorMessage = error;
    if (kDebugMode) {
      debugPrint('Download Error: $error');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class DownloadItem {
  final String id;
  final TrackModel track;
  final DownloadStatus status;
  final double progress;
  final double downloadedSize;
  final double totalSize;
  final DateTime downloadDate;

  DownloadItem({
    required this.id,
    required this.track,
    required this.status,
    required this.progress,
    required this.downloadedSize,
    required this.totalSize,
    required this.downloadDate,
  });

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    double? downloadedSize,
    double? totalSize,
  }) {
    return DownloadItem(
      id: id,
      track: track,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      totalSize: totalSize ?? this.totalSize,
      downloadDate: downloadDate,
    );
  }

  String get progressPercentage => '${(progress * 100).toInt()}%';
  String get sizeInfo =>
      '${downloadedSize.toStringAsFixed(1)} MB / ${totalSize.toStringAsFixed(1)} MB';
}

enum DownloadStatus {
  downloading,
  paused,
  completed,
  failed,
}
