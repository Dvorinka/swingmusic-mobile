import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConstants.defaultApiUrl {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? AppConstants.defaultApiUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        // print(obj); // Enable for debugging
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        // Handle common errors
        String errorMessage = AppConstants.genericErrorMessage;
        
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          errorMessage = AppConstants.networkErrorMessage;
        } else if (error.response?.statusCode == 500) {
          errorMessage = AppConstants.serverErrorMessage;
        } else if (error.response?.statusCode == 401) {
          errorMessage = AppConstants.authErrorMessage;
        }

        // You could emit this through a state management solution
        // For now, just log it
        print('API Error: $errorMessage');
        
        handler.next(error);
      },
    ));
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Tracks API
  Future<List<dynamic>> getTracks({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/tracks', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      
      return response.data['tracks'] ?? [];
    } catch (e) {
      throw Exception('Failed to load tracks: $e');
    }
  }

  Future<dynamic> getTrack(String trackhash) async {
    try {
      final response = await _dio.get('/track/$trackhash');
      return response.data['track'];
    } catch (e) {
      throw Exception('Failed to load track: $e');
    }
  }

  Future<List<dynamic>> searchTracks(String query, {int limit = 15}) async {
    try {
      final response = await _dio.get('/search/tracks', queryParameters: {
        'q': query,
        'limit': limit,
      });
      
      return response.data['tracks'] ?? [];
    } catch (e) {
      throw Exception('Failed to search tracks: $e');
    }
  }

  // Albums API
  Future<List<dynamic>> getAlbums({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/albums', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      
      return response.data['albums'] ?? [];
    } catch (e) {
      throw Exception('Failed to load albums: $e');
    }
  }

  Future<dynamic> getAlbum(String albumhash) async {
    try {
      final response = await _dio.get('/album/$albumhash');
      return response.data['album'];
    } catch (e) {
      throw Exception('Failed to load album: $e');
    }
  }

  Future<List<dynamic>> getAlbumTracks(String albumhash) async {
    try {
      final response = await _dio.get('/album/$albumhash/tracks');
      
      return response.data['tracks'] ?? [];
    } catch (e) {
      throw Exception('Failed to load album tracks: $e');
    }
  }

  // Artists API
  Future<List<dynamic>> getArtists({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/artists', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      
      return response.data['artists'] ?? [];
    } catch (e) {
      throw Exception('Failed to load artists: $e');
    }
  }

  Future<dynamic> getArtist(String artisthash) async {
    try {
      final response = await _dio.get('/artist/$artisthash');
      return response.data['artist'];
    } catch (e) {
      throw Exception('Failed to load artist: $e');
    }
  }

  Future<List<dynamic>> getArtistAlbums(String artisthash) async {
    try {
      final response = await _dio.get('/artist/$artisthash/albums');
      
      return response.data['albums'] ?? [];
    } catch (e) {
      throw Exception('Failed to load artist albums: $e');
    }
  }

  Future<List<dynamic>> getArtistTracks(String artisthash) async {
    try {
      final response = await _dio.get('/artist/$artisthash/tracks');
      
      return response.data['tracks'] ?? [];
    } catch (e) {
      throw Exception('Failed to load artist tracks: $e');
    }
  }

  // Playlists API
  Future<List<dynamic>> getPlaylists() async {
    try {
      final response = await _dio.get('/playlists');
      
      return response.data['playlists'] ?? [];
    } catch (e) {
      throw Exception('Failed to load playlists: $e');
    }
  }

  Future<dynamic> getPlaylist(String playlistId) async {
    try {
      final response = await _dio.get('/playlist/$playlistId');
      return response.data['playlist'];
    } catch (e) {
      throw Exception('Failed to load playlist: $e');
    }
  }

  Future<dynamic> createPlaylist(String name, {String description = ''}) async {
    try {
      final response = await _dio.post('/playlists', data: {
        'name': name,
        'description': description,
      });
      
      return response.data['playlist'];
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
    }
  }

  Future<void> addToPlaylist(String playlistId, String trackhash) async {
    try {
      await _dio.post('/playlist/$playlistId/add', data: {
        'trackhash': trackhash,
      });
    } catch (e) {
      throw Exception('Failed to add to playlist: $e');
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String trackhash) async {
    try {
      await _dio.delete('/playlist/$playlistId/remove', data: {
        'trackhash': trackhash,
      });
    } catch (e) {
      throw Exception('Failed to remove from playlist: $e');
    }
  }

  // Favorites API
  Future<void> toggleFavoriteTrack(String trackhash) async {
    try {
      await _dio.post('/favorites/track/toggle', data: {
        'trackhash': trackhash,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite track: $e');
    }
  }

  Future<void> toggleFavoriteAlbum(String albumhash) async {
    try {
      await _dio.post('/favorites/album/toggle', data: {
        'albumhash': albumhash,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite album: $e');
    }
  }

  Future<void> toggleFavoriteArtist(String artisthash) async {
    try {
      await _dio.post('/favorites/artist/toggle', data: {
        'artisthash': artisthash,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite artist: $e');
    }
  }

  Future<List<dynamic>> getFavoriteTracks() async {
    try {
      final response = await _dio.get('/favorites/tracks');
      
      return response.data['tracks'] ?? [];
    } catch (e) {
      throw Exception('Failed to load favorite tracks: $e');
    }
  }

  Future<List<dynamic>> getFavoriteAlbums() async {
    try {
      final response = await _dio.get('/favorites/albums');
      
      return response.data['albums'] ?? [];
    } catch (e) {
      throw Exception('Failed to load favorite albums: $e');
    }
  }

  Future<List<dynamic>> getFavoriteArtists() async {
    try {
      final response = await _dio.get('/favorites/artists');
      
      return response.data['artists'] ?? [];
    } catch (e) {
      throw Exception('Failed to load favorite artists: $e');
    }
  }
}
