import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/track_model.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart' as artist;
import '../models/playlist_model.dart';
import '../models/search_suggestion_model.dart';
import '../../core/constants/app_constants.dart';

class EnhancedApiService {
  late Dio _dio;
  final String baseUrl;
  late SharedPreferences _prefs;

  EnhancedApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConstants.defaultApiUrl {
    _dio = Dio(BaseOptions(
      baseUrl: this.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _initializePrefs();
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        if (kDebugMode) debugPrint('API: $obj');
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
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
          errorMessage = AppConstants.notFoundErrorMessage;
        }
        
        handler.next(DioException(
          requestOptions: error.requestOptions,
          error: errorMessage,
          type: error.type,
          response: error.response,
        ));
      },
    ));
  }
  
  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
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
    String? search,
    String? artist,
    int limit = 50,
    int offset = 0,
    String? sortBy,
    String? sortOrder,
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
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortby'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['reverse'] = sortOrder == 'desc' ? 1 : 0;
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
  Future<List<artist.ArtistModel>> getArtists({
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
      
      return artistsData.map((artistData) => artist.ArtistModel.fromJson(artistData)).toList();
    } catch (e) {
      throw Exception('Failed to load artists: $e');
    }
  }

  Future<artist.ArtistModel?> getArtist(String artistHash) async {
    try {
      final response = await _dio.get('/artist/$artistHash');
      final artistData = response.data['artist'];
      return artistData != null ? artist.ArtistModel.fromJson(artistData) : null;
    } catch (e) {
      throw Exception('Failed to load artist: $e');
    }
  }

  /// Get artist info with optional track limit and all albums flag
  /// Matches Android: getArtistInfo
  Future<Map<String, dynamic>> getArtistInfo(
    String artistHash, {
    int trackLimit = -1,
    bool returnAllAlbums = true,
  }) async {
    try {
      final response = await _dio.get('/artist/$artistHash/info', queryParameters: {
        'tracklimit': trackLimit,
        'all': returnAllAlbums,
      });
      
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to load artist info: $e');
    }
  }

  /// Get similar artists
  /// Matches Android: getSimilarArtists
  Future<List<artist.ArtistModel>> getSimilarArtists(String artistHash) async {
    try {
      final response = await _dio.get('/artist/$artistHash/similar');
      final artistsData = response.data['artists'] as List<dynamic>? ?? [];
      
      return artistsData.map((artistData) => artist.ArtistModel.fromJson(artistData)).toList();
    } catch (e) {
      throw Exception('Failed to load similar artists: $e');
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

  Future<List<artist.ArtistModel>> getFavoriteArtists({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/favorites/artists', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final artistsData = response.data['artists'] as List<dynamic>? ?? [];
      
      return artistsData.map((artistData) => artist.ArtistModel.fromJson(artistData)).toList();
    } catch (e) {
      throw Exception('Failed to load favorite artists: $e');
    }
  }

  // Search methods
  Future<List<SearchSuggestion>> getSearchSuggestions(String query) async {
    try {
      final response = await _dio.get('/search/suggestions', queryParameters: {
        'q': query,
        'limit': 10,
      });
      final suggestionsData = response.data['suggestions'] as List<dynamic>? ?? [];
      
      return suggestionsData.map((suggestionData) => SearchSuggestion.fromJson(suggestionData)).toList();
    } catch (e) {
      throw Exception('Failed to get search suggestions: $e');
    }
  }

  /// Get top search results (aggregated results with top result)
  /// Matches Android: getTopSearchResults
  Future<Map<String, dynamic>> getTopSearchResults(String query, {int limit = 5}) async {
    try {
      final response = await _dio.get('/search', queryParameters: {
        'q': query,
        'limit': limit,
      });
      
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get top search results: $e');
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

  /// Get root directories for folder navigation
  /// Matches Android: getRootDirectories
  Future<List<dynamic>> getRootDirectories() async {
    try {
      final response = await _dio.get('/folders/root');
      return response.data['folders'] as List<dynamic>? ?? [];
    } catch (e) {
      throw Exception('Failed to load root directories: $e');
    }
  }

  /// Get folders and tracks in a single request
  /// Matches Android: getFoldersAndTracks
  Future<Map<String, dynamic>> getFoldersAndTracks({
    required String folderHash,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.post('/folder/$folderHash/content', data: {
        'limit': limit,
        'offset': offset,
      });
      
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to load folder content: $e');
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
  // Generic HTTP methods
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

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

  Future<Map<String, dynamic>> getDownloadSettings() async {
    try {
      final response = await _dio.get('/settings/downloads');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get download settings: $e');
    }
  }

  Future<void> updateDownloadSettings(Map<String, dynamic> settings) async {
    try {
      await _dio.put('/settings/downloads', data: settings);
    } catch (e) {
      throw Exception('Failed to update download settings: $e');
    }
  }

  Future<void> pauseDownload(String downloadId) async {
    try {
      await _dio.post('/download/$downloadId/pause');
    } catch (e) {
      throw Exception('Failed to pause download: $e');
    }
  }

  Future<void> resumeDownload(String downloadId) async {
    try {
      await _dio.post('/download/$downloadId/resume');
    } catch (e) {
      throw Exception('Failed to resume download: $e');
    }
  }

  Future<void> cancelDownload(String downloadId) async {
    try {
      await _dio.post('/download/$downloadId/cancel');
    } catch (e) {
      throw Exception('Failed to cancel download: $e');
    }
  }

  Future<void> retryDownload(String downloadId) async {
    try {
      await _dio.post('/download/$downloadId/retry');
    } catch (e) {
      throw Exception('Failed to retry download: $e');
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

  // Analytics API methods
  Future<Map<String, dynamic>> getAnalyticsData(String period) async {
    try {
      final response = await _dio.get('/analytics', queryParameters: {
        'period': period,
      });
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to load analytics data: $e');
    }
  }

  Future<List<dynamic>> getTopTracks({int limit = 10}) async {
    try {
      final response = await _dio.get('/analytics/top-tracks', queryParameters: {
        'limit': limit,
      });
      
      return response.data['tracks'] ?? [];
    } catch (e) {
      throw Exception('Failed to load top tracks: $e');
    }
  }

  Future<List<dynamic>> getTopArtists({int limit = 10}) async {
    try {
      final response = await _dio.get('/analytics/top-artists', queryParameters: {
        'limit': limit,
      });
      
      return response.data['artists'] ?? [];
    } catch (e) {
      throw Exception('Failed to load top artists: $e');
    }
  }

  // Settings API methods
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final response = await _dio.get('/settings');
      
      return response.data['settings'] ?? {};
    } catch (e) {
      throw Exception('Failed to load user settings: $e');
    }
  }

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      await _dio.put('/settings', data: settings);
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  // Sync API methods
  Future<Map<String, dynamic>> getLibraryChanges(int lastSyncTimestamp) async {
    try {
      final response = await _dio.get('/sync/library/changes', queryParameters: {
        'since': lastSyncTimestamp,
      });
      
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to get library changes: $e');
    }
  }

  Future<void> syncListeningHistory(List<Map<String, dynamic>> history) async {
    try {
      await _dio.post('/sync/history', data: {
        'history': history,
      });
    } catch (e) {
      throw Exception('Failed to sync listening history: $e');
    }
  }

  /// Log track playback to server.
  /// The Android app logs tracks that have been played for at least 5 seconds.
  /// Endpoint: POST /logger/track/log
  Future<void> logTrackPlay({
    required String trackhash,
    required int durationSeconds,
    required String source,
    int? timestamp,
  }) async {
    try {
      final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _dio.post(
        '${baseUrl}logger/track/log',
        data: {
          'duration': durationSeconds,
          'source': source,
          'timestamp': ts,
          'trackhash': trackhash,
        },
      );
      
      debugPrint('LOG: Track logged -> $trackhash, duration: ${durationSeconds}s, source: $source');
    } on DioException catch (e) {
      debugPrint('NETWORK ERROR LOGGING TRACK TO SERVER: ${e.message}');
      // Don't throw - logging failures shouldn't interrupt playback
    } catch (e) {
      debugPrint('ERROR LOGGING TRACK TO SERVER: $e');
      // Don't throw - logging failures shouldn't interrupt playback
    }
  }
}
