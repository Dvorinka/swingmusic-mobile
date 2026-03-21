import 'package:flutter/foundation.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/artist_model.dart' as artist;

/// Top search result model matching Android TopResult
class TopSearchResult {
  final dynamic item; // Can be TrackModel, AlbumModel, or ArtistModel
  final String type; // 'track', 'album', or 'artist'
  
  TopSearchResult({
    required this.item,
    required this.type,
  });
  
  String get title {
    if (item is TrackModel) return (item as TrackModel).title;
    if (item is AlbumModel) return (item as AlbumModel).title;
    if (item is artist.ArtistModel) return (item as artist.ArtistModel).name;
    return '';
  }
  
  String get subtitle {
    if (item is TrackModel) return (item as TrackModel).artistNames;
    if (item is AlbumModel) {
      final album = item as AlbumModel;
      return album.albumartists.isNotEmpty ? album.albumartists.map((a) => a.name).join(', ') : 'Unknown Artist';
    }
    if (item is artist.ArtistModel) return '${(item as artist.ArtistModel).trackcount} tracks';
    return '';
  }
  
  String get image {
    if (item is TrackModel) return (item as TrackModel).image;
    if (item is AlbumModel) return (item as AlbumModel).image;
    if (item is artist.ArtistModel) return (item as artist.ArtistModel).image;
    return '';
  }
}

class SearchProvider extends ChangeNotifier {
  final EnhancedApiService _apiService;
  
  SearchProvider({required EnhancedApiService apiService}) 
      : _apiService = apiService;
  
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  
  // Search results
  List<TrackModel> _trackResults = [];
  List<AlbumModel> _albumResults = [];
  List<artist.ArtistModel> _artistResults = [];
  
  // Top result (matching Android Search.kt)
  TopSearchResult? _topResult;
  
  // Search suggestions
  List<String> _suggestions = [];
  
  // Search type filter
  SearchType _searchType = SearchType.all;
  
  // Getters
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TrackModel> get trackResults => _trackResults;
  List<AlbumModel> get albumResults => _albumResults;
  List<artist.ArtistModel> get artistResults => _artistResults;
  TopSearchResult? get topResult => _topResult;
  List<String> get suggestions => _suggestions;
  SearchType get searchType => _searchType;
  
  bool get hasResults => _trackResults.isNotEmpty || _albumResults.isNotEmpty || _artistResults.isNotEmpty;
  bool get hasQuery => _searchQuery.isNotEmpty;
  bool get hasTopResult => _topResult != null;
  
  Future<void> search(String query, {SearchType? type}) async {
    if (query.trim().isEmpty) {
      _clearResults();
      return;
    }
    
    try {
      _isLoading = true;
      _errorMessage = null;
      _searchQuery = query;
      _searchType = type ?? SearchType.all;
      notifyListeners();
      
      // Perform search based on type
      switch (_searchType) {
        case SearchType.tracks:
          await _searchTracks(query);
          break;
        case SearchType.albums:
          await _searchAlbums(query);
          break;
        case SearchType.artists:
          await _searchArtists(query);
          break;
        case SearchType.all:
          await _searchAll(query);
          break;
      }
      
      if (kDebugMode) {
        debugPrint('Search results: ${_trackResults.length} tracks, ${_albumResults.length} albums, ${_artistResults.length} artists');
      }
    } catch (e) {
      _setError('Search failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _searchAll(String query) async {
    await Future.wait([
      _searchTracks(query),
      _searchAlbums(query),
      _searchArtists(query),
    ]);
    
    // Calculate top result after all searches complete
    _calculateTopResult(query);
  }
  
  /// Calculate top result based on relevance
  /// Matches Android: TopResultItem in Search.kt
  void _calculateTopResult(String query) {
    final queryLower = query.toLowerCase();
    
    // Priority: exact match > starts with > contains
    // Type priority: track > album > artist
    
    // Check tracks first
    for (final track in _trackResults) {
      if (track.title.toLowerCase() == queryLower) {
        _topResult = TopSearchResult(item: track, type: 'track');
        return;
      }
    }
    
    // Check albums
    for (final album in _albumResults) {
      if (album.title.toLowerCase() == queryLower) {
        _topResult = TopSearchResult(item: album, type: 'album');
        return;
      }
    }
    
    // Check artists
    for (final artistItem in _artistResults) {
      if (artistItem.name.toLowerCase() == queryLower) {
        _topResult = TopSearchResult(item: artistItem, type: 'artist');
        return;
      }
    }
    
    // No exact match, use first track if available
    if (_trackResults.isNotEmpty) {
      _topResult = TopSearchResult(item: _trackResults.first, type: 'track');
    } else if (_albumResults.isNotEmpty) {
      _topResult = TopSearchResult(item: _albumResults.first, type: 'album');
    } else if (_artistResults.isNotEmpty) {
      _topResult = TopSearchResult(item: _artistResults.first, type: 'artist');
    } else {
      _topResult = null;
    }
  }
  
  Future<void> _searchTracks(String query) async {
    try {
      _trackResults = await _apiService.getTracks(search: query);
    } catch (e) {
      _trackResults = [];
      if (kDebugMode) debugPrint('Track search error: $e');
    }
  }
  
  Future<void> _searchAlbums(String query) async {
    try {
      _albumResults = await _apiService.getAlbums(search: query);
    } catch (e) {
      _albumResults = [];
      if (kDebugMode) debugPrint('Album search error: $e');
    }
  }
  
  Future<void> _searchArtists(String query) async {
    try {
      _artistResults = await _apiService.getArtists(search: query);
    } catch (e) {
      _artistResults = [];
      if (kDebugMode) debugPrint('Artist search error: $e');
    }
  }
  
  Future<void> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }
    
    try {
      // Get real search suggestions from API
      final suggestionsData = await _apiService.getSearchSuggestions(query);
      _suggestions = suggestionsData.map((suggestion) => suggestion.text).toList();
      notifyListeners();
    } catch (e) {
      _suggestions = [];
      _setError('Failed to get suggestions: $e');
    }
  }
  
  void setSearchType(SearchType type) {
    _searchType = type;
    
    // Re-run search if we have a query
    if (_searchQuery.isNotEmpty) {
      search(_searchQuery, type: type);
    } else {
      notifyListeners();
    }
  }
  
  void clearSearch() {
    _clearResults();
  }
  
  void _clearResults() {
    _searchQuery = '';
    _trackResults = [];
    _albumResults = [];
    _artistResults = [];
    _topResult = null;
    _suggestions = [];
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    if (kDebugMode) {
      debugPrint('Search Error: $error');
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

enum SearchType {
  all,
  tracks,
  albums,
  artists,
}
