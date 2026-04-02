import 'package:flutter/foundation.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../data/models/artist_model.dart' as artist;
import '../../../data/models/album_model.dart';
import '../../../data/models/track_model.dart';

class ArtistInfoProvider extends ChangeNotifier {
  final EnhancedApiService _apiService;

  ArtistInfoProvider({required EnhancedApiService apiService})
      : _apiService = apiService;

  bool _isLoading = false;
  String? _errorMessage;
  artist.ArtistModel? _currentArtist;
  List<AlbumModel> _artistAlbums = [];
  List<TrackModel> _artistTracks = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  artist.ArtistModel? get currentArtist => _currentArtist;
  List<AlbumModel> get artistAlbums => _artistAlbums;
  List<TrackModel> get artistTracks => _artistTracks;
  bool get hasArtist => _currentArtist != null;

  Future<void> loadArtistInfo(String artistHash) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load artist info, albums, and tracks in parallel
      final results = await Future.wait([
        _apiService.getArtist(artistHash),
        _apiService.getArtistAlbums(artistHash),
        _apiService.getArtistTracks(artistHash),
      ]);

      _currentArtist = results[0] as artist.ArtistModel?;
      _artistAlbums = results[1] as List<AlbumModel>;
      _artistTracks = results[2] as List<TrackModel>;

      if (kDebugMode) {
        debugPrint('Loaded artist: ${_currentArtist?.name}');
        debugPrint(
            'Albums: ${_artistAlbums.length}, Tracks: ${_artistTracks.length}');
      }
    } catch (e) {
      _setError('Failed to load artist info: $e');
      _currentArtist = null;
      _artistAlbums = [];
      _artistTracks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteArtist() async {
    if (_currentArtist == null) return;

    try {
      await _apiService.toggleFavoriteArtist(_currentArtist!.artisthash);

      // Update the artist's favorite status
      _currentArtist = artist.ArtistModel(
        artisthash: _currentArtist!.artisthash,
        name: _currentArtist!.name,
        image: _currentArtist!.image,
        isFavorite: !_currentArtist!.isFavorite,
      );

      notifyListeners();

      if (kDebugMode) {
        debugPrint('Toggled favorite for artist: ${_currentArtist!.name}');
      }
    } catch (e) {
      _setError('Failed to toggle favorite artist: $e');
    }
  }

  Future<void> loadArtistAlbums(String artistHash) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _artistAlbums = await _apiService.getArtistAlbums(artistHash);

      if (kDebugMode) {
        debugPrint('Loaded ${_artistAlbums.length} albums for artist');
      }
    } catch (e) {
      _setError('Failed to load artist albums: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArtistTracks(String artistHash) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _artistTracks = await _apiService.getArtistTracks(artistHash);

      if (kDebugMode) {
        debugPrint('Loaded ${_artistTracks.length} tracks for artist');
      }
    } catch (e) {
      _setError('Failed to load artist tracks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearArtist() {
    _currentArtist = null;
    _artistAlbums = [];
    _artistTracks = [];
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    if (kDebugMode) {
      debugPrint('Artist Info Error: $error');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
