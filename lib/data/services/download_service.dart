import 'package:dio/dio.dart';
import 'package:path/path.dart';

class DownloadService {
  late Dio _dio;
  final String baseUrl;
  final String _downloadPath;

  DownloadService({String? baseUrl, String? downloadPath}) 
      : baseUrl = baseUrl ?? 'https://your-server.com',
        _downloadPath = downloadPath ?? '/storage/emulated/0/Android/data/com.example.swingmusic/files/Downloads';

  DownloadService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        print('Download API: $obj');
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        String errorMessage = 'Download failed';
        
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Network timeout - please check your connection';
        } else if (error.response?.statusCode == 404) {
          errorMessage = 'Download not found';
        } else if (error.response?.statusCode == 500) {
          errorMessage = 'Server error - please try again later';
        } else if (error.response?.statusCode == 503) {
          errorMessage = 'Service unavailable - downloads are disabled';
        }
        
        print('Download Error: $errorMessage');
        handler.next(error);
      },
    ));
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Map<String, dynamic>> getDownloads() async {
    try {
      final response = await _dio.get('/downloads');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>? ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching downloads: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>?> getDownload(String downloadId) async {
    try {
      final response = await _dio.get('/download/$downloadId');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching download: $e');
      return null;
    }
  }

  Future<String> downloadTrack(String trackHash, {
    String quality = '320kbps',
    bool wifiOnly = false,
  }) async {
    try {
      final response = await _dio.post('/download/track', data: {
        'trackHash': trackHash,
        'quality': quality,
        'wifiOnly': wifiOnly,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['downloadId'] as String? ?? '';
      } else {
        throw Exception('Failed to start download');
      }
    } catch (e) {
      throw Exception('Failed to start download: $e');
    }
  }

  Future<String> downloadAlbum(String albumHash, {
    String quality = '320kbps',
    bool wifiOnly = false,
  }) async {
    try {
      final response = await _dio.post('/download/album', data: {
        'albumHash': albumHash,
        'quality': quality,
        'wifiOnly': wifiOnly,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['downloadId'] as String? ?? '';
      } else {
        throw Exception('Failed to start download');
      }
    } catch (e) {
      throw Exception('Failed to start download: $e');
    }
  }

  Future<String> downloadArtist(String artistHash, {
    String quality = '320kbps',
    bool wifiOnly = false,
  }) async {
    try {
      final response = await _dio.post('/download/artist', data: {
        'artistHash': artistHash,
        'quality': quality,
        'wifiOnly': wifiOnly,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['downloadId'] as String? ?? '';
      } else {
        throw Exception('Failed to start download');
      }
    } catch (e) {
      throw Exception('Failed to start download: $e');
    }
  }

  Future<String> downloadPlaylist(String playlistId, {
    String quality = '320kbps',
    bool wifiOnly = false,
  }) async {
    try {
      final response = await _dio.post('/download/playlist', data: {
        'playlistId': playlistId,
        'quality': quality,
        'wifiOnly': wifiOnly,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['downloadId'] as String? ?? '';
      } else {
        throw Exception('Failed to start download');
      }
    } catch (e) {
      throw Exception('Failed to start download: $e');
    }
  }

  Future<bool> pauseDownload(String downloadId) async {
    try {
      final response = await _dio.post('/download/$downloadId/pause');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error pausing download: $e');
      return false;
    }
  }

  Future<bool> resumeDownload(String downloadId) async {
    try {
      final response = await _dio.post('/download/$downloadId/resume');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error resuming download: $e');
      return false;
    }
  }

  Future<bool> cancelDownload(String downloadId) async {
    try {
      final response = await _dio.post('/download/$downloadId/cancel');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error canceling download: $e');
      return false;
    }
  }

  Future<bool> deleteDownload(String downloadId) async {
    try {
      final response = await _dio.delete('/download/$downloadId');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting download: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getDownloadStats() async {
    try {
      final response = await _dio.get('/download/stats');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>? ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching download stats: $e');
      return {};
    }
  }

  Future<String> getDownloadPath() async {
    // TODO: Implement actual path resolution
    return _downloadPath;
  }

  Future<bool> updateDownloadSettings({
    String? downloadPath,
    String? defaultQuality,
    bool? wifiOnly,
    int? maxConcurrentDownloads,
  }) async {
    try {
      final response = await _dio.post('/download/settings', data: {
        if (downloadPath != null) 'downloadPath': downloadPath,
        if (defaultQuality != null) 'defaultQuality': defaultQuality,
        if (wifiOnly != null) 'wifiOnly': wifiOnly,
        if (maxConcurrentDownloads != null) 'maxConcurrentDownloads': maxConcurrentDownloads,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating download settings: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getDownloadSettings() async {
    try {
      final response = await _dio.get('/download/settings');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>? ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching download settings: $e');
      return {};
    }
  }

  Stream<Map<String, dynamic>> watchDownloadProgress(String downloadId) {
    // TODO: Implement WebSocket or SSE for real-time progress updates
    // For now, return periodic polling
    return Stream.periodic(const Duration(seconds: 1), (count) async {
      final download = await getDownload(downloadId);
      
      if (download != null) {
        return {
          'downloadId': downloadId,
          'progress': download['progress'] ?? 0.0,
          'status': download['status'] ?? 'unknown',
          'speed': download['speed'] ?? 0.0,
          'eta': download['eta'] ?? 0,
        };
      }
      
      return {};
    });
  }
}
