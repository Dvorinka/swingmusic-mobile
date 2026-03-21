import 'package:flutter/foundation.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../data/models/track_model.dart';

class FoldersProvider extends ChangeNotifier {
  final EnhancedApiService _apiService;
  
  FoldersProvider({required EnhancedApiService apiService}) 
      : _apiService = apiService;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _folders = [];
  List<TrackModel> _currentFolderTracks = [];
  String? _currentFolderHash;
  String? _currentFolderName;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get folders => _folders;
  List<TrackModel> get currentFolderTracks => _currentFolderTracks;
  String? get currentFolderHash => _currentFolderHash;
  String? get currentFolderName => _currentFolderName;
  bool get hasCurrentFolder => _currentFolderHash != null;
  
  Future<void> loadFolders() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _folders = await _apiService.getFolders();
      
      if (kDebugMode) {
        debugPrint('Loaded ${_folders.length} folders');
      }
    } catch (e) {
      _setError('Failed to load folders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadFolderTracks(String folderHash, String folderName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _currentFolderHash = folderHash;
      _currentFolderName = folderName;
      notifyListeners();
      
      _currentFolderTracks = await _apiService.getFolderTracks(folderHash);
      
      if (kDebugMode) {
        debugPrint('Loaded ${_currentFolderTracks.length} tracks from folder: $folderName');
      }
    } catch (e) {
      _setError('Failed to load folder tracks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearCurrentFolder() {
    _currentFolderHash = null;
    _currentFolderName = null;
    _currentFolderTracks = [];
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    if (kDebugMode) {
      debugPrint('Folders Error: $error');
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
