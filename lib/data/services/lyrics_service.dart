import 'package:flutter/foundation.dart';
import 'enhanced_api_service.dart';
import 'package:dio/dio.dart';

class LyricsService {
  late Dio _dio;
  final EnhancedApiService _apiService;

  LyricsService(this._apiService) {
    _dio = Dio(BaseOptions(
      baseUrl: _apiService.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  Future<String?> getLyrics(String trackHash, {String? filepath}) async {
    try {
      // Use the enhanced API service to get lyrics
      final lyrics = await _apiService.getLyrics(trackHash);
      return lyrics;
    } catch (e) {
      debugPrint('Error fetching lyrics: $e');
      return null;
    }
  }

  Future<bool> checkLyricsExists(String trackHash, {String? filepath}) async {
    try {
      final lyrics = await getLyrics(trackHash, filepath: filepath);
      return lyrics != null && lyrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking lyrics existence: $e');
      return false;
    }
  }

  Future<String?> searchLyrics(String query, {int limit = 10}) async {
    try {
      final response = await _dio.get('/lyrics/search', queryParameters: {
        'q': query,
        'limit': limit,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.isNotEmpty ? results.first['lyrics'] as String? : null;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error searching lyrics: $e');
      return null;
    }
  }

  Future<bool> saveLyrics(String trackHash, String lyrics, {String? filepath}) async {
    try {
      final response = await _dio.post('/lyrics/save', data: {
        'trackhash': trackHash,
        'filepath': filepath,
        'lyrics': lyrics,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error saving lyrics: $e');
      return false;
    }
  }

  Future<bool> updateLyrics(String trackHash, String lyrics, {String? filepath}) async {
    try {
      final response = await _dio.put('/lyrics/update', data: {
        'trackhash': trackHash,
        'filepath': filepath,
        'lyrics': lyrics,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating lyrics: $e');
      return false;
    }
  }

  Future<bool> deleteLyrics(String trackHash, {String? filepath}) async {
    try {
      final response = await _dio.delete('/lyrics/delete', data: {
        'trackhash': trackHash,
        'filepath': filepath,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting lyrics: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getLyricsStats() async {
    try {
      final response = await _dio.get('/lyrics/stats');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>? ?? {};
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching lyrics stats: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getLyricsHistory({int limit = 20}) async {
    try {
      final response = await _dio.get('/lyrics/history', queryParameters: {
        'limit': limit,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return (data['history'] as List<dynamic>? ?? [])
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching lyrics history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getSyncedLyrics(String trackHash, {String? filepath}) async {
    try {
      final response = await _dio.get('/lyrics/synced', queryParameters: {
        'trackhash': trackHash,
        'filepath': filepath,
      });
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>? ?? {};
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching synced lyrics: $e');
      return {};
    }
  }

  Future<bool> saveSyncedLyrics(String trackHash, Map<String, dynamic> syncedLyrics, {String? filepath}) async {
    try {
      final response = await _dio.post('/lyrics/synced/save', data: {
        'trackhash': trackHash,
        'filepath': filepath,
        'synced_lyrics': syncedLyrics,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error saving synced lyrics: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPopularLyrics({int limit = 10}) async {
    try {
      final response = await _dio.get('/lyrics/popular', queryParameters: {
        'limit': limit,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return (data['popular'] as List<dynamic>? ?? [])
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching popular lyrics: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentlyAddedLyrics({int limit = 10}) async {
    try {
      final response = await _dio.get('/lyrics/recent', queryParameters: {
        'limit': limit,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return (data['recent'] as List<dynamic>? ?? [])
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching recent lyrics: $e');
      return [];
    }
  }

  // Utility methods for lyrics processing
  List<String> parseLyrics(String lyrics) {
    // Split lyrics into lines and clean them up
    return lyrics
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> parseSyncedLyrics(String syncedLyrics) {
    // Parse LRC format synced lyrics
    final lines = syncedLyrics.split('\n');
    final parsedLyrics = <Map<String, dynamic>>[];
    
    for (final line in lines) {
      if (line.startsWith('[') && line.contains(']')) {
        final timestampEnd = line.indexOf(']');
        final timestamp = line.substring(1, timestampEnd);
        final text = line.substring(timestampEnd + 1).trim();
        
        // Parse timestamp (format: [mm:ss.xx] or [mm:ss])
        final timeParts = timestamp.split(':');
        if (timeParts.length == 2) {
          try {
            final minutes = int.parse(timeParts[0]);
            final secondsParts = timeParts[1].split('.');
            final seconds = int.parse(secondsParts[0]);
            final milliseconds = secondsParts.length > 1 ? int.parse(secondsParts[1]) * 10 : 0;
            
            final totalMilliseconds = (minutes * 60 * 1000) + (seconds * 1000) + milliseconds;
            
            parsedLyrics.add({
              'time': totalMilliseconds,
              'text': text,
            });
          } catch (e) {
            // Skip invalid timestamp lines
            continue;
          }
        }
      }
    }
    
    return {
      'lines': parsedLyrics,
      'hasSync': parsedLyrics.isNotEmpty,
    };
  }

  String formatTimestamp(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final ms = (duration.inMilliseconds % 1000) ~/ 10;
    
    return '[${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}]';
  }

  String convertToSyncedLyrics(List<String> plainLyrics, {int durationPerLine = 3000}) {
    // Convert plain lyrics to synced lyrics format
    final syncedLines = <String>[];
    int currentTime = 0;
    
    for (final line in plainLyrics) {
      if (line.trim().isNotEmpty) {
        final timestamp = formatTimestamp(currentTime);
        syncedLines.add('$timestamp ${line.trim()}');
        currentTime += durationPerLine;
      }
    }
    
    return syncedLines.join('\n');
  }
}
