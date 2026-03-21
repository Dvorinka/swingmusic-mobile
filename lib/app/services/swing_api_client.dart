import 'dart:io';

import 'package:dio/dio.dart';

class ApiError implements Exception {
  ApiError(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiError($statusCode): $message';
}

typedef AccessTokenProvider = Future<String?> Function();

class SwingApiClient {
  SwingApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? '' {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  late final Dio _dio;
  String _baseUrl;
  AccessTokenProvider? _tokenProvider;

  String get baseUrl => _baseUrl;

  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    _dio.options.baseUrl = baseUrl;
  }

  void setTokenProvider(AccessTokenProvider provider) {
    _tokenProvider = provider;
  }

  Future<Map<String, String>> _authHeaders({
    bool withAuth = true,
    String? bearerToken,
  }) async {
    final headers = <String, String>{};

    if (withAuth) {
      final token = await _tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }

    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $bearerToken';
    }

    return headers;
  }

  Dio _dioFor(String? overrideBaseUrl) {
    if (overrideBaseUrl == null || overrideBaseUrl.isEmpty) {
      return _dio;
    }

    return Dio(
      BaseOptions(
        baseUrl: overrideBaseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        sendTimeout: _dio.options.sendTimeout,
        validateStatus: _dio.options.validateStatus,
        headers: _dio.options.headers,
      ),
    );
  }

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
    bool withAuth = true,
    String? overrideBaseUrl,
  }) async {
    final dio = _dioFor(overrideBaseUrl);
    final headers = await _authHeaders(withAuth: withAuth);

    return dio.get(
      path,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  Future<Response<dynamic>> _post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool withAuth = true,
    String? overrideBaseUrl,
    String? bearerToken,
  }) async {
    final dio = _dioFor(overrideBaseUrl);
    final headers = await _authHeaders(
      withAuth: withAuth,
      bearerToken: bearerToken,
    );

    return dio.post(
      path,
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  Future<Response<dynamic>> _delete(
    String path, {
    Object? data,
    bool withAuth = true,
  }) async {
    final headers = await _authHeaders(withAuth: withAuth);
    return _dio.delete(
      path,
      data: data,
      options: Options(headers: headers),
    );
  }

  Map<String, dynamic> _unwrapMap(Response<dynamic> response) {
    if (response.statusCode == 401) {
      throw ApiError('Unauthorized', statusCode: 401);
    }

    if (response.statusCode == 423) {
      throw ApiError('Setup incomplete', statusCode: 423);
    }

    final payload = response.data;
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }

    throw ApiError(
      'Unexpected server response',
      statusCode: response.statusCode,
    );
  }

  List<Map<String, dynamic>> _unwrapListOfMap(Response<dynamic> response) {
    if (response.statusCode == 401) {
      throw ApiError('Unauthorized', statusCode: 401);
    }

    if (response.statusCode == 423) {
      throw ApiError('Setup incomplete', statusCode: 423);
    }

    final payload = response.data;
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    throw ApiError(
      'Unexpected server response',
      statusCode: response.statusCode,
    );
  }

  // Setup + Auth
  Future<Map<String, dynamic>> getSetupStatus({String? serverBaseUrl}) async {
    final response = await _get(
      '/setup/status',
      withAuth: false,
      overrideBaseUrl: serverBaseUrl,
    );

    return {
      'status': response.statusCode ?? 0,
      'data': (response.data is Map)
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{},
    };
  }

  Future<Map<String, dynamic>> login({
    required String serverBaseUrl,
    required String username,
    required String password,
  }) async {
    final response = await _post(
      '/auth/login',
      withAuth: false,
      overrideBaseUrl: serverBaseUrl,
      data: {'username': username, 'password': password},
    );

    return {
      'status': response.statusCode ?? 0,
      'data': (response.data is Map)
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{},
    };
  }

  Future<Map<String, dynamic>> pairWithCode({
    required String serverBaseUrl,
    required String code,
  }) async {
    final response = await _get(
      '/auth/pair',
      query: {'code': code},
      withAuth: false,
      overrideBaseUrl: serverBaseUrl,
    );

    return {
      'status': response.statusCode ?? 0,
      'data': (response.data is Map)
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{},
    };
  }

  Future<Map<String, dynamic>> getPairCode() async {
    final response = await _get('/auth/getpaircode');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await _post(
      '/auth/refresh',
      withAuth: false,
      bearerToken: refreshToken,
    );

    return {
      'status': response.statusCode ?? 0,
      'data': (response.data is Map)
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{},
    };
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _get('/auth/user');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getUsers({bool simplified = true}) async {
    final response = await _get(
      '/auth/users',
      withAuth: false,
      query: {'simplified': simplified},
    );
    return _unwrapMap(response);
  }

  // Core app data
  Future<Map<String, dynamic>> getHomeRecentAdded({int limit = 12}) async {
    final response = await _get(
      '/nothome/recents/added',
      query: {'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getHomeRecentPlayed({int limit = 12}) async {
    final response = await _get(
      '/nothome/recents/played',
      query: {'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getHomeRecommendations() async {
    final response = await _get('/api/catalog/home/recommendations');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getCatalogArtist(String artistId) async {
    final response = await _get('/api/catalog/artist/$artistId');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getCatalogAlbum(String albumId) async {
    final response = await _get('/api/catalog/album/$albumId');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getCatalogPlaylist(
    String playlistId, {
    int limit = 200,
  }) async {
    final response = await _get(
      '/api/catalog/playlist/$playlistId',
      query: {'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> searchCatalog({
    required String query,
    String type = 'all',
    int limit = 25,
    int offset = 0,
  }) async {
    final response = await _post(
      '/api/catalog/search',
      data: {'query': query, 'type': type, 'limit': limit, 'offset': offset},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> searchTop(String query, {int limit = 8}) async {
    final response = await _get(
      '/search/top',
      query: {'q': query, 'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> searchItems({
    required String query,
    required String itemType,
    int start = 0,
    int limit = 30,
  }) async {
    final response = await _get(
      '/search',
      query: {'q': query, 'itemtype': itemType, 'start': start, 'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getFolder({
    required String folder,
    int start = 0,
    int limit = 50,
    bool tracksOnly = false,
    String sortTracksBy = 'default',
    bool trackSortReverse = false,
    String sortFoldersBy = 'lastmod',
    bool folderSortReverse = false,
  }) async {
    final response = await _post(
      '/folder',
      data: {
        'folder': folder,
        'start': start,
        'limit': limit,
        'tracks_only': tracksOnly,
        'sorttracksby': sortTracksBy,
        'tracksort_reverse': trackSortReverse,
        'sortfoldersby': sortFoldersBy,
        'foldersort_reverse': folderSortReverse,
      },
    );

    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getPlaylists({bool noImages = true}) async {
    final response = await _get('/playlists', query: {'no_images': noImages});
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getPlaylist(
    String playlistId, {
    int start = 0,
    int limit = 100,
  }) async {
    final response = await _get(
      '/playlists/$playlistId',
      query: {'start': start, 'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> createPlaylist(String name) async {
    final response = await _post('/playlists/new', data: {'name': name});
    return _unwrapMap(response);
  }

  Future<int> addTrackToPlaylist({
    required String playlistId,
    required String trackhash,
  }) async {
    final response = await _post(
      '/playlists/$playlistId/add',
      data: {'itemtype': 'tracks', 'itemhash': trackhash},
    );
    return response.statusCode ?? 0;
  }

  Future<int> removeTracksFromPlaylist({
    required String playlistId,
    required List<Map<String, dynamic>> tracks,
  }) async {
    final response = await _post(
      '/playlists/$playlistId/remove-tracks',
      data: {'tracks': tracks},
    );
    return response.statusCode ?? 0;
  }

  Future<Map<String, dynamic>> getFavorites({
    int trackLimit = 50,
    int albumLimit = 24,
    int artistLimit = 24,
  }) async {
    final response = await _get(
      '/favorites',
      query: {
        'track_limit': trackLimit,
        'album_limit': albumLimit,
        'artist_limit': artistLimit,
      },
    );
    return _unwrapMap(response);
  }

  Future<int> addFavorite({required String hash, required String type}) async {
    final response = await _post(
      '/favorites/add',
      data: {'hash': hash, 'type': type},
    );
    return response.statusCode ?? 0;
  }

  Future<int> removeFavorite({
    required String hash,
    required String type,
  }) async {
    final response = await _post(
      '/favorites/remove',
      data: {'hash': hash, 'type': type},
    );
    return response.statusCode ?? 0;
  }

  Future<Map<String, dynamic>> getLyrics({
    required String trackhash,
    required String filepath,
  }) async {
    final response = await _post(
      '/lyrics',
      data: {'trackhash': trackhash, 'filepath': filepath},
    );
    return _unwrapMap(response);
  }

  Future<int> logTrackPlay({
    required String trackhash,
    required int timestamp,
    required int duration,
    required String source,
  }) async {
    final response = await _post(
      '/logger/track/log',
      data: {
        'trackhash': trackhash,
        'timestamp': timestamp,
        'duration': duration,
        'source': source,
      },
    );
    return response.statusCode ?? 0;
  }

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _get('/notsettings');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getAllItems({
    required String itemType,
    int start = 0,
    int limit = 50,
    String sortBy = 'created_date',
    bool reverse = true,
  }) async {
    final response = await _get(
      '/getall/$itemType',
      query: {
        'start': start,
        'limit': limit,
        'sortby': sortBy,
        'reverse': reverse ? '1' : '0',
      },
    );
    return _unwrapMap(response);
  }

  // Local artist / album pages backed by indexed library.
  Future<Map<String, dynamic>> getArtistLocal(
    String artistHash, {
    int trackLimit = 15,
    int albumLimit = 7,
    bool allAlbums = true,
  }) async {
    final response = await _get(
      '/artist/$artistHash',
      query: {'limit': trackLimit, 'albumlimit': albumLimit, 'all': allAlbums},
    );
    return _unwrapMap(response);
  }

  Future<List<Map<String, dynamic>>> getArtistTracks(String artistHash) async {
    final response = await _get('/artist/$artistHash/tracks');
    return _unwrapListOfMap(response);
  }

  Future<Map<String, dynamic>> getAlbumLocal(
    String albumHash, {
    int limit = 150,
  }) async {
    final response = await _post(
      '/album',
      data: {'albumhash': albumHash, 'limit': limit},
    );
    return _unwrapMap(response);
  }

  // Downloads + import workflow
  Future<Map<String, dynamic>> createDownloadJob({
    String? sourceUrl,
    String source = 'spotify',
    String quality = 'high',
    String? codec,
    String? trackhash,
    String? title,
    String? artist,
    String? album,
    String itemType = 'track',
    String? targetPath,
    Map<String, dynamic>? payload,
  }) async {
    final response = await _post(
      '/api/downloads/jobs',
      data: {
        'source_url': sourceUrl,
        'source': source,
        'quality': quality,
        'codec': codec,
        'trackhash': trackhash,
        'title': title,
        'artist': artist,
        'album': album,
        'item_type': itemType,
        'target_path': targetPath,
        'payload': payload ?? <String, dynamic>{},
      }..removeWhere((key, value) => value == null),
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getDownloadQueue({int limit = 200}) async {
    final response = await _get(
      '/api/downloads/queue',
      query: {'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getDownloadJobs({int limit = 200}) async {
    final response = await _get('/api/downloads/jobs', query: {'limit': limit});
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getDownloadStatus({int limit = 500}) async {
    final response = await _get(
      '/api/downloads/status',
      query: {'limit': limit},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getDownloadHistory({
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _get(
      '/api/downloads/history',
      query: {'limit': limit, 'offset': offset},
    );
    return _unwrapMap(response);
  }

  Future<int> cancelDownloadJob(int jobId) async {
    final response = await _post('/api/downloads/jobs/$jobId/cancel');
    return response.statusCode ?? 0;
  }

  Future<int> retryDownloadJob(int jobId) async {
    final response = await _post('/api/downloads/jobs/$jobId/retry');
    return response.statusCode ?? 0;
  }

  Future<Map<String, dynamic>> getImportCandidates(String trackhash) async {
    final response = await _post(
      '/api/downloads/imports/candidates',
      data: {'trackhash': trackhash},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> confirmImport({
    required String trackhash,
    int? sourceUserid,
  }) async {
    final response = await _post(
      '/api/downloads/imports/confirm',
      data: {'trackhash': trackhash, 'source_userid': sourceUserid}
        ..removeWhere((key, value) => value == null),
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getTracksAvailability(
    List<String> trackhashes,
  ) async {
    final response = await _post(
      '/api/downloads/tracks/availability',
      data: {'trackhashes': trackhashes},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getStorageRoots() async {
    final response = await _get('/api/downloads/storage/roots');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> setStorageRoots(List<String> roots) async {
    final response = await _post(
      '/api/downloads/storage/roots',
      data: {'root_dirs': roots},
    );
    return _unwrapMap(response);
  }

  // Mobile offline sync metadata + analytics reconciliation
  Future<Map<String, dynamic>> registerMobileDevice({
    required String name,
    required String type,
    int? storageCapacity,
    int? availableStorage,
    Map<String, dynamic>? preferences,
    String? deviceId,
    String? fingerprint,
  }) async {
    final response = await _post(
      '/api/mobile-offline/devices/register',
      data: {
        'name': name,
        'type': type,
        'storage_capacity': storageCapacity,
        'available_storage': availableStorage,
        'preferences': preferences ?? <String, dynamic>{},
        'device_id': deviceId,
        'fingerprint': fingerprint,
      }..removeWhere((key, value) => value == null),
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getMobileDevices() async {
    final response = await _get('/api/mobile-offline/devices');
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getMobileOfflineLibrary(String deviceId) async {
    final response = await _get(
      '/api/mobile-offline/devices/$deviceId/offline-library',
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> addTracksToMobileOffline({
    required String deviceId,
    required List<Map<String, dynamic>> tracks,
    String? quality,
    String? collection,
  }) async {
    final response = await _post(
      '/api/mobile-offline/devices/$deviceId/add-tracks',
      data: {'tracks': tracks, 'quality': quality, 'collection': collection}
        ..removeWhere((key, value) => value == null),
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> removeTracksFromMobileOffline({
    required String deviceId,
    required List<String> trackhashes,
  }) async {
    final response = await _post(
      '/api/mobile-offline/devices/$deviceId/remove-tracks',
      data: {'trackhashes': trackhashes},
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> syncCollectionToMobileOffline({
    required String deviceId,
    required String collectionType,
    required String collectionId,
    String? quality,
  }) async {
    final response = await _post(
      '/api/mobile-offline/devices/$deviceId/sync-collection',
      data: {
        'collection_type': collectionType,
        'collection_id': collectionId,
        'quality': quality,
      }..removeWhere((key, value) => value == null),
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> getMobileSyncProgress(String deviceId) async {
    final response = await _get(
      '/api/mobile-offline/devices/$deviceId/sync-progress',
    );
    return _unwrapMap(response);
  }

  Future<Map<String, dynamic>> pushMobileEvents({
    required String deviceId,
    required List<Map<String, dynamic>> events,
    List<String>? markSynced,
  }) async {
    final response = await _post(
      '/api/mobile-offline/devices/$deviceId/events/batch',
      data: {'events': events, 'mark_synced': markSynced}
        ..removeWhere((key, value) => value == null),
    );
    return _unwrapMap(response);
  }

  String buildStreamUrl({
    required String trackhash,
    required String filepath,
    required String quality,
    String container = 'mp3',
  }) {
    final safePath = Uri.encodeQueryComponent(filepath);
    return '$_baseUrl/file/$trackhash/legacy?filepath=$safePath&container=$container&quality=$quality';
  }

  bool isSuccessStatus(int status) => status >= 200 && status < 300;

  Future<bool> checkHealth() async {
    final response = await _get('/healthz', withAuth: false);
    return response.statusCode == 200;
  }

  Future<Response<dynamic>> downloadFile(
    String url,
    String destinationPath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    final headers = await _authHeaders();
    return _dio.download(
      url,
      destinationPath,
      options: Options(headers: headers),
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<dynamic>> delete(String path, {Object? data}) {
    return _delete(path, data: data);
  }
}
