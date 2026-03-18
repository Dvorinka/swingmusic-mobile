import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track_model.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/playlist_model.dart';
import '../models/search_suggestion_model.dart';
import '../../core/constants/app_constants.dart';

class EnhancedApiService {
  late Dio _dio;
  final String baseUrl;
  final SharedPreferences _prefs;

  EnhancedApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConstants.defaultApiUrl {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _prefs = SharedPreferences.getInstance() as Future<SharedPreferences>;
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        print('API: $obj');
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        String errorMessage = AppConstants.genericErrorMessage;
        
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          errorMessage = AppConstants.networkErrorMessage;
        } else if (error.response?.statusCode == 500) {
          errorMessage = AppConstants.serverErrorMessage;
        } else if (error.response?.statusCode == 401) {
          errorMessage = AppConstants.authErrorMessage;
        } else if (error.response?.statusCode == 404) {
          errorMessage = 'Resource not found';
        }
        
        print('API Error: $errorMessage');
        handler.next(error);
      },
    ));
  }

  // Authentication methods
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Track methods
  Future<List<TrackModel>> getTracks({
    int limit = 20,
    int offset = 0,
    String? search,
    String? genre,
    String? artist,
    String? album,
    String? folder,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (genre != null && genre.isNotEmpty) {
        queryParams['genre'] = genre;
      }
      if (artist != null && artist.isNotEmpty) {
        queryParams['artist'] = artist;
      }
      if (album != null && album.isNotEmpty) {
        queryParams['album'] = album;
      }
      if (folder != null && folder.isNotEmpty) {
        queryParams['folder'] = folder;
      }

      final response = await _dio.get('/tracks', queryParameters: queryParams);
      final tracksData = response.data['tracks'] as List<dynamic>? ?? [];
      
      return tracksData.map((trackData) => TrackModel.fromJson(trackData)).toList();
    } catch (e) {
      throw Exception('Failed to load tracks: $e');
    }
  }

  Future<TrackModel?> getTrack(String trackHash) async {
    try {
      final response = await _dio.get('/track/$trackHash');
      final trackData = response.data['track'];
      return trackData != null ? TrackModel.fromJson(trackData) : null;
    } catch (e) {
      throw Exception('Failed to load track: $e');
    }
  }

  // Album methods
  Future<List<AlbumModel>> getAlbums({
    int limit = 20,
    int offset = 0,
    String? search,
    String? artist,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (artist != null && artist.isNotEmpty) {
        queryParams['artist'] = artist;
      }

      final response = await _dio.get('/albums', queryParameters: queryParams);
      final albumsData = response.data['albums'] as List<dynamic>? ?? [];
      
      return albumsData.map((albumData) => AlbumModel.fromJson(albumData)).toList();
    } catch (e) {
      throw Exception('Failed to load albums: $e');
    }
  }

  Future<AlbumModel?> getAlbum(String albumHash) async {
    try {
      final response = await _dio.get('/album/$albumHash');
      final albumData = response.data['album'];
      return albumData != null ? AlbumModel.fromJson(albumData) : null;
    } catch (e) {
      throw Exception('Failed to load album: $e');
    }
  }

  Future<List<TrackModel>> getAlbumTracks(String albumHash, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/album/$albumHash/tracks', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final tracksData = response.data['tracks'] as List<dynamic>? ?? [];
      
      return tracksData.map((trackData) => TrackModel.fromJson(trackData)).toList();
    } catch (e) {
      throw Exception('Failed to load album tracks: $e');
    }
  }

  // Artist methods
  Future<List<ArtistModel>> getArtists({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get('/artists', queryParameters: queryParams);
      final artistsData = response.data['artists'] as List<dynamic>? ?? [];
      
      return artistsData.map((artistData) => ArtistModel.fromJson(artistData)).toList();
    } catch (e) {
      throw Exception('Failed to load artists: $e');
    }
  }

  Future<ArtistModel?> getArtist(String artistHash) async {
    try {
      final response = await _dio.get('/artist/$artistHash');
      final artistData = response.data['artist'];
      return artistData != null ? ArtistModel.fromJson(artistData) : null;
    } catch (e) {
      throw Exception('Failed to load artist: $e');
    }
  }

  Future<List<AlbumModel>> getArtistAlbums(String artistHash, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/artist/$artistHash/albums', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final albumsData = response.data['albums'] as List<dynamic>? ?? [];
      
      return albumsData.map((albumData) => AlbumModel.fromJson(albumData)).toList();
    } catch (e) {
      throw Exception('Failed to load artist albums: $e');
    }
  }

  Future<List<TrackModel>> getArtistTracks(String artistHash, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/artist/$artistHash/tracks', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final tracksData = response.data['tracks'] as List<dynamic>? ?? [];
      
      return tracksData.map((trackData) => TrackModel.fromJson(trackData)).toList();
    } catch (e) {
      throw Exception('Failed to load artist tracks: $e');
    }
  }

  // Playlist methods
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final response = await _dio.get('/playlists');
      final playlistsData = response.data['playlists'] as List<dynamic>? ?? [];
      
      return playlistsData.map((playlistData) => PlaylistModel.fromJson(playlistData)).toList();
    } catch (e) {
      throw Exception('Failed to load playlists: $e');
    }
  }

  Future<PlaylistModel?> getPlaylist(String playlistId) async {
    try {
      final response = await _dio.get('/playlist/$playlistId');
      final playlistData = response.data['playlist'];
      return playlistData != null ? PlaylistModel.fromJson(playlistData) : null;
    } catch (e) {
      throw Exception('Failed to load playlist: $e');
    }
  }

  Future<PlaylistModel> createPlaylist(String name, String description) async {
    try {
      final response = await _dio.post('/playlists', data: {
        'name': name,
        'description': description,
      });
      
      return PlaylistModel.fromJson(response.data['playlist']);
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
    }
  }

  Future<void> addToPlaylist(String playlistId, String trackHash) async {
    try {
      await _dio.post('/playlist/$playlistId/add', data: {
        'trackhash': trackHash,
      });
    } catch (e) {
      throw Exception('Failed to add to playlist: $e');
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String trackHash) async {
    try {
      await _dio.delete('/playlist/$playlistId/remove', data: {
        'trackhash': trackHash,
      });
    } catch (e) {
      throw Exception('Failed to remove from playlist: $e');
    }
  }

  // Favorites methods
  Future<void> toggleFavoriteTrack(String trackHash) async {
    try {
      await _dio.post('/favorites/track/toggle', data: {
        'trackhash': trackHash,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite track: $e');
    }
  }

  Future<void> toggleFavoriteAlbum(String albumHash) async {
    try {
      await _dio.post('/favorites/album/toggle', data: {
        'albumhash': albumHash,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite album: $e');
    }
  }

  Future<void> toggleFavoriteArtist(String artistHash) async {
    try {
      await _dio.post('/favorites/artist/toggle', data: {
        'artisthash': artistHash,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite artist: $e');
    }
  }

  Future<List<TrackModel>> getFavoriteTracks({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/favorites/tracks', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final tracksData = response.data['tracks'] as List<dynamic>? ?? [];
      
      return tracksData.map((trackData) => TrackModel.fromJson(trackData)).toList();
    } catch (e) {
      throw Exception('Failed to load favorite tracks: $e');
    }
  }

  Future<List<AlbumModel>> getFavoriteAlbums({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/favorites/albums', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final albumsData = response.data['albums'] as List<dynamic>? ?? [];
      
      return albumsData.map((albumData) => AlbumModel.fromJson(albumData)).toList();
    } catch (e) {
      throw Exception('Failed to load favorite albums: $e');
    }
  }

  Future<List<ArtistModel>> getFavoriteArtists({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/favorites/artists', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final artistsData = response.data['artists'] as List<dynamic>? ?? [];
      
      return artistsData.map((artistData) => ArtistModel.fromJson(artistData)).toList();
    } catch (e) {
      throw Exception('Failed to load favorite artists: $e');
    }
  }

  // Search methods
  Future<List<SearchSuggestionModel>> getSearchSuggestions(String query) async {
    try {
      final response = await _dio.get('/search/suggestions', queryParameters: {
        'q': query,
        'limit': 10,
      });
      final suggestionsData = response.data['suggestions'] as List<dynamic>? ?? [];
      
      return suggestionsData.map((suggestionData) => SearchSuggestionModel.fromJson(suggestionData)).toList();
    } catch (e) {
      throw Exception('Failed to get search suggestions: $e');
    }
  }

  // Folder methods
  Future<List<dynamic>> getFolders() async {
    try {
      final response = await _dio.get('/folders');
      return response.data['folders'] as List<dynamic>? ?? [];
    } catch (e) {
      throw Exception('Failed to load folders: $e');
    }
  }

  Future<List<TrackModel>> getFolderTracks(String folderHash, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/folder/$folderHash/tracks', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final tracksData = response.data['tracks'] as List<dynamic>? ?? [];
      
      return tracksData.map((trackData) => TrackModel.fromJson(trackData)).toList();
    } catch (e) {
      throw Exception('Failed to load folder tracks: $e');
    }
  }

  // User methods
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get('/user/info');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _dio.post('/user/preferences', data: preferences);
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final response = await _dio.get('/user/preferences');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  // Statistics methods
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _dio.get('/statistics');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Download methods
  Future<void> downloadTrack(String trackHash) async {
    try {
      await _dio.post('/download/track', data: {
        'trackhash': trackHash,
      });
    } catch (e) {
      throw Exception('Failed to download track: $e');
    }
  }

  Future<List<dynamic>> getDownloads() async {
    try {
      final response = await _dio.get('/downloads');
      return response.data['downloads'] as List<dynamic>? ?? [];
    } catch (e) {
      throw Exception('Failed to get downloads: $e');
    }
  }

  Future<void> deleteDownload(String downloadId) async {
    try {
      await _dio.delete('/download/$downloadId');
    } catch (e) {
      throw Exception('Failed to delete download: $e');
    }
  }

  // Lyrics methods
  Future<String?> getLyrics(String trackHash) async {
    try {
      final response = await _dio.get('/lyrics/$trackHash');
      return response.data['lyrics'] as String?;
    } catch (e) {
      throw Exception('Failed to get lyrics: $e');
    }
  }

  // Queue methods
  Future<List<TrackModel>> getQueue() async {
    try {
      final response = await _dio.get('/queue');
      final tracksData = response.data['tracks'] as List<dynamic>? ?? [];
      
      return tracksData.map((trackData) => TrackModel.fromJson(trackData)).toList();
    } catch (e) {
      throw Exception('Failed to get queue: $e');
    }
  }

  Future<void> addToQueue(String trackHash) async {
    try {
      await _dio.post('/queue/add', data: {
        'trackhash': trackHash,
      });
    } catch (e) {
      throw Exception('Failed to add to queue: $e');
    }
  }

  Future<void> removeFromQueue(String trackHash) async {
    try {
      await _dio.delete('/queue/remove', data: {
        'trackhash': trackHash,
      });
    } catch (e) {
      throw Exception('Failed to remove from queue: $e');
    }
  }

  Future<void> clearQueue() async {
    try {
      await _dio.delete('/queue/clear');
    } catch (e) {
      throw Exception('Failed to clear queue: $e');
    }
  }

  Future<void> reorderQueue(List<String> trackHashes) async {
    try {
      await _dio.post('/queue/reorder', data: {
        'track_hashes': trackHashes,
      });
    } catch (e) {
      throw Exception('Failed to reorder queue: $e');
    }
  }
}
