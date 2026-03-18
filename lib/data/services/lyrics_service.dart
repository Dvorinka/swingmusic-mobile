import 'package:dio/dio.dart';
import '../models/track_model.dart';

class LyricsService {
  late Dio _dio;
  final String baseUrl;

  LyricsService({String? baseUrl}) : baseUrl = baseUrl ?? 'https://your-server.com' {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        print('Lyrics API: $obj');
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        String errorMessage = 'Failed to load lyrics';
        
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Network timeout - please check your connection';
        } else if (error.response?.statusCode == 404) {
          errorMessage = 'Lyrics not found for this track';
        } else if (error.response?.statusCode == 500) {
          errorMessage = 'Server error - please try again later';
        }
        
        print('Lyrics Error: $errorMessage');
        handler.next(error);
      },
    ));
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<String?> getLyrics(String trackHash) async {
    try {
      final response = await _dio.get('/lyrics/$trackHash');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['lyrics'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
      return null;
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
      print('Error searching lyrics: $e');
      return null;
    }
  }

  Future<bool> saveLyrics(String trackHash, String lyrics) async {
    try {
      final response = await _dio.post('/lyrics/save', data: {
        'trackHash': trackHash,
        'lyrics': lyrics,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error saving lyrics: $e');
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
      print('Error fetching lyrics stats: $e');
      return {};
    }
  }
}
