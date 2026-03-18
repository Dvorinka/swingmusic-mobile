import 'package:flutter/foundation.dart';
import '../../data/services/api_service.dart';
import '../../data/models/track_model.dart';
import '../../data/models/album_model.dart';
import '../../data/models/playlist_model.dart';

class LibraryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Library data
  List<TrackModel> _tracks = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<PlaylistModel> _playlists = [];
  List<TrackModel> _favoriteTracks = [];
  List<AlbumModel> _favoriteAlbums = [];
  List<ArtistModel> _favoriteArtists = [];

  // Loading states
  bool _isLoadingTracks = false;
  bool _isLoadingAlbums = false;
  bool _isLoadingArtists = false;
  bool _isLoadingPlaylists = false;
  bool _isLoadingFavorites = false;

  // Search state
  List<TrackModel> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // Getters
  List<TrackModel> get tracks => _tracks;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<PlaylistModel> get playlists => _playlists;
  List<TrackModel> get favoriteTracks => _favoriteTracks;
  List<AlbumModel> get favoriteAlbums => _favoriteAlbums;
  List<ArtistModel> get favoriteArtists => _favoriteArtists;

  bool get isLoadingTracks => _isLoadingTracks;
  bool get isLoadingAlbums => _isLoadingAlbums;
  bool get isLoadingArtists => _isLoadingArtists;
  bool get isLoadingPlaylists => _isLoadingPlaylists;
  bool get isLoadingFavorites => _isLoadingFavorites;

  List<TrackModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  // Tracks operations
  Future<void> loadTracks({int limit = 20, int offset = 0}) async {
    try {
      _isLoadingTracks = true;
      notifyListeners();

      final response = await _apiService.getTracks(limit: limit, offset: offset);
      _tracks = response.map((json) => TrackModel.fromJson(json)).toList();
      
      _isLoadingTracks = false;
      notifyListeners();
    } catch (e) {
      _isLoadingTracks = false;
      notifyListeners();
      throw Exception('Failed to load tracks: $e');
    }
  }

  Future<void> loadMoreTracks({int limit = 20}) async {
    try {
      final response = await _apiService.getTracks(limit: limit, offset: _tracks.length);
      final newTracks = response.map((json) => TrackModel.fromJson(json)).toList();
      _tracks.addAll(newTracks);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load more tracks: $e');
    }
  }

  // Albums operations
  Future<void> loadAlbums({int limit = 20, int offset = 0}) async {
    try {
      _isLoadingAlbums = true;
      notifyListeners();

      final response = await _apiService.getAlbums(limit: limit, offset: offset);
      _albums = response.map((json) => AlbumModel.fromJson(json)).toList();
      
      _isLoadingAlbums = false;
      notifyListeners();
    } catch (e) {
      _isLoadingAlbums = false;
      notifyListeners();
      throw Exception('Failed to load albums: $e');
    }
  }

  Future<void> loadMoreAlbums({int limit = 20}) async {
    try {
      final response = await _apiService.getAlbums(limit: limit, offset: _albums.length);
      final newAlbums = response.map((json) => AlbumModel.fromJson(json)).toList();
      _albums.addAll(newAlbums);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load more albums: $e');
    }
  }

  // Artists operations
  Future<void> loadArtists({int limit = 20, int offset = 0}) async {
    try {
      _isLoadingArtists = true;
      notifyListeners();

      final response = await _apiService.getArtists(limit: limit, offset: offset);
      _artists = response.map((json) => ArtistModel.fromJson(json)).toList();
      
      _isLoadingArtists = false;
      notifyListeners();
    } catch (e) {
      _isLoadingArtists = false;
      notifyListeners();
      throw Exception('Failed to load artists: $e');
    }
  }

  Future<void> loadMoreArtists({int limit = 20}) async {
    try {
      final response = await _apiService.getArtists(limit: limit, offset: _artists.length);
      final newArtists = response.map((json) => ArtistModel.fromJson(json)).toList();
      _artists.addAll(newArtists);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load more artists: $e');
    }
  }

  // Playlists operations
  Future<void> loadPlaylists() async {
    try {
      _isLoadingPlaylists = true;
      notifyListeners();

      final response = await _apiService.getPlaylists();
      _playlists = response.map((json) => PlaylistModel.fromJson(json)).toList();
      
      _isLoadingPlaylists = false;
      notifyListeners();
    } catch (e) {
      _isLoadingPlaylists = false;
      notifyListeners();
      throw Exception('Failed to load playlists: $e');
    }
  }

  Future<PlaylistModel> createPlaylist(String name, {String description = ''}) async {
    try {
      final response = await _apiService.createPlaylist(name, description: description);
      final newPlaylist = PlaylistModel.fromJson(response);
      _playlists.add(newPlaylist);
      notifyListeners();
      return newPlaylist;
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
    }
  }

  // Favorites operations
  Future<void> loadFavorites() async {
    try {
      _isLoadingFavorites = true;
      notifyListeners();

      final tracksResponse = await _apiService.getFavoriteTracks();
      final albumsResponse = await _apiService.getFavoriteAlbums();
      final artistsResponse = await _apiService.getFavoriteArtists();

      _favoriteTracks = tracksResponse.map((json) => TrackModel.fromJson(json)).toList();
      _favoriteAlbums = albumsResponse.map((json) => AlbumModel.fromJson(json)).toList();
      _favoriteArtists = artistsResponse.map((json) => ArtistModel.fromJson(json)).toList();
      
      _isLoadingFavorites = false;
      notifyListeners();
    } catch (e) {
      _isLoadingFavorites = false;
      notifyListeners();
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<void> toggleFavoriteTrack(String trackhash) async {
    try {
      await _apiService.toggleFavoriteTrack(trackhash);
      
      // Update local state
      final trackIndex = _favoriteTracks.indexWhere((track) => track.trackhash == trackhash);
      if (trackIndex != -1) {
        _favoriteTracks.removeAt(trackIndex);
      } else {
        final track = _tracks.firstWhere((t) => t.trackhash == trackhash);
        _favoriteTracks.add(track);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to toggle favorite track: $e');
    }
  }

  Future<void> toggleFavoriteAlbum(String albumhash) async {
    try {
      await _apiService.toggleFavoriteAlbum(albumhash);
      
      // Update local state
      final albumIndex = _favoriteAlbums.indexWhere((album) => album.albumhash == albumhash);
      if (albumIndex != -1) {
        _favoriteAlbums.removeAt(albumIndex);
      } else {
        final album = _albums.firstWhere((a) => a.albumhash == albumhash);
        _favoriteAlbums.add(album);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to toggle favorite album: $e');
    }
  }

  Future<void> toggleFavoriteArtist(String artisthash) async {
    try {
      await _apiService.toggleFavoriteArtist(artisthash);
      
      // Update local state
      final artistIndex = _favoriteArtists.indexWhere((artist) => artist.artisthash == artisthash);
      if (artistIndex != -1) {
        _favoriteArtists.removeAt(artistIndex);
      } else {
        final artist = _artists.firstWhere((a) => a.artisthash == artisthash);
        _favoriteArtists.add(artist);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to toggle favorite artist: $e');
    }
  }

  // Search operations
  Future<void> searchTracks(String query, {int limit = 15}) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _searchQuery = '';
      notifyListeners();
      return;
    }

    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      final response = await _apiService.searchTracks(query, limit: limit);
      _searchResults = response.map((json) => TrackModel.fromJson(json)).toList();
      
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      throw Exception('Failed to search tracks: $e');
    }
  }

  void clearSearch() {
    _searchResults.clear();
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  // Utility methods
  void refresh() {
    loadTracks();
    loadAlbums();
    loadArtists();
    loadPlaylists();
    loadFavorites();
  }

  bool isTrackFavorite(String trackhash) {
    return _favoriteTracks.any((track) => track.trackhash == trackhash);
  }

  bool isAlbumFavorite(String albumhash) {
    return _favoriteAlbums.any((album) => album.albumhash == albumhash);
  }

  bool isArtistFavorite(String artisthash) {
    return _favoriteArtists.any((artist) => artist.artisthash == artisthash);
  }
}
